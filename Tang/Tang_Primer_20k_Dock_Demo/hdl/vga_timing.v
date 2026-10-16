// 640x480 @ 60 Hz timing (pixel clock 25.2 MHz), negative sync polarity.
module vga_timing (
    input  wire       clk,
    input  wire       rst,
    output reg  [9:0] x = 10'd0,
    output reg  [9:0] y = 10'd0,
    output wire       de,
    output wire       hs,
    output wire       vs,
    output wire       frame_start   // pulse once per frame
);
    localparam H_ACT = 640, H_FP = 16, H_SYNC = 96, H_BP = 48, H_TOT = 800;
    localparam V_ACT = 480, V_FP = 10, V_SYNC = 2,  V_BP = 33, V_TOT = 525;

    always @(posedge clk) begin
        if (rst) begin
            x <= 10'd0;
            y <= 10'd0;
        end else if (x == H_TOT - 1) begin
            x <= 10'd0;
            y <= (y == V_TOT - 1) ? 10'd0 : y + 10'd1;
        end else begin
            x <= x + 10'd1;
        end
    end

    assign de = (x < H_ACT) && (y < V_ACT);
    assign hs = ~((x >= H_ACT + H_FP) && (x < H_ACT + H_FP + H_SYNC));
    assign vs = ~((y >= V_ACT + V_FP) && (y < V_ACT + V_FP + V_SYNC));
    assign frame_start = (x == 10'd0) && (y == V_ACT);
endmodule
