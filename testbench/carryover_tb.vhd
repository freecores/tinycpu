LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.tinycpu.all;

ENTITY carryover_tb IS
END carryover_tb;
 
ARCHITECTURE behavior OF carryover_tb IS 
 
-- Component Declaration for the Unit Under Test (UUT)
 
  component carryover is 
    port(
      EnableCarry: in std_logic;
      DataIn: in std_logic_vector(7 downto 0);
      SegmentIn: in std_logic_vector(7 downto 0);
      Addend: in std_logic_vector(7 downto 0); --How much to increase DataIn by (as a signed number). Believe it or not, that's the actual word for what we need.
      DataOut: out std_logic_vector(7 downto 0);
      SegmentOut: out std_logic_vector(7 downto 0)
--      Debug: out std_logic_vector(8 downto 0)
    );
  end component;
    

  --Inputs
  signal EnableCarry: std_logic := '0';
  signal DataIn: std_logic_vector(7 downto 0) := "00000000";
  signal Addend: std_logic_vector(7 downto 0) := "00000000";
  signal SegmentIn: std_logic_vector(7 downto 0) := "00000000";
  --Outputs
  signal DataOut: std_logic_vector(7 downto 0);
  signal SegmentOut: std_logic_vector(7 downto 0);
--  signal Debug: std_logic_vector(8 downto 0);

  signal Clock: std_logic;
  constant clock_period : time := 10 ns;
 
BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut: carryover PORT MAP (
    EnableCarry => EnableCarry,
    DataIn => DataIn,
    Addend => Addend,
    SegmentIn => SegmentIn,
    DataOut => DataOut,
    SegmentOut => SegmentOut
--    Debug => Debug
  );

  -- Clock process definitions
  clock_process :process
  begin
    Clock <= '0';
    wait for clock_period/2;
    Clock <= '1';
    wait for clock_period/2;
  end process;
 

  -- Stimulus process
  stim_proc: process
    variable err_cnt: integer :=0;
  begin         
    -- hold reset state for 20 ns.
    wait for 20 ns;    

    --wait for clock_period*10;
    EnableCarry <= '1';
    -- case 1
    DataIn <= x"10";
    Addend <= x"02";
    SegmentIn <= x"00";
    wait for 10 ns;
    assert (SegmentOut=x"00" and DataOut = x"12") report "Addition Carryover when not appropriate" severity error;
    --case 2
    DataIn <= x"10";
    Addend <= x"FE"; -- -2
    SegmentIn <= x"00";
    wait for 10 ns;
    assert (SegmentOut=x"00" and DataOut = x"0E") report "Subtraction Carryover when not appropriate" severity error;
    
    DataIn <= x"10";
    Addend <= x"EE"; -- -18 (-0x12)
    SegmentIn <= x"00";
    wait for 10 ns;
    assert (SegmentOut=x"FF" and DataOut = x"FE") report "Subtraction Carryover Error" severity error;
    
    DataIn <= x"FE";
    Addend <= x"04";
    SegmentIn <= x"00";
    wait for 10 ns;
    assert (SegmentOut=x"01" and DataOut = x"02") report "Addition Carryover Error" severity error;


    -- summary of testbench
    assert false
    report "Testbench of carryover completed successfully!"
    severity note;

    wait;

    -- insert stimulus here 

    wait;
  end process;


END;
