// LED state register: a button press toggles, an external request (e.g. HTTP) sets/clears.
module led_ctrl #(
    parameter integer N = 3
) (
    input  wire         clk,
    input  wire         rst,
    input  wire [N-1:0] btn,       // debounced, active high
    input  wire [N-1:0] set_en,    // external write strobe
    input  wire [N-1:0] set_val,
    output reg  [N-1:0] state = {N{1'b0}}
);
    reg [N-1:0] prev = {N{1'b0}};
    wire [N-1:0] press = btn & ~prev;
    integer i;

    always @(posedge clk) begin
        prev <= btn;
        if (rst) begin
            state <= {N{1'b0}};
        end else begin
            for (i = 0; i < N; i = i + 1) begin
                if (set_en[i])      state[i] <= set_val[i];
                else if (press[i])  state[i] <= ~state[i];
            end
        end
    end
endmodule
