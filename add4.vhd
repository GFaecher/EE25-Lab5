library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ADD4 is
    -- Adds two one bit numbers, with a carry out.
    port(
        carry_in_4 : in  std_logic;
        in0_4    : in  std_logic_vector(3 downto 0);
        in1_4    : in  std_logic_vector(3 downto 0);
        output_4 : out std_logic_vector(3 downto 0);
        carry_out_4 : out STD_LOGIC
    );
end ADD4;

architecture structural of ADD4 is
    component ADD1
        port(
            carry_in : in  std_logic := '0';
            in0    : in  std_logic;
            in1    : in  std_logic;
            output : out std_logic;
            carry_out : out STD_LOGIC
        );
    end component;
    signal holder : std_logic_vector(3 downto 0);
begin
    holder(0) <= carry_in_4;
    ADD4_0: ADD1 port map(carry_in => holder(0), 
                        in0 => in0_4(0), 
                        in1 => in1_4(0),
                        output => output_4(0), 
                        carry_out => holder(1));

    ADD4_1: ADD1 port map(carry_in=>holder(1), 
                        in0 => in0_4(1), 
                        in1 => in1_4(1),
                        output => output_4(1), 
                        carry_out => holder(2));

    ADD4_2: ADD1 port map(carry_in=>holder(2), 
                        in0 => in0_4(2), 
                        in1 => in1_4(2),
                        output => output_4(2), 
                        carry_out => holder(3));

    ADD4_3: ADD1 port map(carry_in=>holder(3), 
                        in0 => in0_4(3), 
                        in1 => in1_4(3),
                        output => output_4(3), 
                        carry_out => carry_out_4);
    
end structural;