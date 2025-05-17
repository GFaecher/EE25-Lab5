library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

entity univ_reg is
port(
    clk          	: in  STD_LOGIC;
    rst          	: in  STD_LOGIC;
	IMEM_IN 	 	: in STD_LOGIC_VECTOR(31 downto 0);
	IMEM_OUT 	 	: out STD_LOGIC_VECTOR(31 downto 0);
	PC_IN 		 	: in STD_LOGIC_VECTOR(63 downto 0);
	PC_OUT 			: out STD_LOGIC_VECTOR(63 downto 0);
	ALUSRC_IN 	 	: in STD_LOGIC;
	ALUSRC_OUT 		: out STD_LOGIC;
	ALUOP_IN 	 	: in STD_LOGIC_VECTOR(1 downto 0);
	ALUOP_OUT 	 	: out STD_LOGIC_VECTOR(1 downto 0);
	BRANCH_IN 	 	: in STD_LOGIC;
	BRANCH_OUT 	 	: out STD_LOGIC;
	UBRANCH_IN 	 	: in STD_LOGIC;
	UBRANCH_OUT  	: out STD_LOGIC;
	MEMWRITE_IN  	: in STD_LOGIC;
	MEMWRITE_OUT 	: out STD_LOGIC;
	MEMREAD_IN 	 	: in STD_LOGIC;
	MEMREAD_OUT  	: out STD_LOGIC;
	MEMTOREG_IN  	: in STD_LOGIC;
	MEMTOREG_OUT 	: out STD_LOGIC;
	REGWRITE_IN  	: in STD_LOGIC;
	REGWRITE_OUT 	: out STD_LOGIC;
	READ_DATA1_IN 	: in STD_LOGIC_VECTOR(63 downto 0);
	READ_DATA1_OUT 	: out STD_LOGIC_VECTOR(63 downto 0);
	READ_DATA2_IN 	: in STD_LOGIC_VECTOR(63 downto 0);
	READ_DATA2_OUT  : out STD_LOGIC_VECTOR(63 downto 0);
	SIGN_EXTEND_IN 	: in STD_LOGIC_VECTOR(63 downto 0);
	SIGN_EXTEND_OUT : out STD_LOGIC_VECTOR(63 downto 0);
	INS_31_21_IN 	: in STD_LOGIC_VECTOR(10 downto 0);
	INS_31_21_OUT 	: out STD_LOGIC_VECTOR(10 downto 0);
	WRITE_REG_IN 	: in STD_LOGIC_VECTOR(4 downto 0);
	WRITE_REG_OUT 	: out STD_LOGIC_VECTOR(4 downto 0);
	RIGHT_ADD_IN 	: in STD_LOGIC_VECTOR(63 downto 0);
	RIGHT_ADD_OUT 	: out STD_LOGIC_VECTOR(63 downto 0);
	ZERO_FLAG_IN	: in STD_LOGIC;
	ZERO_FLAG_OUT	: out STD_LOGIC;
	ALU_RESULT_IN 	: in STD_LOGIC_VECTOR(63 downto 0);
	ALU_RESULT_OUT	: out STD_LOGIC_VECTOR(63 downto 0);
	OR_GATE_IN 		: in STD_LOGIC;
	OR_GATE_OUT		: out STD_LOGIC;
	READ_DATA_IN	: in STD_LOGIC_VECTOR(63 downto 0);
	READ_DATA_OUT 	: out STD_LOGIC_VECTOR(63 downto 0);
	PCSRC_IN		: in STD_LOGIC;
	PCSRC_OUT		: out STD_LOGIC;
	REGNUM1_IN		: in STD_LOGIC_VECTOR(4 downto 0);
	REGNUM1_OUT		: out STD_LOGIC_VECTOR(4 downto 0);
	REGNUM2_IN		: in STD_LOGIC_VECTOR(4 downto 0);
	REGNUM2_OUT		: out STD_LOGIC_VECTOR(4 downto 0);
	UNIV_REGWRITE	: in STD_LOGIC
);
end univ_reg;

