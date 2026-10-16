// LED blink with button on/off toggle (Verilog).
// btn_rst  : reset (first button) - re-enables blinking
// btn_user : function button - toggles whether led[0] blinks
// Remaining LEDs stay off. Onboard LEDs are active low.

module led_toggle #(
    parameter integer CLK_HZ          = 27_000_000,
    parameter integer BLINK_HZ        = 2,        // LED toggles at this rate
    parameter integer DEBOUNCE_CYCLES = 540_000,  // 20 ms @ 27 MHz
    parameter         BTN_ACTIVE_LOW  = 1'b1,
    parameter integer NUM_LEDS        = 4
) (
    input  wire                clk,
    input  wire                btn_rst,
    input  wire                btn_user,
    output wire [NUM_LEDS-1:0] led
);

    localparam integer BLINK_HALF = CLK_HZ / (2 * BLINK_HZ);

    // --- reset button: synchronize ----------------------------------------
    reg [1:0] rst_sync = 2'b00;
    always @(posedge clk) rst_sync <= {rst_sync[0], btn_rst};
    wire rst = BTN_ACTIVE_LOW ? ~rst_sync[1] : rst_sync[1];

    // --- function button: synchronize, debounce, rising-edge detect -------
    reg [1:0]  sync = 2'b00;
    reg        btn_stable = 1'b0;
    reg        btn_prev = 1'b0;
    reg [31:0] deb_cnt = 32'd0;
    wire       btn_pressed = BTN_ACTIVE_LOW ? ~sync[1] : sync[1];

    always @(posedge clk) begin
        sync <= {sync[0], btn_user};
        if (btn_pressed == btn_stable) begin
            deb_cnt <= 32'd0;
        end else if (deb_cnt == DEBOUNCE_CYCLES - 1) begin
            deb_cnt    <= 32'd0;
            btn_stable <= btn_pressed;
        end else begin
            deb_cnt <= deb_cnt + 32'd1;
        end
        btn_prev <= btn_stable;
    end

    wire press_event = btn_stable & ~btn_prev;

    // --- enable toggle -----------------------------------------------------
    reg enabled = 1'b1;
    always @(posedge clk)
        if (rst)             enabled <= 1'b1;
        else if (press_event) enabled <= ~enabled;

    // --- blink -------------------------------------------------------------
    reg [31:0] blink_cnt = 32'd0;
    reg        blink = 1'b0;
    always @(posedge clk) begin
        if (rst) begin
            blink_cnt <= 32'd0;
            blink     <= 1'b0;
        end else if (blink_cnt == BLINK_HALF - 1) begin
            blink_cnt <= 32'd0;
            blink     <= ~blink;
        end else begin
            blink_cnt <= blink_cnt + 32'd1;
        end
    end

    wire led0_on = enabled & blink;

    // active low: '0' lights the LED
    assign led = {{(NUM_LEDS-1){1'b1}}, ~led0_on};

endmodule
