#!/usr/bin/env bash
#
# openXC7 toolchain installer (build-from-source wrapper)
#
# Clones openXC7/toolchain-installer into this directory, then builds
# nextpnr-xilinx + prjxray + prjxray-db from source and installs them to
# /opt/openxc7 (isolated from any other toolchain, e.g. oss-cad-suite,
# since it uses its own prefix and is never added to your shell rc files
# automatically).
#
# yosys itself is NOT built here: it's plain upstream yosys with no
# openXC7-specific patches (the demo projects just call `synth_xilinx`),
# so if you already have a reasonably recent yosys (e.g. from oss-cad-suite)
# it can be reused as-is alongside these openXC7-specific tools.
#
# Usage:
#   ./install-openxc7.sh                # build+install nextpnr-xilinx + prjxray (default)
#   ./install-openxc7.sh nextpnr
#   ./install-openxc7.sh prjxray
#   ./install-openxc7.sh yosys          # only if you really want an openXC7-local yosys too
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER_REPO="$SCRIPT_DIR/toolchain-installer"
INSTALL_PREFIX=/opt/openxc7

echo "==> openXC7 toolchain installer"

if ! command -v apt >/dev/null 2>&1; then
	echo "Error: this script targets apt-based systems (Ubuntu/Mint). apt not found." >&2
	exit 1
fi

# --- Fetch/refresh the installer repo -----------------------------------
if [ -d "$INSTALLER_REPO/.git" ]; then
	if [ -z "$(git -C "$INSTALLER_REPO" status --porcelain)" ]; then
		echo "==> Updating existing toolchain-installer checkout"
		git -C "$INSTALLER_REPO" pull --ff-only
	else
		echo "==> toolchain-installer has local patches applied -- skipping pull"
	fi
else
	echo "==> Cloning openXC7/toolchain-installer"
	git clone https://github.com/openXC7/toolchain-installer.git "$INSTALLER_REPO"
fi

# --- Patch known upstream bugs on modern Debian/Ubuntu -------------------
# - yosys dropped its Makefile for a CMake-only build (recent releases)
# - prjxray's `pip install --user` hits PEP 668 externally-managed-environment
# Idempotent: safe to re-run against an already-patched checkout (checks
# for build_prjxray_pyutils, which only exists post-patch).
BUILDER="$INSTALLER_REPO/toolchain-sources-builder.sh"
if ! grep -q 'build_prjxray_pyutils' "$BUILDER"; then
	echo "==> Applying local fixes to toolchain-sources-builder.sh"
	python3 - "$BUILDER" <<'PYEOF'
import re, sys

path = sys.argv[1]
src = open(path).read()

# Fix 1: `make clean` fails when yosys has no Makefile (CMake-only build).
src = src.replace(
	"\tpushd $repo\n\tmake clean\n\tgit clean -fd .",
	"\tpushd $repo\n\t[ -f Makefile ] && make clean\n\tgit clean -fd .",
	1,
)

# Fix 2: recent yosys releases migrated the build system to CMake.
old_build_yosys = (
	"build_yosys() {\n"
	"\trepo=$1\n"
	"\tpushd $repo\n"
	"\tmake -j$(nproc)\n"
	"\tmake install PREFIX=$INSTALL_PREFIX\n"
	"\tpopd\n"
	"}"
)
new_build_yosys = (
	"build_yosys() {\n"
	"\trepo=$1\n"
	"\tpushd $repo\n"
	"\tif [ -f Makefile ]; then\n"
	"\t\tmake -j$(nproc)\n"
	"\t\tmake install PREFIX=$INSTALL_PREFIX\n"
	"\telse\n"
	"\t\t# Recent yosys releases migrated the build system to CMake.\n"
	"\t\tcmake -B build . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX\n"
	"\t\tcmake --build build --config Release --parallel $(nproc)\n"
	"\t\tcmake --install build --strip\n"
	"\tfi\n"
	"\tpopd\n"
	"}"
)
assert old_build_yosys in src, "build_yosys() body not found -- upstream script changed?"
src = src.replace(old_build_yosys, new_build_yosys, 1)

