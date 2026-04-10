# Compile MMI-Files
vcom ../hdl/MMI/attr_disp_sel.vhd
vcom ../hdl/MMI/attr_reg.vhd
vcom ../hdl/MMI/attr_sel.vhd
vcom ../hdl/MMI/debounce.vhd
vcom ../hdl/MMI/rotary_encoder.vhd
vcom ../hdl/MMI/io_ctrl.vhd

vcom ../hdl/MMI/mmi_pkg.vhd
vcom ../hdl/MMI/mmi_top.vhd

# Compile FuncMod-Files
vcom ../hdl/FuncMod/cosine_mod.vhd
vcom ../hdl/FuncMod/ramp_fall_mod.vhd
vcom ../hdl/FuncMod/rect_50_mod.vhd
vcom ../hdl/FuncMod/rect_var_mod.vhd
vcom ../hdl/FuncMod/shape_mux.vhd
vcom ../hdl/FuncMod/tri_mod.vhd
#vcom ../hdl/FuncMod/pn_mod.vhd
vcom ../hdl/FuncMod/pn_gen.vhd

vcom ../hdl/FuncMod/func_mod_pkg.vhd
vcom ../hdl/FuncMod/func_mod_top.vhd

# Compile RampGen-Files
vcom ../hdl/ramp_gen.vhd
vcom ../hdl/phase_shift.vhd
vcom ../hdl/attn_apply.vhd

# Compile FPGATop-Files
vcom ../hdl/fpga_top_pkg.vhd
vcom ../hdl/fpga_top.vhd

# Compile Testbenches
vcom ../tb/tb_fpga_top.vhd
vcom ../tb/tb_attr_reg.vhd
vcom ../tb/tb_attr_sel.vhd
vcom ../tb/tb_cosine_mod.vhd
vcom ../tb/tb_ramp_gen.vhd
vcom ../tb/tb_rect_var_mod.vhd
