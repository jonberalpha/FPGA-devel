# compile software application for mc8051 using SDCC compiler
# and generate Intel HEX file using packihx_tcl
all: cpmif

compile:
	mkdir -p build
	sdcc ./src/main.c -o ./build/
	echo "sdcc: source codes successfully compiled"

# generate MIF and COE files out of Intel HEX file
convert: compile
	../tools/packihx_tcl ./build/main.ihx ./build/mc8051_rom.hex
	../tools/convhex ./build/mc8051_rom.hex
	echo "convhexmif: successfully converted binary to .hex and .mif file"

# copy MIF file to the simulation directory
cpmif: compile convert
	cp ./build/mc8051_rom.mif ../sim/
	echo "cpmif: successfully copied .mif file to sim/ dir"

clean:
	rm -rf build/

.PHONY: all compile convert cpmif clean
