-------------------------------------------------------------------------------
--                        VGA Controller - Project
-------------------------------------------------------------------------------
-- ENTITY:         fpga_top_struc
-- FILENAME:       fpga_top_struc.vhd
-- ARCHITECTURE:   struc
-- ENGINEER:       Jonas Berger
-- DATE:           19.09.2022
-- VERSION:        1.0
-------------------------------------------------------------------------------
-- DESCRIPTION:    This is the architecture struc of the VGA Controller
-------------------------------------------------------------------------------
-- REFERENCES:     (none)
-------------------------------------------------------------------------------
-- PACKAGES:       std_logic_1164  (IEEE library)
-------------------------------------------------------------------------------
-- CHANGES:        Version 1.0 - JB - 19.09.2022
-- ADDITIONAL
-- COMMENTS:       -
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.mc8051_p.all;

entity fpga_top is
  port (
    clk_i   : in std_logic; -- 12 MHz clock signal
    reset_i : in std_logic; -- reset signal

    led_o : out std_logic -- 8 LEDs LED0 - LED7
  );
end fpga_top;

architecture struc of fpga_top is

  -- PLL component declaration
  component SB_PLL40_PAD
    generic (
      FEEDBACK_PATH : string;
      PLLOUT_SELECT : string;
      DIVR          : std_logic_vector(3 downto 0);
      DIVF          : std_logic_vector(6 downto 0);
      DIVQ          : std_logic_vector(2 downto 0);
      FILTER_RANGE  : std_logic_vector(2 downto 0)
    );
    port (
      PACKAGEPIN   : in std_logic;
      PLLOUTGLOBAL : out std_logic;
      LOCK         : out std_logic;
      RESETB       : in std_logic;
      BYPASS       : in std_logic
    );
  end component;

  -- uC signals
  signal s_p2_o : std_logic_vector(7 downto 0); -- 8-bit port P2 of mc8051

  signal s_sync_locked : std_logic_vector(2 downto 0); -- sync shift register
  signal s_reset       : std_logic;
  signal s_reset_8051  : std_logic; -- high-active reset for mc8051

  -- PLL signals
  signal s_locked : std_logic;
  signal s_clk25  : std_logic;

begin

  -- PLL instantiation
  pll_25mhz : SB_PLL40_PAD
  generic map(
    FEEDBACK_PATH => "SIMPLE",
    PLLOUT_SELECT => "GENCLK",
    DIVR          => "0000",
    DIVF          => "1000010",
    DIVQ          => "101",
    FILTER_RANGE  => "001"
  )
  port map
  (
    PACKAGEPIN   => clk_i,
    PLLOUTGLOBAL => s_clk25,
    LOCK         => s_locked,
    RESETB       => '1',
    BYPASS       => '0'
  );

  -- Generates reset signal for the mc8051:
  -- Synchronizes signal "locked" from the PLL to the 25 MHz domain
  -- and deasserts mc8051 reset at the falling clock edge  
  P_reset_generator : process (reset_i, s_clk25)
  begin
    if reset_i = '1' then
      s_reset_8051  <= '1';
      s_sync_locked <= (others => '0');
    elsif s_clk25'event and s_clk25 = '0' then
      s_sync_locked(0) <= s_locked;
      s_sync_locked(1) <= s_sync_locked(0);
      s_sync_locked(2) <= s_sync_locked(1);

      if (s_sync_locked(1) = '1') and (s_sync_locked(2) = '0') then
        s_reset_8051 <= '0';
      end if;
    end if;
  end process P_reset_generator;

  s_reset <= reset_i or s_reset_8051;

  -- instantiation of the mc8051 IP core:
  i_mc8051_top : mc8051_top
  port map
  (
    reset     => s_reset,
    int0_i => (others => '1'),    -- not used in this design
    int1_i => (others => '1'),    -- not used in this design
    all_t0_i => (others => '0'),  -- not used in this design
    all_t1_i => (others => '0'),  -- not used in this design
    all_rxd_i => (others => '0'), -- not used in this design
    all_rxd_o => open,            -- not used in this design
    all_txd_o => open,            -- not used in this design  
    clk       => s_clk25,
    p0_i => (others => '0'), -- not used in this design
    p1_i => (others => '0'), -- not used in this design
    p2_i => (others => '0'), -- not used in this design
    p3_i => (others => '0'), -- not used in this design
    p0_o      => open,       -- not used in this design
    p1_o      => open,       -- not used in this design
    p2_o      => s_p2_o,     -- toggles leds
    p3_o      => open,       -- not used in this design
    test_o    => open        -- not used in this design
  );

  -- Assign uC output to board-leds:
  led_o <= s_p2_o(0);

end struc;