# Fix 3: prjxray's `pip3 install --user -r requirements.txt` silently
# fails under PEP 668 on modern Debian/Ubuntu, so fasm2frames and the
# fasm/textx python packages never actually get installed. Use a
# dedicated venv instead; --system-site-packages reuses the
# apt-installed deps (numpy, intervaltree, pyyaml, simplejson) already
# pulled in by check_dependencies().
old_build_fasm = (
	"build_fasm() {\n"
	"\t#apt install cmake default-jre-headless uuid-dev libantlr4-runtime-dev\n"
	"\t#apt install python3-setuptools cython3\n"
	"\t#git submodule update --init\n"
	"\tpushd prjxray/third_party/fasm\n"
	"\tpython3 setup.py install --verbose --antlr-runtime=shared --home=$INSTALL_PREFIX\n"
	"\tpopd\n"
	"}"
)
new_build_prjxray_pyutils = (
	"build_prjxray_pyutils() {\n"
	"\t[ -d $INSTALL_PREFIX/venv ] || python3 -m venv --system-site-packages $INSTALL_PREFIX/venv\n"
	"\t# prjxray's setup.py only declares packages=['prjxray'], but its\n"
	"\t# console-script entry points (e.g. fasm2frames) import from a sibling\n"
	"\t# top-level utils/ dir that's never packaged -- it only works with the\n"
	"\t# repo root on sys.path, i.e. an editable install. So install editable,\n"
	"\t# but point it at a copy under $INSTALL_PREFIX (permanent) rather than\n"
	"\t# this toolchain-installer checkout (disposable), so it keeps working\n"
	"\t# after this checkout is deleted.\n"
	"\tmkdir -p $INSTALL_PREFIX/src\n"
	"\trm -rf $INSTALL_PREFIX/src/prjxray\n"
	"\tcp -a prjxray $INSTALL_PREFIX/src/prjxray\n"
	"\t$INSTALL_PREFIX/venv/bin/pip install -e $INSTALL_PREFIX/src/prjxray\n"
	"}"
)
assert old_build_fasm in src, "build_fasm() body not found -- upstream script changed?"
src = src.replace(old_build_fasm, new_build_prjxray_pyutils, 1)

# Fix 3b: update the call site to match.
assert "\tbuild_fasm\nfi" in src, "build_fasm call site not found -- upstream script changed?"
src = src.replace("\tbuild_fasm\nfi", "\tbuild_prjxray_pyutils\nfi", 1)

# Fix 3c: put the venv (holding fasm2frames) on PATH in the generated
# export.sh.
old_path_line = "export PATH=$INSTALL_PREFIX/bin:\\$PATH"
new_path_line = "export PATH=$INSTALL_PREFIX/venv/bin:$INSTALL_PREFIX/bin:\\$PATH"
assert old_path_line in src, "export.sh PATH line not found -- upstream script changed?"
src = src.replace(old_path_line, new_path_line, 1)

open(path, 'w').write(src)
print("done")
PYEOF
else
	echo "==> Local fixes already applied to toolchain-sources-builder.sh"
fi

# --- Build & install the toolchain ---------------------------------------
targets=("$@")
if [ ${#targets[@]} -eq 0 ]; then
	targets=(nextpnr prjxray)
fi
echo "==> Running toolchain-sources-builder.sh ${targets[*]} (this can take a while)"
chmod +x "$INSTALLER_REPO/toolchain-sources-builder.sh"
(cd "$INSTALLER_REPO" && ./toolchain-sources-builder.sh "${targets[@]}")

echo
echo "==> Done. Installed under $INSTALL_PREFIX"
echo
echo "This install is NOT added to your shell startup files, so it will not"
echo "interfere with oss-cad-suite or anything else already on your PATH."
echo "To use the openXC7 toolchain in a terminal session, run:"
echo
echo "    source $INSTALL_PREFIX/export.sh"
echo
echo "yosys was NOT built here (your oss-cad-suite yosys works fine for the"
echo "synth_xilinx flow the demo projects use). Source oss-cad-suite's"
echo "environment as usual to get yosys on PATH alongside this."
