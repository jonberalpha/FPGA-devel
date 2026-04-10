PROJ := leds

build:
	# Analyse VHDL sources
	ghdl -a $(PROJ).vhd
	ghdl -a spin1.vhd

	# Synthesize the design.
	# NOTE: if GHDL is built as a module, set MODULE to '-m ghdl' or '-m path/to/ghdl.so',
	#       otherwise, unset it.
	yosys -m ghdl -p 'ghdl $(PROJ); synth_ice40 -json $(PROJ).json'

	# Place & Route
	nextpnr-ice40 --lp1k --package cm36 --pcf io.pcf --asc $(PROJ).asc --json $(PROJ).json

	# Generate bitstream
	icepack $(PROJ).asc $(PROJ).bin
	
# all in one
# yosys $MODULE -p 'ghdl $(PROJ).vhd spin1.vhd -e $(PROJ); synth_ice40 -json $(PROJ).json'
viewpnr:
	nextpnr-ice40 --lp1k --package cm36 --pcf io.pcf --asc $(PROJ).asc --json $(PROJ).json -v --gui
	# assign Timing not working

flash:
	# Program FPGA
	icesprog $(PROJ).bin

clean:
	rm -rf *.asc *.json *.bin

