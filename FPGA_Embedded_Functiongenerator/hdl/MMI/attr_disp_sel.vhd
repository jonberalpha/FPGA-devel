-------------------------------------------------------------------------------
-- Engineer:       Berger Jonas
-- Create Date:    10.02.2023
-- Design Name:    Attribute Display Selection
-- Module Name:    attr_disp_sel - rtl
-- Project Name:   FPGA-Embedded-Functiongenerator
-- Revision:       V01
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity attr_disp_sel is
  generic (
    G_REG_WIDTH : natural := 3
  );
  port (
    attr_value_signalshape_i : in std_logic_vector (G_REG_WIDTH - 1 downto 0); -- mode 1
    attr_value_freq_i        : in std_logic_vector (G_REG_WIDTH - 1 downto 0); -- mode 2
    attr_value_dutycycle_i   : in std_logic_vector (G_REG_WIDTH - 1 downto 0); -- mode 3
    attr_value_attn_i        : in std_logic_vector (G_REG_WIDTH - 1 downto 0); -- mode 4
    attr_value_phasedelay_i  : in std_logic_vector (G_REG_WIDTH - 1 downto 0); -- mode 5
    attr_value_reserved_i    : in std_logic_vector (G_REG_WIDTH - 1 downto 0); -- mode 6

    asel_aedit_i    : in std_logic;                     -- for decimal point
    selected_attr_i : in std_logic_vector (2 downto 0); -- e.g.: "100" -> attr: 4

    A_o  : out std_logic_vector (3 downto 0);
    B_o  : out std_logic_vector (3 downto 0);
    C_o  : out std_logic_vector (3 downto 0);
    D_o  : out std_logic_vector (3 downto 0);
    dp_o : out std_logic_vector (3 downto 0));
end attr_disp_sel;

architecture rtl of attr_disp_sel is

begin

  P_mux : process (selected_attr_i, asel_aedit_i, attr_value_signalshape_i, attr_value_freq_i,
    attr_value_dutycycle_i, attr_value_attn_i, attr_value_phasedelay_i, attr_value_reserved_i)
  begin
    -- default statement
    A_o <= "1010"; -- 1. 7Seg: A
    C_o <= "0000"; -- 3. 7Seg: 0

    if asel_aedit_i = '0' then
      dp_o <= "1011";
    else
      dp_o <= "1110";
    end if;

    case selected_attr_i is -- A1 bis A6
      when "000" =>
        B_o <= "0001";                                                         -- 2. 7Seg: Attr.-number: 1
        D_o <= std_logic_vector(unsigned('0' & attr_value_signalshape_i) + 1); -- 4. 7Seg: Attr.-value
      when "001" =>
        B_o <= "0010";                                                  -- 2. 7Seg: Attr.-number: 2
        D_o <= std_logic_vector(unsigned('0' & attr_value_freq_i) + 1); -- 4. 7Seg: Attr.-value
      when "010" =>
        B_o <= "0011";                                                       -- 2. 7Seg: Attr.-number: 3
        D_o <= std_logic_vector(unsigned('0' & attr_value_dutycycle_i) + 1); -- 4. 7Seg: Attr.-value
      when "011" =>
        B_o <= "0100";                                                  -- 2. 7Seg: Attr.-number: 4
        D_o <= std_logic_vector(unsigned('0' & attr_value_attn_i) + 1); -- 4. 7Seg: Attr.-value
      when "100" =>
        B_o <= "0101";                                                        -- 2. 7Seg: Attr.-number: 5
        D_o <= std_logic_vector(unsigned('0' & attr_value_phasedelay_i) + 1); -- 4. 7Seg: Attr.-value
      when "101" =>
        B_o <= "0110";                                                         -- 2. 7Seg: Attr.-number: 6
        D_o <= std_logic_vector(unsigned('0' & attr_value_reserved_i) + 1);    -- 4. 7Seg: Attr.-value
      when others =>                                                         -- else A1
        B_o <= "0001";                                                         -- 2. 7Seg: Attr.-number: 1
        D_o <= std_logic_vector(unsigned('0' & attr_value_signalshape_i) + 1); -- 4. 7Seg: Attr.-value
    end case;
  end process;

end rtl;
