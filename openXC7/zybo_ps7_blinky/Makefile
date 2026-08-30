# ---------------------------------------------------------------------------
# Zybo Z7-20 (Zynq-7020 xc7z020clg400-1) -- PS7 (ARM Cortex-A9) + AXI-GPIO
#
# Unlike the other zybo_*/basys3_* examples, this one boots software on the
# ARM core (not just PL fabric logic): a bare-metal ELF writes to a custom
# AXI-Lite GPIO peripheral over the PS7's M_AXI_GP0 bus to blink the LEDs.
# Boots from an SD card (BOOT.BIN), not JTAG -- see doc/README.md.
# ---------------------------------------------------------------------------

PROJECT    = ps7_axi_blinky
TOP_MODULE = ps7_axi_blinky
FAMILY     = zynq7
PART       = xc7z020clg400-1
BOARD      = zybo_z7_20

HDL_DIR    = hdl
XDC_DIR    = xdc
TOOLS_DIR  = tools
BUILD_DIR  = build

TOP_SRC    = $(HDL_DIR)/$(PROJECT).v
XDC        = $(XDC_DIR)/$(PROJECT).xdc
CHIPDB_DIR = $(TOOLS_DIR)/chipdb

NEXTPNR_XILINX_PYTHON_DIR ?= /opt/openxc7/lib/python
PRJXRAY_DB_DIR            ?= /opt/openxc7/share/nextpnr/prjxray-db
PYPY3 ?= python3

DBPART = $(shell echo $(PART) | sed -e 's/-[0-9]//g')

REQUIRED_TOOLS = yosys nextpnr-xilinx fasm2frames xc7frames2bit bbasm

# Remove partial/truncated targets left behind by a failed recipe, so the
# next `make` rebuilds them instead of feeding a broken file forward.
.DELETE_ON_ERROR:

.PHONY: all bitstream software qspi-flash-writer jtag-run clean pnrclean check-tools

all: bitstream software

check-tools:
	@for t in $(REQUIRED_TOOLS); do \
		command -v $$t >/dev/null 2>&1 || { \
			echo "error: '$$t' not found on PATH. Run:"; \
			echo "  source ~/oss-cad-suite/environment"; \
			echo "  source /opt/openxc7/export.sh"; \
			exit 1; \
		}; \
	done

$(BUILD_DIR):
	mkdir -p $@

bitstream: check-tools $(BUILD_DIR)/$(PROJECT).bit

$(BUILD_DIR)/$(PROJECT).json: $(TOP_SRC) | $(BUILD_DIR)
	yosys -p "synth_xilinx -flatten -abc9 -arch xc7 -top $(TOP_MODULE); write_json $@" $<

$(CHIPDB_DIR)/$(DBPART).bin:
	mkdir -p $(CHIPDB_DIR)
	$(PYPY3) $(NEXTPNR_XILINX_PYTHON_DIR)/bbaexport.py --device $(PART) --bba $(DBPART).bba
	bbasm -l $(DBPART).bba $@
	rm -f $(DBPART).bba

$(BUILD_DIR)/$(PROJECT).fasm: $(BUILD_DIR)/$(PROJECT).json $(CHIPDB_DIR)/$(DBPART).bin $(XDC) | $(BUILD_DIR)
	nextpnr-xilinx --chipdb $(CHIPDB_DIR)/$(DBPART).bin --xdc $(XDC) --json $(BUILD_DIR)/$(PROJECT).json --fasm $@

$(BUILD_DIR)/$(PROJECT).frames: $(BUILD_DIR)/$(PROJECT).fasm
	fasm2frames --part $(PART) --db-root $(PRJXRAY_DB_DIR)/$(FAMILY) $< > $@

$(BUILD_DIR)/$(PROJECT).bit: $(BUILD_DIR)/$(PROJECT).frames
	xc7frames2bit --part_file $(PRJXRAY_DB_DIR)/$(FAMILY)/$(PART)/part.yaml --part_name $(PART) --frm_file $< --output_file $@

# Builds FSBL + hello-world.elf (ARM Cortex-A9 side) and packages BOOT.BIN
# alongside the bitstream. Needs the bitstream built first.
software: $(BUILD_DIR)/$(PROJECT).bit
	sw/build.sh

# Optional: a one-time QSPI-flash-writer BOOT.BIN, so the board can boot
# standalone from QSPI afterward instead of needing an SD card. Needs
# `make software` run first (reuses its FSBL/toolchain). See doc/README.md.
qspi-flash-writer:
	sw/build-qspi-flash-writer.sh

# Fast development loop: no SD card, no FSBL, no BOOT.BIN -- halts CPU0
# over JTAG, hand-runs PS7 init, loads the bitstream (openFPGALoader) and
# an ELF, and jumps to it. Open your serial terminal BEFORE running this
# (see doc/README.md). Needs `make bitstream` and `make software` first.
# Set JP5 to JTAG (not SD/QSPI) for this.
jtag-run: $(BUILD_DIR)/$(PROJECT).bit
	tools/jtag_run.sh

clean:
	rm -rf $(BUILD_DIR)

pnrclean: clean
