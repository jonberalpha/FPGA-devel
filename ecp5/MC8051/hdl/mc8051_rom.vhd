library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rom_init_pkg.all;

entity mc8051_rom is
  port (
    clka  : in std_logic;
    addra : in std_logic_vector(12 downto 0);
    douta : out std_logic_vector(7 downto 0)
  );
end entity;

architecture rtl of mc8051_rom is
  signal rom_sig : rom_t := ROM; -- copy constant into a signal
begin
  process (clka)
  begin
    if rising_edge(clka) then
      douta <= rom_sig(to_integer(unsigned(addra)));
    end if;
  end process;
end architecture;
