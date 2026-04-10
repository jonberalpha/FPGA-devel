-------------------------------------------------------------------------------
-- Company:        FHTW
-- Engineer:       Berger Jonas
-- Create Date:    10.02.2023
-- Design Name:    Signal Shape Multiplexer
-- Module Name:    shape_mux - rtl
-- Project Name:   FPGA-Embedded-Funktionsgenerator
-- Revision:       V01
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity shape_mux is
  generic (
    G_DATA_WIDTH : natural := 8
  );
  port (
    shape_sel_i : in std_logic_vector(2 downto 0);
    ramp_rise_i : in signed(G_DATA_WIDTH - 1 downto 0);
    ramp_fall_i : in signed(G_DATA_WIDTH - 1 downto 0);
    rect_50_i   : in signed(G_DATA_WIDTH - 1 downto 0);
    rect_var_i  : in signed(G_DATA_WIDTH - 1 downto 0);
    cosine_i    : in signed(G_DATA_WIDTH - 1 downto 0);
    tri_i       : in signed(G_DATA_WIDTH - 1 downto 0);
    pn_i        : in signed(G_DATA_WIDTH - 1 downto 0);

    signal_o : out signed (G_DATA_WIDTH - 1 downto 0));
end shape_mux;

architecture rtl of shape_mux is

  constant C_RAMP_RISING  : std_logic_vector(2 downto 0) := "000";
  constant C_RAMP_FALLING : std_logic_vector(2 downto 0) := "001";
  constant C_RECT_50      : std_logic_vector(2 downto 0) := "010";
  constant C_RECT_VAR     : std_logic_vector(2 downto 0) := "011";
  constant C_COSINE       : std_logic_vector(2 downto 0) := "100";
  constant C_TRIANGLE     : std_logic_vector(2 downto 0) := "101";
  constant C_PN           : std_logic_vector(2 downto 0) := "110";

begin

  P_SHAPE_MUX : process (shape_sel_i, ramp_rise_i, ramp_fall_i, rect_50_i, rect_var_i, cosine_i, tri_i, pn_i)
  begin
    case shape_sel_i is
      when C_RAMP_RISING =>
        signal_o <= ramp_rise_i;
      when C_RAMP_FALLING =>
        signal_o <= ramp_fall_i;
      when C_RECT_50 =>
        signal_o <= rect_50_i;
      when C_RECT_VAR =>
        signal_o <= rect_var_i;
      when C_COSINE =>
        signal_o <= cosine_i;
      when C_TRIANGLE =>
        signal_o <= tri_i;
      when C_PN =>
        signal_o <= pn_i;
      when others => -- C_VCC
        signal_o <= x"7F";
    end case;
  end process;

end rtl;