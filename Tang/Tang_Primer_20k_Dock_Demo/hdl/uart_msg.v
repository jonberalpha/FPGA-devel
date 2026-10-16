// Sends a status line over the UART every PERIOD_S seconds (default 3).
module uart_msg #(
    parameter integer CLK_HZ   = 27_000_000,
    parameter integer BAUD     = 115_200,
    parameter integer PERIOD_S = 3
) (
    input  wire        clk,
    input  wire        rst,
    input  wire [23:0] uptime_bcd,  // 6 digits
    input  wire [15:0] freq_bcd,    // 4 digits
    input  wire [2:0]  led_state,   // {LED3, LED4, LED5}
    input  wire [63:0] phy_regs,    // PHY registers 0..3
    output wire [19:0] cnt_bcd,     // number of messages sent (5 digits)
    output wire        tx
);
    localparam integer LEN = 101;

    wire [8*LEN-1:0] msg;

    function [7:0] dg(input [3:0] n);
        dg = 8'h30 + n;
    endfunction

    function [7:0] hx(input [3:0] n);
        hx = (n < 4'd10) ? (8'h30 + n) : (8'h57 + n);
    endfunction

    assign msg = {
        "Tang Primer 20K Dock | msg #",
        dg(cnt_bcd[19:16]), dg(cnt_bcd[15:12]), dg(cnt_bcd[11:8]), dg(cnt_bcd[7:4]), dg(cnt_bcd[3:0]),
        " | up ",
        dg(uptime_bcd[23:20]), dg(uptime_bcd[19:16]), dg(uptime_bcd[15:12]),
        dg(uptime_bcd[11:8]),  dg(uptime_bcd[7:4]),   dg(uptime_bcd[3:0]),
        "s | LED5-3=",
        dg({3'b0, led_state[0]}), dg({3'b0, led_state[1]}), dg({3'b0, led_state[2]}),
        " | sine ",
        dg(freq_bcd[15:12]), dg(freq_bcd[11:8]), dg(freq_bcd[7:4]), dg(freq_bcd[3:0]),
        "Hz | PHY ",
        hx(phy_regs[63:60]), hx(phy_regs[59:56]), hx(phy_regs[55:52]), hx(phy_regs[51:48]), " ",
        hx(phy_regs[47:44]), hx(phy_regs[43:40]), hx(phy_regs[39:36]), hx(phy_regs[35:32]), " ",
        hx(phy_regs[31:28]), hx(phy_regs[27:24]), hx(phy_regs[23:20]), hx(phy_regs[19:16]), " ",
        hx(phy_regs[15:12]), hx(phy_regs[11:8]),  hx(phy_regs[7:4]),   hx(phy_regs[3:0]),
        "\r\n"
    };

    reg [31:0] timer = 32'd0;
    reg [7:0]  idx   = 8'd0;
    reg        sending = 1'b0;
    reg        start = 1'b0;
    wire       busy;
    reg        inc = 1'b0;

    bcd_counter #(.DIGITS(5)) u_cnt (.clk(clk), .rst(rst), .inc(inc), .bcd(cnt_bcd));

    uart_tx #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_tx (
        .clk(clk), .data(msg[8*(LEN-idx) +: 8]), .start(start), .busy(busy), .tx(tx)
    );

    always @(posedge clk) begin
        start <= 1'b0;
        inc   <= 1'b0;
        if (rst) begin
            timer   <= 32'd0;
            sending <= 1'b0;
            idx     <= 8'd0;
        end else if (!sending) begin
            if (timer == PERIOD_S * CLK_HZ - 1) begin
                timer   <= 32'd0;
                sending <= 1'b1;
                idx     <= 8'd0;
            end else begin
                timer <= timer + 32'd1;
            end
        end else if (!busy && !start) begin
            if (idx == LEN) begin
                sending <= 1'b0;
                inc     <= 1'b1;
            end else begin
                start <= 1'b1;
                idx   <= idx + 8'd1;
            end
        end
    end
endmodule
