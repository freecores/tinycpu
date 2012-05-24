--Memory management component
--By having this separate, it should be fairly easy to add RAMs or ROMs later
--This basically lets the CPU not have to worry about how memory "Really" works
--currently just one RAM. 1024 byte blockram.vhd mapped as 0 - 1023

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity top is
  port(
    Reset: in std_logic;
    Hold: in std_logic;
    HoldAck: out std_logic;
    Clock: in std_logic;
    DMA: in std_logic; --when high, Address, WriteEnable, and Data are connected to memory
    Address: in std_logic_vector(15 downto 0); --memory address (in bytes)
    WriteEnable: in std_logic;
    Data: inout std_logic_vector(15 downto 0);
    Port0: inout std_logic_vector(7 downto 0);
    --debug ports
    DebugR0: out std_logic_vector(7 downto 0)
  );
end top;

architecture Behavioral of top is

  component memory is
    port(
      Address: in std_logic_vector(15 downto 0); --memory address (in bytes)
      WriteWord: in std_logic; --if set, will write a full 16-bit word instead of a byte. Address must be aligned to 16-bit address. (bottom bit must be 0)
      WriteEnable: in std_logic;
      Clock: in std_logic;
      DataIn: in std_logic_vector(15 downto 0);
      DataOut: out std_logic_vector(15 downto 0);
      Port0: inout std_logic_vector(7 downto 0)
    );
  end component;

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
  signal cpuaddr: std_logic_vector(15 downto 0);
  signal cpuww: std_logic;
  signal cpuwe: std_logic;
  signal cpumemin: std_logic_vector(15 downto 0);
  signal cpumemout: std_logic_vector(15 downto 0);
  signal debugir: std_logic_vector(15 downto 0);
  signal debugip: std_logic_vector(7 downto 0);
  signal debugcs: std_logic_vector(7 downto 0);
  signal debugtr: std_logic;

  signal MemAddress: std_logic_vector(15 downto 0); --memory address (in bytes)
  signal MemWriteWord: std_logic; --if set, will write a full 16-bit word instead of a byte. Address must be aligned to 16-bit address. (bottom bit must be 0)
  signal MemWriteEnable: std_logic;
  signal MemDataIn: std_logic_vector(15 downto 0);
  signal MemDataOut: std_logic_vector(15 downto 0);
begin
  cpu: core port map (
    MemAddr => cpuaddr,
    MemWW => cpuww,
    MemWE => cpuwe,
    MemIn => cpumemin,
    MemOut => cpumemout,
    Clock => Clock,
    Reset => Reset,
    Hold => Hold,
    HoldAck => HoldAck,
    DebugIR => DebugIR,
    DebugIP => DebugIP,
    DebugCS => DebugCS,
    DebugTR => DebugTR,
    DebugR0 => DebugR0
  );
  mem: memory port map(
    Address => MemAddress,
    WriteWord => MemWriteWord,
    WriteEnable => MemWriteEnable,
    Clock => Clock,
    DataIn => MemDataIn,
    DataOut => MemDataOut,
    Port0 => Port0
  );

  MemAddress <= cpuaddr when DMA='0' else Address;
  MemWriteWord <= cpuww when DMA='0' else '1';
  MemWriteEnable <= cpuwe when DMA='0' else WriteEnable;
  MemDataIn <= cpumemout when DMA='0' else Data when WriteEnable='1' else "ZZZZZZZZZZZZZZZZ";
  cpumemin <= MemDataOut;
  Data <= MemDataOut when DMA='1' and WriteEnable='0' else "ZZZZZZZZZZZZZZZZ";

end Behavioral;