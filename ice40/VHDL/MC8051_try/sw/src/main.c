// Blink LED Program for mc8051 IP Core Demo Design

#include "8052.h"
#include "stdio.h"

void main(void)
{
  volatile unsigned int i1, i2;

  // blink fast, for ModelSim simulation
  for (i1 = 0; i1 < 10; i1++)
  {
    P2 = 0xFF; // set all eight P2 port pins to logic 1
    P2 = 0x00; // set all eight P2 port pins to logic 0
  }

  // blink slow, for execution on real hardware
  while (1)
  {
    P2 = 0xFF; // set all eight P2 port pins to logic 1

    // soft delay
    for (i1 = 0; i1 < 500; i1++)
      for (i2 = 0; i2 < 1000; i2++)
        ;

    P2 = 0x00; // set all eight P2 port pins to logic 0

    // soft delay
    for (i1 = 0; i1 < 500; i1++)
      for (i2 = 0; i2 < 1000; i2++)
        ;
  }
}
