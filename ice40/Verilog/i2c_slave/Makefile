proj = i2c_slave
top = i2cSlaveTop
files = i2cSlave_define.v timescale.v serialInterface.v registerInterface.v i2cSlave.v led.v i2cSlaveTop.v
pcf = io.pcf

build:
	yosys -p "synth_ice40 -top $(top) -json $(proj).json" $(files)
	nextpnr-ice40 --lp1k --package cm36 --json $(proj).json --pcf $(pcf) --asc $(proj).asc
	icepack $(proj).asc $(proj).bin

flash:
	icesprog $(proj).bin

clean:
	rm -rf *.asc *.json *.bin

