// Sine generator: 32 bit phase accumulator, quarter-wave LUT (64 entries),
// the other quadrants are produced by mirroring the index and inverting the sign.
module audio_sine (
    input  wire        clk,
    input  wire        tick,         // one pulse per sample
    input  wire [31:0] phase_inc,
    output reg  [15:0] sample = 16'd0 // signed two's complement
);
    reg  [31:0] phase = 32'd0;
    wire [1:0]  quad  = phase[31:30];
    wire [5:0]  idx   = quad[0] ? ~phase[29:24] : phase[29:24]; // odd quadrants: read backwards
    wire [15:0] mag;

    sine_lut u_lut (.idx(idx), .val(mag));

    always @(posedge clk) begin
        if (tick) begin
            phase  <= phase + phase_inc;
            sample <= quad[1] ? (~mag + 16'd1) : mag; // second half: negative
        end
    end
endmodule
