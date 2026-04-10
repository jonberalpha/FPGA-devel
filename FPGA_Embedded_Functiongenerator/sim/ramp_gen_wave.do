onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_ramp_gen/clk_i
add wave -noupdate -format Logic /tb_ramp_gen/rst_i
add wave -noupdate -format Logic /tb_ramp_gen/f_reg_i
add wave -noupdate -format Logic /tb_ramp_gen/tick_o
add wave -noupdate -radix signed -format Analog-Step -height 40 -max 256 /tb_ramp_gen/ramp_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {0 ps}
WaveRestoreZoom {0 ps} {1 ns}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -signalnamewidth 0
configure wave -justifyvalue left
