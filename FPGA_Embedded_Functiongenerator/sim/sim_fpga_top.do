vsim -t ns -novopt -lib work work.tb_fpga_top
view *
do fpga_top_wave.do
run 1 ms
