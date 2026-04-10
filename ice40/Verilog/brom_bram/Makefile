file = top
pcf = icebreaker.pcf
srcs = $(file).v brom.v bram.v

build:
	yosys -p "synth_ice40 -top top -json $(file).json" $(srcs)
	nextpnr-ice40 --up5k --json $(file).json --pcf $(pcf) --asc $(file).asc
	icepack $(file).asc $(file).bin

flash:
	icesprog $(file).bin

clean:
	rm -rf *.asc *.json *.bin

