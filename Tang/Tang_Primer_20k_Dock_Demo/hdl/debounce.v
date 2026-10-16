// Synchronizer + debouncer. Output follows the input once it has been stable for CYC clocks.
module debounce #(
    parameter integer CYC = 270_000 // 10 ms @ 27 MHz
) (
    input  wire clk,
    input  wire in,
    output reg  out = 1'b0
);
    reg [1:0]  sync = 2'b00;
    reg [19:0] cnt  = 20'd0;

    always @(posedge clk) begin
        sync <= {sync[0], in};
        if (sync[1] == out) begin
            cnt <= 20'd0;
        end else if (cnt == CYC - 1) begin
            cnt <= 20'd0;
            out <= sync[1];
        end else begin
            cnt <= cnt + 20'd1;
        end
    end
endmodule
