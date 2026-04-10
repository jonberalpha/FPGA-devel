module top(
    input  CLK,         // 12 MHz clock
    output LED1,
    output LED2,
    output LED3,
    output LED4,
    output LED5,
    output LEDR_N,
    output LEDG_N,
    output LED_RED_N
);

    // Slow counter (~500 ms step)
    reg [21:0] slow_cnt = 0;
    always @(posedge CLK)
        slow_cnt <= slow_cnt + 1;

    // ROM address counter
    reg [9:0] rom_addr = 0;
    always @(posedge CLK)
        if (slow_cnt == 0)
            rom_addr <= rom_addr + 1;

    wire [7:0] rom_data;

    // Instantiate ROM
    BROM rom_inst (
        .clk_i(CLK),
        .data_o(rom_data),
        .addr_i(rom_addr),
        .ce_i(1'b1)
    );

    // RAM address counters
    reg [12:0] ram_addr_w = 0;
    reg [12:0] ram_addr_r = 0;
    wire [7:0] ram_data;

    // Instantiate RAM
    BRAM ram_inst (
        .clk_i(CLK),
        .data_i(rom_data),     // copy ROM → RAM
        .data_o(ram_data),
        .addr_r_i(ram_addr_r),
        .addr_w_i(ram_addr_w),
        .we_i(slow_cnt == 0),  // write once per ~500 ms
        .re_i(1'b1)
    );

    // Advance RAM addresses together with ROM
    always @(posedge CLK) begin
        if (slow_cnt == 0) begin
            ram_addr_w <= ram_addr_w + 1;
            ram_addr_r <= ram_addr_r + 1;
        end
    end

    // Show RAM output (not ROM) on LEDs
    assign LED1      = ram_data[0];
    assign LED2      = ram_data[1];
    assign LED3      = ram_data[2];
    assign LED4      = ram_data[3];
    assign LED5      = ram_data[4];
    assign LEDR_N    = ram_data[5];
    assign LEDG_N    = ram_data[6];
    assign LED_RED_N = ram_data[7];

endmodule
