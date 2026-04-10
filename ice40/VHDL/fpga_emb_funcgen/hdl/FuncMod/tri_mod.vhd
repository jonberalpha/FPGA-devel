-------------------------------------------------------------------------------
-- Company:        FHTW
-- Engineer:       Berger Jonas
-- Create Date:    12.02.2023
-- Design Name:    Triangle Modulator
-- Module Name:    tri_mod - rtl
-- Project Name:   FPGA-Embedded-Funktionsgenerator
-- Revision:       V01
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity tri_mod is
  generic (
    G_DATA_WIDTH : natural := 8
  );
  port (
    clk_i   : in std_logic;
    rst_i   : in std_logic;
    tick_i  : in std_logic;
    phase_i : in signed (G_DATA_WIDTH - 1 downto 0);

    tri_o : out signed (G_DATA_WIDTH - 1 downto 0)
  );
end tri_mod;

architecture rtl of tri_mod is

  type t_state is (S_1, S_2);
  signal s_cur_state, s_next_state : t_state;

begin

  P_state_reg : process (clk_i, rst_i)
  begin
    if rst_i = '1' then
      s_cur_state <= S_1;
    elsif clk_i'event and clk_i = '1' then
      if tick_i = '1' then
        s_cur_state <= s_next_state;
      end if;
    end if;
  end process;

  P_next_state_logic : process (s_cur_state, phase_i)
  begin
    s_next_state <= s_cur_state; -- default statement

    case s_cur_state is
      when S_1 =>

        if phase_i = x"80" then
          s_next_state <= S_2;
          tri_o        <= not(phase_i + 1) + 1; -- invert values
        else
          tri_o <= phase_i; -- take over values
        end if;
      when S_2 =>

        if phase_i = x"80" then
          s_next_state <= S_1;
          tri_o        <= phase_i + 1; -- take over values
        else
          tri_o <= not(phase_i) + 1; -- invert values
        end if;
    end case;
  end process;

end rtl;