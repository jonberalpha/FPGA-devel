-------------------------------------------------------------------------------
-- Company:        FHTW
-- Engineer:       Berger Jonas
-- Create Date:    10.02.2023
-- Design Name:    Function Modulator Top
-- Module Name:    func_mod_top - struc
-- Project Name:   FPGA-Embedded-Funktionsgenerator
-- Revision:       V01
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.func_mod_pkg.all; -- location of func_mod-component declarations

entity func_mod_top is
  generic (
    G_DATA_WIDTH : natural := 8
  );
  port (
    clk_i          : in std_logic;
    rst_i          : in std_logic;
    tick_i         : in std_logic;
    signal_shape_i : in std_logic_vector(2 downto 0);
    duty_cycle_i   : in std_logic_vector(2 downto 0);
    ramp_i         : in signed(G_DATA_WIDTH - 1 downto 0);
    pb_s90_i       : in std_logic;

    signal_o : out signed(G_DATA_WIDTH - 1 downto 0));
end func_mod_top;

architecture struc of func_mod_top is

  -- Declare the signals used for interconnection of the submodules
  signal s_ramp_fall : signed(G_DATA_WIDTH - 1 downto 0);
  signal s_rect_50   : signed(G_DATA_WIDTH - 1 downto 0);
  signal s_rect_var  : signed(G_DATA_WIDTH - 1 downto 0);
  signal s_cosine    : signed(G_DATA_WIDTH - 1 downto 0);
  signal s_tri       : signed(G_DATA_WIDTH - 1 downto 0);
  signal s_pn        : signed(G_DATA_WIDTH - 1 downto 0);

  signal s_signedramp_to_stdlogvecramp : std_logic_vector(G_DATA_WIDTH - 1 downto 0);

begin

  i_ramp_fall_mod : ramp_fall_mod
  generic map(
    G_DATA_WIDTH => G_DATA_WIDTH
  )
  port map(
    phase_i     => ramp_i,
    ramp_fall_o => s_ramp_fall
  );

  i_rect_50_mod : rect_50_mod
  generic map(
    G_DATA_WIDTH => G_DATA_WIDTH
  )
  port map(
    phase_msb_i => ramp_i(G_DATA_WIDTH - 1),
    rect_50_o   => s_rect_50
  );

  i_rect_var_mod : rect_var_mod
  generic map(
    G_DATA_WIDTH => G_DATA_WIDTH
  )
  port map(
    phase_i     => ramp_i,
    dutycycle_i => duty_cycle_i,
    rect_var_o  => s_rect_var
  );

  -- concurrent statement to get absolute of signed ramp as phase-index for the cosine modulator
  s_signedramp_to_stdlogvecramp <= std_logic_vector(ramp_i);

  i_cosine_mod : cosine_mod
  generic map(
    G_DATA_WIDTH => G_DATA_WIDTH
  )
  port map(
    clk_i    => clk_i,
    rst_i    => rst_i,
    tick_i   => tick_i,
    phase_i  => s_signedramp_to_stdlogvecramp,
    s90_i    => pb_s90_i, -- sinus default
    cosine_o => s_cosine
  );

  i_tri_mod : tri_mod
  generic map(
    G_DATA_WIDTH => G_DATA_WIDTH
  )
  port map(
    clk_i   => clk_i,
    rst_i   => rst_i,
    tick_i  => tick_i,
    phase_i => ramp_i,
    tri_o   => s_tri
  );

  i_pn_gen : pn_gen
  generic map(
    G_DATA_WIDTH => 8,
    G_SEED       => x"11"
  )
  port map(
    clk_i  => clk_i,
    rst_i  => rst_i,
    tick_i => tick_i,
    pn_o   => s_pn
  );
  
  i_shape_mux : shape_mux
  generic map(
    G_DATA_WIDTH => G_DATA_WIDTH
  )
  port map(
    shape_sel_i => signal_shape_i,
    ramp_rise_i => ramp_i,
    ramp_fall_i => s_ramp_fall,
    rect_50_i   => s_rect_50,
    rect_var_i  => s_rect_var,
    cosine_i    => s_cosine,
    tri_i       => s_tri,
    pn_i        => s_pn,
    signal_o    => signal_o
  );
end struc;