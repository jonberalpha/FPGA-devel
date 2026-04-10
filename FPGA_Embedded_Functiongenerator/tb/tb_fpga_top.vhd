-------------------------------------------------------------------------------
-- Engineer:       Berger Jonas
-- Create Date:    13.02.2023
-- Design Name:    FPGA Top Testbench
-- Module Name:    fpga_top - tb
-- Project Name:   FPGA-Embedded-Functiongenerator
-- Revision:       V01
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fpga_top is
end entity tb_fpga_top;

architecture tb of tb_fpga_top is

  -- Component declaration for fpga_top
  component fpga_top is
    generic (
      G_DATA_WIDTH : natural := 8
    );
    port (
      rst_i    : in std_logic;
      clk_i    : in std_logic;
      pb_i     : in std_logic_vector(3 downto 0);
      rotenc_i : in std_logic_vector(3 downto 0);

      led_o    : out std_logic;
      signal_o : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
      ss_o     : out std_logic_vector(7 downto 0);
      ss_sel_o : out std_logic_vector(3 downto 0));
  end component fpga_top;

  -- Signal declarations
  constant G_DATA_WIDTH : natural := 8;
  signal rst_i          : std_logic;
  signal clk_i          : std_logic;
  signal pb_i           : std_logic_vector(3 downto 0);
  signal rotenc_i       : std_logic_vector(3 downto 0);
  signal led_o          : std_logic;
  signal signal_o       : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
  signal ss_o           : std_logic_vector(7 downto 0);
  signal ss_sel_o       : std_logic_vector(3 downto 0);

  signal s_A : std_logic;
  signal s_B : std_logic;

  constant clk_period : time := 10 ns;

begin

  --! Port map declaration for fpga_top
  i_fpga_top : fpga_top
  generic map(
    G_DATA_WIDTH => G_DATA_WIDTH
  )
  port map(
    rst_i    => rst_i,
    clk_i    => clk_i,
    pb_i     => pb_i,
    rotenc_i => rotenc_i,
    led_o    => led_o,
    signal_o => signal_o,
    ss_o     => ss_o,
    ss_sel_o => ss_sel_o
  );

  P_clk : process
  begin
    clk_i <= '0';
    wait for clk_period/2;
    clk_i <= '1';
    wait for clk_period/2;
  end process;

  P_rot_encoder : process
  begin
    s_A <= '0';
    s_B <= '0';
    -- counting up
    for i in 1 to 4 loop
      wait for clk_period * 50;
      s_A <= '0';
      wait for clk_period * 14.4;
      s_B <= '0';
      wait for clk_period * 11.4;
      s_A <= '1';
      wait for clk_period * 7.4;
      s_B <= '1';
      wait for clk_period * 50;
    end loop;
    -- counting down
    for i in 1 to 4 loop
      wait for clk_period * 50;
      s_B <= '0';
      wait for clk_period * 6.4;
      s_A <= '0';
      wait for clk_period * 8.4;
      s_B <= '1';
      wait for clk_period * 13.4;
      s_A <= '1';
      wait for clk_period * 50;
    end loop;
    wait;
  end process;

  rotenc_i(3) <= '0';
  rotenc_i(2) <= s_A;
  rotenc_i(1) <= s_B;
  rotenc_i(0) <= '0';

  pb_i <= (others => '0');

  P_test : process
  begin
    rst_i <= '1';
    wait for clk_period * 10;
    rst_i <= '0';
    wait;
  end process;

end tb;
