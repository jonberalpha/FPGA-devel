-------------------------------------------------------------------------------
-- Engineer:       Berger Jonas
-- Create Date:    13.02.2023
-- Design Name:    FPGA Top
-- Module Name:    fpga_top - struc
-- Project Name:   FPGA-Embedded-Functiongenerator
-- Revision:       V01
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.fpga_top_pkg.all; -- location of fpga_top-component declarations

entity fpga_top is
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
end fpga_top;

architecture struc of fpga_top is

  -- Declare the signals used for interconnection of the submodules
  signal s_pb_s90               : std_logic;
  signal s_tick                 : std_logic;
  signal s_ramp                 : signed(G_DATA_WIDTH - 1 downto 0);
  signal s_shifted_ramp         : signed(G_DATA_WIDTH - 1 downto 0);
  signal s_attn_signal          : signed(G_DATA_WIDTH - 1 downto 0);
  signal s_signal_signed        : signed(G_DATA_WIDTH - 1 downto 0);
  signal s_signal_signed_offset : signed(G_DATA_WIDTH downto 0);

  signal s_attr_value_attn        : std_logic_vector(2 downto 0);
  signal s_attr_value_signalshape : std_logic_vector(2 downto 0);
  signal s_attr_value_dutycycle   : std_logic_vector(2 downto 0);
  signal s_attr_value_freq        : std_logic_vector(2 downto 0);
  signal s_attr_value_phasedelay  : std_logic_vector(2 downto 0);
  --signal s_attr_value_reserved    : std_logic_vector(2 downto 0);

begin

  i_mmi_top : mmi_top
  port map(
    clk_i                    => clk_i,
    rst_i                    => rst_i,
    pb_i                     => pb_i,
    rotenc_i                 => rotenc_i,
    attr_value_dutycycle_o   => s_attr_value_dutycycle,
    attr_value_freq_o        => s_attr_value_freq,
    attr_value_phasedelay_o  => s_attr_value_phasedelay,
    attr_value_attn_o        => s_attr_value_attn,
    attr_value_reserved_o    => open,
    attr_value_signalshape_o => s_attr_value_signalshape,
    led_o                    => led_o,
    pb_s90_o                 => s_pb_s90,
    ss_o                     => ss_o,
    ss_sel_o                 => ss_sel_o
  );

  i_ramp_gen : ramp_gen
  generic map(
    G_DATA_WIDTH => G_DATA_WIDTH
  )
  port map(
    clk_i   => clk_i,
    rst_i   => rst_i,
    f_reg_i => s_attr_value_freq,
    tick_o  => s_tick,
    ramp_o  => s_ramp
  );

  i_phase_shift : phase_shift
  generic map(
    G_DATA_WIDTH => G_DATA_WIDTH
  )
  port map(
    ramp_i            => s_ramp,
    phase_shift_sel_i => s_attr_value_phasedelay,
    shifted_ramp_o    => s_shifted_ramp
  );

  i_func_mod_top : func_mod_top
  generic map(
    G_DATA_WIDTH => G_DATA_WIDTH
  )
  port map(
    clk_i          => clk_i,
    rst_i          => rst_i,
    tick_i         => s_tick,
    signal_shape_i => s_attr_value_signalshape,
    duty_cycle_i   => s_attr_value_dutycycle,
    ramp_i         => s_shifted_ramp,
    pb_s90_i       => s_pb_s90,
    signal_o       => s_signal_signed
  );

  i_attn_apply : attn_apply
  generic map(
    G_DATA_WIDTH => G_DATA_WIDTH
  )
  port map(
    attn_sel_i    => s_attr_value_attn,
    signal_i      => s_signal_signed,
    attn_signal_o => s_attn_signal
  );

  signal_o <= std_logic_vector(s_attn_signal + x"80"); -- from value range 80-7F to 00-FF

end struc;
