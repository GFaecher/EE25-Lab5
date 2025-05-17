library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use IEEE.NUMERIC_STD.ALL;

entity HDU is
    port (
        ID_EX_MEMREAD : in std_logic;
        IF_ID_REG1 : in std_logic_vector(4 downto 0);
        IF_ID_REG2 : in std_logic_vector(4 downto 0);
        ID_EX_WBREG : in std_logic_vector(4 downto 0);
        CONT_MUX : out std_logic;
        IF_ID_WRITE : out std_logic;
        PCWRITE : out std_logic
    );
end HDU;

architecture dataflow of HDU is

begin

    process (all) is
    begin --If LDUR AND REGNUM1 in ALU stage = 
        if(ID_EX_MEMREAD = '1' and ((IF_ID_REG1 = ID_EX_WBREG) or (IF_ID_REG2 = ID_EX_WBREG))) then
            CONT_MUX <= '0';
            PCWRITE <= '0'; --STALL PIPELINE
            IF_ID_WRITE <= '0';
        else
            CONT_MUX <= '1';
            PCWRITE <= '1';
            IF_ID_WRITE <= '1';
        end if;
    end process;
end dataflow;
