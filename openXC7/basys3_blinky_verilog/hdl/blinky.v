`default_nettype none

module blinky (
    input  wire clk,
    output wire led,
    output wire [3:0] an,
    output wire [6:0] seg,
    output wire dp
);

    reg [24:0] r_count = 0;

    always @(posedge clk) r_count <= r_count + 1;

    assign led = r_count[24];

    // Basys3's 7-segment display glows faintly if its pins are left
    // undriven; hold every digit and segment disabled (active-low).
    assign an  = 4'b1111;
    assign seg = 7'b1111111;
    assign dp  = 1'b1;

endmodule
