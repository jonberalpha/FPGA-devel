PROJ = led_on
PIN_DEF = ../ulx3s.lpf
PNRDEVICE = 85k
PNRPACKAGE = CABGA381

all: clean bit

json:
	yosys -m ghdl -p 'ghdl $(PROJ).vhd -e $(PROJ); synth_ecp5 -json $(PROJ).json'

config: json
	nextpnr-ecp5 --$(PNRDEVICE) --package $(PNRPACKAGE) --json $(PROJ).json --textcfg $(PROJ).config --lpf $(PIN_DEF) -q --timing-allow-fail

bit: config
	ecppack $(PROJ).config $(PROJ).bit

prog:
	fujprog $(PROJ).bit

sudo-prog:
	@echo 'Executing prog as root!!!'
	sudo fujprog $(PROJ).bit

clean:
	rm -f $(PROJ).json $(PROJ).config $(PROJ).bit 

.SECONDARY:
.PHONY: all prog clean
