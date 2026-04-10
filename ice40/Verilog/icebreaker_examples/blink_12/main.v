// Cause yosys to throw an error when we implicitly declare nets
`default_nettype none

module top (
    input CLK,           // system clock
    output LEDG_N,
    output P1A1
);
    // We will blink the LED at 1Hz.
    reg led_reg = 1'b0;
    assign LEDG_N = led_reg;
    // With 23 bits we can count up to 8,388,605.
    reg[22:0] led_counter = 23'd0;
    localparam led_counter_max = 23'd5999999;

    // We will oscillate P1A1 at 1MHz.
    reg p1a1_reg = 1'b0;
    assign P1A1 = p1a1_reg;
    reg[2:0] p1a1_counter = 3'd0;
    localparam p1a1_counter_max = 3'd5;

    always @(posedge CLK) begin
        led_counter <= led_counter + 1;
        if (led_counter == led_counter_max) begin
            led_counter <= 23'd0;
            led_reg <= !led_reg;
        end

        p1a1_counter <= p1a1_counter + 1;
        if (p1a1_counter == p1a1_counter_max) begin
            p1a1_counter <= 3'd0;
            p1a1_reg <= !p1a1_reg;
        end
    end

endmodule
