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

package func_mod_pkg is

  component ramp_fall_mod is
    generic (
      G_DATA_WIDTH : natural
    );
    port (
      phase_i : in signed (G_DATA_WIDTH - 1 downto 0);

      ramp_fall_o : out signed (G_DATA_WIDTH - 1 downto 0));
  end component ramp_fall_mod;

  component rect_50_mod is
    generic (
      G_DATA_WIDTH : natural
    );
    port (
      phase_msb_i : in std_logic;

      rect_50_o : out signed (G_DATA_WIDTH - 1 downto 0));
  end component rect_50_mod;

  component rect_var_mod is
    generic (
      G_DATA_WIDTH : natural
    );
    port (
      phase_i     : in signed (G_DATA_WIDTH - 1 downto 0);
      dutycycle_i : in std_logic_vector (2 downto 0);

      rect_var_o : out signed (G_DATA_WIDTH - 1 downto 0));
  end component rect_var_mod;

  component cosine_mod is
    generic (
      G_DATA_WIDTH : natural
    );
    port (
      clk_i   : in std_logic;
      rst_i   : in std_logic;
      tick_i  : in std_logic;
      phase_i : in std_logic_vector (7 downto 0);
      s90_i   : in std_logic;

      cosine_o : out signed (G_DATA_WIDTH - 1 downto 0));
  end component cosine_mod;

  component tri_mod is
    generic (
      G_DATA_WIDTH : natural
    );
    port (
      clk_i   : in std_logic;
      rst_i   : in std_logic;
      tick_i  : in std_logic;
      phase_i : in signed (G_DATA_WIDTH - 1 downto 0);

      tri_o : out signed (G_DATA_WIDTH - 1 downto 0)
    );
  end component tri_mod;

  component pn_gen is
    generic (
      G_DATA_WIDTH : natural;
      G_SEED       : std_logic_vector
    );
    port (
      clk_i  : in std_logic;
      rst_i  : in std_logic;
      tick_i : in std_logic;

      pn_o : out signed (G_DATA_WIDTH - 1 downto 0));
  end component pn_gen;

  component shape_mux is
    generic (
      G_DATA_WIDTH : natural
    );
    port (
      shape_sel_i : in std_logic_vector(2 downto 0);
      ramp_rise_i : in signed(G_DATA_WIDTH - 1 downto 0);
      ramp_fall_i : in signed(G_DATA_WIDTH - 1 downto 0);
      rect_50_i   : in signed(G_DATA_WIDTH - 1 downto 0);
      rect_var_i  : in signed(G_DATA_WIDTH - 1 downto 0);
      cosine_i    : in signed(G_DATA_WIDTH - 1 downto 0);
      tri_i       : in signed(G_DATA_WIDTH - 1 downto 0);
      pn_i        : in signed(G_DATA_WIDTH - 1 downto 0);

      signal_o : out signed (G_DATA_WIDTH - 1 downto 0));
  end component shape_mux;

end func_mod_pkg;