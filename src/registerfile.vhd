library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all; 

entity registerfile is
  port(
    Write:in std_logic_vector(7 downto 0); --what should be put into the write register
    SelRead:in std_logic_vector(2 downto 0); --select which register to read
    SelWrite:in std_logic_vector(2 downto 0); --select which register to write
    UseWrite:in std_logic; --if the register should actually be written to
    Clock:in std_logic;
    Read:out std_logic_vector(7 downto 0) --register to be read output
  );
end registerfile;

architecture Behavioral of registerfile is
  type registerstype is array(0 to 7) of std_logic_vector(7 downto 0);
  signal registers: registerstype;
begin
  writereg: process(Write, SelWrite, UseWrite, Clock)
  begin
    if(UseWrite='1') then
      if(rising_edge(clock)) then
	registers(conv_integer(SelWrite)) <= Write;
      end if;
    end if;
  end process;
  Read <= registers(conv_integer(SelRead));
end Behavioral;