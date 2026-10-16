library ieee;
use ieee.std_logic_1164.all;

entity pll is
  port (
    clkin  : in std_logic;  -- input clock (27 MHz)
    clkout : out std_logic; -- generated clock (20.25 MHz)
    locked : out std_logic
  );
end entity;

architecture rtl of pll is
  -- Gowin rPLL primitive: fixed settings, see parameters below
  -- generated with: gowin_pll -i 27 -o 20 -d "GW2A-18 C8/I7"
  -- PFD = 6.75 MHz, VCO = 648 MHz, CLKOUT = 20.25 MHz
  component rPLL
    generic (
      FCLKIN    : string  := "27.0";
      IDIV_SEL  : integer := 3;
      FBDIV_SEL : integer := 2;
      ODIV_SEL  : integer := 32
    );
    port (
      CLKIN    : in std_logic;
      CLKFB    : in std_logic;
      RESET    : in std_logic;
      RESET_P  : in std_logic;
      FBDSEL   : in std_logic_vector(5 downto 0);
      IDSEL    : in std_logic_vector(5 downto 0);
      ODSEL    : in std_logic_vector(5 downto 0);
      PSDA     : in std_logic_vector(3 downto 0);
      DUTYDA   : in std_logic_vector(3 downto 0);
      FDLY     : in std_logic_vector(3 downto 0);
      CLKOUT   : out std_logic;
      LOCK     : out std_logic;
      CLKOUTP  : out std_logic;
      CLKOUTD  : out std_logic;
      CLKOUTD3 : out std_logic
    );
  end component;
begin

  pll_inst : rPLL
  generic map(
    FCLKIN    => "27.0",
    IDIV_SEL  => 3,
    FBDIV_SEL => 2,
    ODIV_SEL  => 32
  )
  port map
  (
    CLKIN    => clkin,
    CLKFB    => '0',
    RESET    => '0',
    RESET_P  => '0',
    FBDSEL   => (others => '0'),
    IDSEL    => (others => '0'),
    ODSEL    => (others => '0'),
    PSDA     => (others => '0'),
    DUTYDA   => (others => '0'),
    FDLY     => (others => '0'),
    CLKOUT   => clkout,
    LOCK     => locked,
    CLKOUTP  => open,
    CLKOUTD  => open,
    CLKOUTD3 => open
  );

end architecture;
