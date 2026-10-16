// Minimal MDIO (SMI) master for the RTL8201F PHY:
//  1. waits for the PHY after reset,
//  2. writes page 7 / register 16 = 0x0FFE so that CRS_DV acts as RX_DV (as in the Sipeed UDP example),
//  3. returns to page 0, sets the advertised abilities (ANAR) and restarts auto-negotiation, then polls the basic status register (bit 2 = link up).
module mdio_master #(
    parameter [4:0]  PHY_ADDR = 5'd1,
    parameter integer WAIT_CLKS = 3_000_000,  // ~110 ms @ 27 MHz after reset release
    parameter [4:0]  REG_BASE = 5'd0,         // first of the four PHY registers that are polled
    parameter [15:0] BMCR = 16'h1200          // basic control: AN enable + restart (0x2100 = forced 100 Mbit full duplex)
) (
    input  wire clk,          // 27 MHz
    input  wire rst,          // hold in reset while the PHY is in reset
    output reg  mdc = 1'b0,   // 27 MHz / 32
    inout  wire mdio,
    output reg  link_up = 1'b0,
    output reg  cfg_done = 1'b0,
    output reg  [63:0] regs = 64'd0,  // PHY registers {r0, r1, r2, r3}
    input  wire        wr_req,        // pulse: write wr_data to register wr_reg (live debug access)
    input  wire [4:0]  wr_reg,
    input  wire [15:0] wr_data
);
    reg        pend = 1'b0;
    reg [4:0]  pend_reg = 5'd0;
    reg [15:0] pend_data = 16'd0;

    reg        mdio_o = 1'b1, mdio_oe = 1'b0;
    assign mdio = mdio_oe ? mdio_o : 1'bz;   // push-pull while the master drives, released for the PHY's answer

    reg [3:0]  div = 4'd0;
    reg [6:0]  n = 7'd0;
    reg [63:0] frame = 64'd0;
    reg        is_read = 1'b0;
    reg [15:0] rdata = 16'd0;
    reg [2:0]  step = 3'd0;
    reg [31:0] wait_cnt = 32'd0;
    reg [31:0] lim = WAIT_CLKS;
    reg        busy = 1'b0;
    reg [1:0]  rd_idx = 2'd0;
    reg [1:0]  cur_idx = 2'd0;

    task start(input rd, input [4:0] r, input [15:0] d);
        begin
            frame   <= {32'hFFFF_FFFF, 2'b01, rd ? 2'b10 : 2'b01, PHY_ADDR, r, rd ? 2'b11 : 2'b10, rd ? 16'hFFFF : d};
            is_read <= rd;
            n       <= 7'd0;
            busy    <= 1'b1;
        end
    endtask

    always @(posedge clk) begin
        if (wr_req) begin pend <= 1'b1; pend_reg <= wr_reg; pend_data <= wr_data; end
        if (rst) begin
            mdc <= 1'b0; div <= 4'd0; busy <= 1'b0; step <= 3'd0; wait_cnt <= 32'd0; lim <= WAIT_CLKS;
            mdio_oe <= 1'b0; mdio_o <= 1'b1; cfg_done <= 1'b0; link_up <= 1'b0; rd_idx <= 2'd0;
        end else if (!busy) begin
            mdc <= 1'b0; mdio_oe <= 1'b0;
            if (wait_cnt < lim) wait_cnt <= wait_cnt + 32'd1;
            else begin
                wait_cnt <= 32'd0;
                lim      <= 32'd270_000;   // 10 ms between transactions
                if (pend && step >= 3'd5) begin
                    start(1'b0, pend_reg, pend_data); pend <= 1'b0;
                end else
                case (step)
                    3'd0: begin start(1'b0, 5'd31, 16'h0007); step <= 3'd1; end
                    3'd1: begin start(1'b0, 5'd16, 16'h0FFE); step <= 3'd2; end
                    3'd2: begin start(1'b0, 5'd31, 16'h0000); step <= 3'd3; end
                    3'd3: begin start(1'b0, 5'd4,  16'h01E1); step <= 3'd4; end   // advertise 10/100 half/full (the reset value is unusable)
                    3'd4: begin start(1'b0, 5'd0,  BMCR); step <= 3'd5; end   // enable + restart auto-negotiation
                    default: begin start(1'b1, REG_BASE + {3'b000, rd_idx}, 16'h0000); cur_idx <= rd_idx; rd_idx <= rd_idx + 2'd1; step <= 3'd5; cfg_done <= 1'b1; end
                endcase
            end
        end else begin
            div <= div + 4'd1;
            if (div == 4'd15) begin
                mdc <= ~mdc;
                if (!mdc) begin
                    // rising edge of MDC: sample read data (bits 48..63 of the frame)
                    if (is_read && n >= 7'd48) rdata <= {rdata[14:0], mdio};
                end else begin
                    // falling edge: present the next bit
                    if (n == 7'd63) begin
                        busy <= 1'b0;
                        mdio_oe <= 1'b0;
                        if (is_read) begin
                            regs[16*(3-cur_idx) +: 16] <= rdata;
                            if (cur_idx == 2'd1) link_up <= rdata[2];
                        end
                    end else begin
                        n <= n + 7'd1;
                    end
                end
            end
            if (div == 4'd0 && !mdc) begin
                mdio_o  <= frame[63 - n];
                mdio_oe <= !(is_read && n >= 7'd46);
            end
        end
    end
endmodule
