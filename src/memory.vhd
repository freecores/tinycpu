--Memory management component
--By having this separate, it should be fairly easy to add RAMs or ROMs later
--This basically lets the CPU not have to worry about how memory "Really" works
--currently just one RAM. 1024 byte blockram.vhd mapped as 0 - 1023

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity memory is
  port(
    Address: in std_logic_vector(15 downto 0); --memory address (in bytes)
    WriteWord: in std_logic; --if set, will write a full 16-bit word instead of a byte. Address must be aligned to 16-bit address. (bottom bit must be 0)
    WriteEnable: in std_logic;
    Clock: in std_logic;
    DataIn: in std_logic_vector(15 downto 0);
    DataOut: out std_logic_vector(15 downto 0)
--    Reset: in std_logic
    
    --RAM/ROM interface (RAMA is built in to here
    --RAMBDataIn: out std_logic_vector(15 downto 0);
    --RAMBDataOut: in std_logic_vector(15 downto 0);
    --RAMBAddress: out std_logic_vector(15 downto 0);
    --RAMBWriteEnable: out std_logic_vector(1 downto 0);
  );
end memory;

architecture Behavioral of memory is

  component blockram
    port(
      Address: in std_logic_vector(7 downto 0); --memory address
      WriteEnable: in std_logic_vector(1 downto 0); --write or read
      Enable: in std_logic; 
      Clock: in std_logic;
      DataIn: in std_logic_vector(15 downto 0);
      DataOut: out std_logic_vector(15 downto 0)
    );
  end component;

  constant R1START: integer := 0;
  constant R1END: integer := 1023;
  signal addr: std_logic_vector(15 downto 0) := (others => '0');
  signal R1addr: std_logic_vector(7 downto 0);
  signal we: std_logic_vector(1 downto 0);
  signal datawrite: std_logic_vector(15 downto 0);
  signal dataread: std_logic_vector(15 downto 0);
  --signal en: std_logic;
  signal R1we: std_logic_vector(1 downto 0);
  signal R1en: std_logic;
  signal R1in: std_logic_vector(15 downto 0);
  signal R1out: std_logic_vector(15 downto 0);
begin
  R1: blockram port map (R1addr, R1we, R1en, Clock, R1in, R1out);
  addrwe: process(Address, WriteWord, WriteEnable, DataIn)
  begin
    addr <= Address(15 downto 1) & '0';
    if WriteEnable='1' then
      if WriteWord='1' then
        we <= "11";
        datawrite <= DataIn;
      else
        if Address(0)='0' then
          we <= "01";
          datawrite <= x"00" & DataIn(7 downto 0); --not really necessary
        else
          we <= "10";
          datawrite <= DataIn(7 downto 0) & x"00";
        end if;
      end if;
    else
      datawrite <= x"0000";
      we <= "00";
    end if;
  end process;
  
  assignram: process (we, datawrite, addr, r1out)
  variable tmp: integer;
  variable found: boolean := false;
  begin
    tmp := to_integer(unsigned(addr));
    if tmp >= R1START and tmp <= R1END then
      --map all to R1
      found := true;
      R1en <= '1';
      R1we <= we;
      R1in <= datawrite;
      dataread <= R1out;
      R1addr <= addr(8 downto 1);
    else
      R1en <= '0';
      R1we <= "00";
      R1in <= x"0000";
      R1addr <= x"00";
      dataread <= x"0000";
    end if;
  end process;

  readdata: process(Address, dataread)
  begin
    if Address(0) = '0' then
      DataOut <= dataread;
    else
      DataOut <= x"00" & dataread(15 downto 8);
    end if;
  end process;
  
end Behavioral;