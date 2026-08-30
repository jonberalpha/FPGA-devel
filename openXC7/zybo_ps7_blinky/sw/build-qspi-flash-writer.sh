#!/usr/bin/env bash
#
# Builds a one-time QSPI-flash-writer BOOT.BIN. It boots via SD (or JTAG),
# reads TARGET.BIN from the SD card's FAT filesystem, and writes it into
# the Zybo Z7-20's onboard QSPI flash -- after which the board can boot
# standalone from QSPI (JP5 -> QSPI), no SD card needed.
#
# Run `sw/build.sh` first (needed for the ARM toolchain, embeddedsw clone,
# and fsbl.elf, all reused here unchanged).
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BOARD=zybo_z7_20
ARM_TOOLCHAIN_DIR=arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-eabi

cd "$SCRIPT_DIR"

if [ ! -x "$ARM_TOOLCHAIN_DIR/bin/arm-none-eabi-gcc" ] || [ ! -d embeddedsw ] || \
   [ ! -f embeddedsw/lib/sw_apps/zynq_fsbl/src/fsbl.elf ] || [ ! -d zynq-mkbootimage ]; then
	echo "error: run sw/build.sh first (need the toolchain, embeddedsw, fsbl.elf, zynq-mkbootimage)" >&2
	exit 1
fi
export PATH="$SCRIPT_DIR/$ARM_TOOLCHAIN_DIR/bin:$PATH"
MAKE_SH="make SHELL=$(command -v bash)"

echo "==> Installing qspi_flash_writer app sources"
APP_DIR="embeddedsw/lib/sw_apps/qspi_flash_writer/src"
mkdir -p "$APP_DIR"
cp "$PROJECT_DIR/tools/qspi_flash_writer/"* "$APP_DIR/"

# The shared BSP library (libxil.a, holding XilFFs/XQspiPs/etc.) is built
# by the FSBL's own Makefile with a hardcoded "-O2 -c" and no
# function/data-sections -- too large in combination with this app's
# needs to fit ps7_ram_1 (see comment in tools/qspi_flash_writer/Makefile).
# Patch it to match, idempotently.
FSBL_MK="embeddedsw/lib/sw_apps/zynq_fsbl/src/Makefile"
if ! grep -q -- '-ffunction-sections' "$FSBL_MK"; then
	echo "==> Patching FSBL Makefile's BSP build flags for size"
	sed -i 's/"C_FLAGS=-O2 -c"/"C_FLAGS=-Os -c -ffunction-sections -fdata-sections"/' "$FSBL_MK"
fi
# The above C_FLAGS never actually reaches the individual per-driver
# compiles: this second, auto-generated makefile (Xilinx HSM output)
# hardcodes its own "-O2 -c" directly in its recipes instead of using a
# variable, so e.g. xil_cache.c/xil_util.c compile as one monolithic
# .text block each regardless of the FSBL Makefile's C_FLAGS -- meaning
# --gc-sections (Makefile) can't discard their unused functions. Verified
# by hand-compiling xil_cache.c with the intended flags directly: it
# properly splits into per-function .text.* sections then. Patch this
# makefile too, idempotently.
MISC_MK="embeddedsw/lib/sw_apps/zynq_fsbl/misc/makefile"
if ! grep -q -- '-ffunction-sections' "$MISC_MK"; then
	echo "==> Patching misc/makefile's hardcoded per-driver build flags for size"
	sed -i 's/"COMPILER_FLAGS=  -O2 -c"/"COMPILER_FLAGS=  -Os -c -ffunction-sections -fdata-sections"/' "$MISC_MK"
fi

# Runs from the same ~63.5KB ps7_ram_1 OCM bank the main demo's app uses
# (see tools/qspi_flash_writer/lscript.ld) and boots via the same proven
# NODDR fsbl.elf already built by sw/build.sh. An earlier version of this
# ran from DDR with its own DDR-initializing FSBL to sidestep the tight
# OCM budget, but that hung completely on real hardware during DDR
# calibration with zero UART output -- DDR bring-up without a JTAG
# debugger is too risky to chase blind, so this stays OCM-only instead,
# trimmed hard enough on both code (xparameters.h: FatFs read-only, no
# LFN) and stack/heap sizing (lscript.ld) to fit.
# qspi_flash_writer.c never calls f_lseek/f_stat/opendir/etc (sequential
# f_read only), so FatFs's most aggressive size-reduction level is safe.
# Not exposed via a FILE_SYSTEM_* xparameters.h hook like the other
# options (see there), so patch ffconf.h directly, idempotently.
FFCONF="embeddedsw/lib/sw_services/xilffs/src/include/ffconf.h"
if grep -q '^#define FF_FS_MINIMIZE	0$' "$FFCONF"; then
	echo "==> Patching ffconf.h: FF_FS_MINIMIZE 0 -> 3"
	sed -i 's/^#define FF_FS_MINIMIZE\t0$/#define FF_FS_MINIMIZE\t3/' "$FFCONF"
fi
# 932 (Shift-JIS) pulls in sizable multi-byte conversion tables; our
# filenames (BOOT.BIN/TARGET.BIN) are plain ASCII, so 437 (US) is enough
# and has a much smaller table.
if grep -q '^#define FF_CODE_PAGE	932$' "$FFCONF"; then
	echo "==> Patching ffconf.h: FF_CODE_PAGE 932 -> 437"
	sed -i 's/^#define FF_CODE_PAGE\t932$/#define FF_CODE_PAGE\t437/' "$FFCONF"
fi

echo "==> Building qspi-flash-writer.elf"
$MAKE_SH -C "$APP_DIR" clean
$MAKE_SH BOARD=$BOARD -C "$APP_DIR"

echo "==> Packaging qspi_flash_writer BOOT.BIN (no bitstream -- not needed to flash)"
cat > output_qspi_flash_writer.bif << EOF
the_ROM_image:
{
	[bootloader]embeddedsw/lib/sw_apps/zynq_fsbl/src/fsbl.elf
	$APP_DIR/qspi-flash-writer.elf
}
EOF
./zynq-mkbootimage/mkbootimage output_qspi_flash_writer.bif \
	"$PROJECT_DIR/build/qspi_flash_writer.BOOT.BIN"

echo
echo "==> Done: $PROJECT_DIR/build/qspi_flash_writer.BOOT.BIN"
echo "On a FAT32 SD card, place BOTH:"
echo "  build/qspi_flash_writer.BOOT.BIN  -> copy to the SD card as BOOT.BIN"
echo "  build/BOOT.BIN                    -> copy to the SD card as TARGET.BIN"
echo "Boot with JP5 on SD as usual; watch the serial console (115200 8N1)."
echo "Once it prints DONE, power off, set JP5 to QSPI, and power back on --"
echo "the SD card is no longer needed."
