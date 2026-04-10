import os
import re
import sys

# --------------------------
# Configuration
# --------------------------
SEARCH_DIR = "build"
OUT_DIR = os.path.join("..", "hdl")
OUT_FILE = os.path.join(OUT_DIR, "rom_init_pkg.vhd")

# --------------------------
# Parsing functions
# --------------------------

def parse_mif(lines):
    """Parse .mif file; detect if each line is binary or hex"""
    data = []
    for x in lines:
        x = x.strip()
        if not x:
            continue
        # detect binary line (only 0 or 1)
        if all(c in "01" for c in x):
            val = int(x, 2) & 0xFF
        else:
            val = int(x, 16) & 0xFF
        data.append(val)
    return data

def parse_mem(lines):
    """Parse .mem file (hex values, '@' optional address)"""
    data = []
    for line in lines:
        line = line.strip()
        if not line:
            continue
        if line.startswith('@'):
            parts = line.split()
            if len(parts) > 1:
                val = int(parts[1], 16) & 0xFF
                data.append(val)
        else:
            val = int(line, 16) & 0xFF
            data.append(val)
    return data

def parse_hex(lines):
    """Parse Intel HEX file"""
    data = []
    for line in lines:
        if not line.startswith(':'):
            continue
        byte_count = int(line[1:3], 16)
        record_type = int(line[7:9], 16)
        if record_type == 0:  # data record
            for i in range(byte_count):
                b = int(line[9+2*i:11+2*i], 16) & 0xFF
                data.append(b)
    return data

def parse_coe(lines):
    """Parse .coe file (usually binary)"""
    data = []
    for line in lines:
        if line.strip().startswith("memory_initialization_vector"):
            continue
        for part in re.split(r'[,;]', line):
            if part.strip():
                val = int(part.strip(), 2) & 0xFF
                data.append(val)
    return data

# --------------------------
# Helper functions
# --------------------------

def detect_and_parse(path):
    with open(path, "r") as f:
        lines = f.readlines()
    if path.endswith(".mif"):
        return parse_mif(lines)
    elif path.endswith(".mem"):
        return parse_mem(lines)
    elif path.endswith(".hex"):
        return parse_hex(lines)
    elif path.endswith(".coe"):
        return parse_coe(lines)
    else:
        raise ValueError("Unknown file extension: " + path)

def format_value(val, mode):
    if mode == "hex":
        return f'x"{val:02X}"'
    else:  # binary (default)
        return f'"{val:08b}"'

def write_vhdl_package(data, out_file, mode="binary"):
    os.makedirs(os.path.dirname(out_file), exist_ok=True)
    with open(out_file, "w") as f:
        f.write("library ieee;\n")
        f.write("use ieee.std_logic_1164.all;\n")
        f.write("use ieee.numeric_std.all;\n\n")
        f.write("package rom_init_pkg is\n")
        f.write("  type rom_t is array (0 to {}) of std_logic_vector(7 downto 0);\n".format(len(data)-1))
        f.write("  constant ROM : rom_t := (\n")
        for i, val in enumerate(data):
            f.write(f"    {i} => {format_value(val, mode)}")
            if i < len(data)-1:
                f.write(",\n")
            else:
                f.write("\n")
        f.write("  );\n")
        f.write("end package;\n")

# --------------------------
# Main
# --------------------------

def main():
    # CLI arg handling
    mode = "binary"
    if "-h" in sys.argv:
        mode = "hex"
    elif "-b" in sys.argv:
        mode = "binary"

    # Priority order
    exts = [".mif", ".mem", ".hex", ".coe"]

    # --------------------------
    # Find ROM init file (skip *quartus* files)
    # --------------------------
    found_file = None
    for ext in exts:
        for fname in os.listdir(SEARCH_DIR):
            if "quartus" in fname.lower():
                continue
            if fname.endswith(ext):
                found_file = os.path.join(SEARCH_DIR, fname)
                break
        if found_file:
            break

    if not found_file:
        print("No ROM init file found in ./build/ (ignoring '*quartus*' files)")
        sys.exit(1)

    print(f"Using {found_file} → output format: {mode}")
    data = detect_and_parse(found_file)
    write_vhdl_package(data, OUT_FILE, mode)
    print(f"ROM package written to {OUT_FILE} with {len(data)} entries")

if __name__ == "__main__":
    main()
