onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_rect_var_mod/clk_i
add wave -noupdate -format Logic /tb_rect_var_mod/phase_i
add wave -noupdate -format Logic /tb_rect_var_mod/dutycycle_i
add wave -noupdate -radix signed -format Analog-Step -height 40 -max 256 /tb_rect_var_mod/rect_var_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {0 ps}
WaveRestoreZoom {0 ps} {1 ns}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -signalnamewidth 0
configure wave -justifyvalue left
