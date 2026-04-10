vsim -t ns -novopt -lib work work.tb_rect_var_mod
view *
do rect_var_mod_wave.do
run 5.5 us
