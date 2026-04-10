module mc8051_rom (
    input  wire        clka,    // clock
    input  wire [12:0]  addra,   // 1K addresses
    output reg  [7:0]  douta    // 8-bit data
  );

  // ROM storage
  reg [7:0] rom [0:8192];

  // Optional initialization from file
  initial
  begin
    $readmemb("../sw/build/mc8051_rom.mif", rom);
  end

  always @(posedge clka)
  begin
    douta <= rom[addra];
  end

endmodule
