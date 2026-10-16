// 8N1 UART receiver; rx must already be synchronous to clk (2-FF synchroniser inside).
module uart_rx #(
    parameter integer CLK_HZ = 27_000_000,
    parameter integer BAUD   = 115_200
) (
    input  wire       clk,
    input  wire       rx,
    output reg  [7:0] data = 8'd0,
    output reg        valid = 1'b0
);
    localparam integer DIV = CLK_HZ / BAUD;
    reg [1:0] sync = 2'b11;
    reg [15:0] cnt = 16'd0;
    reg [3:0]  bitn = 4'd0;
    reg        busy = 1'b0;
    reg [7:0]  sh = 8'd0;

    always @(posedge clk) begin
        sync  <= {sync[0], rx};
        valid <= 1'b0;
        if (!busy) begin
            if (!sync[1]) begin busy <= 1'b1; cnt <= DIV / 2; bitn <= 4'd0; end
        end else if (cnt != 0) begin
            cnt <= cnt - 16'd1;
        end else begin
            cnt <= DIV - 1;
            if (bitn == 4'd0) begin
                if (sync[1]) busy <= 1'b0;                 // false start bit
                bitn <= 4'd1;
            end else if (bitn <= 4'd8) begin
                sh <= {sync[1], sh[7:1]};
                bitn <= bitn + 4'd1;
            end else begin
                busy  <= 1'b0;                              // stop bit
                data  <= sh;
                valid <= 1'b1;
            end
        end
    end
endmodule
