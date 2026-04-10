ENTITY=fpga_top
HDL_CODE := ./hdl
PROJ := fpga_top

build:
	# Analyse MMI-Files
	ghdl -a $(HDL_CODE)/MMI/attr_reg.vhd
	ghdl -a $(HDL_CODE)/MMI/attr_sel.vhd
	ghdl -a $(HDL_CODE)/MMI/debounce.vhd
	ghdl -a $(HDL_CODE)/MMI/rotary_encoder.vhd
	ghdl -a $(HDL_CODE)/MMI/io_ctrl.vhd
	ghdl -a $(HDL_CODE)/MMI/mmi_pkg.vhd
	ghdl -a $(HDL_CODE)/MMI/mmi_top.vhd
	# Compile FuncMod-Files
	ghdl -a $(HDL_CODE)/FuncMod/cosine_mod.vhd
	ghdl -a $(HDL_CODE)/FuncMod/ramp_fall_mod.vhd
	ghdl -a $(HDL_CODE)/FuncMod/rect_50_mod.vhd
	ghdl -a $(HDL_CODE)/FuncMod/rect_var_mod.vhd
	ghdl -a $(HDL_CODE)/FuncMod/shape_mux.vhd
	ghdl -a $(HDL_CODE)/FuncMod/tri_mod.vhd
	ghdl -a $(HDL_CODE)/FuncMod/pn_gen.vhd
	ghdl -a $(HDL_CODE)/FuncMod/func_mod_pkg.vhd
	ghdl -a $(HDL_CODE)/FuncMod/func_mod_top.vhd
	# Compile RampGen-Files
	ghdl -a $(HDL_CODE)/ramp_gen.vhd
	ghdl -a $(HDL_CODE)/phase_shift.vhd
	ghdl -a $(HDL_CODE)/attn_apply.vhd
	# Compile FPGATop-Files
	ghdl -a $(HDL_CODE)/fpga_top_pkg.vhd
	ghdl -a $(HDL_CODE)/fpga_top.vhd

	# Synthesize the design.
	# NOTE: if GHDL is built as a module, set MODULE to '-m ghdl' or '-m path/to/ghdl.so',
	#       otherwise, unset it.
	yosys -p 'ghdl $(PROJ); synth_ice40 -json $(PROJ).json'

	# Place & Route
	nextpnr-ice40 --lp1k --package cm36 --pcf io.pcf --asc $(PROJ).asc --json $(PROJ).json

	# Generate bitstream
	icepack $(PROJ).asc $(PROJ).bin

# all in one
# yosys $MODULE -p 'ghdl leds.vhdl spin1.vhdl -e leds; synth_ice40 -json leds.json'
viewpnr:
	nextpnr-ice40 --lp1k --package cm36 --pcf io.pcf --asc $(PROJ).asc --json $(PROJ).json -v --gui
	# assign Timing not working

svgjson:
	yosys -p "ghdl $(ENTITY); prep -top $(ENTITY); write_json -compat-int svg.json";

svgimg:
	mkdir svg
	netlistsvg svg.json -o svg/$(ENTITY).svg;

flash:
	# Program FPGA; set clk 72MHz
	icesprog -c 4
	icesprog $(PROJ).bin

clean:
	rm -rf *.asc *.json *.bin

