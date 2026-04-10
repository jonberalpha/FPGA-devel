-------------------------------------------------------------------------------
-- Company:        FHTW
-- Engineer:       Berger Jonas
-- Create Date:    10.02.2023
-- Design Name:    Phase Shifter
-- Module Name:    phase_shift - rtl
-- Project Name:   FPGA-Embedded-Funktionsgenerator
-- Revision:       V01
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity phase_shift is
  generic (
    G_DATA_WIDTH : natural := 8
  );
  port (
    ramp_i            : in signed(G_DATA_WIDTH - 1 downto 0);
    phase_shift_sel_i : in std_logic_vector(2 downto 0);

    shifted_ramp_o : out signed(G_DATA_WIDTH - 1 downto 0)
  );
end entity phase_shift;

architecture rtl of phase_shift is

  type t_shifted_ramp is array (0 to 7) of signed (G_DATA_WIDTH - 1 downto 0);
  constant C_SHIFT_VAL : t_shifted_ramp :=
  (
  x"F0", x"E0", x"C0", x"00", x"40", x"60", x"70", x"80"
  );

begin

  shifted_ramp_o <= ramp_i + C_SHIFT_VAL(to_integer(unsigned(phase_shift_sel_i)));

end architecture;