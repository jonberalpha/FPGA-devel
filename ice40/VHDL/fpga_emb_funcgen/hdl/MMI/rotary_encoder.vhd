-------------------------------------------------------------------------------
-- Company:        FHTW
-- Engineer:       Berger Jonas
-- Create Date:    10.02.2023
-- Design Name:    Rotary Encoder
-- Module Name:    rotary_encoder - rtl
-- Project Name:   FPGA-Embedded-Funktionsgenerator
-- Revision:       V01
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity rotary_encoder is
  port (
    clk_i : in std_logic;
    rst_i : in std_logic;
    A_i   : in std_logic;
    B_i   : in std_logic;

    TR_o : out std_logic;
    TL_o : out std_logic);
end rotary_encoder;

architecture rtl of rotary_encoder is

  type t_state is (s_idle, s_L1, s_L2, s_L3, s_R1, s_R2, s_R3);
  signal s_cur_state, s_next_state : t_state;

  constant C_ENABLE  : std_logic := '1';
  constant C_DISABLE : std_logic := '0';

begin
  P_state_reg : process (rst_i, clk_i)
  begin
    if rst_i = '1' then
      s_cur_state <= s_idle;
    elsif clk_i'event and clk_i = '1' then
      s_cur_state <= s_next_state;
    end if;
  end process;

  P_next_state_logic : process (A_i, B_i, s_cur_state)
  begin
    s_next_state <= s_cur_state; --default statement
    case s_cur_state is
      when s_idle =>
        if A_i = '0' and B_i = '1' then
          s_next_state <= s_L1;
        end if;
        if A_i = '1' and B_i = '0' then
          s_next_state <= s_R1;
        end if;

      when s_L1 =>
        if A_i = '1' and B_i = '1' then
          s_next_state <= s_L2;
        end if;
        if B_i = '0' then
          s_next_state <= s_idle;
        end if;

      when s_L2 =>
        if A_i = '1' and B_i = '0' then
          s_next_state <= s_L3;
        end if;
        if A_i = '0' and B_i = '1' then
          s_next_state <= s_L1;
        end if;
        if A_i = '0' and B_i = '0' then
          s_next_state <= s_idle;
        end if;

      when s_L3 =>
        s_next_state <= s_idle;

      when s_R1 =>
        if A_i = '1' and B_i = '1' then
          s_next_state <= s_R2;
        end if;
        if A_i = '0' then
          s_next_state <= s_idle;
        end if;

      when s_R2 =>
        if A_i = '0' and B_i = '1' then
          s_next_state <= s_R3;
        end if;
        if A_i = '0' and B_i = '0' then
          s_next_state <= s_idle;
        end if;

      when s_R3 =>
        s_next_state <= s_idle;

      when others =>
        s_next_state <= s_idle;

    end case;
  end process;

  P_output_logic : process (s_cur_state)
  begin
    case s_cur_state is
      when s_idle =>
        TR_o <= C_DISABLE;
        TL_o <= C_DISABLE;
      when s_L1 =>
        TR_o <= C_DISABLE;
        TL_o <= C_DISABLE;
      when s_L2 =>
        TR_o <= C_DISABLE;
        TL_o <= C_DISABLE;
      when s_L3 =>
        TR_o <= C_DISABLE;
        TL_o <= C_ENABLE;
      when s_R1 =>
        TR_o <= C_DISABLE;
        TL_o <= C_DISABLE;
      when s_R2 =>
        TR_o <= C_DISABLE;
        TL_o <= C_DISABLE;
      when s_R3 =>
        TR_o <= C_ENABLE;
        TL_o <= C_DISABLE;

    end case;
  end process;

end rtl;