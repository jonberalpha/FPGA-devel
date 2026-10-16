# Tang Nano 20K – MC8051

Der [MC8051-IP-Core](https://oregano.at/ip/8051-ip-cores/) (VHDL, 8051-kompatibel) auf dem Sipeed Tang Nano 20K
(GW2AR-18 (GW2AR-LV18QN88C8/I7)). Portierung des ULX3S-Referenzprojekts (GHDL + Yosys) auf Gowin.
Die C-Firmware liest einen Button (P1.0) und zeigt ihn auf einer LED (P2.0) an.

| Funktion | Taste/LED |
|---|---|
| Reset | S1 (Pin 88) |
| Button → LED | S2 (Pin 87) (gedrückt = high) |
| LED | LED0 (Pin 15) |

Takt: 27 MHz → rPLL → 20,25 MHz.

## Kompilieren

Benötigte Tools (z. B. [OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build)): `yosys`, `nextpnr-himbaechel`, `gowin_pack`, `openFPGALoader`, `ghdl` (+ ghdl-yosys-plugin) und `sdcc` (Firmware).

```sh
make          # Firmware (sw/) + Synthese + Place&Route + Bitstream -> build/fpga_top.fs
make sw       # nur Firmware -> sw/build/mc8051_rom.mif
make clean
```
Place & Route dauert ca. 6 Minuten.

## Flashen

```sh
make flash      # in den SRAM (flüchtig, weg nach Power-Cycle)
make flash-ext  # in den Flash (dauerhaft)
```

## Struktur

`hdl/` Core, PLL, Top, ROM/RAM · `sw/` C-Firmware · `tools/` packihx/convhex · `cst/` Pin-Constraints · `doc/` Referenzdokumente · `sim/` Simulationsdateien
