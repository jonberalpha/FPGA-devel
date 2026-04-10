-------------------------------------------------------------------------------
-- Company:        FHTW
-- Engineer:       Berger Jonas
-- Create Date:    12.02.2023
-- Design Name:    Function Modulator Package
-- Module Name:    func_mod_pkg - pkg
-- Project Name:   FPGA-Embedded-Funktionsgenerator
-- Revision:       V01
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

package fpga_top_pkg is

  component mmi_top is
    port (
      clk_i    : in std_logic;
      rst_i    : in std_logic;
      rotenc_i : in std_logic_vector(3 downto 0);

      attr_value_dutycycle_o   : out std_logic_vector(2 downto 0);
      attr_value_freq_o        : out std_logic_vector(2 downto 0);
      attr_value_phasedelay_o  : out std_logic_vector(2 downto 0);
      attr_value_attn_o        : out std_logic_vector(2 downto 0);
      attr_value_reserved_o    : out std_logic_vector(2 downto 0);
      attr_value_signalshape_o : out std_logic_vector(2 downto 0);

      pb_s90_o : out std_logic);
  end component mmi_top;

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

  component phase_shift is
    generic (
      G_DATA_WIDTH : natural
    );
    port (
      ramp_i            : in signed(G_DATA_WIDTH - 1 downto 0);
      phase_shift_sel_i : in std_logic_vector(2 downto 0);

      shifted_ramp_o : out signed(G_DATA_WIDTH - 1 downto 0)
    );
  end component phase_shift;

  component func_mod_top is
    generic (
      G_DATA_WIDTH : natural
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
  end component func_mod_top;

  component attn_apply is
    generic (
      G_DATA_WIDTH : natural
    );
    port (
      attn_sel_i    : in std_logic_vector (2 downto 0);
      signal_i      : in signed (G_DATA_WIDTH - 1 downto 0);
      attn_signal_o : out signed (G_DATA_WIDTH - 1 downto 0));
  end component attn_apply;

end fpga_top_pkg;