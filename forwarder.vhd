library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use IEEE.NUMERIC_STD.ALL;

entity forwarder is
    port (
        MEM_WB_REGWRITE : in std_logic;
        EX_MEM_REGWRITE : in std_logic;
        EX_MEM_REGNUM : in std_logic_vector(4 downto 0);
        MEM_WB_REGNUM : in std_logic_vector(4 downto 0);
        ID_EX_REGNUM1 : in std_logic_vector(4 downto 0);
        ID_EX_REGNUM2 : in std_logic_vector(4 downto 0);
        ForwardA : out std_logic_vector(1 downto 0);
        ForwardB : out std_logic_vector(1 downto 0)
    );
end forwarder;

architecture dataflow of forwarder is

begin

    process (all) is
    begin

        if(((MEM_WB_REGWRITE = '1') and (not (MEM_WB_REGNUM = x"1F"))) and -- If MEM/WB register is being written to
        (not ((EX_MEM_REGWRITE = '1') and (not (EX_MEM_REGNUM = x"1F")) and ((EX_MEM_REGNUM = ID_EX_REGNUM1)))) --not forward 10
        and ((MEM_WB_REGNUM = ID_EX_REGNUM1))) then 
            ForwardA <= "01"; -- FOR R1: If data hazard two after another, take data from MEM/WB register

        elsif(((EX_MEM_REGWRITE = '1') and (not (EX_MEM_REGNUM = x"1F"))) and -- If MEM/WB register is being written to
        (not ((MEM_WB_REGWRITE = '1') and (not (MEM_WB_REGNUM = x"1F")) and ((MEM_WB_REGNUM = ID_EX_REGNUM1)))) --not forward 01
        and ((EX_MEM_REGNUM = ID_EX_REGNUM1))) then
            ForwardA <= "10"; -- FOR R1: If data hazard one after another, take data from EX/MEM register
        
        else
            ForwardA <= "00";
        end if;

        if(((MEM_WB_REGWRITE = '1') and (not (MEM_WB_REGNUM = x"1F"))) and -- If MEM/WB register is being written to
        (not ((EX_MEM_REGWRITE = '1') and (not (EX_MEM_REGNUM = x"1F")) and ((EX_MEM_REGNUM = ID_EX_REGNUM2)))) --not forward 10
        and ((MEM_WB_REGNUM = ID_EX_REGNUM2))) then
            ForwardB <= "01"; -- FOR R2: If data hazard two after another, take data from MEM/WB register

        elsif(((EX_MEM_REGWRITE = '1') and (not (EX_MEM_REGNUM = x"1F"))) and -- If MEM/WB register is being written to
        (not ((MEM_WB_REGWRITE = '1') and (not (MEM_WB_REGNUM = x"1F")) and ((MEM_WB_REGNUM = ID_EX_REGNUM2)))) --not forward 01
        and ((EX_MEM_REGNUM = ID_EX_REGNUM2))) then
            ForwardB <= "10"; -- FOR R1: If data hazard one after another, take data from EX/MEM register

        else
            ForwardB <= "00";
        end if;

    end process;

end dataflow;
