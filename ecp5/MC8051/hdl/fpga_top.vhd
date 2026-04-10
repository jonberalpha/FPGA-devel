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
    clk_25mhz : in std_logic;                    -- clock signal
    btn       : in std_logic_vector(5 downto 0); -- input buttons

    led : out std_logic_vector(7 downto 0) -- 8 LEDs
  );
end fpga_top;

architecture struc of fpga_top is

  -- uC signals
  signal s_p2_o : std_logic_vector(7 downto 0); -- 8-bit port P2 of mc8051

  signal s_rst_btn     : std_logic;
  signal s_sync_locked : std_logic_vector(2 downto 0); -- sync shift register
  signal s_reset       : std_logic;
  signal s_reset_8051  : std_logic; -- high-active reset for mc8051

  -- PLL signals
  signal s_clk20  : std_logic;
  signal s_locked : std_logic;

begin

  s_rst_btn <= btn(4);

  -- PLL instantiation
  pll_i : entity work.pll
    port map
    (
      clkin  => clk_25mhz,
      clkout => s_clk20,
      locked => s_locked
    );

  -- Generates reset signal for the mc8051:
  -- Synchronizes signal "locked" from the PLL to the 20 MHz uC domain
  -- and deasserts mc8051 reset at the falling clock edge
  -- (should be 25MHz but ECP5 critcal path too bad, Xilinx better)
  P_reset_generator : process (s_rst_btn, s_clk20)
  begin
    if s_rst_btn = '1' then
      s_reset_8051  <= '1';
      s_sync_locked <= (others => '0');
    elsif s_clk20'event and s_clk20 = '0' then
      s_sync_locked(0) <= s_locked;
      s_sync_locked(1) <= s_sync_locked(0);
      s_sync_locked(2) <= s_sync_locked(1);

      if (s_sync_locked(1) = '1') and (s_sync_locked(2) = '0') then
        s_reset_8051 <= '0';
      end if;
    end if;
  end process P_reset_generator;

  s_reset <= s_rst_btn or s_reset_8051;

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
    clk       => s_clk20,
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
  led(7 downto 1) <= (others => '0');
  led(0)          <= s_p2_o(0);

end struc;
