# Root Makefile: Tang Primer 20K Dock peripheral demo (Verilog)
#
#   make          synthesize, place & route, pack bitstream -> build/top.fs
#   make sim      run all testbenches (iverilog), writes sim/frame.ppm
#   make flash    program FPGA SRAM (volatile)
#   make flash-ext program onboard flash (persistent)
#   make clean

TOP     = top
BUILD   = build
PIN_DEF = cst/tang_primer_20k_dock_demo.cst
DEVICE  = GW2A-LV18PG256C8/I7
FAMILY  = GW2A-18C
BOARD   = tangprimer20k

SRC = hdl/top.v hdl/debounce.v hdl/led_ctrl.v hdl/bcd_counter.v \
      hdl/uart_tx.v hdl/uart_rx.v hdl/uart_msg.v hdl/eth_server.v hdl/mdio_master.v \
      hdl/pt8211.v hdl/audio_sine.v hdl/sine_lut.v \
      hdl/vga_timing.v hdl/text_gen.v hdl/tmds_encoder.v hdl/dvi_tx.v hdl/pll_126.v
DATA = hdl/font8x16.hex hdl/screen.hex hdl/screen_fields.vh hdl/http_page.hex hdl/http_page.vh

all: $(BUILD)/$(TOP).fs

$(BUILD):
	mkdir -p $(BUILD)

# regenerate the generated hdl data files
hdl/font8x16.hex:
	python3 tools/gen_font.py
hdl/screen.hex hdl/screen_fields.vh: tools/gen_screen.py
	python3 tools/gen_screen.py
hdl/http_page.hex hdl/http_page.vh: tools/gen_http.py
	python3 tools/gen_http.py
hdl/sine_lut.v: tools/gen_sine.py
	python3 tools/gen_sine.py

$(BUILD)/$(TOP).json: $(SRC) $(DATA) | $(BUILD)
	yosys -p 'read_verilog -I hdl $(SRC); synth_gowin -top $(TOP) -json $@'

$(BUILD)/$(TOP)_pnr.json: $(BUILD)/$(TOP).json $(PIN_DEF)
	nextpnr-himbaechel --json $< --write $@ --device $(DEVICE) \
		--vopt family=$(FAMILY) --vopt cst=$(PIN_DEF) --freq 27

$(BUILD)/$(TOP).fs: $(BUILD)/$(TOP)_pnr.json
	gowin_pack -d $(FAMILY) -o $@ $<

sim: $(DATA) hdl/sine_lut.v | $(BUILD)
	sh tb/run_all.sh

flash: $(BUILD)/$(TOP).fs
	openFPGALoader -b $(BOARD) $<

flash-ext: $(BUILD)/$(TOP).fs
	openFPGALoader -b $(BOARD) -f $<

clean:
	rm -rf $(BUILD) sim/rx.hex sim/tx.hex sim/*.ppm
	rm -f $(DATA) hdl/sine_lut.v

.PHONY: all sim flash flash-ext clean
