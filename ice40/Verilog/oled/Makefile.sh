PROJECTNAME=oled
VERILOGS=$(PROJECTNAME).v SSD1351.v

#yosys -q -p "synth_ice40 -top $PROJECTNAME -json $PROJECTNAME.json" $VERILOGS || exit
#nextpnr-ice40 --force --json $PROJECTNAME.json --pcf $PROJECTNAME.pcf --asc $PROJECTNAME.asc --freq 12 --hx1k --package tq144 $1 || exit
#icetime -p $PROJECTNAME.pcf -P tq144 -r $PROJECTNAME.timings -d hx1k -t $PROJECTNAME.asc
#icepack $PROJECTNAME.asc $PROJECTNAME.bin || exit
#iceprog $PROJECTNAME.bin || exit
#echo DONE.

build:
	yosys -q -p "synth_ice40 -top $(PROJECTNAME) -json $(PROJECTNAME).json" $(VERILOGS)
	nextpnr-ice40 --lp1k --package cm36 --json $(PROJECTNAME).json --pcf $(PROJECTNAME).pcf --asc $(PROJECTNAME).asc
	icepack $(PROJECTNAME).asc $(PROJECTNAME).bin

flash:
	icesprog $(PROJECTNAME).bin

clean:
	rm -rf *.asc *.json *.bin


