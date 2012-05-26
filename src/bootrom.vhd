
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity bootrom is
port (CLK : in std_logic;
      EN : in std_logic;
      ADDR : in std_logic_vector(4 downto 0);
      DATA : out std_logic_vector(15 downto 0));
end bootrom;

architecture syn of bootrom is
  constant ROMSIZE: integer := 64;
  type ROM_TYPE is array(ROMSIZE/2-1 downto 0) of std_logic_vector(15 downto 0);
  signal ROM: ROM_TYPE := (x"0801", x"0a01", x"58a3", x"0600", x"0402", x"5063", x"4040", x"3007", x"1701", x"3006", x"1700", x"0e16", 
x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000", x"0000");
  signal rdata : std_logic_vector(15 downto 0);
begin

    rdata <= ROM(to_integer(unsigned(ADDR)));

    process (CLK)
    begin
        if (CLK'event and CLK = '1') then
            if (EN = '1') then
                DATA <= rdata;
            end if;
        end if;
    end process;

end syn;

                