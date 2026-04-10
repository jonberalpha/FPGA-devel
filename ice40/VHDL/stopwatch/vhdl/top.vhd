library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
  port (
    clk : in std_logic;
    rst : in std_logic;
    HDSensoren : in std_logic_vector(3 downto 0);
    LDRs : in std_logic_vector(1 downto 0);
    seg : out std_logic_vector(6 downto 0);
    an : out std_logic_vector(3 downto 0);
    dpo : out std_logic
  );
end top;

architecture struc of top is

  component DispMux is
    Port ( A : in  STD_LOGIC_VECTOR (3 downto 0);
           B : in  STD_LOGIC_VECTOR (3 downto 0);
           C : in  STD_LOGIC_VECTOR (3 downto 0);
           D : in  STD_LOGIC_VECTOR (3 downto 0);
           dpi : in  STD_LOGIC_VECTOR (3 downto 0);
           clk : in  STD_LOGIC;
           tick : in STD_LOGIC;
           rst : in  STD_LOGIC;
           seg : out  STD_LOGIC_VECTOR (6 downto 0);
           dpo : out  STD_LOGIC;
           an : out  STD_LOGIC_VECTOR (3 downto 0));
  end component DispMux;
  
  component FSM is
    Port ( HDSensoren : in  STD_LOGIC_VECTOR (3 downto 0);
           LDRs : in  STD_LOGIC_VECTOR (1 downto 0);
           clk : in  STD_LOGIC;
           tick : in STD_LOGIC;
           rst : in  STD_LOGIC;
           Motor : out STD_LOGIC_VECTOR (3 downto 0));
  end component FSM;
  
  component TickGen is
    Generic( SIZE : integer);
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           tick : out  STD_LOGIC);
  end component TickGen;
  
  component TickSeg is
    Generic ( SIZE : integer ); 
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           tick : out  STD_LOGIC);
  end component TickSeg;
  
  signal s_tickfsm : std_logic;
  signal s_tickseg : std_logic;
  signal s_motor : std_logic_vector(3 downto 0);

begin

  i_DispMux : DispMux
    port map (
      A    => x"0",
      B    => x"0",
      C    => x"0",
      D    => s_motor,
      dpi  => x"0",
      clk  => clk,
      tick => s_tickseg,
      rst  => rst,
      seg  => seg,
      dpo  => dpo,
      an   => an
    );
  
  i_FSM : FSM
    port map (
      HDSensoren => HDSensoren,
      LDRs       => LDRs,
      clk        => clk,
      tick       => s_tickfsm,
      rst        => rst,
      Motor      => s_motor
    );
  
  i_TickGen : TickGen
    generic map (
      SIZE => 50
    )
    port map (
      clk  => clk,
      rst  => rst,
      tick => s_tickfsm
    );
  
  i_TickSeg : TickSeg
    generic map (
      SIZE => 250000
    )
    port map (
      clk  => clk,
      rst  => rst,
      tick => s_tickseg
    );

end struc;

