-------------------------------------------------------------------------------
-- Engineer:       Berger Jonas
-- Create Date:    13.02.2023
-- Design Name:    Variable Rectangle Modulator Testbench
-- Module Name:    rect_var_mod - tb
-- Project Name:   FPGA-Embedded-Functiongenerator
-- Revision:       V01
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_rect_var_mod is
end entity tb_rect_var_mod;

architecture tb of tb_rect_var_mod is

  -- Signal declarations
  signal phase_i     : signed (7 downto 0);
  signal dutycycle_i : std_logic_vector (2 downto 0);
  signal rect_var_o  : signed (7 downto 0);
  signal clk_i       : std_logic;

  constant clk_period : time := 10 ns;

  -- Component declaration for rect_var_mod
  component rect_var_mod is
    generic (
      G_DATA_WIDTH : natural
    );
    port (
      phase_i     : in signed (G_DATA_WIDTH - 1 downto 0);
      dutycycle_i : in std_logic_vector (2 downto 0);

      rect_var_o : out signed (G_DATA_WIDTH - 1 downto 0));
  end component rect_var_mod;
begin

  -- Port map declaration for rect_var_mod
  i_rect_var_mod : rect_var_mod
  generic map(
    G_DATA_WIDTH => 8
  )
  port map(
    phase_i     => phase_i,
    dutycycle_i => dutycycle_i,
    rect_var_o  => rect_var_o
  );

  -- Clock process
  P_clk : process
  begin
    clk_i <= '0';
    wait for clk_period/2;
    clk_i <= '1';
    wait for clk_period/2;
  end process;

  dutycycle_i <= "100";

  P_phase : process
  begin
    for j in 0 to 1 loop
      for i in 16#00# to 16#FF# loop -- hex2int-Syntax is used: base#value#
        wait until clk_i'event and clk_i = '0';
        phase_i <= to_signed(i - 16#7F#, 8); -- 8 bits -> 7 downto 0, take away offset
      end loop;
    end loop;
    wait;
  end process;

end tb;
