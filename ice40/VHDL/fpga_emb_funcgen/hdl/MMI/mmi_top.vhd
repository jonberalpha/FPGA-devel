-------------------------------------------------------------------------------
-- Company:        FHTW
-- Engineer:       Berger Jonas
-- Create Date:    10.02.2023
-- Design Name:    MMI Top
-- Module Name:    mmi_top - struc
-- Project Name:   FPGA-Embedded-Funktionsgenerator
-- Revision:       V01
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.mmi_pkg.all; -- location of mmi-component declarations

entity mmi_top is
  port (
    clk_i    : in std_logic;
    rst_i    : in std_logic;
    rotenc_i : in std_logic_vector(3 downto 0);

    attr_value_signalshape_o : out std_logic_vector(2 downto 0);
    attr_value_freq_o        : out std_logic_vector(2 downto 0);
    attr_value_dutycycle_o   : out std_logic_vector(2 downto 0);
    attr_value_attn_o        : out std_logic_vector(2 downto 0);
    attr_value_phasedelay_o  : out std_logic_vector(2 downto 0);
    attr_value_reserved_o    : out std_logic_vector(2 downto 0);

    pb_s90_o : out std_logic);
end mmi_top;

architecture struc of mmi_top is

  -- Declare the signals used for interconnection of the submodules
  signal s_inc           : std_logic;
  signal s_dec           : std_logic;
  signal s_asel_aedit    : std_logic;
  signal s_selected_attr : std_logic_vector(2 downto 0);

  signal s_enA1_signalshape : std_logic;
  signal s_enA2_freq        : std_logic;
  signal s_enA3_dutycycle   : std_logic;
  signal s_enA4_attn        : std_logic;
  signal s_enA5_phasedelay  : std_logic;
  signal s_enA6_reserved    : std_logic;

  signal s_attr_value_signalshape : std_logic_vector(2 downto 0);
  signal s_attr_value_freq        : std_logic_vector(2 downto 0);
  signal s_attr_value_dutycycle   : std_logic_vector(2 downto 0);
  signal s_attr_value_attn        : std_logic_vector(2 downto 0);
  signal s_attr_value_phasedelay  : std_logic_vector(2 downto 0);
  signal s_attr_value_reserved    : std_logic_vector(2 downto 0);

begin

  -- Instantiate IO Control
  i_io_ctrl : io_ctrl
  generic map(
    G_BUTTON_CNT => 2
  )
  port map(
    clk_i        => clk_i,
    rst_i        => rst_i,
    rotenc_i     => rotenc_i,
    pb_s90_o     => pb_s90_o,
    inc_o        => s_inc,
    dec_o        => s_dec,
    asel_aedit_o => s_asel_aedit
  );

  -- Instantiate all attribute registers
  i_attr_reg_signalshape : attr_reg
  generic map(
    G_REG_WIDTH => 3,
    G_RST_VALUE => "100"
  )
  port map(
    clk_i        => clk_i,
    rst_i        => rst_i,
    asel_edit_i  => s_asel_aedit,
    sel_attr_i   => s_enA1_signalshape,
    inc_i        => s_inc,
    dec_i        => s_dec,
    attr_value_o => s_attr_value_signalshape
  );

  attr_value_signalshape_o <= s_attr_value_signalshape;

  i_attr_reg_freq : attr_reg
  generic map(
    G_REG_WIDTH => 3,
    G_RST_VALUE => "100"
  )
  port map(
    clk_i        => clk_i,
    rst_i        => rst_i,
    asel_edit_i  => s_asel_aedit,
    sel_attr_i   => s_enA2_freq,
    inc_i        => s_inc,
    dec_i        => s_dec,
    attr_value_o => s_attr_value_freq
  );

  attr_value_freq_o <= s_attr_value_freq;

  i_attr_reg_dutycycle : attr_reg
  generic map(
    G_REG_WIDTH => 3,
    G_RST_VALUE => "011"
  )
  port map(
    clk_i        => clk_i,
    rst_i        => rst_i,
    asel_edit_i  => s_asel_aedit,
    sel_attr_i   => s_enA3_dutycycle,
    inc_i        => s_inc,
    dec_i        => s_dec,
    attr_value_o => s_attr_value_dutycycle
  );

  attr_value_dutycycle_o <= s_attr_value_dutycycle;

  i_attr_reg_attn : attr_reg
  generic map(
    G_REG_WIDTH => 3,
    G_RST_VALUE => "000"
  )
  port map(
    clk_i        => clk_i,
    rst_i        => rst_i,
    asel_edit_i  => s_asel_aedit,
    sel_attr_i   => s_enA4_attn,
    inc_i        => s_inc,
    dec_i        => s_dec,
    attr_value_o => s_attr_value_attn
  );

  attr_value_attn_o <= s_attr_value_attn;

  i_attr_reg_phasedelay : attr_reg
  generic map(
    G_REG_WIDTH => 3,
    G_RST_VALUE => "000"
  )
  port map(
    clk_i        => clk_i,
    rst_i        => rst_i,
    asel_edit_i  => s_asel_aedit,
    sel_attr_i   => s_enA5_phasedelay,
    inc_i        => s_inc,
    dec_i        => s_dec,
    attr_value_o => s_attr_value_phasedelay
  );

  attr_value_phasedelay_o <= s_attr_value_phasedelay;

  i_attr_reg_reserved : attr_reg
  generic map(
    G_REG_WIDTH => 3,
    G_RST_VALUE => "000"
  )
  port map(
    clk_i        => clk_i,
    rst_i        => rst_i,
    asel_edit_i  => s_asel_aedit,
    sel_attr_i   => s_enA6_reserved,
    inc_i        => s_inc,
    dec_i        => s_dec,
    attr_value_o => s_attr_value_reserved
  );

  attr_value_reserved_o <= s_attr_value_reserved;

  i_attr_sel : attr_sel
  port map(
    clk_i           => clk_i,
    rst_i           => rst_i,
    asel_aedit_i    => s_asel_aedit,
    inc_i           => s_inc,
    dec_i           => s_dec,
    selected_attr_o => s_selected_attr,
    sel_1_o         => s_enA1_signalshape,
    sel_2_o         => s_enA2_freq,
    sel_3_o         => s_enA3_dutycycle,
    sel_4_o         => s_enA4_attn,
    sel_5_o         => s_enA5_phasedelay,
    sel_6_o         => s_enA6_reserved
  );

end struc;