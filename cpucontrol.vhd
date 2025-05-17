library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use IEEE.NUMERIC_STD.ALL;

entity CPUControl is
-- Based on the Opcode (11 bits), CPU Control outputs select lines that are used throughout the rest 
--  of the processor architecture. In other words, given an operation (specified by an Opcode), CPU 
--  Control sets the select lines at 0 or 1 in order to appropriately control the rest of the functional 
--  units. For a visual, please refer to Figure 4.23 in the textbook. 
-- Functionality should match the truth table shown in Figure 4.22 of the textbook, inlcuding the
--    output 'X' values.
-- The truth table in Figure 4.22 only lists R-format, LDUR, STUR, and CBZ instructions. You will need
--  to implement I-format and UBranch instructions as well. To implement the unconditional branch 
--  instruction:
--    UBranch = '1'
--    MemWrite = RegWrite = '0'
--    all other outputs = 'X'	
port(Opcode   : in  STD_LOGIC_VECTOR(10 downto 0);
     Reg2Loc   : out STD_LOGIC;
     CBranch  : out STD_LOGIC;  --conditional
     MemRead  : out STD_LOGIC;
     MemtoReg : out STD_LOGIC;
     MemWrite : out STD_LOGIC;
     ALUSrc   : out STD_LOGIC;
     RegWrite : out STD_LOGIC;
     UBranch  : out STD_LOGIC; -- This is unconditional
     ALUOp    : out STD_LOGIC_VECTOR(1 downto 0)
);
end CPUControl;


architecture dataflow of CPUControl is


