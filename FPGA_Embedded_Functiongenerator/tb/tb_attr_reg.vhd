-------------------------------------------------------------------------------
-- Engineer:       Berger Jonas
-- Create Date:    14.02.2023
-- Design Name:    Attribute Register Testbench
-- Module Name:    attr_reg - tb
-- Project Name:   FPGA-Embedded-Functiongenerator
-- Revision:       V01
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_attr_reg is
end entity tb_attr_reg;

architecture tb of tb_attr_reg is

  -- Signal declarations
  signal clk_i        : std_logic;
  signal rst_i        : std_logic;
  signal asel_edit_i  : std_logic;
  signal sel_attr_i   : std_logic;
  signal inc_i        : std_logic;
  signal dec_i        : std_logic;
  signal attr_value_o : std_logic_vector (2 downto 0);

  constant clk_period : time := 10 ns;

  -- Component declaration for attr_reg
  component attr_reg is
    generic (
      G_REG_WIDTH : natural;
      G_RST_VALUE : unsigned
    );
    port (
      clk_i       : in std_logic;
      rst_i       : in std_logic;
      asel_edit_i : in std_logic;
      sel_attr_i  : in std_logic;
      inc_i       : in std_logic;
      dec_i       : in std_logic;

      attr_value_o : out std_logic_vector (G_REG_WIDTH - 1 downto 0));
  end component attr_reg;

begin

  -- Port map declaration for attr_reg
  i_attr_reg : attr_reg
  generic map(
    G_REG_WIDTH => 3,
    G_RST_VALUE => "000"
  )
  port map(
    clk_i        => clk_i,
    rst_i        => rst_i,
    asel_edit_i  => asel_edit_i,
    sel_attr_i   => sel_attr_i,
    inc_i        => inc_i,
    dec_i        => dec_i,
    attr_value_o => attr_value_o
  );

  -- Clock process definitions
  P_clk_process : process
  begin
    clk_i <= '0';
    wait for clk_period/2;
    clk_i <= '1';
    wait for clk_period/2;
  end process;

  rst_i       <= '1', '0' after 40 ns;
  asel_edit_i <= '1';
  sel_attr_i  <= '1';
  inc_i       <= '0', '1' after 47.5 ns, '0' after 52.5 ns, '1' after 87.5 ns, '0' after 92.5 ns;
  dec_i       <= '0', '1' after 147.5 ns, '0' after 152.5 ns, '1' after 187.5 ns, '0' after 192.5 ns;

end tb;
