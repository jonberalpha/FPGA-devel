module mc8051_rom (
    input  wire        clka,    // clock (unused for read, kept for compatibility)
    input  wire [12:0] addra,   // 8K addresses
    output wire [7:0]  douta    // 8-bit data
);
    // ROM storage
    reg [7:0] rom [0:8191];

    initial
    begin
        $readmemb("../sw/build/mc8051_rom.mif", rom);
    end

    always @(posedge clka)
    begin
        douta <= rom[addra];
    end

endmodule
