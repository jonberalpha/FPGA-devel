-------------------------------------------------------------------------------
-- Company:        FHTW
-- Engineer:       Berger Jonas
-- Create Date:    10.02.2023
-- Design Name:    Attribute Selection
-- Module Name:    attr_sel - rtl
-- Project Name:   FPGA-Embedded-Funktionsgenerator
-- Revision:       V01
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity attr_sel is
  port (
    clk_i        : in std_logic;
    rst_i        : in std_logic;
    asel_aedit_i : in std_logic;
    inc_i        : in std_logic;
    dec_i        : in std_logic;

    selected_attr_o : out std_logic_vector (2 downto 0);
    sel_1_o         : out std_logic;
    sel_2_o         : out std_logic;
    sel_3_o         : out std_logic;
    sel_4_o         : out std_logic;
    sel_5_o         : out std_logic;
    sel_6_o         : out std_logic); -- 0-4 Attribute + 1 Reg. reserved
end attr_sel;

architecture rtl of attr_sel is

  constant C_MAXVALUE : unsigned (2 downto 0) := "101"; -- max=5
  constant C_MINVALUE : unsigned (2 downto 0) := "000"; -- min=0

  signal s_count         : unsigned (2 downto 0) := "000";
  signal s_counter_value : std_logic_vector (2 downto 0);

begin

  P_up_down_counter : process (rst_i, clk_i)
  begin
    if rst_i = '1' then
      s_count <= "000";
    elsif clk_i'event and clk_i = '1' then
      if asel_aedit_i = '0' then -- wenn T-FF Q=0, dann den Counter enablen
        if inc_i = '1' then
          s_count <= s_count + 1;
          if s_count = C_MAXVALUE then
            s_count <= C_MINVALUE;
          end if;
        end if;
        if dec_i = '1' then
          s_count <= s_count - 1;
          if s_count = C_MINVALUE then
            s_count <= C_MAXVALUE;
          end if;
        end if;
      end if;
    end if;
  end process;

  s_counter_value <= std_logic_vector(s_count);
  selected_attr_o <= s_counter_value;

  --select process
  select_p : process (s_counter_value)
  begin
    -- default statement
    sel_1_o <= '0';
    sel_2_o <= '0';
    sel_3_o <= '0';
    sel_4_o <= '0';
    sel_5_o <= '0';
    sel_6_o <= '0';

    case s_counter_value is
      when "000" =>
        sel_1_o <= '1';
      when "001" =>
        sel_2_o <= '1';
      when "010" =>
        sel_3_o <= '1';
      when "011" =>
        sel_4_o <= '1';
      when "100" =>
        sel_5_o <= '1';
      when "101" =>
        sel_6_o <= '1';
      when others =>
        sel_1_o <= '1';
    end case;
  end process;

end rtl;