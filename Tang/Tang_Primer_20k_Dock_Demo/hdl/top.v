// Tang Primer 20K Dock peripheral demo - stage 1
//   S0 reset | S1..S3 toggle LED5/LED4/LED3 | UART status line every 3 s |
//   Ethernet web server (192.168.50.2) | HDMI text terminal + bouncing sprite | 1 kHz+ sine on the headphone jack (DIP2-5 raise the pitch)

module top (
    input  wire       clk27,
    input  wire       rst_btn_n,   // S0, active low
    input  wire       s1_n,        // S1..S3, active low
    input  wire       s2_n,
    input  wire       s3_n,
    input  wire [3:0] dip,         // DIP2..DIP5, high = up

    output wire [2:0] led_n,       // {LED3, LED4, LED5}, active low

    output wire       uart_tx,
    input  wire       uart_rx,

    output wire       tmds_clk_p,
    output wire       tmds_clk_n,
    output wire [2:0] tmds_d_p,
    output wire [2:0] tmds_d_n,

    output wire       pa_en,
    output wire       hp_bck,
    output wire       hp_ws,
    output wire       hp_din,

    input  wire       eth_ref_clk, // RMII 50 MHz from the PHY
    output wire       eth_rst_n,
    output wire [1:0] eth_txd,
    output wire       eth_txen,
    output wire       eth_mdc,
    inout  wire       eth_mdio,
    input  wire [1:0] eth_rxd,
    input  wire       eth_crs_dv
);
    // ---- clocks and reset ---------------------------------------------------
    wire clk_ser, pll_lock, clk_pix;

    pll_126 u_pll (.clkin(clk27), .clkout(clk_ser), .locked(pll_lock));

    CLKDIV #(.DIV_MODE("5"), .GSREN("false")) u_clkdiv (
        .HCLKIN(clk_ser), .RESETN(pll_lock), .CALIB(1'b0), .CLKOUT(clk_pix)
    );

    wire rst_btn;
    debounce #(.CYC(27_000)) u_db_rst (.clk(clk27), .in(~rst_btn_n), .out(rst_btn));
    wire rst = rst_btn | ~pll_lock;

    reg [1:0] rst_pix_s = 2'b11;
    always @(posedge clk_pix or posedge rst) begin
        if (rst) rst_pix_s <= 2'b11;
        else     rst_pix_s <= {rst_pix_s[0], 1'b0};
    end
    wire rst_pix = rst_pix_s[1];

    // ---- time base ---------------------------------------------------------
    reg [24:0] sec_cnt = 25'd0;
    reg        sec_tick = 1'b0;
    always @(posedge clk27) begin
        sec_tick <= 1'b0;
        if (rst) sec_cnt <= 25'd0;
        else if (sec_cnt == 27_000_000 - 1) begin sec_cnt <= 25'd0; sec_tick <= 1'b1; end
        else sec_cnt <= sec_cnt + 25'd1;
    end

    wire [23:0] uptime_bcd;
    bcd_counter #(.DIGITS(6)) u_uptime (.clk(clk27), .rst(rst), .inc(sec_tick), .bcd(uptime_bcd));

    // ---- buttons, DIP switches, LEDs -----------------------------------------
    wire [2:0] btn;
    debounce u_db1 (.clk(clk27), .in(~s1_n), .out(btn[0]));
    debounce u_db2 (.clk(clk27), .in(~s2_n), .out(btn[1]));
    debounce u_db3 (.clk(clk27), .in(~s3_n), .out(btn[2]));

    wire [3:0] dip_s;
    debounce u_dbd0 (.clk(clk27), .in(dip[0]), .out(dip_s[0]));
    debounce u_dbd1 (.clk(clk27), .in(dip[1]), .out(dip_s[1]));
    debounce u_dbd2 (.clk(clk27), .in(dip[2]), .out(dip_s[2]));
    debounce u_dbd3 (.clk(clk27), .in(dip[3]), .out(dip_s[3]));

    wire [2:0] led_state;
    wire [2:0] http_set_en, http_set_val;
    led_ctrl #(.N(3)) u_led (
        .clk(clk27), .rst(rst), .btn(btn),
        .set_en(http_set_en), .set_val(http_set_val),
        .state(led_state)
    );
    assign led_n = ~led_state;

    // ---- sine frequency: 1000 Hz + 500 Hz * DIP --------------------------------
    reg [15:0] freq_bcd;
    always @* begin
        case (dip_s)
            4'd0:  freq_bcd = 16'h1000;
            4'd1:  freq_bcd = 16'h1500;
            4'd2:  freq_bcd = 16'h2000;
            4'd3:  freq_bcd = 16'h2500;
            4'd4:  freq_bcd = 16'h3000;
            4'd5:  freq_bcd = 16'h3500;
            4'd6:  freq_bcd = 16'h4000;
            4'd7:  freq_bcd = 16'h4500;
            4'd8:  freq_bcd = 16'h5000;
            4'd9:  freq_bcd = 16'h5500;
            4'd10: freq_bcd = 16'h6000;
            4'd11: freq_bcd = 16'h6500;
            4'd12: freq_bcd = 16'h7000;
            4'd13: freq_bcd = 16'h7500;
            4'd14: freq_bcd = 16'h8000;
            default: freq_bcd = 16'h8500;
        endcase
    end
    // fs = 1.5 MHz / 32 = 46875 Hz -> increment = f * 2^32 / fs = f * 91625.97
    wire [31:0] phase_inc = (32'd1000 + 32'd500 * dip_s) * 32'd91626;

    // ---- audio ------------------------------------------------------------------
    wire        frame;
    wire [15:0] sample;
    audio_sine u_sine (.clk(clk27), .tick(frame), .phase_inc(phase_inc), .sample(sample));
    pt8211 u_dac (.clk(clk27), .sample(sample), .frame(frame), .bck(hp_bck), .ws(hp_ws), .din(hp_din));
    assign pa_en = 1'b1;

    // ---- Ethernet / HTTP server (50 MHz RMII clock domain) ----------------------------
    // PHY reset: low for ~20 ms after reset
    reg [19:0] phy_cnt = 20'd0;
    always @(posedge clk27)
        if (rst) phy_cnt <= 20'd0;
        else if (!phy_cnt[19]) phy_cnt <= phy_cnt + 20'd1;
    // live debug access over the UART: 3 bytes {reg, hi, lo} write a PHY register
    // NOTE: the PHY is deliberately never reset from the FPGA - after a reset pulse it latches the wrong straps
    // (AN off, no link); it only links up after a power cycle, so eth_rst_n stays high.
    wire [7:0] rx_b; wire rx_v;
    uart_rx u_rx (.clk(clk27), .rx(uart_rx), .data(rx_b), .valid(rx_v));
    reg [1:0]  rx_n = 2'd0;
    reg [4:0]  cmd_reg = 5'd0;
    reg [7:0]  cmd_hi = 8'd0;
    reg [23:0] rx_to = 24'd0;
    reg        cmd_wr = 1'b0;
    reg [15:0] cmd_data = 16'd0;
    always @(posedge clk27) begin
        cmd_wr <= 1'b0;
        rx_to <= rx_v ? 24'd0 : (rx_to == 24'hFFFFFF ? rx_to : rx_to + 24'd1);
        if (rx_to > 24'd2_700_000) rx_n <= 2'd0;                 // 100 ms gap -> resync
        if (rx_v) begin
            if (rx_n == 2'd0) begin
                cmd_reg <= rx_b[4:0]; rx_n <= 2'd1;
            end else if (rx_n == 2'd1) begin cmd_hi <= rx_b; rx_n <= 2'd2; end
            else begin cmd_data <= {cmd_hi, rx_b}; cmd_wr <= 1'b1; rx_n <= 2'd0; end
        end
    end
    assign eth_rst_n = 1'b1;

    reg [1:0] eth_rst_s = 2'b11;
    always @(posedge eth_ref_clk or posedge rst) begin
        if (rst) eth_rst_s <= 2'b11;
        else     eth_rst_s <= {eth_rst_s[0], ~phy_cnt[19]};
    end

    reg [2:0] led_state_e1 = 3'b0, led_state_e2 = 3'b0;
    always @(posedge eth_ref_clk) begin
        led_state_e1 <= led_state;
        led_state_e2 <= led_state_e1;
    end

    wire [2:0] e_led_tgl, e_led_val;
    wire       e_req_tgl, e_rx_tgl;
    eth_server u_eth (
        .clk(eth_ref_clk), .rst(eth_rst_s[1]),
        .rxd(eth_rxd), .crs_dv(eth_crs_dv), .txd(eth_txd), .tx_en(eth_txen),
        .led_state(led_state_e2), .led_tgl(e_led_tgl), .led_val(e_led_val),
        .req_tgl(e_req_tgl), .rx_tgl(e_rx_tgl)
    );

    wire phy_link, phy_cfg;
    wire [63:0] phy_regs;
    mdio_master u_mdio (.clk(clk27), .rst(~phy_cnt[19]), .mdc(eth_mdc), .wr_req(cmd_wr), .wr_reg(cmd_reg), .wr_data(cmd_data), .mdio(eth_mdio),
                        .link_up(phy_link), .cfg_done(phy_cfg), .regs(phy_regs));

    // toggle signals back into the 27 MHz domain
    reg [3:0] tgl_s0 = 0, tgl_s1 = 0, tgl_s2 = 0, tgl_s3 = 0;   // {req, led3, led4, led5}
    reg [2:0] val_s1 = 0, val_s2 = 0;
    always @(posedge clk27) begin
        tgl_s0 <= {e_req_tgl, e_led_tgl[2:0]};
        tgl_s1 <= tgl_s0;
        tgl_s2 <= tgl_s1;
        tgl_s3 <= tgl_s2;
        val_s1 <= e_led_val;
        val_s2 <= val_s1;
    end
    assign http_set_en  = tgl_s2[2:0] ^ tgl_s3[2:0];
    assign http_set_val = val_s2;
    wire req_pulse = tgl_s2[3] ^ tgl_s3[3];

    wire [19:0] reqcnt_bcd;
    bcd_counter #(.DIGITS(5)) u_reqcnt (.clk(clk27), .rst(rst), .inc(req_pulse), .bcd(reqcnt_bcd));

    // ---- UART ---------------------------------------------------------------------
    wire [19:0] msgcnt_bcd;
    uart_msg u_uart (
        .clk(clk27), .rst(rst), .uptime_bcd(uptime_bcd), .freq_bcd(freq_bcd),
        .led_state(led_state), .phy_regs(phy_regs), .cnt_bcd(msgcnt_bcd), .tx(uart_tx)
    );

    // ---- HDMI ---------------------------------------------------------------------
    wire [9:0] vx, vy;
    wire       v_de, v_hs, v_vs, v_frame;
    wire [7:0] pr, pg, pb;
    wire       p_de, p_hs, p_vs;

    reg [24:0] blink_cnt = 25'd0;
    always @(posedge clk27) blink_cnt <= blink_cnt + 25'd1;

    vga_timing u_vga (.clk(clk_pix), .rst(rst_pix), .x(vx), .y(vy), .de(v_de), .hs(v_hs), .vs(v_vs), .frame_start(v_frame));

    text_gen u_text (
        .clk(clk_pix), .x(vx), .y(vy), .de_in(v_de), .hs_in(v_hs), .vs_in(v_vs), .frame_start(v_frame),
        .uptime_bcd(uptime_bcd), .msgcnt_bcd(msgcnt_bcd), .reqcnt_bcd(reqcnt_bcd), .freq_bcd(freq_bcd), .dip(dip_s), .link(phy_link),
        .led_state(led_state), .blink(blink_cnt[23]),
        .r(pr), .g(pg), .b(pb), .de(p_de), .hs(p_hs), .vs(p_vs)
    );

    dvi_tx u_dvi (
        .pclk(clk_pix), .fclk(clk_ser), .rst(rst_pix),
        .r(pr), .g(pg), .b(pb), .de(p_de), .hs(p_hs), .vs(p_vs),
        .tmds_clk_p(tmds_clk_p), .tmds_clk_n(tmds_clk_n), .tmds_d_p(tmds_d_p), .tmds_d_n(tmds_d_n)
    );

endmodule