begin --I HAD TO CHANGE ALL OF MY X's TO 0s BECAUSE THE WAVEFORM WAS NOT COMPILING.

     process(all) is
          begin
               if Opcode = "000101" & "00000" then --Branch
                    UBranch <= '1';
                    MemWrite <= '0';
                    RegWrite <= '0';
                    Reg2Loc <= '0';
                    CBranch <= '0';
                    MemRead <= '0';
                    MemtoReg <= '0';
                    ALUSrc <= '0';
                    ALUOp <= "00";
               elsif Opcode = "10001010000" then --AND
                    Reg2Loc <= '0';
                    ALUSrc <= '0';
                    MemtoReg <= '0';
                    RegWrite <= '1';
                    MemRead <= '0';
                    MemWrite <= '0';
                    CBranch <= '0';
                    ALUOp <= "10";
                    UBranch <= '0';
               elsif Opcode = "10001011000" then --R format ADD
                    Reg2Loc <= '0';
                    ALUSrc <= '0';
                    MemtoReg <= '0';
                    RegWrite <= '1';
                    MemRead <= '0';
                    MemWrite <= '0';
                    CBranch <= '0';
                    ALUOp <= "10";
                    UBranch <= '0';
               elsif Opcode = ("1001000100" & "0") then --NOT R TYPE. ADDI
                    Reg2Loc <= '0'; --ALL OF THESE SHOULD BE 0 FOR I TYPE
                    ALUSrc <= '1';
                    MemtoReg <= '0';
                    RegWrite <= '1';
                    MemRead <= '0';
                    MemWrite <= '0';
                    CBranch <= '0';
                    ALUOp <= "10";
                    UBranch <= '0';
               elsif Opcode = "1001001000" & "0" then --NOT R TYPE. ANDI
                    Reg2Loc <= '0';
                    ALUSrc <= '1';
                    MemtoReg <= '0';
                    RegWrite <= '1';
                    MemRead <= '0';
                    MemWrite <= '0';
                    CBranch <= '0';
                    ALUOp <= "10";
                    UBranch <= '0';
               elsif Opcode = "10101010000" then --ORR
                    Reg2Loc <= '0';
                    ALUSrc <= '0';
                    MemtoReg <= '0';
                    RegWrite <= '1';
                    MemRead <= '0';
                    MemWrite <= '0';
                    CBranch <= '0';
                    ALUOp <= "10";
                    UBranch <= '0';
               elsif Opcode = "1011001000" & "0" then --NOT R TYPE. ORRI
                    Reg2Loc <= '0';
                    ALUSrc <= '1';
                    MemtoReg <= '0';
                    RegWrite <= '1';
                    MemRead <= '0';
                    MemWrite <= '0';
                    CBranch <= '0';
                    ALUOp <= "10";
                    UBranch <= '0';
               elsif Opcode = "10110100" & "000" then --NOT R TYPE. CBZ
                    Reg2Loc <= '1';
                    ALUSrc <= '0';
                    MemtoReg <= '0';
                    RegWrite <= '0';
                    MemRead <= '0';
                    MemWrite <= '0';
                    CBranch <= '1';
                    ALUOp <= "01";
                    UBranch <= '0';
               elsif Opcode = "10110101" & "000" then --NOT R TYPE. CBNZ
                    Reg2Loc <= '1';
                    ALUSrc <= '0';
                    MemtoReg <= '0';
                    RegWrite <= '0';
                    MemRead <= '0';
                    MemWrite <= '0';
                    CBranch <= '1';
                    ALUOp <= "01";
                    UBranch <= '0';
               elsif Opcode = "11001011000" then --SUB
                    Reg2Loc <= '0';
                    ALUSrc <= '0';
                    MemtoReg <= '0';
                    RegWrite <= '1';
                    MemRead <= '0';
                    MemWrite <= '0';
                    CBranch <= '0';
                    ALUOp <= "10";
                    UBranch <= '0';
               elsif Opcode = "1101000100" & "0" then --NOT R TYPE. SUBI
                    Reg2Loc <= '0';
                    ALUSrc <= '1';
                    MemtoReg <= '0';
                    RegWrite <= '1';
                    MemRead <= '0';
                    MemWrite <= '0';
                    CBranch <= '0';
                    ALUOp <= "10";
                    UBranch <= '0';
               elsif Opcode = "11111000010" then --LDUR 011111000010 11111000010
                    Reg2Loc <= '0';
                    ALUSrc <= '1';
                    MemtoReg <= '1';
                    RegWrite <= '1';
                    MemRead <= '1';
                    MemWrite <= '0';
                    CBranch <= '0';
                    ALUOp <= "00";
                    UBranch <= '0';
               elsif Opcode = "11111000000" then --STUR 11010011011 11111000000
                    Reg2Loc <= '1';
                    ALUSrc <= '1';
                    MemtoReg <= '0';
                    RegWrite <= '0';
                    MemRead <= '0';
                    MemWrite <= '1';
                    CBranch <= '0';
                    ALUOp <= "00";
                    UBranch <= '0';
               elsif Opcode = "11010011011" then --LSL
                    Reg2Loc <= '0';
                    ALUSrc <= '1';
                    MemtoReg <= '0';
                    RegWrite <= '1';
                    MemRead <= '0';
                    MemWrite <= '0';
                    CBranch <= '0';
                    ALUOp <= "10";
                    UBranch <= '0';
               elsif Opcode = "11010011010" then --LSR
                    Reg2Loc <= '0';
                    ALUSrc <= '1';
                    MemtoReg <= '0';
                    RegWrite <= '1';
                    MemRead <= '0';
                    MemWrite <= '0';
                    CBranch <= '0';
                    ALUOp <= "10";
                    UBranch <= '0';
               elsif Opcode = "00000000000" then --NOP
                    Reg2Loc <= '0';
                    ALUSrc <= '0';
                    MemtoReg <= '0';
                    RegWrite <= '0';
                    MemRead <= '0';
                    MemWrite <= '0';
                    CBranch <= '0';
                    ALUOp <= "11";
                    UBranch <= '0';
               else
                    Reg2Loc <= '0';
                    ALUSrc <= '0';
                    MemtoReg <= '0';
                    RegWrite <= '0';
                    MemRead <= '0';
                    MemWrite <= '0';
                    CBranch <= '0';
                    ALUOp <= "00";
                    UBranch <= '0';
          end if;
     end process;
end dataflow;

               


