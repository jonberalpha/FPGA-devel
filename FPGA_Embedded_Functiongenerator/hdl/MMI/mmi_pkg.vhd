-------------------------------------------------------------------------------
-- Engineer:       Berger Jonas
-- Create Date:    10.02.2023
-- Design Name:    MMI Package
-- Module Name:    mmi_pkg - pkg
-- Project Name:   FPGA-Embedded-Functiongenerator
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

      pb_i     : in std_logic_vector (G_BUTTON_CNT - 3 downto 0);
      rotenc_i : in std_logic_vector (3 downto 0);

      A_i  : in std_logic_vector (3 downto 0);
      B_i  : in std_logic_vector (3 downto 0);
      C_i  : in std_logic_vector (3 downto 0);
      D_i  : in std_logic_vector (3 downto 0);
      dp_i : in std_logic_vector (3 downto 0);

      led_o        : out std_logic;
      pb_s90_o     : out std_logic;
      ss_o         : out std_logic_vector (6 downto 0);
      ss_sel_o     : out std_logic_vector (3 downto 0);
      dp_o         : out std_logic;
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

  component attr_disp_sel is
    generic (
      G_REG_WIDTH : natural
    );
    port (
      attr_value_signalshape_i : in std_logic_vector (G_REG_WIDTH - 1 downto 0);
      attr_value_freq_i        : in std_logic_vector (G_REG_WIDTH - 1 downto 0);
      attr_value_dutycycle_i   : in std_logic_vector (G_REG_WIDTH - 1 downto 0);
      attr_value_attn_i        : in std_logic_vector (G_REG_WIDTH - 1 downto 0);
      attr_value_phasedelay_i  : in std_logic_vector (G_REG_WIDTH - 1 downto 0);
      attr_value_reserved_i    : in std_logic_vector (G_REG_WIDTH - 1 downto 0);

      asel_aedit_i    : in std_logic;
      selected_attr_i : in std_logic_vector (G_REG_WIDTH - 1 downto 0);

      A_o  : out std_logic_vector (3 downto 0);
      B_o  : out std_logic_vector (3 downto 0);
      C_o  : out std_logic_vector (3 downto 0);
      D_o  : out std_logic_vector (3 downto 0);
      dp_o : out std_logic_vector (3 downto 0));
  end component attr_disp_sel;

end mmi_pkg;
