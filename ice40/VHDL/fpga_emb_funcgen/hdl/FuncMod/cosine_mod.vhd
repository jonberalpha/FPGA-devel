-------------------------------------------------------------------------------
-- Company:        FHTW
-- Engineer:       Berger Jonas
-- Create Date:    10.02.2023
-- Design Name:    Cosine Modulator with LUT
-- Module Name:    cosine_mod - rtl
-- Project Name:   FPGA-Embedded-Funktionsgenerator
-- Revision:       V01
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity cosine_mod is
  generic (
    G_DATA_WIDTH : natural := 8
  );
  port (
    clk_i   : in std_logic;
    rst_i   : in std_logic;
    tick_i  : in std_logic;
    phase_i : in std_logic_vector (G_DATA_WIDTH - 1 downto 0);
    s90_i   : in std_logic;

    cosine_o : out signed (G_DATA_WIDTH - 1 downto 0));
end cosine_mod;

architecture rtl of cosine_mod is

  -- Cosine Lookup-Table
  type t_cosine is array (0 to 63) of signed (G_DATA_WIDTH - 1 downto 0);
  constant C_COSINE_LUT : t_cosine :=
  (
  x"7F", x"7F", x"7F", x"7F", -- START: 1. Quadrant CosineLUT
  x"7E", x"7E", x"7E", x"7D",
  x"7D", x"7C", x"7B", x"7A",
  x"79", x"79", x"78", x"76",
  x"75", x"74", x"73", x"71",
  x"70", x"6E", x"6D", x"6B",
  x"69", x"68", x"66", x"64",
  x"62", x"60", x"5E", x"5C",
  x"5A", x"57", x"55", x"53",
  x"50", x"4E", x"4B", x"49",
  x"46", x"44", x"41", x"3E",
  x"3B", x"39", x"36", x"33",
  x"30", x"2D", x"2A", x"27",
  x"24", x"21", x"1E", x"1B",
  x"18", x"15", x"12", x"0F",
  x"0C", x"09", x"05", x"02" -- END: 1. Quadrant CosineLUT
  );

  -- Signal definitions
  signal s_phase    : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
  signal s_data     : signed(G_DATA_WIDTH - 1 downto 0);
  signal s_data_reg : signed(G_DATA_WIDTH - 1 downto 0);

begin

  -- Phase Delay 90 degrees Process
  -- => if S90 is set sine wave will be created
  P_phase90 : process (s90_i, phase_i)
  begin
    s_phase <= phase_i; -- default statement
    
    if s90_i = '1' then -- go one quadrant back in each case:
      if phase_i(7 downto 6) = "00" then
        s_phase(7 downto 6) <= "11";
      elsif phase_i(7 downto 6) = "01" then
        s_phase(7 downto 6) <= "00";
      elsif phase_i(7 downto 6) = "10" then
        s_phase(7 downto 6) <= "01";
      elsif phase_i(7 downto 6) = "11" then
        s_phase(7 downto 6) <= "10";
      end if;
    end if;
  end process;

  -- Cosine Modulator Process
  P_cosine_mod : process (s_phase)
  begin
    -- 1.Quadrant: MSBits = 00
    if s_phase(7 downto 6) = "00" then
      s_data <= C_COSINE_LUT(to_integer(unsigned(s_phase(5 downto 0)))); -- reading normal from LUT

      -- 2.Quadrant: MSBits = 01
    elsif s_phase(7 downto 6) = "01" then
      s_data <= not(C_COSINE_LUT(63 - to_integer(unsigned(s_phase(5 downto 0))))) + 1; --  two’s complement and reading reversed from LUT

      -- 3.Quadrant: MSBits = 10
    elsif s_phase(7 downto 6) = "10" then
      s_data <= not(C_COSINE_LUT(to_integer(unsigned(s_phase(5 downto 0))))) + 1; -- two’s complement and reading normal from LUT

      -- 4.Quadrant: MSBits = 11
    elsif s_phase(7 downto 6) = "11" then
      s_data <= C_COSINE_LUT(63 - to_integer(unsigned(s_phase(5 downto 0)))); -- reading reversed from LUT

    else
      s_data <= (others => '0');
    end if;
  end process;

  -- Register Process
  P_reg : process (clk_i, rst_i)
  begin
    if rst_i = '1' then
      s_data_reg <= (others => '0');
    elsif clk_i'event and clk_i = '1' then
      if tick_i = '1' then
        s_data_reg <= s_data;
      end if;
    end if;
  end process;

  cosine_o <= s_data_reg;

end rtl;