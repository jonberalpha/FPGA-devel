all: clean cpmif

# compile software application for mc8051 using SDCC compiler
# and generate Intel HEX file using packihx_tcl 
compile:
	mkdir -p build
	sdcc ./src/main.c -o ./build/
	echo "sdcc: source codes successfully compiled"

# generate MIF and COE files out of Intel HEX file
convert: compile
	../tools/packihx_tcl ./build/main.ihx ./build/mc8051_rom.hex
	../tools/convhex ./build/mc8051_rom.hex
	echo "convhexmif: successfully converted binary to .hex and .mif file"

# copy MIF file (required for simulation only) to ModelSim simulation directory
cpmif: compile convert
	cp ./build/mc8051_rom.mif ../sim/
	echo "cpmif: successfully copied .mif file to sim/ dir"

clean:
	rm -rf build/

