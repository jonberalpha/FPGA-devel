# Root Makefile: LED blink + button toggle (VERILOG) on the Sipeed Tang Primer 20K (Dock)
#
#   make        synthesize, place & route, pack bitstream
#   make sim    run testbench (iverilog)
#   make flash  program FPGA SRAM (volatile)
#   make flash-ext program onboard flash (persistent)
#   make clean

TOP    = led_top
BUILD  = build
PIN_DEF = cst/tang_primer_20k_led.cst
DEVICE = GW2A-LV18PG256C8/I7
FAMILY = GW2A-18C
BOARD  = tangprimer20k
SRC = hdl/led_toggle.v hdl/led_top.v

all: $(BUILD)/$(TOP).fs

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/$(TOP).json: $(SRC) | $(BUILD)
	yosys -p 'read_verilog $(SRC); synth_gowin -top $(TOP) -json $@'

$(BUILD)/$(TOP)_pnr.json: $(BUILD)/$(TOP).json $(PIN_DEF)
	nextpnr-himbaechel --json $< --write $@ --device $(DEVICE) \
		--vopt family=$(FAMILY) --vopt cst=$(PIN_DEF)

$(BUILD)/$(TOP).fs: $(BUILD)/$(TOP)_pnr.json
	gowin_pack -d $(FAMILY) -o $@ $<

sim: | $(BUILD)
	iverilog -o $(BUILD)/tb.vvp tb/tb_led_toggle.v hdl/led_toggle.v
	vvp $(BUILD)/tb.vvp

flash: $(BUILD)/$(TOP).fs
	openFPGALoader -b $(BOARD) $<

flash-ext: $(BUILD)/$(TOP).fs
	openFPGALoader -b $(BOARD) -f $<

clean:
	rm -rf $(BUILD)

.PHONY: all sim flash flash-ext clean
