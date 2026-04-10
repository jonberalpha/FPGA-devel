--------------------------------------------------------------------------------
-- Engineer:      Berger Jonas
-- Create Date:   19/03/2019
-- Design Name:   Cosine Modulator
-- Module Name:   CosineMod_TB.vhd
-- Project Name:  FPGA-Embedded-Functiongenerator
-- Revision:      V01
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- File I/O
use ieee.std_logic_textio.all;
use std.textio.all;

entity tb_cosine_mod is
end entity tb_cosine_mod;

architecture tb of tb_cosine_mod is

  -- Signal declarations
  signal clk_i    : std_logic;
  signal rst_i    : std_logic;
  signal tick_i   : std_logic;
  signal phase_i  : std_logic_vector (7 downto 0);
  signal s90_i    : std_logic;
  signal cosine_o : signed (7 downto 0);

  -- Clock period definitions
  constant clk_period  : time := 10 ns; -- 10 MHz
  constant tick_period : time := 200 ns;

  --! Component declaration for cosine_mod
  component cosine_mod is
    generic (
      G_DATA_WIDTH : natural
    );
    port (
      clk_i   : in std_logic;
      rst_i   : in std_logic;
      tick_i  : in std_logic;
      phase_i : in std_logic_vector (G_DATA_WIDTH - 1 downto 0);
      s90_i   : in std_logic;

      cosine_o : out signed (G_DATA_WIDTH - 1 downto 0));
  end component cosine_mod;

begin

  -- Port map declaration for cosine_mod
  i_cosine_mod : cosine_mod
  generic map(
    G_DATA_WIDTH => 8
  )
  port map(
    clk_i    => clk_i,
    rst_i    => rst_i,
    tick_i   => tick_i,
    phase_i  => phase_i,
    s90_i    => s90_i,
    cosine_o => cosine_o
  );

  -- Clock process
  P_clk : process
  begin
    clk_i <= '0';
    wait for clk_period/2;
    clk_i <= '1';
    wait for clk_period/2;
  end process;

  -- Tick process
  P_tick : process
  begin
    tick_i <= '0';
    wait for clk_period * 10;
    tick_i <= '1';
    wait for clk_period;
  end process;

  -- Phase Process
  P_phase : process
  begin
    phase_i <= x"00";
    for j in 0 to 1 loop
      for i in 16#00# to 16#FF# loop -- hex2int-Syntax is used: base#value#
        wait until clk_i'event and clk_i = '1' and tick_i = '1';
        phase_i <= std_logic_vector(to_unsigned(i, 8)); -- 8 bits -> 7 downto 0
      end loop;
    end loop;
    wait;
  end process;

  -- Write File Process
  P_write_file : process
    -- Create ISE Output-File in MATLAB Directory:
    file OutputFile     : TEXT open WRITE_MODE is "../../MATLAB/ise_output_file_cosine.txt";
    variable LineBuffer : LINE;
  begin
    wait on cosine_o; -- if data changes it will be written on file
    write(LineBuffer, std_logic_vector(cosine_o));
    writeline(OutputFile, LineBuffer);
  end process;

  -- Finite Delays:
  rst_i <= '1', '0' after 40 ns;
  S90_i <= '0'; -- if '0' => cosine; if '1' => sine

  -- Select dB
  --seldB <= "000";

end tb;
