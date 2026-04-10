onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_attr_reg/clk_i
add wave -noupdate -format Logic /tb_attr_reg/rst_i
add wave -noupdate -format Logic /tb_attr_reg/asel_edit_i
add wave -noupdate -format Logic /tb_attr_reg/sel_attr_i
add wave -noupdate -format Logic /tb_attr_reg/inc_i
add wave -noupdate -format Logic /tb_attr_reg/dec_i
add wave -noupdate -format Logic /tb_attr_reg/attr_value_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {0 ps}
WaveRestoreZoom {0 ps} {1 ns}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -signalnamewidth 0
configure wave -justifyvalue left
