# basys3_blinky_verilog

Minimal blinking-LED example for the Digilent Basys3 board, in Verilog.

## Hardware

| | |
|---|---|
| Board  | Digilent Basys3 |
| FPGA   | Artix-7 `xc7a35tcpg236-1` |
| Clock  | `clk` -> pin W5, 100 MHz onboard oscillator |
| Output | `led` -> pin U16 (LD0) |

## Layout

- `hdl/`   - Verilog source (`blinky.v`)
- `xdc/`   - pin/IO constraints (`blinky.xdc`)
- `sim/`   - testbench for simulation only, not synthesized
- `sw/`    - unused in this example (would hold firmware sources for a
  soft/hard microcontroller such as an 8051, if this design had one)
- `tools/` - generated, cached chip-database used by nextpnr-xilinx
  (`tools/chipdb/`); created automatically on first build
- `build/` - generated bitstream build products; created automatically,
  safe to delete (`make clean`)

## One-time environment setup

```bash
source ~/oss-cad-suite/environment   # yosys, iverilog, openFPGALoader
source /opt/openxc7/export.sh        # nextpnr-xilinx, prjxray tools
```

## Usage

```bash
make          # synthesize + place&route + bitstream -> build/blinky.bit
make program  # flash it to the board over USB-JTAG
make sim      # run the testbench with icarus verilog
make clean    # remove build/ (keeps the cached chip database in tools/)
```
