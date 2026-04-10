-------------------------------------------------------------------------------
-- Company:        FHTW
-- Engineer:       Berger Jonas
-- Create Date:    10.02.2023
-- Design Name:    Attribute Register
-- Module Name:    attr_reg - rtl
-- Project Name:   FPGA-Embedded-Funktionsgenerator
-- Revision:       V01
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity attr_reg is
  generic (
    G_REG_WIDTH : natural  := 3;
    G_RST_VALUE : unsigned := "000"
  );
  port (
    clk_i       : in std_logic;
    rst_i       : in std_logic;
    asel_edit_i : in std_logic;
    sel_attr_i  : in std_logic;
    inc_i       : in std_logic;
    dec_i       : in std_logic;

    attr_value_o : out std_logic_vector (G_REG_WIDTH - 1 downto 0)); -- 0-7 Attributwert
end attr_reg;

architecture rtl of attr_reg is

  constant C_MAXVALUE : unsigned (G_REG_WIDTH - 1 downto 0) := "111"; -- max=7
  constant C_MINVALUE : unsigned (G_REG_WIDTH - 1 downto 0) := "000"; -- min=0

  signal s_count : unsigned (G_REG_WIDTH - 1 downto 0);

begin

  --up down counter
  P_up_down_counter : process (rst_i, clk_i)
  begin
    if rst_i = '1' then
      s_count <= G_RST_VALUE;
    elsif clk_i'event and clk_i = '1' then
      if asel_edit_i = '1' then -- if T-FF, than enable counter
        if sel_attr_i = '1' then
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
    end if;
  end process;

  attr_value_o <= std_logic_vector(s_count);

end rtl;