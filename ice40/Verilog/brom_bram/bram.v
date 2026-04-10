module BRAM (
    input        clk_i,          // Read/Write clock
    input  [7:0] data_i,         // Data input (write)
    output reg [7:0] data_o,     // Data output (read)
    input [12:0] addr_r_i,       // Read address (13 bits -> 8192 bytes)
    input [12:0] addr_w_i,       // Write address
    input        we_i,           // Write enable
    input        re_i            // Read enable
);

    parameter bram_size = 8192;
    reg [7:0] mem [0:bram_size-1];

    integer i;
    initial begin
        for (i = 0; i < bram_size; i = i + 1)
            mem[i] = 8'd0;
    end

    always @(posedge clk_i) begin
        if (re_i)
            data_o <= mem[addr_r_i];
        if (we_i)
            mem[addr_w_i] <= data_i;
    end

endmodule
