-------------------------------------------------------------------------------
-- Company:        FHTW
-- Engineer:       Berger Jonas
-- Create Date:    10.02.2023
-- Design Name:    50% DutyCycle Rectangle Modulator
-- Module Name:    rect_50_mod - rtl
-- Project Name:   FPGA-Embedded-Funktionsgenerator
-- Revision:       V01
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity rect_50_mod is
  generic (
    G_DATA_WIDTH : natural := 8
  );
  port (
    phase_msb_i : in std_logic;

    rect_50_o : out signed (G_DATA_WIDTH - 1 downto 0));
end rect_50_mod;

architecture rtl of rect_50_mod is

begin

  rect_50_o <= x"7F" when phase_msb_i = '0' else x"80";

end rtl;