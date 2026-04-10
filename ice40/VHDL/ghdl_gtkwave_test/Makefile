proj = full_adder

all: clean build simwave

build:
	ghdl -a $(proj).vhd
	ghdl -a tb_$(proj).vhd
	ghdl -e tb_$(proj)
	ghdl -r tb_$(proj) --vcd=$(proj).vcd
	ghdl -r tb_$(proj) --wave=$(proj).ghw

# also enumareted signals
simwave:
	gtkwave $(proj).ghw

# only port signals
simvcd:
	gtkwave $(proj).vcd

clean:
	rm -rf *.lst *.o *.cf *.vcd *.ghw

