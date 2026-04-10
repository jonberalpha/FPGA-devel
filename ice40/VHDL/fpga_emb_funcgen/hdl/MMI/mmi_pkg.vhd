-------------------------------------------------------------------------------
-- Company:        FHTW
-- Engineer:       Berger Jonas
-- Create Date:    10.02.2023
-- Design Name:    MMI Package
-- Module Name:    mmi_pkg - pkg
-- Project Name:   FPGA-Embedded-Funktionsgenerator
-- Revision:       V01
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

package mmi_pkg is

  component io_ctrl is
    generic (
      G_BUTTON_CNT : natural
    );
    port (
      clk_i : in std_logic;
      rst_i : in std_logic;

      rotenc_i : in std_logic_vector (3 downto 0);

      pb_s90_o     : out std_logic;
      inc_o        : out std_logic;
      dec_o        : out std_logic;
      asel_aedit_o : out std_logic);
  end component io_ctrl;

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

  component attr_sel is
    port (
      clk_i        : in std_logic;
      rst_i        : in std_logic;
      asel_aedit_i : in std_logic;
      inc_i        : in std_logic;
      dec_i        : in std_logic;

      selected_attr_o : out std_logic_vector (2 downto 0);
      sel_1_o         : out std_logic;
      sel_2_o         : out std_logic;
      sel_3_o         : out std_logic;
      sel_4_o         : out std_logic;
      sel_5_o         : out std_logic;
      sel_6_o         : out std_logic);
  end component attr_sel;

end mmi_pkg;