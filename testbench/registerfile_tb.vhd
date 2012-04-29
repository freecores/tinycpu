LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY registerfile_tb IS
END registerfile_tb;
 
ARCHITECTURE behavior OF registerfile_tb IS 
 
-- Component Declaration for the Unit Under Test (UUT)
 
  component registerfile
    port(
      Write:in std_logic_vector(7 downto 0); --what should be put into the write register
      SelRead:in std_logic_vector(2 downto 0); --select which register to read
      SelWrite:in std_logic_vector(2 downto 0); --select which register to write
      UseWrite:in std_logic; --if the register should actually be written to
      Clock:in std_logic;
      Read:out std_logic_vector(7 downto 0) --register to be read output
    );
  end component;
    

  --Inputs
  signal Write : std_logic_vector(7 downto 0) := (others => '0');
  signal SelRead: std_logic_vector(2 downto 0) := (others => '0');
  signal SelWrite: std_logic_vector(2 downto 0) := (others => '0');
  signal UseWrite: std_logic := '0';

  --Outputs
  signal Read : std_logic_vector(7 downto 0);

  signal Clock: std_logic;
  constant clock_period : time := 10 ns;
 
BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut: registerfile PORT MAP (
    Write => Write,
    SelRead => SelRead,
    SelWrite => SelWrite,
    UseWrite => UseWrite,
    Clock => Clock,
    Read => Read
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
    SelWrite <= "000";	
    Write <= "11110000";
    UseWrite <= '1';
    wait for 10 ns;
    SelRead <= "000";
    UseWrite <= '0';
    wait for 10 ns;
    assert (Read="11110000") report "Storage error case 1" severity error;
    if (Read/="11110000") then
	err_cnt:=err_cnt+1;
    end if;

    -- case 2
    SelWrite <= "100";	
    Write <= "11110001";
    UseWrite <= '1';
    wait for 10 ns;
    SelRead <= "100";
    UseWrite <= '0';
    wait for 10 ns;
    assert (Read="11110001") report "Storage selector error case 2" severity error;
    if (Read/="11110001") then
	err_cnt:=err_cnt+1;
    end if;

    -- case 3
    SelRead <= "000";
    UseWrite <= '0';
    wait for 10 ns;
    assert (Read="11110000") report "Storage selector(remembering) error case 3" severity error;
    if (Read/="11110000") then
	err_cnt:=err_cnt+1;
    end if;

    -- summary of testbench
    if (err_cnt=0) then
      assert false
      report "Testbench of registerfile completed successfully!"
      severity note;
    else
      assert true
      report "Something wrong, try again"
      severity error;
    end if;
	    
    wait;

    -- insert stimulus here 

    wait;
  end process;


END;
