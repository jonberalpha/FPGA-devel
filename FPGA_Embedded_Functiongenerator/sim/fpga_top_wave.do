onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_fpga_top/rst_i
add wave -noupdate -format Logic /tb_fpga_top/clk_i
#add wave -noupdate -format Logic /tb_fpga_top/pb_i
add wave -noupdate -format Logic /tb_fpga_top/rotenc_i
add wave -noupdate -format Logic /tb_fpga_top/led_o
add wave -noupdate -hex /tb_fpga_top/ss_o
add wave -noupdate -format Logic /tb_fpga_top/ss_sel_o
add wave -noupdate -unsigned -format Analog-Step -height 40 -max 256 /tb_fpga_top/signal_o
add wave -noupdate -radix signed -format Analog-Step -height 40 -max 256 /tb_fpga_top/i_fpga_top/i_func_mod_top/ramp_i
add wave -noupdate -radix signed -format Analog-Step -height 40 -max 256 /tb_fpga_top/i_fpga_top/i_func_mod_top/s_ramp_fall
add wave -noupdate -radix signed -format Analog-Step -height 40 -max 256 /tb_fpga_top/i_fpga_top/i_func_mod_top/s_rect_50
add wave -noupdate -radix signed -format Analog-Step -height 40 -max 256 /tb_fpga_top/i_fpga_top/i_func_mod_top/s_rect_var
add wave -noupdate -radix signed -format Analog-Step -height 40 -max 256 /tb_fpga_top/i_fpga_top/i_func_mod_top/s_cosine
add wave -noupdate -radix signed -format Analog-Step -height 40 -max 256 /tb_fpga_top/i_fpga_top/i_func_mod_top/s_tri
add wave -noupdate -radix signed -format Analog-Step -height 40 -max 256 /tb_fpga_top/i_fpga_top/i_func_mod_top/s_pn
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {0 ps}
WaveRestoreZoom {0 ps} {1 ns}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -signalnamewidth 0
configure wave -justifyvalue left
