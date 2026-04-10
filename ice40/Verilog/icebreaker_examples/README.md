# FPGA Code

Here are some concrete iCEBreaker examples.

To run them, you'll need the [OSS CAD Suite]https://github.com/YosysHQ/oss-cad-suite-build()
installed, as well as `make`. And an iCEBreaker dev board.

To synthesize them, change to the relevant directory and run `make`. To program the board, run `make
prog`.

## Button Blink

This demo turns on an LED when you press a button. The result is much like a hello world on a
microcontroller, but the way it works is much different! On a microcontroller, the processor is
repeatedly checking the voltage on an input pin, and when it notices a change it then activates a
driver to charge (or discharge) an output pint. This involves at least the control unit, and various
special registers in the microcontroller's core, plus the IO peripherals. On the FPGA, the logic
cells are reconfigured so there is a direct analog path connecting the input pin (i.e. button) to
the gate of a transistor whose output is attached to the LED.

## Button Toggle

This demo is like the last, except the button acts as a toggle for the LED. To do this we need the
FPGA to remember the current state of the button. To do this we use a register. We also use a
register to keep track of the LED state, and three extra registers to debounce the button signal.

## Blink (12 MHz)

This demo isn't interactive, but is helpful if you want to dive a little deeper. It uses a counter
to divide the clock frequency. The LED is blinked at 1 Hz, and a squarewave with a frequency of 1
MHz is produced on an output pin. If you have an oscilloscope handy, you can use this to confirm
that the FPGA is operating at the expected clock frequency: 12 MHz.

## Blink (24 MHz)

This is like the previous demo, but we run the FPGA at 24 MHz instead of 12 MHz. To do this, we
use the onboard phase locked loop (PLL) to multiply the FPGA's clock frequency. This is accomplished
using the Lattice FPGA primitive `SB_PLL40_PAD`.

## BRAM

This is a module that can be used to instantiate a BRAM block. We could use another primitive, but
nextpnr is smart enough to figure out what we mean. BRAM blocks are memory cells that reside next to
reconfigure logic blocks. You can always implement memory using the reconfigurable logic cells, but
it's very inefficient to do so. Using the built in memory primitives allows you to store much more
data, and to keep your clock cycle short.
