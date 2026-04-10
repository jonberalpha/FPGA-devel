----------------------------------------------------------------------------------
-- Company:      HTBL Hollabrunn
-- Engineer:      Berger Jonas
-- Create Date:    19/01/2019
-- Design Name:    Linienfolger
-- Module Name:    FSM - Behavioral 
-- Project Name:   Line_Follower
-- Revision:       V01
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FSM is
  Port ( HDSensoren : in  STD_LOGIC_VECTOR (3 downto 0);
         LDRs : in  STD_LOGIC_VECTOR (1 downto 0);
         clk : in  STD_LOGIC;
         tick : in STD_LOGIC;
         rst : in  STD_LOGIC;
         Motor : out STD_LOGIC_VECTOR (3 downto 0));
end FSM;

architecture Behavioral of FSM is

  --Definition eines neuen Datentyps fuer die Zustaende
  type state_type is (s_GO, s_STOP, s_TL, s_TR);

  --Definition der temporaeren Zustandssignale:
  --current State: jetziger Zustand
  --next State: naechster Zustand
  signal curState, nextState: state_type;

  --Definition der zu vorverarbeitende Signale 
  signal SENSL, SENSR, LDR: STD_LOGIC;
  
  --Definiton der Ausgangszustandskonstanten
  constant GO: STD_LOGIC_VECTOR:= "1010";
  constant STOP: STD_LOGIC_VECTOR:= "0000";
  constant TURNL: STD_LOGIC_VECTOR:= "1001";
  constant TURNR: STD_LOGIC_VECTOR:= "0110";

begin

  --Input Logic: Vorverarbeitung der Sensoren durch nebenlaeufige Anweisungen
  SENSL <= HDSensoren(3) and HDSensoren(2);
  SENSR <= HDSensoren(1) and HDSensoren(0);
  LDR <= LDRs(1) or LDRs(0);

  --State Register: Zustandsspeicher
  State_Register_p: process(rst, clk)
  begin
    if rst = '1' then   --asynchrones Reset
       curState <= s_GO;
    elsif clk'event and clk = '1' then 
      if tick = '1' then
         curState <= nextState;
      end if;
    end if;
  end process;
  
  --Next State Logic
  Next_State_Logic_p: process(curState, SENSL, SENSR, LDR)
  begin
  
    nextState <= curState; --Default-Anweisung entspricht dem else der ifs
    
    case curState is
      
      when s_GO =>          --Go forward
        if LDR = '1' then
           nextState <= s_STOP;
        else
           if SENSL = '1' and SENSR = '1' then
              nextState <= s_GO;
           elsif SENSL = '0' and SENSR = '0' then
              nextState <= s_GO;
           elsif SENSL = '1' then      
              nextState <= s_TL; 
           elsif SENSR = '1' then
              nextState <= s_TR;
           end if;
        end if;
      
      when s_STOP =>         --Stop
        if LDR = '1' then
           nextState <= curState;
        else
           if SENSL = '1' and SENSR = '1' then
              nextState <= s_GO;
           elsif SENSL = '0' and SENSR = '0' then
              nextState <= s_GO;
           elsif SENSL = '1' then
              nextState <= s_TL; 
           elsif SENSR = '1' then
              nextState <= s_TR;
           end if;
        end if;
      
      when s_TL =>            --Turn left
        if LDR = '1' then
           nextState <= s_STOP;
        else
           if SENSL = '1' and SENSR = '1' then
              nextState <= s_GO;
           elsif SENSL = '0' and SENSR = '0' then
              nextState <= s_GO;
           end if;
        end if;

      when s_TR =>            --Turn right
        if LDR = '1' then
           nextState <= s_STOP;
        else
           if SENSL = '1' and SENSR = '1' then
              nextState <= s_GO;
           elsif SENSL = '0' and SENSR = '0' then
              nextState <= s_GO;
           end if;
        end if;
      
    end case;
  end process;

  --Output Logic
  Output_Logic_p: process(curState)
  begin
    Motor <= GO;    --Default Anweisung
    case curState is 
      when s_GO =>
        Motor <= GO;
      when s_STOP =>
        Motor <= STOP;
      when s_TL =>
        Motor <= TURNL;
      when s_TR =>
        Motor <= TURNR;
    end case;
  end process;
  
end Behavioral;

