#!/usr/bin/env bash
#
# Fast JTAG debug-run: no SD card, no FSBL, no BOOT.BIN. Halts CPU0, runs
# PS7 clock/MIO/peripherals init by hand (same authoritative register
# data as the FSBL, translated to Tcl -- see gen_ps7_init_tcl.py),
# loads the bitstream via openFPGALoader, enables the PS-PL level
# shifters, then loads an ELF straight into memory and jumps to it.
#
# Open your serial terminal (115200 8N1) BEFORE running this: the app's
# first prints fire the instant the core resumes, and already-transmitted
# UART bytes can't be replayed if you connect late.
#
# Usage: tools/jtag_run.sh [path/to/app.elf]
#   (defaults to the AXI_TEST hello-world.elf built by sw/build.sh)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

BIT=build/ps7_axi_blinky.bit
ELF=${1:-sw/embeddedsw/lib/sw_apps/hello_world/src/hello-world.elf}
OCDCFG=tools/openocd_zybo_z7_20.cfg
PS7INIT=tools/ps7_init_jtag.tcl
ARM_TOOLCHAIN_DIR=sw/arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-eabi

[ -f "$BIT" ] || { echo "error: $BIT not found -- run 'make bitstream' first" >&2; exit 1; }
[ -f "$ELF" ] || { echo "error: $ELF not found -- run 'make software' first" >&2; exit 1; }
command -v openocd >/dev/null || { echo "error: openocd not found -- source ~/oss-cad-suite/environment" >&2; exit 1; }
command -v openFPGALoader >/dev/null || { echo "error: openFPGALoader not found -- source ~/oss-cad-suite/environment" >&2; exit 1; }
[ -x "$ARM_TOOLCHAIN_DIR/bin/arm-none-eabi-readelf" ] || { echo "error: ARM toolchain not found -- run 'sw/build.sh' first" >&2; exit 1; }
export PATH="$PROJECT_DIR/$ARM_TOOLCHAIN_DIR/bin:$PATH"

# Regenerate from the authoritative source (tools/zybo_z7_20_bsp/ps7_init.c)
# every run, so this can never silently drift out of sync with it.
python3 tools/gen_ps7_init_tcl.py tools/zybo_z7_20_bsp/ps7_init.c > "$PS7INIT"

ENTRY=$(arm-none-eabi-readelf -h "$ELF" | awk '/Entry point/{print $NF}')
echo "==> ELF entry point: $ENTRY"

echo "==> Step 1/3: halting CPU0, running PS7 MIO/PLL/clock/peripherals init via JTAG"
openocd -f "$OCDCFG" -c "init" \
	-c "targets zynq.cpu0" \
	-c "halt" \
	-c "source [find $PS7INIT]" \
	-c "ps7_mio_pll_clock_init" \
	-c "shutdown"

# openFPGALoader needs the JTAG bus exclusively -- OpenOCD must not be
# holding it open at the same time.
echo "==> Step 2/3: loading bitstream ($BIT) via JTAG"
openFPGALoader --board zybo_z7_20 --bitstream "$BIT"

echo "==> Step 3/3: enabling PS-PL level shifters, loading $ELF, starting CPU0"
echo "    (check your serial terminal now)"
openocd -f "$OCDCFG" -c "init" \
	-c "targets zynq.cpu0" \
	-c "source [find $PS7INIT]" \
	-c "ps7_post_config" \
	-c "load_image $ELF" \
	-c "reg pc $ENTRY" \
	-c "resume" \
	-c "shutdown"

echo
echo "==> Running. Ctrl-C the board's power or JTAG cable won't stop it --"
echo "power-cycle (JP5 still on JTAG) to reset, or re-run this script to reload."
