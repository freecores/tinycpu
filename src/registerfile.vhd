library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all; 

entity registerfile is
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
end registerfile;

architecture Behavioral of registerfile is
  type registerstype is array(0 to 15) of std_logic_vector(7 downto 0);
  signal registers: registerstype;
begin
  writereg: process(Write1, Write2, SelWrite1, SelWrite2, UseWrite1, UseWrite2, Clock)
  begin
    if(UseWrite1='1') then
      if(rising_edge(clock)) then
	registers(conv_integer(SelWrite1)) <= Write1;
      end if;
    end if;
    if(UseWrite2='1') then
      if(rising_edge(clock) and conv_integer(SelWrite1)/=conv_integer(SelWrite2)) then
        registers(conv_integer(SelWrite2)) <= Write2;
      end if;
    end if;
  end process;
  Read1 <= registers(conv_integer(SelRead1));
  Read2 <= registers(conv_integer(SelRead2));
end Behavioral;