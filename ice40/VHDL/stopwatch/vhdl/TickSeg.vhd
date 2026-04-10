----------------------------------------------------------------------------------
-- Company:        HTL Hollabrunn
-- Engineer:       Berger Jonas
-- Create Date:    24/02/2018
-- Design Name:    Linienfolger
-- Module Name:    tick_seg - Behavioral 
-- Project Name:   Line_Follower
-- Revision:       V0.1
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TickSeg is
    Generic ( SIZE : integer := 250000 ); -- 200 Hz
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           tick : out  STD_LOGIC);
end TickSeg;

architecture Behavioral of TickSeg is

signal tickcounter: integer range 0 to SIZE-1;
constant max: integer range 0 to SIZE-1 := SIZE-1; 

begin
  counter_p: process(clk,rst)
  begin
    if rst='1' then
       tickcounter <= max;
    elsif clk'event and clk='1' then
       if tickcounter = 0 then
          tickcounter <= max;
          tick <= '1';
       else
          tickcounter <= tickcounter - 1;
          tick <= '0';
       end if;
    end if;
  end process;

end Behavioral;
