library ieee;
use ieee.std_logic_1164.all;

entity tb_blinky is
end entity tb_blinky;

architecture sim of tb_blinky is
    signal clk : std_logic := '0';
    signal led : std_logic;
begin

    dut : entity work.blinky
        port map (
            clk => clk,
            led => led
        );

    clk <= not clk after 5 ns; -- 100 MHz

    process
    begin
        wait for 2000 ns; -- 200 clock cycles
        report "simulation finished";
        std.env.finish;
    end process;

end architecture sim;
