
build:
	# Analyse VHDL sources
	ghdl -a leds.vhdl
	ghdl -a spin1.vhdl

	# Synthesize the design.
	# NOTE: if GHDL is built as a module, set MODULE to '-m ghdl' or '-m path/to/ghdl.so',
	#       otherwise, unset it.
	yosys -m ghdl -p 'ghdl leds; synth_ice40 -json leds.json'

	# Place & Route
	nextpnr-ice40 --lp1k --package cm36 --pcf io.pcf --asc leds.asc --json leds.json

	# Generate bitstream
	icepack leds.asc leds.bin

# all in one
# yosys $MODULE -p 'ghdl leds.vhdl spin1.vhdl -e leds; synth_ice40 -json leds.json'
viewpnr:
	nextpnr-ice40 --lp1k --package cm36 --pcf io.pcf --asc leds.asc --json leds.json -v --gui
	# assign Timing not working

flash:
	# Program FPGA
	icesprog leds.bin

clean:
	rm -rf *.asc *.json *.bin *.o *.cf

