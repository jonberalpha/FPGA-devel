// DVI transmitter: 3 TMDS data channels + clock, serialized with OSER10 (10:1 DDR)
// and driven through true-differential TLVDS_OBUF outputs.
module dvi_tx (
    input  wire       pclk,        // pixel clock 25.2 MHz
    input  wire       fclk,        // serial clock 126 MHz (5x pclk, DDR -> 10x data rate)
    input  wire       rst,
    input  wire [7:0] r,
    input  wire [7:0] g,
    input  wire [7:0] b,
    input  wire       de,
    input  wire       hs,
    input  wire       vs,
    output wire       tmds_clk_p,
    output wire       tmds_clk_n,
    output wire [2:0] tmds_d_p,
    output wire [2:0] tmds_d_n
);
    wire [9:0] q0, q1, q2;
    tmds_encoder u_enc0 (.clk(pclk), .d(b), .c({vs, hs}), .de(de), .q(q0));
    tmds_encoder u_enc1 (.clk(pclk), .d(g), .c(2'b00),    .de(de), .q(q1));
    tmds_encoder u_enc2 (.clk(pclk), .d(r), .c(2'b00),    .de(de), .q(q2));

    wire [2:0] ser;
    wire       ser_clk;

    OSER10 u_ser0 (.Q(ser[0]), .D0(q0[0]), .D1(q0[1]), .D2(q0[2]), .D3(q0[3]), .D4(q0[4]),
                   .D5(q0[5]), .D6(q0[6]), .D7(q0[7]), .D8(q0[8]), .D9(q0[9]),
                   .FCLK(fclk), .PCLK(pclk), .RESET(rst));
    OSER10 u_ser1 (.Q(ser[1]), .D0(q1[0]), .D1(q1[1]), .D2(q1[2]), .D3(q1[3]), .D4(q1[4]),
                   .D5(q1[5]), .D6(q1[6]), .D7(q1[7]), .D8(q1[8]), .D9(q1[9]),
                   .FCLK(fclk), .PCLK(pclk), .RESET(rst));
    OSER10 u_ser2 (.Q(ser[2]), .D0(q2[0]), .D1(q2[1]), .D2(q2[2]), .D3(q2[3]), .D4(q2[4]),
                   .D5(q2[5]), .D6(q2[6]), .D7(q2[7]), .D8(q2[8]), .D9(q2[9]),
                   .FCLK(fclk), .PCLK(pclk), .RESET(rst));
    OSER10 u_serc (.Q(ser_clk), .D0(1'b1), .D1(1'b1), .D2(1'b1), .D3(1'b1), .D4(1'b1),
                   .D5(1'b0), .D6(1'b0), .D7(1'b0), .D8(1'b0), .D9(1'b0),
                   .FCLK(fclk), .PCLK(pclk), .RESET(rst));

    TLVDS_OBUF u_ob0 (.I(ser[0]),  .O(tmds_d_p[0]), .OB(tmds_d_n[0]));
    TLVDS_OBUF u_ob1 (.I(ser[1]),  .O(tmds_d_p[1]), .OB(tmds_d_n[1]));
    TLVDS_OBUF u_ob2 (.I(ser[2]),  .O(tmds_d_p[2]), .OB(tmds_d_n[2]));
    TLVDS_OBUF u_obc (.I(ser_clk), .O(tmds_clk_p),  .OB(tmds_clk_n));
endmodule
