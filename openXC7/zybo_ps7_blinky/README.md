# zybo_ps7_blinky — quick reference

Zybo Z7-20 (Zynq-7020): the ARM Cortex-A9 core (not just PL fabric logic)
drives the LEDs, over an AXI-Lite peripheral in the FPGA fabric. Full
details, pinout, and background in [`doc/README.md`](doc/README.md).

One-time setup, either flow:
```bash
source ~/oss-cad-suite/environment   # yosys, ghdl, openocd, openFPGALoader
source /opt/openxc7/export.sh        # nextpnr-xilinx, prjxray tools
make bitstream                       # -> build/ps7_axi_blinky.bit
make software                        # -> build/BOOT.BIN + ARM toolchain/embeddedsw
```

## Flow A: fast iteration (JTAG, no SD card)

Use this while developing -- seconds per cycle, nothing written to any
storage.

1. **JP5 -> JTAG**, board powered on, USB cable connected
2. Open a serial terminal on the board's UART (115200 8N1) **before**
   the next step -- first prints fire the instant the core resumes and
   can't be replayed if you connect late. (Which `/dev/ttyUSB*` is the
   UART can shift between runs -- try the other one if you see nothing.)
3. `make jtag-run`

This halts CPU0, hand-runs PS7 init via JTAG, loads the bitstream, loads
`hello-world.elf` into memory, and jumps to it. Edit code, rebuild
(`make software` for the ELF, `make bitstream` for HDL changes), rerun
`make jtag-run`. Power-cycle the board between runs for a clean state --
rerunning PS7 init on top of an already-running system works but isn't
guaranteed to.

## Flow B: bootable image (production / no computer attached)

Use this once something is ready to leave running on its own.

**SD card:**
1. Copy `build/BOOT.BIN` to a FAT32 SD card
2. **JP5 -> SD**, insert card, power-cycle

**QSPI flash (fully standalone, no SD card either):**
1. `make qspi-flash-writer` -> `build/qspi_flash_writer.BOOT.BIN`
2. On a FAT32 SD card: `build/qspi_flash_writer.BOOT.BIN` -> save as
   `BOOT.BIN`, and `build/BOOT.BIN` -> save as `TARGET.BIN` (both on the
   card at once)
3. **JP5 -> SD**, power-cycle, watch the serial console for `DONE`
4. Power off, **JP5 -> QSPI**, power back on -- the SD card is no longer
   needed at all
