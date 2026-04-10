library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity leds is
  port (CLK : in std_logic;
        LED : out std_logic);
end leds;
