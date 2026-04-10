vsim -t ns -novopt -lib work work.tb_attr_reg
view *
do attr_reg_wave.do
run 10 ms
