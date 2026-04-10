-------------------------------------------------------------------------------
-- Company:        FHTW
-- Engineer:       Berger Jonas
-- Create Date:    10.02.2023
-- Design Name:    Debounce
-- Module Name:    debounce - rtl
-- Project Name:   FPGA-Embedded-Funktionsgenerator
-- Revision:       V01
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity debounce is
  port (
    clk_i   : in std_logic;
    rst_i   : in std_logic;
    tick_i  : in std_logic;   -- slowed down clk_ien for debouncing
    sw_i    : in std_logic;   -- input
    swout_o : out std_logic); -- debounced output
end debounce;

architecture rtl of debounce is

  type stateType is (s_low, s_low2high, s_high, s_high2low);
  signal curState, nextState : stateType;

begin

  state_reg_p : process (rst_i, clk_i) -- state register
  begin
    if rst_i = '1' then
      curState <= s_low;
    elsif clk_i'event and clk_i = '1' then
      if tick_i = '1' then
        curState <= nextState;
      end if;
    end if;
  end process;

  nextstatelogic_p : process (curState, sw_i) -- next state logic
  begin
    nextState <= curState; -- default assignment
    case curState is
      when s_low =>
        if sw_i = '1' then
          nextState <= s_low2high;
        end if;
        swout_o <= '0';

      when s_low2high =>
        if sw_i = '1' then
          nextState <= s_high;
        else
          nextState <= s_low;
        end if;
        swout_o <= '0';

      when s_high =>
        if sw_i = '0' then
          nextState <= s_high2low;
        end if;
        swout_o <= '1';

      when s_high2low =>
        if sw_i = '0' then
          nextState <= s_low;
        else
          nextState <= s_high;
        end if;
        swout_o <= '1';

    end case;
  end process;

end rtl;