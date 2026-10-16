// Text-mode terminal renderer (80x30 characters of 8x16 pixels) plus a bouncing sprite.
// Character RAM is initialised from screen.hex; some fields are overlaid with live data.
// Pipeline latency: 3 pixel clocks (de/hs/vs are delayed accordingly).
module text_gen (
    input  wire        clk,         // pixel clock
    input  wire [9:0]  x,
    input  wire [9:0]  y,
    input  wire        de_in,
    input  wire        hs_in,
    input  wire        vs_in,
    input  wire        frame_start,

    // live data (quasi static, from the 27 MHz domain)
    input  wire [23:0] uptime_bcd,
    input  wire [19:0] msgcnt_bcd,
    input  wire [19:0] reqcnt_bcd,
    input  wire [15:0] freq_bcd,
    input  wire [3:0]  dip,
    input  wire        link,
    input  wire [2:0]  led_state,   // {LED3, LED4, LED5}
    input  wire        blink,

    output reg  [7:0]  r = 8'd0,
    output reg  [7:0]  g = 8'd0,
    output reg  [7:0]  b = 8'd0,
    output reg         de = 1'b0,
    output reg         hs = 1'b0,
    output reg         vs = 1'b0
);
    `include "screen_fields.vh"

    // ---- character RAM and font ROM ---------------------------------------
    reg [7:0] screen [0:2399];
    reg [7:0] font   [0:4095];
    initial begin
        $readmemh("hdl/screen.hex", screen);
        $readmemh("hdl/font8x16.hex", font);
    end

    wire [4:0] row0 = y[8:4];
    wire [6:0] col0 = x[9:3];
    wire [11:0] addr0 = ({7'b0, row0} << 6) + ({7'b0, row0} << 4) + {5'b0, col0};

    // ---- dynamic fields ----------------------------------------------------
    function [7:0] dg(input [3:0] n);
        dg = 8'h30 + n;
    endfunction

    function [8:0] on_off(input s, input [1:0] pos); // {valid, char}
        case (pos)
            2'd0: on_off = {1'b1, s ? 8'h20 : "O"};
            2'd1: on_off = {1'b1, s ? "O"  : "F"};
            default: on_off = {1'b1, s ? "N" : "F"};
        endcase
    endfunction

    reg [8:0] dyn;  // {override, char}
    always @* begin
        dyn = 9'd0;
        if (row0 == F_UPTIME_ROW && col0 >= F_UPTIME_COL && col0 < F_UPTIME_COL + F_UPTIME_LEN)
            dyn = {1'b1, dg(uptime_bcd[4*(F_UPTIME_LEN-1-(col0-F_UPTIME_COL)) +: 4])};
        else if (row0 == F_MSGCNT_ROW && col0 >= F_MSGCNT_COL && col0 < F_MSGCNT_COL + F_MSGCNT_LEN)
            dyn = {1'b1, dg(msgcnt_bcd[4*(F_MSGCNT_LEN-1-(col0-F_MSGCNT_COL)) +: 4])};
        else if (row0 == F_REQCNT_ROW && col0 >= F_REQCNT_COL && col0 < F_REQCNT_COL + F_REQCNT_LEN)
            dyn = {1'b1, dg(reqcnt_bcd[4*(F_REQCNT_LEN-1-(col0-F_REQCNT_COL)) +: 4])};
        else if (row0 == F_FREQ_ROW && col0 >= F_FREQ_COL && col0 < F_FREQ_COL + F_FREQ_LEN)
            dyn = {1'b1, dg(freq_bcd[4*(F_FREQ_LEN-1-(col0-F_FREQ_COL)) +: 4])};
        else if (row0 == F_DIP_ROW && col0 >= F_DIP_COL && col0 < F_DIP_COL + F_DIP_LEN)
            dyn = {1'b1, dg({3'b0, dip[col0 - F_DIP_COL]})};
        else if (row0 == F_L5_ROW && col0 >= F_L5_COL && col0 < F_L5_COL + F_L5_LEN)
            dyn = on_off(led_state[0], col0 - F_L5_COL);
        else if (row0 == F_L4_ROW && col0 >= F_L4_COL && col0 < F_L4_COL + F_L4_LEN)
            dyn = on_off(led_state[1], col0 - F_L4_COL);
        else if (row0 == F_L3_ROW && col0 >= F_L3_COL && col0 < F_L3_COL + F_L3_LEN)
            dyn = on_off(led_state[2], col0 - F_L3_COL);
        else if (row0 == F_LINK_ROW && col0 >= F_LINK_COL && col0 < F_LINK_COL + F_LINK_LEN)
            dyn = {1'b1, link ? (col0 == F_LINK_COL ? "U" : col0 == F_LINK_COL + 1 ? "P" : 8'h20)
                            : (col0 == F_LINK_COL ? "D" : col0 == F_LINK_COL + 1 ? "O" : col0 == F_LINK_COL + 2 ? "W" : "N")};
        else if (row0 == F_CUR_ROW && col0 == F_CUR_COL)
            dyn = {1'b1, blink ? 8'hdb : 8'h20};
    end

    // ---- stage 1: RAM read and field overlay ------------------------------
    reg [7:0] ram_ch;
    reg [8:0] dyn1;
    reg [9:0] x1, y1;
    reg       de1, hs1, vs1;
    always @(posedge clk) begin
        ram_ch <= screen[addr0];
        dyn1   <= dyn;
        x1 <= x; y1 <= y; de1 <= de_in; hs1 <= hs_in; vs1 <= vs_in;
    end

    // ---- stage 2: font ROM read -------------------------------------------
    wire [7:0] ch1 = dyn1[8] ? dyn1[7:0] : ram_ch;
    reg [7:0] glyph;
    reg [9:0] x2, y2;
    reg       de2, hs2, vs2;
    always @(posedge clk) begin
        glyph <= font[{ch1, y1[3:0]}];
        x2 <= x1; y2 <= y1; de2 <= de1; hs2 <= hs1; vs2 <= vs1;
    end

    // ---- sprite: 32x32 box bouncing around the screen ---------------------
    localparam SPR = 32;
    reg [9:0] sx = 10'd100, sy = 10'd250;
    reg       dx = 1'b0, dy = 1'b0;      // 0 = positive direction
    always @(posedge clk) begin
        if (frame_start) begin
            if (!dx) begin
                if (sx + SPR + 3 >= 640) dx <= 1'b1;
                sx <= sx + 10'd3;
            end else begin
                if (sx <= 3) dx <= 1'b0;
                sx <= sx - 10'd3;
            end
            if (!dy) begin
                if (sy + SPR + 2 >= 480) dy <= 1'b1;
                sy <= sy + 10'd2;
            end else begin
                if (sy <= 2) dy <= 1'b0;
                sy <= sy - 10'd2;
            end
        end
    end

    wire in_spr  = (x2 >= sx) && (x2 < sx + SPR) && (y2 >= sy) && (y2 < sy + SPR);
    wire spr_bdr = in_spr && ((x2 == sx) || (x2 == sx + SPR - 1) || (y2 == sy) || (y2 == sy + SPR - 1));
    wire spr_dia = in_spr && ((x2 - sx) == (y2 - sy) || (x2 - sx) == (SPR - 1 - (y2 - sy)));

    // ---- stage 3: pixel colour --------------------------------------------
    wire pix = glyph[3'd7 - x2[2:0]];
    always @(posedge clk) begin
        de <= de2; hs <= hs2; vs <= vs2;
        if (!de2) begin
            {r, g, b} <= 24'd0;
        end else if (spr_bdr) begin
            {r, g, b} <= {8'hff, 8'hff, 8'hff};
        end else if (spr_dia) begin
            {r, g, b} <= {8'hff, 8'h40, 8'h00};
        end else if (in_spr) begin
            {r, g, b} <= {8'hff, 8'ha0, 8'h00};
        end else if (pix) begin
            {r, g, b} <= {8'h40, 8'hff, 8'h70};
        end else begin
            {r, g, b} <= {8'h00, 8'h00, 8'h28};
        end
    end
endmodule
