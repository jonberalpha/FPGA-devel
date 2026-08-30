library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity blinky is
    port (
        clk : in  std_logic;
        led : out std_logic;
        an  : out std_logic_vector(3 downto 0);
        seg : out std_logic_vector(6 downto 0);
        dp  : out std_logic
    );
end entity blinky;

architecture rtl of blinky is
    signal r_count : unsigned(24 downto 0) := (others => '0');
begin

    process (clk)
    begin
        if rising_edge(clk) then
            r_count <= r_count + 1;
        end if;
    end process;

    led <= r_count(24);

    -- Basys3's 7-segment display glows faintly if its pins are left
    -- undriven; hold every digit and segment disabled (active-low).
    an  <= (others => '1');
    seg <= (others => '1');
    dp  <= '1';

end architecture rtl;
