-- Board top level: wires the 27 MHz clock, reset button, function button and LEDs.

library ieee;
use ieee.std_logic_1164.all;

entity led_top is
  port (
    clk_27mhz : in std_logic;
    btn_rst   : in std_logic; -- S1: reset
    btn_user  : in std_logic; -- S2: blink on/off
    led       : out std_logic_vector(6 - 1 downto 0)
  );
end entity;

architecture rtl of led_top is
begin
  u_led_toggle : entity work.led_toggle
    generic map(NUM_LEDS => 6)
    port map(clk => clk_27mhz, btn_rst => btn_rst, btn_user => btn_user, led => led);
end architecture;
