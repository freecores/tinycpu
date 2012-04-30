--RAM module
--4096*8 bit file
--simultaneous write/read support
--16 bit or 8 bit data bus
--16 bit address bus
--On Reset, will load a "default" RAM image

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all; 



entity blockram is
  port(
    Address: in std_logic_vector(7 downto 0); --memory address
    WriteEnable: in std_logic; --write or read
    Enable: in std_logic; 
    Clock: in std_logic;
    DataIn: in std_logic_vector(15 downto 0);
    DataOut: out std_logic_vector(15 downto 0)
  );
end blockram;

architecture Behavioral of blockram is
    type ram_type is array (255 downto 0) of std_logic_vector (15 downto 0);
    signal RAM: ram_type;
begin

  process (Clock)
  begin
    if rising_edge(Clock) then
      if Enable = '1' then
        if WriteEnable = '1' then
            RAM(conv_integer(Address)) <= DataIn;
        end if;
        DataOut <= RAM(conv_integer(Address)) ;
      end if;
    end if;
  end process;

end Behavioral;