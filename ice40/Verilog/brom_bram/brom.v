module BROM(
	input clk_i,// Read clock
	output reg [7:0]data_o,// Data output
	input [9:0] addr_i,// Read address
	input ce_i);// Read enable

parameter rom_size = 1024;
	
reg [7:0] rom[rom_size-1:0];
parameter MEM_INIT_FILE = "mc8051_rom.mif";

initial begin
  if (MEM_INIT_FILE != "") begin
    $readmemb(MEM_INIT_FILE, rom);
  end
end

always@(posedge clk_i) begin
	if(ce_i) 
		data_o <= rom[addr_i];	
end	

endmodule