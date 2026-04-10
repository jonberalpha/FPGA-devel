-------------------------------------------------------------------------------
-- Engineer:       Berger Jonas
-- Create Date:    13.02.2023
-- Design Name:    Ramp Generator Testbench
-- Module Name:    ramp_gen - tb
-- Project Name:   FPGA-Embedded-Functiongenerator
-- Revision:       V01
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_ramp_gen is
end entity tb_ramp_gen;

architecture tb of tb_ramp_gen is

  -- Signal declarations
  signal clk_i   : std_logic;
  signal rst_i   : std_logic;
  signal f_reg_i : std_logic_vector (2 downto 0);
  signal tick_o  : std_logic;
  signal ramp_o  : signed (7 downto 0);

  constant clk_period : time := 10 ns;

  -- Component declaration for ramp_gen
  component ramp_gen is
    generic (
      G_DATA_WIDTH : natural
    );
    port (
      clk_i   : in std_logic;
      rst_i   : in std_logic;
      f_reg_i : in std_logic_vector (2 downto 0);

      tick_o : out std_logic;
      ramp_o : out signed (G_DATA_WIDTH - 1 downto 0));
  end component ramp_gen;
begin

  -- Port map declaration for ramp_gen
  i_ramp_gen : ramp_gen
  generic map(
    G_DATA_WIDTH => 8
  )
  port map(
    clk_i   => clk_i,
    rst_i   => rst_i,
    f_reg_i => f_reg_i,
    tick_o  => tick_o,
    ramp_o  => ramp_o
  );

  -- Clock process definitions
  P_clk_process : process
  begin
    clk_i <= '0';
    wait for clk_period/2;
    clk_i <= '1';
    wait for clk_period/2;
  end process;

  -- Stimulus process
  stim_proc : process
  begin
    rst_i <= '1';
    wait for 100 ns;
    rst_i <= '0';
    wait for 27 ms;
    wait;
  end process;

  f_reg_i <= "111"; -- fastest time 10MHz

end tb;
