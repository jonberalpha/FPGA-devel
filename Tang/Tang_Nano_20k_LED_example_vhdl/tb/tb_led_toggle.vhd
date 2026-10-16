library ieee;
use ieee.std_logic_1164.all;

entity tb_led_toggle is
end entity;

architecture sim of tb_led_toggle is
  signal clk  : std_logic := '0';
  signal btn  : std_logic := '0';
  signal led  : std_logic_vector(5 downto 0);
  signal done : boolean := false;
begin

  -- fast parameters for simulation: 1 kHz clock-equivalent
  dut : entity work.led_toggle
    generic map(CLK_HZ => 1000, BLINK_HZ => 10, DEBOUNCE_CYCLES => 3)
    port map(clk => clk, btn_rst => '0', btn_user => btn, led => led);

  clk <= not clk after 500 us when not done;

  stim : process
    variable before_n, after_n : integer;
    variable errors : integer := 0;

    procedure press is
    begin
      btn <= '1'; wait for 20 ms; btn <= '0'; wait for 20 ms;
    end procedure;

    procedure count_toggles(cycles : integer; n : out integer) is
      variable prev : std_logic;
    begin
      n := 0; prev := led(0);
      for i in 1 to cycles loop
        wait until rising_edge(clk);
        if led(0) /= prev then n := n + 1; end if;
        prev := led(0);
      end loop;
    end procedure;
  begin
    wait for 10 ms;
    count_toggles(200, before_n);
    press; -- disable
    count_toggles(200, after_n);
    report "blinking: " & integer'image(before_n) & " toggles, after press: " & integer'image(after_n);
    if before_n < 3 or after_n /= 0 then errors := errors + 1; end if;
    press; -- re-enable
    count_toggles(200, after_n);
    if after_n < 3 then errors := errors + 1; end if;
    if errors = 0 then report "PASS"; else report "FAIL" severity failure; end if;
    done <= true;
    wait;
  end process;

end architecture;
