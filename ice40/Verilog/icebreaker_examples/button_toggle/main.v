// Cause yosys to throw an error when we implicitly declare nets
`default_nettype none

module top (
    input CLK,           // system clock
    input BTN_N,
    output LEDR_N
);
    reg debounce_0 = 1'b0;
    reg debounce_1 = 1'b0;
    reg debounce_2 = 1'b0;

    reg btn_state = 1'b0;
    reg led_state = 1'b0;

    assign LEDR_N = led_state;

    always @(posedge CLK) begin
        debounce_2 <= debounce_1;
        debounce_1 <= debounce_0;
        debounce_0 <= BTN_N;

        if (btn_state) begin
            if (!debounce_0 && !debounce_1 && !debounce_2) begin
                btn_state <= 1'b0;
            end
        end else begin
            if (debounce_0 && debounce_1 && debounce_2) begin
                btn_state <= 1'b1;
                led_state = !led_state;
            end
        end
    end
endmodule
