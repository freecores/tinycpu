LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY memory_tb IS
END memory_tb;
 
ARCHITECTURE behavior OF memory_tb IS 
 
-- Component Declaration for the Unit Under Test (UUT)
 
  component memory
    port(
      Address: in std_logic_vector(15 downto 0); --memory address
      Write: in std_logic; --write or read
      UseTopBits: in std_logic;  --if 1, top 8 bits of data is ignored and not written to memory
      Clock: in std_logic;
      DataIn: in std_logic_vector(15 downto 0);
      DataOut: out std_logic_vector(15 downto 0);
      Reset: in std_logic
    );
  end component;
    

  --Inputs
  signal Address: std_logic_vector(15 downto 0) := (others => '0');
  signal Write: std_logic := '0';
  signal UseTopBits: std_logic := '0';
  signal DataIn: std_logic_vector(15 downto 0) := (others => '0');
  signal Reset: std_logic := '0';

  --Outputs
  signal DataOut: std_logic_vector(15 downto 0);

  signal Clock: std_logic;
  constant clock_period : time := 10 ns;
 
BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut: memory PORT MAP (
    Address => Address,
    Write => Write,
    UseTopBits => UseTopBits,
    Clock => Clock,
    DataIn => DataIn,
    DataOut => DataOut,
    Reset => Reset
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
    Reset <= '1';
    wait for 100 ns;    

    wait for clock_period*10;
    
    --case 1
    Reset <= '0';
    Write <= '0';
    wait for 10 ns;
    Address <= "0000000000001000";
    DataIn <= "1000000000001000";
    Write <= '1';
    UseTopBits <= '1';
    wait for 10 ns;
    Write <= '0';
    wait for 10 ns;
    assert (DataOut="1000000000001000") report "Storage error case 1" severity error;

     --case 2
    Address <= "0000000000001100";
    DataIn <= "1000000000001100";
    Write <= '1';
    UseTopBits <= '1';
    wait for 10 ns;
    Write <= '0';
    wait for 10 ns;
    assert (DataOut="1000000000001100") report "memory selection error case 2" severity error;

    -- case 3
    Address <= "0000000000001000";
    wait for 10 ns;
    assert (DataOut="1000000000001000") report "memory retention error case 3" severity error;
    
    --case 4
    Address <= x"0000";
    Write <= '1';
    DataIn <= x"FFCC";
    wait for 10 ns;
    UseTopBits <= '0';
    DataIn <= x"F0C0";
    wait for 10 ns;
    UseTopBits <='1';
    Write <= '0';
    wait for 10 ns;
    assert (DataOut=x"FFC0") report "ignore top bits error case 4" severity error;
    
    --case 5
    Address <= x"FFFF";
    Write <= '0';
    wait for 10 ns;
    assert (DataOut=x"FFC0") report "memory out of range error case 5" severity error;
    
    --case 6 (fetch and store practical)
    Address <= x"0012";
    wait for 10 ns;
    Address <= x"0000";
    wait for 5 ns;
    assert(DataOut=x"FFC0") report "practical fail 1" severity error;
    Address <= x"00FF";
    Write <= '1';
    DataIn <= x"1234";
    wait for 5 ns;
    Write <= '0';
    wait for 10 ns;
    assert(DataOut=x"1234") report "practical fail 2" severity error;



   assert false
   report "Testbench of memory completed successfully!"
   severity note;
            
    wait;

    -- insert stimulus here 

    wait;
  end process;


END;
