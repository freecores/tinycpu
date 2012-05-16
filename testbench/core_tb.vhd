LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.tinycpu.all;

ENTITY core_tb IS
END core_tb;
 
ARCHITECTURE behavior OF core_tb IS 
 
-- Component Declaration for the Unit Under Test (UUT)
 
  component core is 
    port(
      --memory interface 
      MemAddr: out std_logic_vector(15 downto 0); --memory address (in bytes)
      MemWW: out std_logic; --memory writeword
      MemWE: out std_logic; --memory writeenable
      MemIn: in std_logic_vector(15 downto 0);
      MemOut: out std_logic_vector(15 downto 0);
      --general interface
      Clock: in std_logic;
      Reset: in std_logic; --When this is high, CPU will reset within 1 clock cycles. 
      --Enable: in std_logic; --When this is high, the CPU executes as normal, when low the CPU stops at the next clock cycle(maintaining all state)
      Hold: in std_logic; --when high, CPU pauses execution and places Memory interfaces into high impendance state so the memory can be used by other components
      HoldAck: out std_logic; --when high, CPU acknowledged hold and buses are in high Z
      --todo: port interface

      --debug ports:
      DebugIR: out std_logic_vector(15 downto 0); --current instruction
      DebugIP: out std_logic_vector(7 downto 0); --current IP
      DebugCS: out std_logic_vector(7 downto 0); --current code segment
      DebugTR: out std_logic; --current value of TR
      DebugR0: out std_logic_vector(7 downto 0)
    );
  end component;
    

  --memory interface 
  signal MemAddr: std_logic_vector(15 downto 0); --memory address (in bytes)
  signal MemWW: std_logic; --memory writeword
  signal MemWE: std_logic; --memory writeenable
  signal MemOut: std_logic_vector(15 downto 0);
  signal MemIn: std_logic_vector(15 downto 0):=x"0000";
  --general interface
  signal Reset: std_logic:='0'; --When this is high, CPU will reset within 1 clock cycles. 
  --Enable: in std_logic; --When this is high, the CPU executes as normal, when low the CPU stops at the next clock cycle(maintaining all state)
  signal Hold: std_logic:='0'; --when high, CPU pauses execution and places Memory interfaces into high impendance state so the memory can be used by other components
  signal HoldAck: std_logic; --when high, CPU acknowledged hold and buses are in high Z
  --todo: port interface

  --debug ports:
  signal DebugIR: std_logic_vector(15 downto 0); --current instruction
  signal DebugIP: std_logic_vector(7 downto 0); --current IP
  signal DebugCS: std_logic_vector(7 downto 0); --current code segment
  signal DebugTR: std_logic; --current value of TR
  signal DebugR0: std_logic_vector(7 downto 0);

  signal Clock: std_logic;
  constant clock_period : time := 10 ns;
 
BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut: core PORT MAP (
    MemAddr => MemAddr,
    MemWW => MemWW,
    MemWE => MemWE,
    MemOut => MemOut,
    MemIn => MemIn,
    --general interface
    Clock => Clock,
    Reset => Reset,
    --Enable: in std_logic; --When this is high, the CPU executes as normal, when low the CPU stops at the next clock cycle(maintaining all state)
    Hold => Hold,
    HoldAck => HoldAck,
    DebugIR => DebugIR,
    DebugIP => DebugIP,
    DebugCS => DebugCS,
    DebugTR => DebugTR,
    DebugR0 => DebugR0
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
    Reset <= '1';
    wait for 20 ns;    
    
    --state tests:
    Hold <= '1';
    wait for 10 ns;
    assert(HoldAck = '1') report "hold state is not acknowledged" severity error;
    --assert(MemAddr = "ZZZZZZZZZZZZZZZZ" and MemWW="Z" and MemWE="Z" and MemOut = "ZZZZZZZZZZZZZZZZZZZZ")
    --  report "hold state does not set high-Z" severity error;
    Hold <= '0';
    wait for 10 ns;
    assert(HoldAck = '0') report "hold state lasts longer than it should" severity error;
    
    Reset <= '0';
    MemIn <= x"0012"; --mov r0, 0xFF
    wait for 30 ns; --fetcher needs two clock cycles to catch up
    assert(MemAddr = x"0100") report "Not fetching from correct start address" severity error;
    MemIn <= x"00F1"; --mov r0, 0xF1
    wait for 10 ns;
    assert(MemAddr = x"0102") report "fetcher is not incrementing address" severity error;
    assert(DebugIR = x"00F1" and DebugR0 /= x"12") report "IR is not correct. Execution occurs during first fetch";
    MemIn <= x"0056";
    wait for 10 ns;
    assert(DebugR0 = x"F1") report "loaded value of R0 is not correct" severity error;
    wait for 10 ns;
    
    -- summary of testbench
    assert false
    report "Testbench of core completed successfully!"
    severity note;

    wait;

    -- insert stimulus here 

    wait;
  end process;


END;
