// Cause yosys to throw an error when we implicitly declare nets
`default_nettype none

module top (
    input CLK,           // system clock
    output LEDG_N,
    output P1A1
);
    wire clk_24mhz;
    wire clk_24mhz_lock;
    SB_PLL40_PAD #(
        .FEEDBACK_PATH("SIMPLE"),
        .PLLOUT_SELECT("GENCLK"),
        .DIVR(4'b0000),
        .DIVF(7'b0111111),
        .DIVQ(3'b101),
        .FILTER_RANGE(3'b001)
    ) pll_24mhz (
        .PACKAGEPIN(CLK),
        .PLLOUTGLOBAL(clk_24mhz),
        .LOCK(clk_24mhz_lock),
        .RESETB(1'b1),
        .BYPASS(1'b0)
    );

    // We will blink the LED at 1Hz.
    // With 24 bits we can count up to 16,777,215.
    localparam led_counter_min = 24'd0;
    localparam led_counter_max = 24'd11999999;
    reg[23:0] led_counter = led_counter_min;
    reg led_reg = 1'b0;
    assign LEDG_N = led_reg;

    // We will oscillate P1A1 at 1MHz.
    localparam p1a1_counter_min = 4'd0;
    localparam p1a1_counter_max = 4'd11;
    reg[3:0] p1a1_counter = p1a1_counter_min;
    reg p1a1_reg = 1'b0;
    assign P1A1 = p1a1_reg;

    always @(posedge clk_24mhz or negedge clk_24mhz_lock) begin
        if (!clk_24mhz_lock) begin
            led_counter <= led_counter_min;
            led_reg <= 1'b0;
            p1a1_counter <= p1a1_counter_min;
            p1a1_reg <= 1'b0;
        end else begin
            led_counter <= led_counter + 1;
            if (led_counter == led_counter_max) begin
                led_counter <= led_counter_min;
                led_reg <= !led_reg;
            end

            p1a1_counter <= p1a1_counter + 1;
            if (p1a1_counter == p1a1_counter_max) begin
                p1a1_counter <= p1a1_counter_min;
                p1a1_reg <= !p1a1_reg;
            end
        end
    end

endmodule
