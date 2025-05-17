library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use IEEE.NUMERIC_STD.ALL;

entity ADD is
-- Adds two signed 64-bit inputs
-- output = in1 + in2
-- carry_in : 1 bit carry_in
-- carry_out : 1 bit carry_out
-- Hint: there are multiple ways to do this
--       -- cascade smaller adders to make the 64-bit adder (make a heirarchy)
--       -- use a Python script (or Excel) to automate filling in the signals
--       -- try a Gen loop (you will have to look this up)
port(
     carry_in : in STD_LOGIC;
     in0    : in  STD_LOGIC_VECTOR(63 downto 0);
     in1    : in  STD_LOGIC_VECTOR(63 downto 0);
     output : out STD_LOGIC_VECTOR(63 downto 0);
     carry_out : out STD_LOGIC
);
end ADD;

architecture structural of ADD is

     component ADD16
          port(
              carry_in_16 : in  STD_LOGIC;
              in0_16    : in  std_logic_vector(15 downto 0);
              in1_16    : in  std_logic_vector(15 downto 0);
              output_16 : out std_logic_vector(15 downto 0);
              carry_out_16 : out STD_LOGIC
          );
      end component;

     signal holder : std_logic_vector(3 downto 0); 

begin
     holder(0) <= carry_in;
     ADD64_0 : ADD16 port map(carry_in_16 => holder(0),
                              in0_16 => in0(15 downto 0),
                              in1_16 => in1(15 downto 0),
                              output_16 => output(15 downto 0),
                              carry_out_16 => holder(1));

     ADD64_1 : ADD16 port map(carry_in_16 => holder(1),
                              in0_16 => in0(31 downto 16),
                              in1_16 => in1(31 downto 16),
                              output_16 => output(31 downto 16),
                              carry_out_16 => holder(2));

     ADD64_2 : ADD16 port map(carry_in_16 => holder(2),
                              in0_16 => in0(47 downto 32),
                              in1_16 => in1(47 downto 32),
                              output_16 => output(47 downto 32),
                              carry_out_16 => holder(3));
                              
     ADD64_3 : ADD16 port map(carry_in_16 => holder(3),
                              in0_16 => in0(63 downto 48),
                              in1_16 => in1(63 downto 48),
                              output_16 => output(63 downto 48),
                              carry_out_16 => carry_out);

end architecture;
