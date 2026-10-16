// Testbench for mdio_master with a tiny behavioural PHY: prints every decoded MDIO frame.
`timescale 1ns / 1ps
module tb_mdio;
    reg clk = 1'b0;
    reg rst = 1'b1;
    wire mdc, mdio, link_up, cfg_done;
    wire [63:0] regs;
    pullup (mdio);
    always #18.5 clk = ~clk;

    mdio_master #(.WAIT_CLKS(2000)) dut (.clk(clk), .rst(rst), .mdc(mdc), .mdio(mdio),
                                         .link_up(link_up), .cfg_done(cfg_done), .regs(regs));

    // PHY model
    reg [15:0] mem [0:31];
    reg [15:0] sh;
    integer bitn, got_pre;
    reg phy_drv = 1'b0, phy_o = 1'b1;
    reg [1:0] st_op;
    reg [4:0] pa, ra;
    reg [15:0] rdv;
    assign mdio = phy_drv ? phy_o : 1'bz;
    integer k;
    initial begin
        for (k = 0; k < 32; k = k + 1) mem[k] = 16'h0;
        mem[0] = 16'h2100; mem[1] = 16'h7849; mem[2] = 16'h001c; mem[3] = 16'hc816;
        bitn = 0; got_pre = 0;
    end

    reg [1:0] state = 0; // 0 preamble, 1 header (14 bits), 2 data
    reg [31:0] hdr;
    integer cnt = 0;
    always @(posedge mdc) begin
        case (state)
            0: begin
                if (mdio === 1'b1) cnt <= cnt + 1; else if (cnt >= 32 && mdio === 1'b0) begin state <= 1; hdr <= 32'd0; cnt <= 1; end else cnt <= 0;
            end
            1: begin
                hdr <= {hdr[30:0], mdio};
                cnt <= cnt + 1;
                if (cnt == 13) begin state <= 2; cnt <= 0; end
            end
            2: begin
                // TA (2 bits) + 16 data bits
                cnt <= cnt + 1;
                if (cnt >= 2) sh <= {sh[14:0], mdio};
                if (cnt == 17) begin
                    // hdr = {ST(2), OP(2), PHY(5), REG(5)} as first 14 bits (hdr[13:0] after shifting) with leading 0 start bit
                    ra = hdr[4:0]; pa = hdr[9:5];
                    if (hdr[11:10] == 2'b01) begin
                        mem[ra] <= {sh[14:0], mdio};
                        $display("%t WRITE phy=%0d reg=%0d data=%04x", $time, pa, ra, {sh[14:0], mdio});
                    end
                    state <= 0; cnt <= 0;
                end
            end
        endcase
    end

    initial begin
        #1000 rst = 1'b0;
        #40_000_000;
        $display("regs = %04x %04x %04x %04x  link=%b cfg=%b", regs[63:48], regs[47:32], regs[31:16], regs[15:0], link_up, cfg_done);
        $finish;
    end
endmodule
