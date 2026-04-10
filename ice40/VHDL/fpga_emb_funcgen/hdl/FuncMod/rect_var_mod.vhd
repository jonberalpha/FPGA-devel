-------------------------------------------------------------------------------
-- Company:        FHTW
-- Engineer:       Berger Jonas
-- Create Date:    10.02.2023
-- Design Name:    Variable Rectangle Modulator
-- Module Name:    rect_var_mod - rtl
-- Project Name:   FPGA-Embedded-Funktionsgenerator
-- Revision:       V01
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity rect_var_mod is
  generic (
    G_DATA_WIDTH : natural := 8
  );
  port (
    phase_i     : in signed (G_DATA_WIDTH - 1 downto 0);
    dutycycle_i : in std_logic_vector (2 downto 0);

    rect_var_o : out signed (G_DATA_WIDTH - 1 downto 0));
end rect_var_mod;

architecture rtl of rect_var_mod is

  type t_offset is array(0 to 7) of signed(G_DATA_WIDTH - 1 downto 0);
  constant C_OFFSET : t_offset :=
  (
  x"70", x"60", x"40", x"00", x"F0", x"E0", x"C0", x"80"
  );

begin

  rect_var_o <= x"7F" when phase_i > C_OFFSET(to_integer(unsigned(dutycycle_i))) else x"80";

end rtl;