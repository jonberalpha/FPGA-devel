# Tang Primer 20K + Dock – LED-Beispiel (VHDL)

Die LED blinkt mit 2 Hz. Eine Taste schaltet das Blinken ein/aus, die erste Taste ist der Reset.

| Funktion | Taste/LED |
|---|---|
| Reset (Blinken wieder an) | S0 (T10) |
| Blinken ein/aus | S1 (T3) (gedrückt = low) |
| LED | LED5, oberste LED (L16) |

FPGA: GW2A-18 (GW2A-LV18PG256C8/I7), Takt 27 MHz (H11).

## Kompilieren

Benötigte Tools (z. B. [OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build)): `yosys`, `nextpnr-himbaechel`, `gowin_pack`, `openFPGALoader`, `ghdl` (+ ghdl-yosys-plugin).

```sh
make          # Synthese + Place&Route + Bitstream -> build/led_top.fs
make sim      # selbstprüfende Simulation (ghdl)
make clean
```

## Flashen

```sh
make flash      # in den SRAM (flüchtig)
make flash-ext  # in den Flash (dauerhaft)
```

## Struktur

`hdl/` Quellen · `cst/` Pin-Constraints · `tb/` Testbench · `sim/` Simulationsausgaben
