-------------------------------------------------------------------------------
-- Engineer:       Berger Jonas
-- Create Date:    14.02.2023
-- Design Name:    Attribute Select Testbench
-- Module Name:    attr_sel - tb
-- Project Name:   FPGA-Embedded-Functiongenerator
-- Revision:       V01
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity tb_attr_sel is
end entity tb_attr_sel;

architecture tb of tb_attr_sel is

  -- Signal declarations
  signal clk_i           : std_logic;
  signal rst_i           : std_logic;
  signal asel_aedit_i    : std_logic;
  signal inc_i           : std_logic;
  signal dec_i           : std_logic;
  signal selected_attr_o : std_logic_vector (2 downto 0);
  signal sel_0_o         : std_logic;
  signal sel_1_o         : std_logic;
  signal sel_2_o         : std_logic;
  signal sel_3_o         : std_logic;
  signal sel_4_o         : std_logic;
  signal sel_5_o         : std_logic;

  constant clk_period : time := 10 ns;

  -- Component declaration for attr_sel
  component attr_sel is
    port (
      clk_i        : in std_logic;
      rst_i        : in std_logic;
      asel_aedit_i : in std_logic;
      inc_i        : in std_logic;
      dec_i        : in std_logic;

      selected_attr_o : out std_logic_vector (2 downto 0);
      sel_0_o         : out std_logic;
      sel_1_o         : out std_logic;
      sel_2_o         : out std_logic;
      sel_3_o         : out std_logic;
      sel_4_o         : out std_logic;
      sel_5_o         : out std_logic);
  end component attr_sel;
begin

  -- Port map declaration for attr_sel
  comp_attr_sel : attr_sel
  port map(
    clk_i           => clk_i,
    rst_i           => rst_i,
    asel_aedit_i    => asel_aedit_i,
    inc_i           => inc_i,
    dec_i           => dec_i,
    selected_attr_o => selected_attr_o,
    sel_0_o         => sel_0_o,
    sel_1_o         => sel_1_o,
    sel_2_o         => sel_2_o,
    sel_3_o         => sel_3_o,
    sel_4_o         => sel_4_o,
    sel_5_o         => sel_5_o
  );

  -- Clock process definitions
  P_clk_process : process
  begin
    clk_i <= '0';
    wait for clk_period/2;
    clk_i <= '1';
    wait for clk_period/2;
  end process;

  rst_i        <= '1', '0' after 40 ns;
  asel_aedit_i <= '0';
  inc_i        <= '0', '1' after 50 ns, '0' after 70 ns, '1' after 90 ns, '0' after 110 ns;
  dec_i        <= '0', '1' after 150 ns, '0' after 170 ns, '1' after 190 ns, '0' after 210 ns;

end tb;
