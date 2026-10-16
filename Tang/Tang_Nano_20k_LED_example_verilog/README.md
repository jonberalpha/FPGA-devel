# Tang Nano 20K – LED-Beispiel (VERILOG)

Die LED blinkt mit 2 Hz. Eine Taste schaltet das Blinken ein/aus, die erste Taste ist der Reset.

| Funktion | Taste/LED |
|---|---|
| Reset (Blinken wieder an) | S1 (Pin 88) |
| Blinken ein/aus | S2 (Pin 87) (gedrückt = high) |
| LED | LED0 (Pin 15) |

FPGA: GW2AR-18 (GW2AR-LV18QN88C8/I7), Takt 27 MHz (Pin 4).

## Kompilieren

Benötigte Tools (z. B. [OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build)): `yosys`, `nextpnr-himbaechel`, `gowin_pack`, `openFPGALoader`.

```sh
make          # Synthese + Place&Route + Bitstream -> build/led_top.fs
make sim      # selbstprüfende Simulation (iverilog + vvp)
make clean
```

## Flashen

```sh
make flash      # in den SRAM (flüchtig)
make flash-ext  # in den Flash (dauerhaft)
```

## Struktur

`hdl/` Quellen · `cst/` Pin-Constraints · `tb/` Testbench · `sim/` Simulationsausgaben
