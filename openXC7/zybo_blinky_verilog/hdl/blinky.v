`default_nettype none

module blinky (
    input  wire clk,
    output wire led
);

    reg [24:0] r_count = 0;

    always @(posedge clk) r_count <= r_count + 1;

    assign led = r_count[24];

endmodule
