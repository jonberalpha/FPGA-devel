ENTITY = fpga_top
PROJ   = fpga_top
HDL    = ../hdl
GHDL_ARGS   = -fsynopsys
PIN_DEF = ../pcf/ulx3s.lpf
PNRDEVICE = 85k
PNRPACKAGE = CABGA381

# Build target
build:
	# ---------------------------------------------------------
	# Compile mc8051 RAM and Program Code ROM
	# ---------------------------------------------------------
	#ghdl -a $(GHDL_ARGS) $(HDL)/rom_init_pkg.vhd
	#ghdl -a $(GHDL_ARGS) $(HDL)/mc8051_rom.vhd
	#ghdl -a $(GHDL_ARGS) $(HDL)/mc8051_ram.vhd

	# ---------------------------------------------------------
	# Compile mc8051 core hierarchy
	# ---------------------------------------------------------
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/mc8051_p.vhd

	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/control_mem_.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/control_mem_rtl.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/control_mem_rtl_cfg.vhd

	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/control_fsm_.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/control_fsm_rtl.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/control_fsm_rtl_cfg.vhd

	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/mc8051_control_.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/mc8051_control_struc.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/mc8051_control_struc_cfg.vhd

	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/alucore_.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/alucore_rtl.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/alucore_rtl_cfg.vhd

	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/alumux_.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/alumux_rtl.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/alumux_rtl_cfg.vhd

	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/addsub_cy_.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/addsub_cy_rtl.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/addsub_cy_rtl_cfg.vhd

	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/addsub_ovcy_.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/addsub_ovcy_rtl.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/addsub_ovcy_rtl_cfg.vhd

	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/addsub_core_.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/addsub_core_struc.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/addsub_core_struc_cfg.vhd

	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/comb_divider_.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/comb_divider_rtl.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/comb_divider_rtl_cfg.vhd

	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/comb_mltplr_.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/comb_mltplr_rtl.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/comb_mltplr_rtl_cfg.vhd

	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/dcml_adjust_.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/dcml_adjust_rtl.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/dcml_adjust_rtl_cfg.vhd

	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/mc8051_alu_.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/mc8051_alu_struc.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/mc8051_alu_struc_cfg.vhd

	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/mc8051_siu_.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/mc8051_siu_rtl.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/mc8051_siu_rtl_cfg.vhd

	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/mc8051_tmrctr_.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/mc8051_tmrctr_rtl.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/mc8051_tmrctr_rtl_cfg.vhd

	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/mc8051_core_.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/mc8051_core_struc.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/mc8051_core_struc_cfg.vhd

	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/mc8051_top_.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/mc8051_top_struc.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/mc8051/mc8051_top_struc_cfg.vhd

	# ---------------------------------------------------------
	# Compile FPGA top-level
	# ---------------------------------------------------------
	ghdl -a $(GHDL_ARGS) $(HDL)/pll.vhd
	ghdl -a $(GHDL_ARGS) $(HDL)/fpga_top.vhd

	########################

	# Synthesize with yosys
	yosys -m ghdl -p 'ghdl $(GHDL_ARGS) $(ENTITY); read_verilog $(HDL)/mc8051_rom.v $(HDL)/mc8051_ram.v; synth_ecp5 -top $(ENTITY) -json $(PROJ).json'

	# Clean compiled vhdl code
	rm -rf *.o

	# Place & Route + Timing Report
	nextpnr-ecp5 --seed 2 --$(PNRDEVICE) --package $(PNRPACKAGE) --json $(PROJ).json --textcfg $(PROJ).config --lpf $(PIN_DEF) -q --timing-allow-fail --freq 20 --report $(PROJ)_timing_report.txt

	# Generate bitstream
	ecppack $(PROJ).config $(PROJ).bit

viewpnr:
	nextpnr-ecp5 --$(PNRDEVICE) --package $(PNRPACKAGE)	--json $(PROJ).json --textcfg $(PROJ).config --lpf $(PIN_DEF) --gui

svgjson:
	yosys -m ghdl -p "ghdl $(GHDL_ARGS) $(ENTITY); prep -top $(ENTITY); write_json -compat-int svg.json"

svgimg: svgjson
	mkdir -p svg
	netlistsvg svg.json -o svg/$(ENTITY).svg

flash:
	fujprog $(PROJ).bit

clean:
	rm -rf *.config *.json *.bit *.o *.txt *.cf *.bin svg svg.json

.PHONY: all flash clean viewpnr svgjson svgimg

