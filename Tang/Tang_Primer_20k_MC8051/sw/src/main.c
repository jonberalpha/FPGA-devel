// Button -> LED demo for mc8051 IP Core
// Port P1 bit 0 is wired to the user button, port P2 bit 0 to the onboard LED.

#include "8052.h"

void main(void)
{
  while (1)
  {
    // copy button state (P1.0) to LED (P2.0)
    P2 = P1 & 0x01;
  }
}
