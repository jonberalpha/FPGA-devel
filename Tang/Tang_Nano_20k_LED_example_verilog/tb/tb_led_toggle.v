`timescale 1ns / 1ps

module tb_led_toggle;
    reg clk = 1'b0;
    reg btn = 1'b0;
    wire [5:0] led;

    // fast parameters for simulation: 1 kHz clock-equivalent
    led_toggle #(
        .CLK_HZ(1000), .BLINK_HZ(10), .DEBOUNCE_CYCLES(3)
    ) dut (.clk(clk), .btn_rst(1'b0), .btn_user(btn), .led(led));

    always #500 clk = ~clk; // 1 kHz

    integer toggles_before, toggles_after, errors = 0;
    reg prev;
    integer cnt;

    task press; begin
        btn = 1'b1; #20000; btn = 1'b0; #20000;
    end endtask

    task count_toggles(input integer cycles, output integer n); integer i; begin
        n = 0; prev = led[0];
        for (i = 0; i < cycles; i = i + 1) begin
            @(posedge clk);
            if (led[0] !== prev) n = n + 1;
            prev = led[0];
        end
    end endtask

    initial begin
        $dumpfile("build/tb_led_toggle.vcd");
        $dumpvars(0, tb_led_toggle);
        #10000;
        count_toggles(200, toggles_before);
        press;                       // disable blinking
        count_toggles(200, toggles_after);
        $display("blinking: %0d toggles, after press: %0d toggles", toggles_before, toggles_after);
        if (toggles_before < 3 || toggles_after != 0) errors = errors + 1;
        press;                       // re-enable
        count_toggles(200, toggles_after);
        if (toggles_after < 3) errors = errors + 1;
        if (errors == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
