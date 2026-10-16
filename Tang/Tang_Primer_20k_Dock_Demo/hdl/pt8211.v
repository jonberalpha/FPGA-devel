// Driver for the PT8211 stereo DAC (16 bit, MSB first, WS low = left).
// BCK = clk / (2*BCK_HALF), one stereo frame = 32 BCK cycles.
// Data and WS change on the falling BCK edge, the DAC samples on the rising edge.
module pt8211 #(
    parameter integer BCK_HALF = 9      // 27 MHz / 18 = 1.5 MHz -> fs = 46.875 kHz
) (
    input  wire        clk,
    input  wire [15:0] sample,          // mono, held for the whole frame
    output reg         frame = 1'b0,    // pulse: next sample is latched
    output reg         bck = 1'b0,
    output reg         ws  = 1'b0,
    output reg         din = 1'b0
);
    reg [7:0] div = 8'd0;
    reg [4:0] bitcnt = 5'd0;       // 0..31, bit position within the frame
    reg [15:0] cur = 16'd0;

    always @(posedge clk) begin
        frame <= 1'b0;
        if (div == BCK_HALF - 1) begin
            div <= 8'd0;
            bck <= ~bck;
            if (bck) begin // falling edge: present next bit
                if (bitcnt == 5'd0) begin
                    cur <= sample;
                    frame <= 1'b1;
                    din <= sample[15];
                end else begin
                    din <= cur[15 - (bitcnt[3:0])];
                end
                ws <= bitcnt[4];
                bitcnt <= bitcnt + 5'd1;
            end
        end else begin
            div <= div + 8'd1;
        end
    end
endmodule
