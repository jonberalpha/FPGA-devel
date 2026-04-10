----------------------------------------------------------------------------------
-- Company:        HTL Hollabrunn
-- Engineer:       Berger Jonas
-- Create Date:    19/01/2019
-- Design Name:    Linienfolger
-- Module Name:    TickGen - Behavioral 
-- Project Name:   Line_Follower
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TickGen is
    Generic( SIZE : integer := 50 );
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           tick : out  STD_LOGIC);
end TickGen;

architecture Behavioral of TickGen is

--Neuer Datentyp definiert
signal tickcounter : integer range 0 to SIZE-1;
constant max: integer range 0 to SIZE-1 := SIZE-1;

begin

  counter_p: process(clk,rst)
  begin
    if rst = '1' then
       tickcounter <= max;
    elsif clk'event and clk = '1' then
       tickcounter <= tickcounter - 1;
       tick <= '0';
       if tickcounter = 0 then
          tickcounter <= max;
          tick <= '1';
       end if;
    end if;
  end process;

end Behavioral;
