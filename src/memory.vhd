library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all; 

entity memory is
  port(
    Address: in std_logic_vector(15 downto 0); --memory address
    Write: in std_logic; --write or read
    UseTopBits: in std_logic;  --if 1, top 8 bits of data is ignored and not written to memory
    Clock: in std_logic;
    DataIn: in std_logic_vector(15 downto 0);
    DataOut: out std_logic_vector(15 downto 0);
    Reset: in std_logic
  );
end memory;

architecture Behavioral of memory is
  constant SIZE : integer := 4096;
  type memorytype is array(0 to (size-1)) of std_logic_vector(7 downto 0);
  signal mem: memorytype;
  
begin

  writemem: process(Reset,Write, Address, UseTopBits, Clock)
    variable addr: integer;
  begin
    addr := conv_integer(Address);
    if(addr>size-1) then
      addr:=0;
    end if;
    if(Reset ='1' and rising_edge(Clock)) then
      mem <= (others => "00000000");
    elsif(Write='1' and Reset='0') then
      if(rising_edge(clock)) then
        mem(conv_integer(addr)) <= DataIn(7 downto 0);
        if(UseTopBits='1') then
          mem(conv_integer(addr)+1) <= DataIn(15 downto 8);
        end if;
      end if;
    end if;
  end process;
  readmem: process(Reset,Address,Write,Clock)
    variable addr: integer;
  begin
    addr := conv_integer(Address);
    if(addr>size-1) then
      addr:=0;
    end if;
    if(Reset='1') then
      DataOut <= (others => '0');
    elsif(Write='0') then
      DataOut <= mem(conv_integer(addr)+1) & mem(conv_integer(addr));
    else 
      DataOut <= (others => '0');
    end if;
  end process;
end Behavioral;