all: clean cpmif
	echo "mc8051 software application built successfully!"

# compile software application for mc8051 using SDCC compiler
# and generate Intel HEX file using packihx_tcl 
compile:
	mkdir -p build
	sdcc ./src/main.c -o ./build/
	echo "sdcc: main.c sucessfully compiled"

# generate MIF and COE files out of Intel HEX file
convert: compile
	../tools/packihx_tcl ./build/main.ihx ./build/mc8051_rom.hex
	../tools/convhex ./build/mc8051_rom.hex

# copy MIF file (required for simulation only) to ModelSim simulation directory
cpmif: compile convert
	cp ./build/mc8051_rom.mif ../sim/

clean:
	rm -rf build/

