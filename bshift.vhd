library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bshift is
    port (
    in0 : in std_logic_vector(63 downto 0);
    in1 : in std_logic_vector(63 downto 0);
    operation : in std_logic_vector(3 downto 0);
    y : out std_logic_vector(63 downto 0)
	);
end bshift;

architecture dataflow of bshift is

begin
	process(all) is
    begin
        if(operation = "1010") then
            y <= std_logic_vector(shift_left(unsigned(in0), to_integer(signed(in1))));
        elsif(operation = "1011") then
            y <= std_logic_vector(shift_right(unsigned(in0), to_integer(signed(in1))));
        end if;
    end process;
end architecture;