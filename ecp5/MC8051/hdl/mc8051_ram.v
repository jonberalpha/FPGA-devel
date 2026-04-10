module mc8051_ram (
    input  wire        clka,     // clock
    input  wire [0:0]  wea,      // write enable (1-bit vector)
    input  wire [6:0]  addra,    // 128 addresses
    input  wire [7:0]  dina,     // data in
    output reg  [7:0]  douta     // data out
);

    reg [7:0] ram [0:127];

    always @(posedge clka) begin
        if (wea[0]) begin
            ram[addra] <= dina;
        end
        douta <= ram[addra];
    end

endmodule
