// Cause yosys to throw an error when we implicitly declare nets
`default_nettype none

module top (
    input CLK,           // system clock
    input BTN_N,
    output LEDR_N
);
    assign LEDR_N = BTN_N;
endmodule
