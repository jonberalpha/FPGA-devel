# Root Makefile: LED blink + button toggle (VHDL) on the Sipeed Tang Nano 20K
#
#   make        synthesize, place & route, pack bitstream
#   make sim    run testbench (ghdl)
#   make flash  program FPGA SRAM (volatile)
#   make flash-ext program onboard flash (persistent)
#   make clean

TOP    = led_top
BUILD  = build
PIN_DEF = cst/tang_nano_20k_led.cst
DEVICE = GW2AR-LV18QN88C8/I7
FAMILY = GW2A-18C
BOARD  = tangnano20k
SRC = hdl/led_toggle.vhd hdl/led_top.vhd
GHDL_ARGS = --std=08 --workdir=$(BUILD)

all: $(BUILD)/$(TOP).fs

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/$(TOP).json: $(SRC) | $(BUILD)
	ghdl -a $(GHDL_ARGS) $(SRC)
	yosys -m ghdl -p 'ghdl $(GHDL_ARGS) $(TOP); synth_gowin -top $(TOP) -json $@'

$(BUILD)/$(TOP)_pnr.json: $(BUILD)/$(TOP).json $(PIN_DEF)
	nextpnr-himbaechel --json $< --write $@ --device $(DEVICE) \
		--vopt family=$(FAMILY) --vopt cst=$(PIN_DEF)

$(BUILD)/$(TOP).fs: $(BUILD)/$(TOP)_pnr.json
	gowin_pack -d $(FAMILY) -o $@ $<

sim: | $(BUILD)
	ghdl -a --std=08 --workdir=$(BUILD) hdl/led_toggle.vhd tb/tb_led_toggle.vhd
	ghdl -e --std=08 --workdir=$(BUILD) -o $(BUILD)/tb_led_toggle tb_led_toggle
	$(BUILD)/tb_led_toggle

flash: $(BUILD)/$(TOP).fs
	openFPGALoader -b $(BOARD) $<

flash-ext: $(BUILD)/$(TOP).fs
	openFPGALoader -b $(BOARD) -f $<

clean:
	rm -rf $(BUILD)

.PHONY: all sim flash flash-ext clean
