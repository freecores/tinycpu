LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY registerfile_tb IS
END registerfile_tb;
 
ARCHITECTURE behavior OF registerfile_tb IS 
 
-- Component Declaration for the Unit Under Test (UUT)
 
  component registerfile
    port(
      Write1:in std_logic_vector(7 downto 0); --what should be put into the write register
      Write2: in std_logic_vector(7 downto 0); 
      SelRead1:in std_logic_vector(3 downto 0); --select which register to read
      SelRead2: in std_logic_vector(3 downto 0); --select second register to read
      SelWrite1:in std_logic_vector(3 downto 0); --select which register to write
      SelWrite2:in std_logic_vector(3 downto 0); 
      UseWrite1:in std_logic; --if the register should actually be written to
      UseWrite2: in std_logic;
      Clock:in std_logic;
      Read1:out std_logic_vector(7 downto 0); --register to be read output
      Read2:out std_logic_vector(7 downto 0) --register to be read on second output 
  );
  end component;
    

  --Inputs
  signal Write1 : std_logic_vector(7 downto 0) := (others => '0');
  signal Write2 : std_logic_vector(7 downto 0) := (others => '0');
  signal SelRead1: std_logic_vector(3 downto 0) := (others => '0');
  signal SelRead2: std_logic_vector(3 downto 0) := (others => '0');
  signal SelWrite1: std_logic_vector(3 downto 0) := (others => '0');
  signal SelWrite2: std_logic_vector(3 downto 0) := (others => '0');
  signal UseWrite1: std_logic := '0';
  signal UseWrite2: std_logic := '0';

  --Outputs
  signal Read1 : std_logic_vector(7 downto 0);
  signal Read2 : std_logic_vector(7 downto 0);

  signal Clock: std_logic;
  constant clock_period : time := 10 ns;
 
BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut: registerfile PORT MAP (
    Write1 => Write1,
    Write2 => Write2,
    SelRead1 => SelRead1,
    SelRead2 => SelRead2,
    SelWrite1 => SelWrite1,
    SelWrite2 => SelWrite2,
    UseWrite1 => UseWrite1,
    UseWrite2 => UseWrite2,
    Clock => Clock,
    Read1 => Read1,
    Read2 => Read2
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
    -- hold reset state for 100 ns.
    wait for 100 ns;	

    wait for clock_period*10;

    -- case 1
    SelWrite1 <= "0000";	
    Write1 <= "11110000";
    UseWrite1 <= '1';
    wait for 10 ns;
    SelRead1 <= "0000";
    UseWrite1 <= '0';
    wait for 10 ns;
    assert (Read1="11110000") report "Storage error case 1" severity error;

    -- case 2
    SelWrite1 <= "1000";	
    Write1 <= "11110001";
    UseWrite1 <= '1';
    wait for 10 ns;
    SelRead1 <= "1000";
    UseWrite1 <= '0';
    wait for 10 ns;
    assert (Read1="11110001") report "Storage selector error case 2" severity error;

    -- case 3
    SelRead1 <= "0000";
    UseWrite1 <= '0';
    wait for 10 ns;
    assert (Read1="11110000") report "Storage selector(remembering) error case 3" severity error;
    
    --case 4
    SelWrite1 <= x"0";
    SelWrite2 <= x"1";
    Write1 <= x"12";
    Write2 <= x"34";
    UseWrite1 <= '1';
    UseWrite2 <= '1';
    wait for 10 ns;
    UseWrite1 <= '0';
    UseWrite2 <= '0';
    SelRead1 <= x"0";
    SelRead2 <= x"1";
    wait for 10 ns;
    assert (Read1=x"12" and Read2=x"34") report "simultaneous write and read error case 4" severity error;

    SelWrite1 <= x"0";
    SelWrite2 <= x"0";
    Write1 <= x"ff";
    Write2 <= x"00";
    UseWrite1 <= '1';
    UseWrite2 <= '1';
    wait for 10 ns;
    SelRead1 <= x"0";
    UseWrite1 <= '0';
    UseWrite2 <= '0';
    wait for 10 ns;
    assert (Read1=x"ff") report "dual-write error handling error case 5" severity error;



    -- summary of testbench
    assert false
    report "Testbench of registerfile completed successfully!"
    severity note;

    wait;

    -- insert stimulus here 

    wait;
  end process;


END;
