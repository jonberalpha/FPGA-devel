library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

architecture spin1 of leds is
  signal counter : unsigned(23 downto 0) := (others => '0');
begin
  cnt_p : process(CLK)
  begin 
    if CLK'event and CLK = '1' then
      counter <= counter + 1;
    end if;
  end process;
  
  LED <= std_logic(counter(23));
  
end spin1;

