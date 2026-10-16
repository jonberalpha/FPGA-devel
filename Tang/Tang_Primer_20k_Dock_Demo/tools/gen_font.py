#!/usr/bin/env python3
"""Convert a Linux console PSF font (8x16) to hdl/font8x16.hex (256 glyphs x 16 rows, one byte per line)."""
import gzip, struct, sys

src = sys.argv[1] if len(sys.argv) > 1 else "/usr/share/consolefonts/Lat15-VGA16.psf.gz"
dst = sys.argv[2] if len(sys.argv) > 2 else "hdl/font8x16.hex"

data = gzip.open(src).read() if src.endswith(".gz") else open(src, "rb").read()
if data[:2] == b"\x36\x04":                 # PSF1
    charsize = data[3]
    off = 4
    assert charsize == 16, "need 8x16 font"
elif data[:4] == b"\x72\xb5\x4a\x86":       # PSF2
    _, _, hdr, _, nglyph, charsize, h, w = struct.unpack("<8I", data[:32])[0:8]
    off = hdr
    assert (h, w) == (16, 8), "need 8x16 font"
else:
    sys.exit("unknown PSF format")

glyphs = data[off:off + 256 * 16]
with open(dst, "w") as f:
    for b in glyphs:
        f.write("%02x\n" % b)
print("wrote", dst, len(glyphs), "bytes")
