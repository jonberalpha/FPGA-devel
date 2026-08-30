# zybo_blinky_verilog

Minimal blinking-LED example for the Digilent Zybo Z7-20 board, in Verilog.

## Hardware

| | |
|---|---|
| Board  | Digilent Zybo Z7-20 |
| FPGA   | Zynq-7020 `xc7z020clg400-1` |
| Clock  | `clk` -> pin K17, 125 MHz onboard oscillator |
| Output | `led` -> pin M14 (LD0) |

Pinout confirmed against Digilent's official `Zybo-Z7-Master.xdc`
(shared between the Z7-10 and Z7-20 variants).

Only the FPGA fabric is used here (PL side); the Zynq's ARM cores (PS
side) are not involved in this example.

`make program` loads the bitstream over JTAG straight into the PL's
volatile config SRAM -- it's gone on power-cycle. There's no persistent
(QSPI-flash) boot option for this example: the Zybo Z7-20's QSPI flash is
wired only to the Zynq's PS-side MIO pins, unreachable from JTAG/PL
boundary-scan for any design (confirmed directly: `openFPGALoader -f`
against this board fails with "can't flash non-volatile memory for
Zynq7000 devices -- SPI Flash access is only available from PS side").
Getting persistent boot would require a PS7 core and ARM-side flash-writer
software, like `zybo_ps7_blinky`'s `qspi-flash-writer` -- out of scope for
this pure-PL example.

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
