-------------------------------------------------------------------------------
-- Company:        FHTW
-- Engineer:       Berger Jonas
-- Create Date:    24.02.2023
-- Design Name:    Pseudonoise Generator
-- Module Name:    pn_gen - rtl
-- Project Name:   FPGA-Embedded-Funktionsgenerator
-- Revision:       V01
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity pn_gen is
  generic (
    G_DATA_WIDTH : natural          := 8;
    G_SEED       : std_logic_vector := x"11"); --all 1 forbidden but is hex so no problem
  port (
    clk_i  : in std_logic;
    rst_i  : in std_logic;
    tick_i : in std_logic;

    pn_o : out signed (G_DATA_WIDTH - 1 downto 0));
end pn_gen;

architecture rtl of pn_gen is

  signal s_shift_reg : std_logic_vector (G_DATA_WIDTH - 1 downto 0);
  signal s_bit_in    : std_logic;

begin

  P_shift : process (clk_i, rst_i)
  begin
    if rst_i = '1' then
      s_shift_reg <= G_SEED;
    elsif clk_i'event and clk_i = '1' then
      if tick_i = '1' then
        s_shift_reg <= s_shift_reg(G_DATA_WIDTH - 2 downto 0) & s_bit_in; --shift right
      end if;
    end if;
  end process;

  s_bit_in <= s_shift_reg(3) xnor s_shift_reg(4) xnor s_shift_reg(5) xnor s_shift_reg(7); -- feedback
  pn_o     <= signed(s_shift_reg);

end rtl;