-- IMEM_OUT
-- PC_OUT
--
-- ALUSRC
-- ALUOP
-- BRANCH
-- UBRANCH
-- MEMWRITE
-- MEMREAD
-- MEMTOREG
-- REGWRITE
-- PC_OUT_2
-- READ_DATA_1
-- READ_DATA_2
-- SIGN_EXTEND_OUT
-- INST_31-21
-- INST 4-0 (write reg)
-- 
-- MEMREAD
-- MEMWRITE
-- UBRANCH
-- BRANCH
-- REGWRITE
-- MEMTOREG
-- RIGHT_ADD_OUT
-- ZERO_FLAG
-- ALU_RESULT_OUT
-- READ_DATA_2
-- INST 4-0 (write reg)
--
-- MEMTOREG
-- BRANCH_OUTPUT (OUTPUT OF OR GATE PLEASE CHECK THIS)
-- READ_DATA_OUT
-- ALU_RESULT_OUT
-- INST 4-0 (write reg)
--
architecture Behavioral of univ_reg is
begin

process(clk,rst)
begin
	if (rst = '1') then
		IMEM_OUT <= (others => '0');
		PC_OUT <= (others => '0');
		ALUSRC_OUT <= '0';
		ALUOP_OUT <= (others => '0');
		BRANCH_OUT <= '0';
		UBRANCH_OUT <= '0';
		MEMWRITE_OUT <= '0';
		MEMREAD_OUT <= '0';
		MEMTOREG_OUT <= '0';
		REGWRITE_OUT <= '0';
		READ_DATA1_OUT <= (others => '0');
		READ_DATA2_OUT <= (others => '0');
		SIGN_EXTEND_OUT <= (others => '0');
		INS_31_21_OUT <= (others => '0');
		WRITE_REG_OUT <= (others => '0');
		RIGHT_ADD_OUT <= (others => '0');
		ZERO_FLAG_OUT <= '0';
		ALU_RESULT_OUT <= (others => '0');
		OR_GATE_OUT <= '0';
		READ_DATA_OUT <= (others => '0');
		PCSRC_OUT <= '0';
		REGNUM1_OUT <= (others => '0');
		REGNUM2_OUT <= (others => '0');
	else
		if rising_edge(clk) and UNIV_REGWRITE = '1' then
			IMEM_OUT <= IMEM_IN;
			PC_OUT <= PC_IN;
			ALUSRC_OUT <= ALUSRC_IN;
			ALUOP_OUT <= ALUOP_IN;
			BRANCH_OUT <= BRANCH_IN;
			UBRANCH_OUT <= UBRANCH_IN;
			MEMWRITE_OUT <= MEMWRITE_IN;
			MEMREAD_OUT <= MEMREAD_IN;
			MEMTOREG_OUT <= MEMTOREG_IN;
			REGWRITE_OUT <= REGWRITE_IN;
			READ_DATA1_OUT <= READ_DATA1_IN;
			READ_DATA2_OUT <= READ_DATA2_IN;
			SIGN_EXTEND_OUT <= SIGN_EXTEND_IN;
			INS_31_21_OUT <= INS_31_21_IN;
			WRITE_REG_OUT <= WRITE_REG_IN;
			RIGHT_ADD_OUT <= RIGHT_ADD_IN;
			ZERO_FLAG_OUT <= ZERO_FLAG_IN;
			ALU_RESULT_OUT <= ALU_RESULT_IN;
			OR_GATE_OUT <= OR_GATE_IN;
			READ_DATA_OUT <= READ_DATA_IN;
			PCSRC_OUT <= PCSRC_IN;
			REGNUM1_OUT <= REGNUM1_IN;
			REGNUM2_OUT <= REGNUM2_IN;
		end if;
	end if;
end process;

end Behavioral;

