library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SignExtend is
port(
     x : in  STD_LOGIC_VECTOR(31 downto 0);
     Opcode : in STD_LOGIC_VECTOR(10 downto 0);
     y : out STD_LOGIC_VECTOR(63 downto 0)
);
end SignExtend;

architecture dataflow of SignExtend is 
signal extend : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal imm_extend : STD_LOGIC_VECTOR(51 downto 0) := (others => '0');
signal b_extend : STD_LOGIC_VECTOR(37 downto 0) := (others => '0');
signal cb_extend : STD_LOGIC_VECTOR(44 downto 0) := (others => '0');
signal d_extend : STD_LOGIC_VECTOR(54 downto 0) := (others => '0');
signal shift_extend : STD_LOGIC_VECTOR(57 downto 0) := (others => '0');
    begin


     process(all) is
     begin
          if((Opcode(10 downto 1) = "1001000100") or  (Opcode(10 downto 1) = "1001001000") or 
          (Opcode(10 downto 1) = "1011001000") or (Opcode(10 downto 1) = "1101000100")) then

               imm_extend <= x"FFFFFFFFFFFFF" when x(21) = '1' else x"0000000000000";
               y <= imm_extend & x(21 downto 10);

          elsif(Opcode(10 downto 5) = "000101") then

               b_extend <= x"FFFFFFFFF" & "11" when x(25) = '1' else x"000000000" & "00";
               y <= b_extend & x(25 downto 0);

          elsif((Opcode(10 downto 3) = "10110100") or (Opcode(10 downto 3) = "10110101")) then

               cb_extend <= x"FFFFFFFFFFF" & '1' when x(23) = '1' else x"00000000000" & '0';
               y <= cb_extend & x(23 downto 5);

          elsif((Opcode = "11111000010") or (Opcode = "11111000000")) then

               d_extend <= x"FFFFFFFFFFFFF" & "111" when x(20) = '1' else x"0000000000000" & "000";
               y <= d_extend & x(20 downto 12);
          elsif((Opcode = "11010011011") or (Opcode = "11010011010")) then
               shift_extend <= x"FFFFFFFFFFFFFF" & "11" when x(15) else x"00000000000000" & "00";
               y <= shift_extend & x(15 downto 10);

          else

               extend <= x"FFFFFFFF" when x(31) = '1' else x"00000000";
               y <= extend & x(31 downto 0);



          end if;
     end process;


     
end dataflow;