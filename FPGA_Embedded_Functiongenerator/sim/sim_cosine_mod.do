vsim -t ns -novopt -lib work work.tb_cosine_mod
view *
do cosine_mod_wave.do
run 56 us
