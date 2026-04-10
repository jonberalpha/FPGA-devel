library ieee;
use ieee.std_logic_1164.all;

entity pll is
  port (
    clkin  : in std_logic;  -- input clock
    clkout : out std_logic; -- generated clock
    locked : out std_logic
  );
end entity;

architecture rtl of pll is
  -- 20MHz PLL
  component EHXPLLL
    generic (
      CLKI_DIV     : integer := 5;
      CLKOP_DIV    : integer := 30;
      CLKOP_CPHASE : integer := 14;
      CLKOP_FPHASE : integer := 0;
      CLKOP_ENABLE : string  := "ENABLED";
      FEEDBK_PATH  : string  := "CLKOP";
      CLKFB_DIV    : integer := 4
    );
    port (
      CLKI         : in std_logic;
      CLKOP        : out std_logic;
      CLKFB        : in std_logic;
      RST          : in std_logic;
      STDBY        : in std_logic;
      LOCK         : out std_logic;
      CLKINTFB     : out std_logic;
      PHASESEL0    : in std_logic;
      PHASESEL1    : in std_logic;
      PHASEDIR     : in std_logic;
      PHASESTEP    : in std_logic;
      PHASELOADREG : in std_logic;
      PLLWAKESYNC  : in std_logic;
      ENCLKOP      : in std_logic
    );
  end component;

  signal clkfb : std_logic;
  signal clk_i : std_logic;

begin

  clkout <= clk_i;
  clkfb  <= clk_i;

  pll_inst : EHXPLLL
  generic map(
    CLKI_DIV     => 5,
    CLKOP_DIV    => 30,
    CLKOP_CPHASE => 14,
    CLKOP_FPHASE => 0,
    CLKOP_ENABLE => "ENABLED",
    FEEDBK_PATH  => "CLKOP",
    CLKFB_DIV    => 4
  )
  port map
  (
    CLKI         => clkin,
    CLKOP        => clk_i,
    CLKFB        => clkfb,
    RST          => '0',
    STDBY        => '0',
    LOCK         => locked,
    CLKINTFB     => open,
    PHASESEL0    => '0',
    PHASESEL1    => '0',
    PHASEDIR     => '0',
    PHASESTEP    => '0',
    PHASELOADREG => '0',
    PLLWAKESYNC  => '0',
    ENCLKOP      => '1'
  );

end architecture;
