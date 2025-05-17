library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
    port(
        in0       : in  STD_LOGIC_VECTOR(63 downto 0);
        in1       : in  STD_LOGIC_VECTOR(63 downto 0);
        operation : in  STD_LOGIC_VECTOR(3 downto 0);
        result    : buffer STD_LOGIC_VECTOR(63 downto 0);
        zero      : buffer STD_LOGIC;
        overflow  : buffer STD_LOGIC
    );
end ALU;

architecture structural of ALU is
    component ADD
        port(
            carry_in : in  STD_LOGIC;
            in0      : in  std_logic_vector(63 downto 0);
            in1      : in  std_logic_vector(63 downto 0);
            output   : out std_logic_vector(63 downto 0);
            carry_out : out STD_LOGIC
        );
    end component;

    component bshift
        port(
            in0 : in std_logic_vector(63 downto 0);
            in1 : in std_logic_vector(63 downto 0);
            operation : in std_logic_vector(3 downto 0);
            y : out std_logic_vector(63 downto 0)
        );
    end component;

    signal in0_add, in1_add, output_add : std_logic_vector(63 downto 0);
    signal carry_in_add, carry_out_add : std_logic;
    signal in0_shift, in1_shift, output_shift : std_logic_vector(63 downto 0);

begin

    ADDER: ADD port map(
        carry_in => carry_in_add, 
        in0      => in0_add,
        in1      => in1_add,
        output   => output_add,
        carry_out => carry_out_add
    );

    BSHIFTER : bshift port map(
        in0 => in0_shift,
        in1 => in1_shift,
        operation => operation,
        y => output_shift
    );

    process(all) is
    begin
        case operation is
            when "0000" =>  -- AND
                result <= in0 and in1;
                overflow <= '0';
            when "0001" =>  -- OR
                result <= in0 or in1;
                overflow <= '0';
            when "0010" =>  -- ADD
                carry_in_ADD <= '0';
                in0_add <= in0;
                in1_add <= in1;
                result <= output_ADD;
                overflow <= '1' when 
                (((not in0(63)) and (not in1(63)) and result(63)) or
                (in0(63) and in1(63) and (not result(63)))) else '0';
            when "0110" =>  -- SUBTRACT
                carry_in_ADD <= '1';
                in0_add <= in0;
                in1_add <= not in1;
                result <= output_ADD; 
                overflow <= '1' when 
                    ((in0(63) and (not in1(63)) and (not result(63))) or --negative minus positive = negative
                    ((not in0(63)) and in1(63) and result(63))) else '0'; --positive minus negative = positive
            when "0111" => --CBZ
                result <= in1;
                overflow <= '0';
            when "1010" => --LSL
                in0_shift <= in0;
                in1_shift <= in1;
                result <= output_shift;
            when "1011" => --LSR
                in0_shift <= in0;
                in1_shift <= in1;
                result <= output_shift;
            when others =>
                result <= x"UUUUUUUUUUUUUUUU";
        end case;
    end process;
    zero <= '1' when result = x"0000000000000000" else '0';
end architecture;