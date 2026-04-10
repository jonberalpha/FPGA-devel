`ifndef _dice_bram_v_
`define _dice_bram_v_

// This should synthesize to use an SB_RAM40_4K primitive.
module bram #(
    n_bytes = 256,
    localparam log_n_bytes = $clog2(n_bytes)
)(
    input clk,                      // clock
    input[log_n_bytes - 1:0] waddr, // write address
    input[7:0] wdata,               // data to write
    input wen,                      // write enable (active high)
    input[log_n_bytes - 1:0] raddr, // read address
    output reg[7:0] rdata,          // read data
    input ren                       // read enable (active high)
);
    reg[7:0] mem[n_bytes - 1:0];

    always @(posedge clk) begin
        if (wen) begin
            mem[waddr] <= wdata;
        end

        if (ren) begin
            rdata <= mem[raddr];
        end
    end
endmodule

`endif
