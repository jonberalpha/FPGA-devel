# ---------------------------------------------------------------------------
# Basys3 (Artix-7 xc7a35tcpg236-1) -- blinky, Verilog
# ---------------------------------------------------------------------------

PROJECT    = blinky
TOP_MODULE = blinky
FAMILY     = artix7
PART       = xc7a35tcpg236-1
BOARD      = basys3

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

.PHONY: all program sim clean pnrclean check-tools check-prog-tools

all: check-tools $(BUILD_DIR)/$(PROJECT).bit

check-tools:
	@for t in $(REQUIRED_TOOLS); do \
		command -v $$t >/dev/null 2>&1 || { \
			echo "error: '$$t' not found on PATH. Run:"; \
			echo "  source ~/oss-cad-suite/environment"; \
			echo "  source /opt/openxc7/export.sh"; \
			exit 1; \
		}; \
	done

check-prog-tools:
	@command -v openFPGALoader >/dev/null 2>&1 || { \
		echo "error: 'openFPGALoader' not found on PATH. Run:"; \
		echo "  source ~/oss-cad-suite/environment"; \
		exit 1; \
	}

$(BUILD_DIR):
	mkdir -p $@

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

program: check-prog-tools $(BUILD_DIR)/$(PROJECT).bit
	openFPGALoader --board $(BOARD) --bitstream $(BUILD_DIR)/$(PROJECT).bit

sim: | $(BUILD_DIR)
	iverilog -o $(BUILD_DIR)/sim.vvp $(TOP_SRC) sim/tb_$(PROJECT).v
	vvp $(BUILD_DIR)/sim.vvp

clean:
	rm -rf $(BUILD_DIR)

pnrclean: clean
