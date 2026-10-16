// Board top level: wires the 27 MHz clock, reset button, function button and LEDs.

module led_top (
    input  wire clk_27mhz,
    input  wire btn_rst,   // S0: reset
    input  wire btn_user,  // S1: blink on/off
    output wire [4-1:0] led
);
    led_toggle #(.NUM_LEDS(4)) u_led_toggle (
        .clk(clk_27mhz), .btn_rst(btn_rst), .btn_user(btn_user), .led(led)
    );
endmodule
