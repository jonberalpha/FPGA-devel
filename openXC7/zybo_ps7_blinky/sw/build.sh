#!/usr/bin/env bash
#
# Builds BOOT.BIN for the Zybo Z7-20 PS7+AXI-GPIO demo:
#   FSBL (runs on ARM Cortex-A9 core 0) + hello-world.elf (AXI_TEST build,
#   pokes the PL-side AXI-GPIO peripheral to blink LEDs) + the PL bitstream.
#
# Unlike the upstream openXC7 demo-projects reference
# (ps7-blinky-digilent-pynqz1/genz_setup.sh), this does NOT run GenZ to
# generate ps7_init.c: GenZ has no Zybo Z7-20 preset, and hand-deriving
# its MIO_PIN description table from scratch would be error-prone. Instead
# ../tools/zybo_z7_20_bsp/ps7_init.c was assembled directly from Xilinx's
# own Vivado-generated PS7 register data for "the Zybo-z7-20 board"
# (sourced from u-boot's board/xilinx/zynq/zynq-zybo-z7/ps7_init_gpl.c,
# which documents exactly that provenance), spliced into the FSBL's own
# zc702 ps7_init.c template (same Zynq-7020 silicon, so generic helper
# functions are identical). Real hardware is always silicon version 3, so
# the template's silicon-version-1/2 PLL/clock/DDR/MIO/peripherals tables
# were deleted outright rather than just left unused: they're several
# hundred KB of dead .rodata that overflowed the FSBL's on-chip-RAM
# region. ps7_ddr_init_data_3_0 was also trimmed to a no-op -- this
# design has no DDR-backed code/data (NODDR, below).
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BOARD=zybo_z7_20

EMBEDDEDSW_COMMIT=01914be60c881f67799fdb55ce9af8b8a0c1a9e3
MKBOOTIMAGE_COMMIT=a44afe3b65aa7d7c293dfde6452c1a9ec96f50e0
ARM_TOOLCHAIN_URL=https://developer.arm.com/-/media/Files/downloads/gnu/14.2.rel1/binrel/arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-eabi.tar.xz
ARM_TOOLCHAIN_DIR=arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-eabi

cd "$SCRIPT_DIR"

# --- System dependency for zynq-mkbootimage ------------------------------
dpkg -l libelf-dev 2>/dev/null | grep -q '^ii' || sudo apt install -y libelf-dev

# --- ARM bare-metal toolchain -------------------------------------------
# (the Ubuntu/Mint gcc-arm-none-eabi package is known to be incompatible
# with this BSP build -- see comment in the upstream reference script)
if [ ! -x "$ARM_TOOLCHAIN_DIR/bin/arm-none-eabi-gcc" ]; then
	echo "==> Downloading arm-none-eabi toolchain"
	wget -q "$ARM_TOOLCHAIN_URL"
	tar xf "$(basename "$ARM_TOOLCHAIN_URL")"
fi
export PATH="$SCRIPT_DIR/$ARM_TOOLCHAIN_DIR/bin:$PATH"

# --- embeddedsw (FSBL + hello_world + standalone BSP), pinned ----------
if [ ! -d embeddedsw ]; then
	echo "==> Cloning regymm/embeddedsw @ $EMBEDDEDSW_COMMIT"
	git clone https://github.com/regymm/embeddedsw
	git -C embeddedsw checkout "$EMBEDDEDSW_COMMIT"
fi

echo "==> Installing Zybo Z7-20 board support files"
mkdir -p "embeddedsw/lib/sw_apps/zynq_fsbl/misc/$BOARD"
cp "$PROJECT_DIR/tools/zybo_z7_20_bsp/"* "embeddedsw/lib/sw_apps/zynq_fsbl/misc/$BOARD/"

# The embeddedsw Makefiles use bash-only `[ x == y ]` test syntax in a few
# places, but `make` invokes recipes via /bin/sh, which is dash (no `==`)
# on Debian/Ubuntu -- that makes the BSP driver-library compile step
# silently no-op instead of erroring. Force bash as the recipe shell.
MAKE_SH="make SHELL=$(command -v bash)"

echo "==> Building hello-world.elf (AXI_TEST: pokes AXI-GPIO to blink LEDs)"
$MAKE_SH -C embeddedsw/lib/sw_apps/hello_world/src clean
$MAKE_SH BOARD=$BOARD "CFLAGS=-DAXI_TEST" -C embeddedsw/lib/sw_apps/hello_world/src

echo "==> Building FSBL (NODDR: this design has no DDR-backed code/data)"
$MAKE_SH -C embeddedsw/lib/sw_apps/zynq_fsbl/src clean
$MAKE_SH BOARD=$BOARD "CFLAGS=-DFSBL_DEBUG_INFO -DNODDR" -C embeddedsw/lib/sw_apps/zynq_fsbl/src

# --- zynq-mkbootimage (open bootgen replacement), pinned ----------------
if [ ! -d zynq-mkbootimage ]; then
	echo "==> Cloning antmicro/zynq-mkbootimage @ $MKBOOTIMAGE_COMMIT"
	git clone https://github.com/antmicro/zynq-mkbootimage
	git -C zynq-mkbootimage checkout "$MKBOOTIMAGE_COMMIT"
fi
make -C zynq-mkbootimage

# --- Bitstream must already be built (see ../Makefile) -------------------
BITSTREAM="$PROJECT_DIR/build/ps7_axi_blinky.bit"
if [ ! -f "$BITSTREAM" ]; then
	echo "error: $BITSTREAM not found -- run 'make bitstream' in $PROJECT_DIR first" >&2
	exit 1
fi

echo "==> Packaging BOOT.BIN"
cat > output.bif << EOF
the_ROM_image:
{
	[bootloader]embeddedsw/lib/sw_apps/zynq_fsbl/src/fsbl.elf
	$BITSTREAM
	embeddedsw/lib/sw_apps/hello_world/src/hello-world.elf
}
EOF
./zynq-mkbootimage/mkbootimage output.bif "$PROJECT_DIR/build/BOOT.BIN"

echo
echo "==> Done: $PROJECT_DIR/build/BOOT.BIN"
echo "Copy it to a FAT32-formatted SD card, insert it, set the Zybo Z7-20's"
echo "JP5 boot-mode jumper to SD, and power-cycle the board."
