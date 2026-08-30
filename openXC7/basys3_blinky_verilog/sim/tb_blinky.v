`timescale 1ns/1ps

module tb_blinky;

    reg  clk = 0;
    wire led;

    blinky dut (
        .clk (clk),
        .led (led)
    );

    always #5 clk = ~clk; // 100 MHz

    initial begin
        $dumpfile("build/tb_blinky.vcd");
        $dumpvars(0, tb_blinky);

        repeat (200) @(posedge clk);
        $display("r_count = %0d after 200 clock cycles", dut.r_count);
        $finish;
    end

endmodule
