library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use IEEE.NUMERIC_STD.ALL;

entity ALUControl is
-- Functionality should match truth table shown in Figure 4.12 in the textbook. Avoid Figure 4.13 as it may 
--  cause confusion.
-- Check table on page2 of ISA.pdf on canvas. Pay attention to opcode of operations and type of operations. 
-- If an operation doesn't use ALU, you don't need to check for its case in the ALU control implemenetation.	
-- To ensure proper functionality, you must implement the "don't-care" values in the funct field,
--  for example when ALUOp = '00", Operation must be "0010" regardless of what Funct is.
port(
     ALUOp     : in  STD_LOGIC_VECTOR(1 downto 0);
     Opcode    : in  STD_LOGIC_VECTOR(10 downto 0);
     Operation : out STD_LOGIC_VECTOR(3 downto 0)
    );
end ALUControl;

--if aluop is 00, then the operation is 0010
--if aluop is 01, then the operation is 0111
--if aluop is 10,
architecture dataflow of ALUControl is
begin
    process(all) is
    begin
        if ALUOp = "00" then
            Operation <= "0010";
        elsif ALUOp = "01" then
            Operation <= "0111";
        elsif ALUOp = "10" then
            if Opcode = "10001011000" then --ADD
                Operation <= "0010";
            elsif Opcode = "11001011000" then --SUB
                Operation <= "0110";
            elsif Opcode = "11010001000" then --SUBI
                Operation <= "0110";
            elsif Opcode = "10001010000" then --AND
                Operation <= "0000";
            elsif Opcode = "10101010000" then --ORR
                Operation <= "0001";
            elsif Opcode = "10010001000" then --ADDI
                Operation <= "0010";
            elsif Opcode = "10110010000" then --ORRI
                Operation <= "0001";
            elsif Opcode = "10010010000" then --ANDI
                Operation <= "0000";
            elsif Opcode = "11010011011" then --LSL
                Operation <= "1010";
            elsif Opcode = "11010011010" then --LSR
                Operation <= "1011";
            else
                Operation <= "UUUU";
            end if;
        else
            Operation <= "UUUU";
        end if;
    end process;
end architecture;