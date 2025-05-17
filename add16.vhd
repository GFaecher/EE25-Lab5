library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ADD16 is
    port(
        carry_in_16 : in  STD_LOGIC;
        in0_16    : in  std_logic_vector(15 downto 0);
        in1_16    : in  std_logic_vector(15 downto 0);
        output_16 : out std_logic_vector(15 downto 0);
        carry_out_16 : out STD_LOGIC
    );
end ADD16;

architecture structural of ADD16 is
    component ADD4
        port(
            carry_in_4 : in  STD_LOGIC;
            in0_4   : in  std_logic_vector(3 downto 0);
            in1_4    : in  std_logic_vector(3 downto 0);
            output_4 : out std_logic_vector(3 downto 0);
            carry_out_4 : out STD_LOGIC
        );
    end component;
    signal holder : std_logic_vector(3 downto 0);
begin
    holder(0) <= carry_in_16;
    ADD16_0 : ADD4 port map(carry_in_4 => holder(0), 
                            in0_4 => in0_16(3 downto 0), 
                            in1_4 => in1_16(3 downto 0),
                            output_4 => output_16(3 downto 0), 
                            carry_out_4 => holder(1));

    ADD16_1 : ADD4 port map(carry_in_4 => holder(1), 
                            in0_4 => in0_16(7 downto 4), 
                            in1_4 => in1_16(7 downto 4),
                            output_4 => output_16(7 downto 4), 
                            carry_out_4 => holder(2));

    ADD16_2 : ADD4 port map(carry_in_4 => holder(2), 
                            in0_4 => in0_16(11 downto 8), 
                            in1_4 => in1_16(11 downto 8),
                            output_4 => output_16(11 downto 8), 
                            carry_out_4 => holder(3));

    ADD16_3 : ADD4 port map(carry_in_4 => holder(3), 
                            in0_4 => in0_16(15 downto 12), 
                            in1_4 => in1_16(15 downto 12),
                            output_4 => output_16(15 downto 12), 
                            carry_out_4 => carry_out_16);
    
end structural;