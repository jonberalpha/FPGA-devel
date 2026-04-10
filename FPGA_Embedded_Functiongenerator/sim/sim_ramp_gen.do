vsim -t ns -novopt -lib work work.tb_ramp_gen
view *
do ramp_gen_wave.do
run 100 us
