PROJ=top
ENTITY=top
VHDLSRC=vhdl
BUILD=build

build:
	# Analyse VHDL sources
	ghdl -a $(VHDLSRC)/*.vhd

	# Synthesize the design.
	# NOTE: if GHDL is built as a module, set MODULE to '-m ghdl' or '-m path/to/ghdl.so',
	#       otherwise, unset it.
	#yosys -p 'ghdl $(PROJ); synth_ice40 -json $(PROJ).json'

	# Place & Route
	#nextpnr-ice40 --lp1k --package cm36 --pcf io.pcf --asc $(PROJ).asc --json $(PROJ).json

	# Generate bitstream
	#icepack $(PROJ).asc $(PROJ).bin

# all in one
# yosys $MODULE -p 'ghdl leds.vhdl spin1.vhdl -e leds; synth_ice40 -json leds.json'
#viewpnr:
	#nextpnr-ice40 --lp1k --package cm36 --pcf io.pcf --asc $(PROJ).asc --json $(PROJ).json -v --gui
	# assign Timing not working

svgjson:
	yosys -p "ghdl $(ENTITY); prep -top $(ENTITY); write_json rtltop.json";
	yosys -p "ghdl $(ENTITY); prep -top $(ENTITY) -flatten; write_json rtlflat.json";

svgimg:
	netlistsvg rtltop.json -o rtl/rtltop.svg;
	netlistsvg rtlflat.json -o rtl/rtlflat.svg;

#flash:
	# Program FPGA
	#icesprog $(PROJ).bin

clean:
	rm -rf *.asc *.json *.bin rtl/

