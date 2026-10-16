-- LED blink with button on/off toggle (VHDL).
-- btn_rst  : reset (first button) - re-enables blinking
-- btn_user : function button - toggles whether led(0) blinks
-- Remaining LEDs stay off. Onboard LEDs are active low.

library ieee;
use ieee.std_logic_1164.all;

entity led_toggle is
  generic (
    CLK_HZ          : positive := 27_000_000;
    BLINK_HZ        : positive := 2;       -- LED toggles at this rate
    DEBOUNCE_CYCLES : positive := 540_000; -- 20 ms @ 27 MHz
    BTN_ACTIVE_LOW  : boolean  := false;
    NUM_LEDS        : positive := 6
  );
  port (
    clk      : in std_logic;
    btn_rst  : in std_logic;
    btn_user : in std_logic;
    led      : out std_logic_vector(NUM_LEDS - 1 downto 0)
  );
end entity;

architecture rtl of led_toggle is
  constant BLINK_HALF : positive := CLK_HZ / (2 * BLINK_HZ);

  signal rst_sync    : std_logic_vector(1 downto 0) := "00";
  signal rst         : std_logic;
  signal sync        : std_logic_vector(1 downto 0) := "00";
  signal btn_pressed : std_logic;
  signal btn_stable  : std_logic := '0';
  signal btn_prev    : std_logic := '0';
  signal deb_cnt     : natural range 0 to DEBOUNCE_CYCLES := 0;
  signal enabled     : std_logic := '1';
  signal blink_cnt   : natural range 0 to BLINK_HALF := 0;
  signal blink       : std_logic := '0';
  signal led0_on     : std_logic;
begin

  rst         <= not rst_sync(1) when BTN_ACTIVE_LOW else rst_sync(1);
  btn_pressed <= not sync(1) when BTN_ACTIVE_LOW else sync(1);

  -- synchronize, debounce, edge detect, toggle
  process (clk)
  begin
    if rising_edge(clk) then
      rst_sync <= rst_sync(0) & btn_rst;
      sync     <= sync(0) & btn_user;

      if btn_pressed = btn_stable then
        deb_cnt <= 0;
      elsif deb_cnt = DEBOUNCE_CYCLES - 1 then
        deb_cnt    <= 0;
        btn_stable <= btn_pressed;
      else
        deb_cnt <= deb_cnt + 1;
      end if;

      btn_prev <= btn_stable;
      if rst = '1' then
        enabled <= '1';
      elsif btn_stable = '1' and btn_prev = '0' then
        enabled <= not enabled;
      end if;
    end if;
  end process;

  -- blink
  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        blink_cnt <= 0;
        blink     <= '0';
      elsif blink_cnt = BLINK_HALF - 1 then
        blink_cnt <= 0;
        blink     <= not blink;
      else
        blink_cnt <= blink_cnt + 1;
      end if;
    end if;
  end process;

  led0_on <= enabled and blink;

  -- active low: '0' lights the LED
  led(0) <= not led0_on;
  led(NUM_LEDS - 1 downto 1) <= (others => '1');

end architecture;
