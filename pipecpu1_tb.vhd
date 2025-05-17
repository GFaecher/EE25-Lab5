library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;

entity PipeCPU_testbench is
end PipeCPU_testbench;

-- when your testbench is complete you should report error with severity failure.
-- this will end the simulation. Do not add stop times to the Makefile

architecture structural of PipeCPU_testbench is

    component PipelinedCPU1 is
        port(
        clk :in std_logic;
        rst :in std_logic;
        --Probe ports used for testing
        -- Forwarding control signals
        DEBUG_FORWARDA : out std_logic_vector(1 downto 0);
        DEBUG_FORWARDB : out std_logic_vector(1 downto 0);
        --The current address (AddressOut from the PC)
        DEBUG_PC : out std_logic_vector(63 downto 0);
        --Value of PC.write_enable
        DEBUG_PC_WRITE_ENABLE : out STD_LOGIC;
        --The current instruction (Instruction output of IMEM)
        DEBUG_INSTRUCTION : out std_logic_vector(31 downto 0);
        --DEBUG ports from other components
        DEBUG_TMP_REGS : out std_logic_vector(64*4-1 downto 0);
        DEBUG_SAVED_REGS : out std_logic_vector(64*4-1 downto 0);
        DEBUG_MEM_CONTENTS : out std_logic_vector(64*4-1 downto 0)
        );
    end component;

    signal clk, rst, DEBUG_PC_WRITE_ENABLE : STD_LOGIC;
    signal DEBUG_PC : STD_LOGIC_VECTOR(63 downto 0);
    signal DEBUG_INSTRUCTION : STD_LOGIC_VECTOR(31 downto 0);
    signal DEBUG_TMP_REGS, DEBUG_SAVED_REGS, DEBUG_MEM_CONTENTS : STD_LOGIC_VECTOR(64*4 - 1 downto 0);
    signal DEBUG_FORWARDA, DEBUG_FORWARDB : std_logic_vector(1 downto 0);

begin

    uut : PipelinedCPU1 port map(clk => clk, 
                                 rst => rst, 
                                 DEBUG_PC => DEBUG_PC, 
                                 DEBUG_INSTRUCTION => DEBUG_INSTRUCTION,
                                 DEBUG_TMP_REGS => DEBUG_TMP_REGS, 
                                 DEBUG_SAVED_REGS => DEBUG_SAVED_REGS, 
                                 DEBUG_MEM_CONTENTS => DEBUG_MEM_CONTENTS,
                                 DEBUG_FORWARDA => DEBUG_FORWARDA,
                                 DEBUG_FORWARDB => DEBUG_FORWARDB,
                                 DEBUG_PC_WRITE_ENABLE => DEBUG_PC_WRITE_ENABLE);

    stimproc : process
    begin
        rst <= '1';
        clk <= '1';
        wait for 10 ns;
        rst <= '0';
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait;
    end process;

end structural;
