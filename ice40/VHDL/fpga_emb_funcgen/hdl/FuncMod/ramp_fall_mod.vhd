-------------------------------------------------------------------------------
-- Company:        FHTW
-- Engineer:       Berger Jonas
-- Create Date:    10.02.2023
-- Design Name:    Falling-Ramp Modulator
-- Module Name:    ramp_fall_mod - rtl
-- Project Name:   FPGA-Embedded-Funktionsgenerator
-- Revision:       V01
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity ramp_fall_mod is
  generic (
    G_DATA_WIDTH : natural := 8
  );
  port (
    phase_i : in signed (G_DATA_WIDTH - 1 downto 0);

    ramp_fall_o : out signed (G_DATA_WIDTH - 1 downto 0));
end ramp_fall_mod;

architecture rtl of ramp_fall_mod is

begin

  ramp_fall_o <= not (phase_i) + 1; -- two’s complement

end rtl;