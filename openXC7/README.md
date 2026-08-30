# openXC7 setup

## What this is

- `install-openxc7.sh` - single-file installer for the openXC7-specific
  toolchain pieces (`nextpnr-xilinx`, `prjxray`, `prjxray-db`), built
  from source into `/opt/openxc7`. Clones `openXC7/toolchain-installer`
  into a sibling folder on first run (not something you need to keep --
  see below), patches two known upstream build bugs, then builds.
- `basys3_blinky_verilog/`, `basys3_blinky_vhdl/`,
  `zybo_blinky_verilog/`, `zybo_blinky_vhdl/` - simple PL-only blinky
  examples, each a self-contained `doc/hdl/xdc/sim/sw/tools/Makefile`
  layout
- `zybo_ps7_blinky/` - uses the Zybo Z7-20's ARM Cortex-A9 core, not
  just the FPGA fabric; has its own `README.md` with three
  boot/programming flows (fast JTAG iteration, SD card, standalone QSPI)

`yosys`, `ghdl`, `iverilog`, and `openFPGALoader` are **not** built here
-- they come from an existing [oss-cad-suite](https://github.com/YosysHQ/oss-cad-suite-build)
install, reused as-is. Only the Xilinx-7-series-specific place&route/bitstream
tools are built locally, into their own prefix (`/opt/openxc7`), so this
never touches or conflicts with oss-cad-suite.

Nothing here is added to shell startup files. A fresh terminal (or a
reboot) always starts with neither oss-cad-suite nor these openXC7 tools
on `PATH` until you explicitly source them (see below).

## Setting this up on a new PC

Prerequisites: a Debian/Ubuntu-family Linux (apt-based, e.g. Mint), `git`,
and an existing `oss-cad-suite` install (e.g. at `~/oss-cad-suite`).

```bash
# 1. Copy just this one file onto the new machine
mkdir -p ~/Documents/openXC7
cp install-openxc7.sh ~/Documents/openXC7/
cd ~/Documents/openXC7

# 2. Run it. Clones toolchain-installer, patches two known upstream
#    build bugs (yosys's CMake-only build; prjxray's `pip install --user`
#    failing under PEP 668), then builds nextpnr-xilinx + prjxray.
#    Asks for your sudo password once (apt build-dependencies).
./install-openxc7.sh

# 3. Copy the project folders over too -- they're plain files, nothing
#    to install:
#      basys3_blinky_verilog/  basys3_blinky_vhdl/
#      zybo_blinky_verilog/    zybo_blinky_vhdl/  zybo_ps7_blinky/
```

That's the entire install. No manual patching or troubleshooting should
be needed. `toolchain-installer/` (cloned into this same directory by
step 2) isn't something you need to keep afterward -- it holds the
source checkouts the build compiled from, not anything the projects
depend on at runtime; deleting it just means a future rebuild re-clones
it fresh.

## Building a project

Every time you open a new terminal to build or flash:

```bash
source ~/oss-cad-suite/environment   # yosys, ghdl, iverilog, openFPGALoader, openocd
source /opt/openxc7/export.sh        # nextpnr-xilinx, prjxray tools, fasm2frames
```

Then, inside any project folder:

```bash
make          # synthesize + place&route + bitstream -> build/blinky.bit
make program  # flash to the board over USB-JTAG
make sim      # run the testbench
make clean    # remove build/ (keeps the cached chip database in tools/)
```

See each project's `doc/README.md` (and `zybo_ps7_blinky/README.md` for
its extra ARM-core-related flows) for board/pinout details.
