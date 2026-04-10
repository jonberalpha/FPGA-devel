-------------------------------------------------------------------------------
-- Engineer:       Berger Jonas
-- Create Date:    10.02.2023
-- Design Name:    IO Control
-- Module Name:    io_ctrl - rtl
-- Project Name:   FPGA-Embedded-Functiongenerator
-- Revision:       V01
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity io_ctrl is
  generic (
    G_BUTTON_CNT : natural := 6
  );
  port (
    clk_i : in std_logic;
    rst_i : in std_logic;

    pb_i     : in std_logic_vector (G_BUTTON_CNT - 3 downto 0); -- only 4 push buttons on board
    rotenc_i : in std_logic_vector (3 downto 0);                -- + 2 from rotary encoder (asel_aedit, S90)

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
end io_ctrl;

architecture rtl of io_ctrl is

  -- *** Component insertions ***
  -- insert debounce module
  component debounce
    port (
      clk_i   : in std_logic;
      rst_i   : in std_logic;
      tick_i  : in std_logic;
      sw_i    : in std_logic;
      swout_o : out std_logic);
  end component debounce;

  -- insert rotary encoder module
  component rotary_encoder
    port (
      clk_i : in std_logic;
      rst_i : in std_logic;
      A_i   : in std_logic;
      B_i   : in std_logic;
      TR_o  : out std_logic;
      TL_o  : out std_logic);
  end component rotary_encoder;

  -- *** Type definitions ***
  -- every 100 000 counts one tick (100MHz/1kHz):
  type t_tick_counter is range 99999 downto 0;   -- define new type
  signal s_tick_count : t_tick_counter;          -- define signal with new type
  constant C_MAX1kHz  : t_tick_counter := 99999; -- define constant with new type

  -- *** Intermediate signal definitions ***
  signal s_1khzen : std_logic; -- enable signal for the 7-segment-displays

  signal s_pb_i           : std_logic_vector (G_BUTTON_CNT - 1 downto 0);
  signal s_pbsync         : std_logic_vector (G_BUTTON_CNT - 1 downto 0); -- synchronized pb-buttons
  signal s_pbsync_clkd    : std_logic_vector (G_BUTTON_CNT - 1 downto 0);
  signal s_sig            : std_logic_vector (G_BUTTON_CNT - 1 downto 0);
  signal s_btn_inc        : std_logic;
  signal s_btn_dec        : std_logic;
  signal s_btn_asel_aedit : std_logic;
  signal s_TR             : std_logic;
  signal s_TL             : std_logic;
  signal s_T_rotenc       : std_logic;
  signal s_Q_rotenc       : std_logic;
  signal s_T_s90          : std_logic;
  signal s_Q_s90          : std_logic;

  signal s_ss_sel   : std_logic_vector (3 downto 0); -- display select signal
  signal s_ABCD_seg : std_logic_vector (3 downto 0);
  signal s_cnt_an   : unsigned(1 downto 0); -- counter variable

begin

  -- Tick counter process to achieve a 1kHz tick signal
  P_tick_1kHz_counter : process (rst_i, clk_i)
  begin
    if rst_i = '1' then
      s_tick_count <= C_MAX1kHz;
      s_1khzen     <= '0';
    elsif clk_i'event and clk_i = '1' then
      if s_tick_count = 0 then
        s_tick_count <= C_MAX1kHz;
        s_1khzen     <= '1';
      else
        s_tick_count <= s_tick_count - 1;
        s_1khzen     <= '0';
      end if;
    end if;
  end process;

  s_pb_i <= rotenc_i(3) & pb_i & rotenc_i(0);

  GEN_btn_debouncers : for i in 0 to G_BUTTON_CNT - 1 generate
    i_debounce_rotenc : debounce
    port map
    (
      clk_i   => clk_i,
      rst_i   => rst_i,
      tick_i  => s_1khzen,
      sw_i    => s_pb_i(i),
      swout_o => s_pbsync(i));
  end generate GEN_btn_debouncers;

  -- Button to tick process: Converts respective button push in one clk period impulse
  P_btn2tick : process (rst_i, clk_i)
  begin
    if rst_i = '1' then
      s_pbsync_clkd <= (others => '0');
      s_sig         <= (others => '0');
    elsif clk_i'event and clk_i = '1' then
      for i in 0 to G_BUTTON_CNT - 1 loop
        if s_sig(i) = '0' and s_pbsync(i) = '1' then
          s_pbsync_clkd(i) <= not s_pbsync_clkd(i);
          s_sig(i)         <= '1';
        else
          s_pbsync_clkd(i) <= '0';
          s_sig(i)         <= s_pbsync(i);
        end if;
      end loop;
    end if;
  end process;

  s_btn_inc        <= s_pbsync_clkd(3);
  s_btn_dec        <= s_pbsync_clkd(2);
  s_btn_asel_aedit <= s_pbsync_clkd(1) or s_pbsync_clkd(0); -- either onboard-pb or rotaryencoder-pb
  s_T_rotenc       <= s_btn_asel_aedit;
  s_T_s90          <= s_pbsync_clkd(4) or s_pbsync_clkd(5); -- either onboard-pb or extra pb on rotenc

  -- T-FlipFlop process Rotary Encoder Button
  P_tff_rotenc : process (rst_i, clk_i)
  begin
    if rst_i = '1' then
      s_Q_rotenc <= '0';
    elsif clk_i'event and clk_i = '1' then
      if s_T_rotenc = '1' then
        s_Q_rotenc <= not(s_Q_rotenc);
      end if;
    end if;
  end process;

  asel_aedit_o <= s_Q_rotenc;

  -- T-FlipFlop process s90 grad button
  P_tff_s90 : process (rst_i, clk_i)
  begin
    if rst_i = '1' then
      s_Q_s90 <= '0'; -- 0 means s90 flag not set -> cosinus
    elsif clk_i'event and clk_i = '1' then
      if s_T_s90 = '1' then
        s_Q_s90 <= not(s_Q_s90);
      end if;
    end if;
  end process;

  pb_s90_o <= s_Q_s90;
  led_o    <= s_Q_s90;

  -- Instantiate rotary encoder module
  i_rotary_encoder : rotary_encoder
  port map
  (
    clk_i => clk_i,
    rst_i => rst_i,
    A_i   => rotenc_i(2),
    B_i   => rotenc_i(1),
    TR_o  => s_TR,
    TL_o  => s_TL);

  inc_o <= s_TR or s_btn_inc;
  dec_o <= s_TL or s_btn_dec;

  -- count Process: 0-3 Counter
  count_p : process (rst_i, clk_i, s_1khzen)
  begin
    if rst_i = '1' then
      s_cnt_an <= "00";
    elsif clk_i'event and clk_i = '1' then
      if s_1khzen = '1' then
        if s_cnt_an = "11" then
          s_cnt_an <= "00";
        else
          s_cnt_an <= s_cnt_an + 1;
        end if;
      end if;
    end if;
  end process;

  -- MUX Process
  mux_p : process (s_cnt_an, A_i, B_i, C_i, D_i, dp_i)
  begin
    case s_cnt_an is
      when "00" => -- First Digit
        ss_sel_o   <= "0111";
        s_ABCD_seg <= A_i;
        if dp_i = "0111" then
          dp_o <= '0';
        else
          dp_o <= '1';
        end if;

      when "01" => -- Second Digit
        ss_sel_o   <= "1011";
        s_ABCD_seg <= B_i;
        if dp_i = "1011" then
          dp_o <= '0';
        else
          dp_o <= '1';
        end if;

      when "10" => -- Third Digit
        ss_sel_o   <= "1101";
        s_ABCD_seg <= C_i;
        if dp_i = "1101" then
          dp_o <= '0';
        else
          dp_o <= '1';
        end if;

      when "11" => -- Fourth Digit
        ss_sel_o   <= "1110";
        s_ABCD_seg <= D_i;
        if dp_i = "1110" then
          dp_o <= '0';
        else
          dp_o <= '1';
        end if;

      when others =>
        ss_sel_o <= "1111";
    end case;
  end process;

  -- bin-7segm-Process: binary to 7-segment
  P_bin_7segm : process (s_ABCD_seg)
  begin
    case s_ABCD_seg is
      when "0000" => ss_o <= "1000000"; -- 0
      when "0001" => ss_o <= "1111001"; -- 1
      when "0010" => ss_o <= "0100100"; -- 2
      when "0011" => ss_o <= "0110000"; -- 3
      when "0100" => ss_o <= "0011001"; -- 4
      when "0101" => ss_o <= "0010010"; -- 5
      when "0110" => ss_o <= "0000010"; -- 6
      when "0111" => ss_o <= "1111000"; -- 7
      when "1000" => ss_o <= "0000000"; -- 8
      when "1001" => ss_o <= "0010000"; -- 9
      when "1010" => ss_o <= "0001000"; -- A
      when "1011" => ss_o <= "0000011"; -- b
      when "1100" => ss_o <= "0100111"; -- c
      when "1101" => ss_o <= "0100001"; -- d
      when "1110" => ss_o <= "0000110"; -- E
      when others => ss_o <= "0001110"; -- F
    end case;
  end process;

end rtl;
