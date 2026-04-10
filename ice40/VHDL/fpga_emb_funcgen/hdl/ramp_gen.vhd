-------------------------------------------------------------------------------
-- Company:        FHTW
-- Engineer:       Berger Jonas
-- Create Date:    10.02.2023
-- Design Name:    Ramp generator
-- Module Name:    ramp_gen - rtl
-- Project Name:   FPGA-Embedded-Funktionsgenerator
-- Revision:       V01
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity ramp_gen is
  generic (
    G_DATA_WIDTH : natural := 8
  );
  port (
    clk_i   : in std_logic;
    rst_i   : in std_logic;
    f_reg_i : in std_logic_vector (2 downto 0);

    tick_o : out std_logic;
    ramp_o : out signed (G_DATA_WIDTH - 1 downto 0));
end ramp_gen;

architecture rtl of ramp_gen is

  type t_tick_counter is range 0 to 7812;--999999; -- define new type
  signal s_tick_count : t_tick_counter; -- define signal with new type
  signal s_tick       : std_logic;      -- tick signal

  -- tickcount: 1, 4, 8, 39, 78, 391, 3906, 7813 all -1
  -- frequency: 390625; 100e3; 48e3; 10e3; 5e3; 1e3; 100; 50
  constant C_MAX_390kHz : t_tick_counter := 0;--0;
  constant C_MAX_100kHz : t_tick_counter := 3;--9;
  constant C_MAX_48kHz  : t_tick_counter := 7;--99;
  constant C_MAX_10kHz  : t_tick_counter := 39;--999;
  constant C_MAX_5kHz   : t_tick_counter := 77;--2082;
  constant C_MAX_1kHz   : t_tick_counter := 390;--9999;
  constant C_MAX_100Hz  : t_tick_counter := 3905;--19999;
  constant C_MAX_50Hz   : t_tick_counter := 7812;--99999;

  signal s_accu : signed (G_DATA_WIDTH - 1 downto 0);

begin

  P_freq_div : process (rst_i, clk_i)
  begin
    if rst_i = '1' then
      s_tick_count <= 0;
      s_tick       <= '0';
    elsif clk_i'event and clk_i = '1' then
      if s_tick_count = 0 then
        case f_reg_i is
          when "000" =>
            s_tick_count <= C_MAX_50Hz;
          when "001" =>
            s_tick_count <= C_MAX_100Hz;
          when "010" =>
            s_tick_count <= C_MAX_1kHz;
          when "011" =>
            s_tick_count <= C_MAX_5kHz;
          when "100" =>
            s_tick_count <= C_MAX_10kHz;
          when "101" =>
            s_tick_count <= C_MAX_48kHz;
          when "110" =>
            s_tick_count <= C_MAX_100kHz;
          when others =>
            s_tick_count <= C_MAX_390kHz;
        end case;
        s_tick <= '1';
      else
        s_tick_count <= s_tick_count - 1;
        s_tick       <= '0';
      end if;
    end if;
  end process;

  tick_o <= s_tick;

  P_accu : process (rst_i, clk_i)
  begin
    if rst_i = '1' then
      s_accu <= (others => '0');
    elsif clk_i'event and clk_i = '1' then
      if s_tick = '1' then
        s_accu <= s_accu + 1;
      end if;
    end if;
  end process;

  ramp_o <= s_accu;
end rtl;