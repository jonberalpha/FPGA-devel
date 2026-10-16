// 8N1 UART transmitter.
module uart_tx #(
    parameter integer CLK_HZ = 27_000_000,
    parameter integer BAUD   = 115_200
) (
    input  wire       clk,
    input  wire [7:0] data,
    input  wire       start,   // pulse, ignored while busy
    output wire       busy,
    output wire       tx
);
    localparam integer DIV = (CLK_HZ + BAUD / 2) / BAUD;

    reg [15:0] bd   = 16'd0;
    reg [3:0]  nbit = 4'd0;
    reg [9:0]  sh   = 10'h3ff;
    reg        run  = 1'b0;

    assign busy = run;
    assign tx   = sh[0];

    always @(posedge clk) begin
        if (!run) begin
            if (start) begin
                sh   <= {1'b1, data, 1'b0}; // stop, data (LSB first), start
                nbit <= 4'd0;
                bd   <= 16'd0;
                run  <= 1'b1;
            end
        end else if (bd == DIV - 1) begin
            bd <= 16'd0;
            if (nbit == 4'd9) begin
                run <= 1'b0;
                sh  <= 10'h3ff;
            end else begin
                sh   <= {1'b1, sh[9:1]};
                nbit <= nbit + 4'd1;
            end
        end else begin
            bd <= bd + 16'd1;
        end
    end
endmodule
