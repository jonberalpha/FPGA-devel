-------------------------------------------------------------------------------
-- Engineer:       Berger Jonas
-- Create Date:    22.02.2023
-- Design Name:    Attenuation Apply
-- Module Name:    attn_apply - rtl
-- Project Name:   FPGA-Embedded-Functiongenerator
-- Revision:       V01
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity attn_apply is
  generic (
    G_DATA_WIDTH : natural := 8
  );
  port (
    attn_sel_i    : in std_logic_vector (2 downto 0);
    signal_i      : in signed (G_DATA_WIDTH - 1 downto 0);
    attn_signal_o : out signed (G_DATA_WIDTH - 1 downto 0));
end attn_apply;

architecture rtl of attn_apply is

  -- LUT with attenutation-values
  type t_attn_mult is array (0 to 7) of signed (G_DATA_WIDTH - 1 downto 0);
  constant C_ATTN_VAL : t_attn_mult := (-- Attenuation for
  x"7F", x"5A", x"3F", x"2D",  -- 0dB, 3db, 6dB, 9dB, | calculated with MAX/(sqrt2*N)
  x"20", x"16", x"10", x"0B"); -- 12dB, 15dB, 18dB, 21dB)

  -- Signal definition
  signal s_product : signed (2 * G_DATA_WIDTH - 1 downto 0);

begin
  -- Apply attenuation
  s_product <= signal_i * C_ATTN_VAL(to_integer(unsigned(attn_sel_i)));

  -- Assign product to output
  attn_signal_o <= s_product(2 * G_DATA_WIDTH - 2 downto G_DATA_WIDTH - 1);

end rtl;
