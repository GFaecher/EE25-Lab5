library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ADD1 is
    -- Adds two one bit numbers, with a carry out.
    port(
        carry_in : in  std_logic;
        in0    : in  std_logic;
        in1    : in  std_logic;
        output : out std_logic;
        carry_out : out STD_LOGIC
    );
    end ADD1;

architecture Dataflow of ADD1 is
    begin
        output <= ((in0 xor in1) xor carry_in);
        carry_out <= (((in0 xor in1) and carry_in) or (in0 and in1));
end Dataflow;

    