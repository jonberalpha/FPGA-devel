library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mc8051_ram is
  port (
    clka  : in std_logic;
    wea   : in std_logic_vector(0 downto 0); -- write enable (1 bit)
    addra : in std_logic_vector(6 downto 0); -- 128 words
    dina  : in std_logic_vector(7 downto 0);
    douta : out std_logic_vector(7 downto 0)
  );
end entity;

architecture rtl of mc8051_ram is
  type ram_t is array (0 to 127) of std_logic_vector(7 downto 0);
  signal ram : ram_t := (others => (others => '0'));
begin
  process (clka)
  begin
    if rising_edge(clka) then
      if wea(0) = '1' then
        ram(to_integer(unsigned(addra))) <= dina;
      end if;
      douta <= ram(to_integer(unsigned(addra)));
    end if;
  end process;
end architecture;
