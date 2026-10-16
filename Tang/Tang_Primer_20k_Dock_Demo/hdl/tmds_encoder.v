// DVI/HDMI TMDS 8b/10b encoder (one colour channel).
module tmds_encoder (
    input  wire       clk,
    input  wire [7:0] d,
    input  wire [1:0] c,     // control bits (hsync/vsync on channel 0)
    input  wire       de,
    output reg  [9:0] q = 10'b1101010100
);
    wire [3:0] n1d = d[0] + d[1] + d[2] + d[3] + d[4] + d[5] + d[6] + d[7];
    wire use_xnor  = (n1d > 4'd4) || (n1d == 4'd4 && !d[0]);

    wire [8:0] qm;
    assign qm[0] = d[0];
    assign qm[1] = use_xnor ? ~(qm[0] ^ d[1]) : (qm[0] ^ d[1]);
    assign qm[2] = use_xnor ? ~(qm[1] ^ d[2]) : (qm[1] ^ d[2]);
    assign qm[3] = use_xnor ? ~(qm[2] ^ d[3]) : (qm[2] ^ d[3]);
    assign qm[4] = use_xnor ? ~(qm[3] ^ d[4]) : (qm[3] ^ d[4]);
    assign qm[5] = use_xnor ? ~(qm[4] ^ d[5]) : (qm[4] ^ d[5]);
    assign qm[6] = use_xnor ? ~(qm[5] ^ d[6]) : (qm[5] ^ d[6]);
    assign qm[7] = use_xnor ? ~(qm[6] ^ d[7]) : (qm[6] ^ d[7]);
    assign qm[8] = ~use_xnor;

    wire [3:0] n1q = qm[0] + qm[1] + qm[2] + qm[3] + qm[4] + qm[5] + qm[6] + qm[7];
    wire [3:0] n0q = 4'd8 - n1q;

    reg signed [5:0] cnt = 6'sd0;                  // running disparity
    wire signed [5:0] diff = $signed({2'b0, n1q}) - $signed({2'b0, n0q});

    always @(posedge clk) begin
        if (de) begin
            if (cnt == 0 || n1q == n0q) begin
                q[9]   <= ~qm[8];
                q[8]   <= qm[8];
                q[7:0] <= qm[8] ? qm[7:0] : ~qm[7:0];
                cnt    <= qm[8] ? cnt + diff : cnt - diff;
            end else if ((cnt > 0 && n1q > n0q) || (cnt < 0 && n0q > n1q)) begin
                q[9]   <= 1'b1;
                q[8]   <= qm[8];
                q[7:0] <= ~qm[7:0];
                cnt    <= cnt + (qm[8] ? 6'sd2 : 6'sd0) - diff;
            end else begin
                q[9]   <= 1'b0;
                q[8]   <= qm[8];
                q[7:0] <= qm[7:0];
                cnt    <= cnt - (qm[8] ? 6'sd0 : 6'sd2) + diff;
            end
        end else begin
            cnt <= 6'sd0;
            case (c)
                2'b00: q <= 10'b1101010100;
                2'b01: q <= 10'b0010101011;
                2'b10: q <= 10'b0101010100;
                2'b11: q <= 10'b1010101011;
            endcase
        end
    end
endmodule
