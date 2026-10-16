# Root Makefile for the mc8051 demo on the Sipeed Tang Primer 20K
# (button on P1.0 -> LED on P2.0, firmware compiled with SDCC).
#
# Toolchain (OSS-CAD-SUITE): ghdl + ghdl-yosys-plugin, yosys,
# nextpnr-himbaechel (Gowin), gowin_pack, openFPGALoader; plus sdcc.
#
#   make          compile firmware, synthesize, place & route, pack bitstream
#   make sw       compile firmware only (sw/build/mc8051_rom.mif)
#   make flash    program FPGA SRAM (volatile)
#   make flash-ext program onboard flash (persistent)
#   make clean

ENTITY = fpga_top
PROJ   = $(ENTITY)
HDL    = hdl
SW     = sw
BUILD  = build
GHDL_ARGS = -fsynopsys --workdir=$(BUILD)

PIN_DEF = cst/tang_primer_20k_mc8051.cst
DEVICE  = GW2A-LV18PG256C8/I7
FAMILY  = GW2A-18C
BOARD   = tangprimer20k

# VHDL sources in compile order (same order as the ULX3S reference project)
VHDL_SRC = mc8051/mc8051_p.vhd \
          mc8051/control_mem_.vhd \
          mc8051/control_mem_rtl.vhd \
          mc8051/control_mem_rtl_cfg.vhd \
          mc8051/control_fsm_.vhd \
          mc8051/control_fsm_rtl.vhd \
          mc8051/control_fsm_rtl_cfg.vhd \
          mc8051/mc8051_control_.vhd \
          mc8051/mc8051_control_struc.vhd \
          mc8051/mc8051_control_struc_cfg.vhd \
          mc8051/alucore_.vhd \
          mc8051/alucore_rtl.vhd \
          mc8051/alucore_rtl_cfg.vhd \
          mc8051/alumux_.vhd \
          mc8051/alumux_rtl.vhd \
          mc8051/alumux_rtl_cfg.vhd \
          mc8051/addsub_cy_.vhd \
          mc8051/addsub_cy_rtl.vhd \
          mc8051/addsub_cy_rtl_cfg.vhd \
          mc8051/addsub_ovcy_.vhd \
          mc8051/addsub_ovcy_rtl.vhd \
          mc8051/addsub_ovcy_rtl_cfg.vhd \
          mc8051/addsub_core_.vhd \
          mc8051/addsub_core_struc.vhd \
          mc8051/addsub_core_struc_cfg.vhd \
          mc8051/comb_divider_.vhd \
          mc8051/comb_divider_rtl.vhd \
          mc8051/comb_divider_rtl_cfg.vhd \
          mc8051/comb_mltplr_.vhd \
          mc8051/comb_mltplr_rtl.vhd \
          mc8051/comb_mltplr_rtl_cfg.vhd \
          mc8051/dcml_adjust_.vhd \
          mc8051/dcml_adjust_rtl.vhd \
          mc8051/dcml_adjust_rtl_cfg.vhd \
          mc8051/mc8051_alu_.vhd \
          mc8051/mc8051_alu_struc.vhd \
          mc8051/mc8051_alu_struc_cfg.vhd \
          mc8051/mc8051_siu_.vhd \
          mc8051/mc8051_siu_rtl.vhd \
          mc8051/mc8051_siu_rtl_cfg.vhd \
          mc8051/mc8051_tmrctr_.vhd \
          mc8051/mc8051_tmrctr_rtl.vhd \
          mc8051/mc8051_tmrctr_rtl_cfg.vhd \
          mc8051/mc8051_core_.vhd \
          mc8051/mc8051_core_struc.vhd \
          mc8051/mc8051_core_struc_cfg.vhd \
          mc8051/mc8051_top_.vhd \
          mc8051/mc8051_top_struc.vhd \
          mc8051/mc8051_top_struc_cfg.vhd \
          pll.vhd \
          fpga_top.vhd
VHDL_FILES = $(patsubst %,$(HDL)/%,$(VHDL_SRC))

all: $(BUILD)/$(PROJ).fs

# Firmware: C -> ihx -> hex -> mif (loaded into the ROM via $readmemb)
$(SW)/build/mc8051_rom.mif: $(SW)/src/main.c
	$(MAKE) -C $(SW) compile convert

sw: $(SW)/build/mc8051_rom.mif

$(BUILD):
	mkdir -p $(BUILD)

# Compile VHDL + synthesize with yosys (ROM/RAM are Verilog)
$(BUILD)/$(PROJ).json: $(VHDL_FILES) $(HDL)/mc8051_rom.v $(HDL)/mc8051_ram.v $(SW)/build/mc8051_rom.mif | $(BUILD)
	ghdl -a $(GHDL_ARGS) $(VHDL_FILES)
	yosys -m ghdl -p 'ghdl $(GHDL_ARGS) $(ENTITY); read_verilog $(HDL)/mc8051_rom.v $(HDL)/mc8051_ram.v; synth_gowin -top $(ENTITY) -json $@'

# Place & route
$(BUILD)/$(PROJ)_pnr.json: $(BUILD)/$(PROJ).json $(PIN_DEF)
	nextpnr-himbaechel --json $< --write $@ --device $(DEVICE) \
		--vopt family=$(FAMILY) --vopt cst=$(PIN_DEF) \
		--freq 20 --timing-allow-fail --report $(BUILD)/$(PROJ)_timing_report.json

# Bitstream
$(BUILD)/$(PROJ).fs: $(BUILD)/$(PROJ)_pnr.json
	gowin_pack -d $(FAMILY) -o $@ $<

flash: $(BUILD)/$(PROJ).fs
	openFPGALoader -b $(BOARD) $<

flash-ext: $(BUILD)/$(PROJ).fs
	openFPGALoader -b $(BOARD) -f $<

clean:
	rm -rf $(BUILD)
	$(MAKE) -C $(SW) clean

.PHONY: all sw flash flash-ext clean
