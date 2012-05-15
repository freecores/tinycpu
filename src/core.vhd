--Core module. 
--This module is basically connects everything and decodes the opcodes.
--The only thing above this is toplevel.vhd which actually sets the pinout for the FPGA


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.tinycpu.all;

entity core is 
  port(
    --memory interface 
    MemAddr: out std_logic_vector(15 downto 0); --memory address (in bytes)
    MemWW: out std_logic; --memory writeword
    MemWE: out std_logic; --memory writeenable
    MemOut: in std_logic_vector(15 downto 0);
    MemIn: out std_logic_vector(15 downto 0);
    --general interface
    Clock: in std_logic;
    Reset: in std_logic; --When this is high, CPU will reset within 1 clock cycles. 
    --Enable: in std_logic; --When this is high, the CPU executes as normal, when low the CPU stops at the next clock cycle(maintaining all state)
    Hold: in std_logic; --when high, CPU pauses execution and places Memory interfaces into high impendance state so the memory can be used by other components
    HoldAck: out std_logic; --when high, CPU acknowledged hold and buses are in high Z
    --todo: port interface

    --debug ports:
    DebugIR: out std_logic_vector(15 downto 0); --current instruction
    DebugIP: out std_logic_vector(15 downto 0); --current IP
    DebugCS: out std_logic_vector(15 downto 0); --current code segment
    DebugTR: out std_logic; --current value of TR
   );
end core;

architecture Behavioral of core is
  component fetch is 
    port(
      Enable: in std_logic;
      AddressIn: in std_logic_vector(15 downto 0);
      Clock: in std_logic;
      DataIn: in std_logic_vector(15 downto 0); --interface from memory
      IROut: out std_logic_vector(15 downto 0);
      AddressOut: out std_logic_vector(15 downto 0) --interface to memory
    );
  end component;
  component alu is
    port(
      Op: in std_logic_vector(4 downto 0);
      DataIn1: in std_logic_vector(7 downto 0);
      DataIn2: in std_logic_vector(7 downto 0);
      DataOut: out std_logic_vector(7 downto 0);
      TR: out std_logic
    );
  end component;
  component carryover is 
    port(
      EnableCarry: in std_logic; --When disabled, SegmentIn goes to SegmentOut
      DataIn: in std_logic_vector(7 downto 0);
      SegmentIn: in std_logic_vector(7 downto 0);
      Addend: in std_logic_vector(7 downto 0); --How much to increase DataIn by (as a signed number). Believe it or not, that's the actual word for what we need.
      DataOut: out std_logic_vector(7 downto 0);
      SegmentOut: out std_logic_vector(7 downto 0)
    );
  end component;
  component registerfile is
  port(
    WriteEnable: in regwritetype;
    DataIn: in regdatatype;
    Clock: in std_logic;
    DataOut: out regdatatype
  );
  end component;

  constant REGIP: integer := 7;
  constant REGSP: integer := 6;
  constant REGSS: integer := 15;
  constant REGES: integer := 14;
  constant REGDS: integer := 13;
  constant REGCS: integer := 12;

  type ProcessorState is (
    ResetProcessor,
    FirstFetch,
    Execute,
    WaitForMemory,
    HoldMemory
  );
  signal state: ProcessState;
  signal HeldState: ProcessState; --state the processor was in when HOLD was activated

  --carryout signals
  signal CarryCS: std_logic;
  signal CarrySS: std_logic;
  signal IPAddend: std_logic_vector(7 downto 0);
  signal SPAddend: std_logic_vector(7 downto 0);
  signal IPCarryOut: std_logic_vector(7 downto 0);
  signal CSCarryOut: std_logic_vector(7 downto 0);
  --register signals
  signal regWE:regwritetype;
  signal regIn: regdatatype;
  signal regOut: regdatatype;
  --fetch signals
  signal fetchEN: std_logic;
  signal IR: std_logic_vector(15 downto 0);
  
  --control signals
  signal InReset: std_logic;

  --opcode shortcut signals
  signal opmain: std_logic_vector(3 downto 0);
  signal opimmd: std_logic_vector(7 downto 0);
  signal opcond1: std_logic; --first conditional bit
  signal opcond2: std_logic; --second conditional bit
  signal opreg1: std_logic_vector(2 downto 0);
  signal opreg2: std_logic_vector(2 downto 0);
  signal opreg3: std_logic_vector(2 downto 0);
  signal opseges: std_logic; --use ES segment
  
begin
  reg: port map registerfile(
    WriteEnable => regWE,
    DataIn => regIn,
    Clock => Clock,
    DataOut => regOut
  );
  carryovercs: port map carryover(
    EnableCarry => CarryCS,
    DataIn => regOut(REGIP);
    SegmentIn => regOut(REGCS);
    Addend => IPAddend;
    DataOut => IPCarryOut;
    SegmentOut => CSCarryOut;\
  );
  fetcher: port map fetch(
    Enable => fetchEN,
    AddressIn => regOut(REGCS) & regOut(REGIP),
    Clock => Clock,
    DataIn => MemIn,
    IROut => IR,
    AddressOut => MemAddr --this component supports tristate, so no worries about an intermediate signal
  );
  
  opmain <= IR(15 downto 12);
  opimmd <= IR(7 downto 0);
  opcond1 <= IR(8);
  opcond2 <= IR(7);
  opreg1 <= IR(11 downto 9);
  opreg3 <= IR(2 downto 0);
  opreg2 <= IR(5 downto 3);
  opseges <= IR(6);
  
  states: process()
  begin
    if rising_edge(Clock) then
      if reset='1' then
        InReset <= '1';
        state <= ResetProcessor;
        CarryCS <= '1';
        CarrySS <= '0';
        --finish up
      elsif InReset='1' and reset='0' and Hold='0' then --reset is done, start executing
        InReset <= '0';
        state <= FirstFetch;
        fetchEN <= '1';
      elsif Hold = '1' and (state=HoldMemory or state=Execute or state=ResetProcessor) then
        state <= HoldMemory;
        HoldAck <= '1';
        FetchEN <= '0';
        MemAddr <= "ZZZZZZZZZZZZZZZZ";
        MemIn <= "ZZZZZZZZZZZZZZZZ";
      elsif Hold='0' and state=HoldMemory then
        state <= ResetProcessor when reset='1' else Execute;
        FetchEN <= '1';
      elsif state=FirstFetch then --we have to let IR get loaded before we can execute.
        state <= Execute; 
      end if;
        
    end if;
  end process;
  
  decode: process()
  begin
    if rising_edge(Clock) and Hold='0' then
      if state=Execute then
        --reset to "usual"
        RegIn(REGIP) <= IPCarryOut;
        RegIn(REGCS) <= CSCarryOut;
        RegWE <= (others => '0');
        
        --actual decoding
        case opmain is 
          when "0000" => --mov reg,imm
            RegIn(to_integer(unsigned(opreg1))) <= opimmd;
            RegWE(to_integer(unsigned(opreg1))) <= '1';
          when others => 
            --synthesis off
            report "Not implemented" severity error;
            --synthesis on
        end case;
      end if;
    end if;
  end process;








  
end Behavioral;