library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;

entity PipelinedCPU1 is
port(
clk :in std_logic;
rst :in std_logic;
--Probe ports used for testing
-- Forwarding control signals
DEBUG_FORWARDA : out std_logic_vector(1 downto 0);
DEBUG_FORWARDB : out std_logic_vector(1 downto 0);
--The current address (AddressOut from the PC)
DEBUG_PC : out std_logic_vector(63 downto 0);
--Value of PC.write_enable
DEBUG_PC_WRITE_ENABLE : out STD_LOGIC;
--The current instruction (Instruction output of IMEM)
DEBUG_INSTRUCTION : out std_logic_vector(31 downto 0);
--DEBUG ports from other components
DEBUG_TMP_REGS : out std_logic_vector(64*4-1 downto 0);
DEBUG_SAVED_REGS : out std_logic_vector(64*4-1 downto 0);
DEBUG_MEM_CONTENTS : out std_logic_vector(64*4-1 downto 0)
);
end PipelinedCPU1;

architecture structural of PipelinedCPU1 is
    component ADD is
        port(
            carry_in : in  STD_LOGIC;
            in0      : in  std_logic_vector(63 downto 0);
            in1      : in  std_logic_vector(63 downto 0);
            output   : out std_logic_vector(63 downto 0);
            carry_out : out STD_LOGIC
        );
    end component;

    component ALU is
        port(
            in0       : in  STD_LOGIC_VECTOR(63 downto 0);
            in1       : in  STD_LOGIC_VECTOR(63 downto 0);
            operation : in  STD_LOGIC_VECTOR(3 downto 0);
            result    : buffer STD_LOGIC_VECTOR(63 downto 0);
            zero      : buffer STD_LOGIC;
            overflow  : buffer STD_LOGIC
        );
    end component;

    component ALUControl is
         port(
              ALUOp     : in  STD_LOGIC_VECTOR(1 downto 0);
              Opcode    : in  STD_LOGIC_VECTOR(10 downto 0);
              Operation : out STD_LOGIC_VECTOR(3 downto 0)
         );
    end component;

    component CPUControl is
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
    end component;

    component DMEM is
         port(
              WriteData          : in  STD_LOGIC_VECTOR(63 downto 0); -- Input data
              Address            : in  STD_LOGIC_VECTOR(63 downto 0); -- Read/Write address
              MemRead            : in  STD_LOGIC; -- Indicates a read operation
              MemWrite           : in  STD_LOGIC; -- Indicates a write operation
              Clock              : in  STD_LOGIC; -- Writes are triggered by a rising edge
              ReadData           : out STD_LOGIC_VECTOR(63 downto 0); -- Output data
              --Probe ports used for testing
              -- Four 64-bit words: DMEM(0) & DMEM(4) & DMEM(8) & DMEM(12)
              DEBUG_MEM_CONTENTS : out STD_LOGIC_VECTOR(255 downto 0)
         );
    end component;

    component IMEM is
         port(
              Address  : in  STD_LOGIC_VECTOR(63 downto 0); -- Address to read from
              ReadData : out STD_LOGIC_VECTOR(31 downto 0)
         );
    end component;

    component MUX5 is
         port(
         in0    : in STD_LOGIC_VECTOR(4 downto 0); -- sel == 0
         in1    : in STD_LOGIC_VECTOR(4 downto 0); -- sel == 1
         sel    : in STD_LOGIC; -- selects in0 or in1
         output : out STD_LOGIC_VECTOR(4 downto 0)
    );
    end component;

    component MUX64 is
         port(
         in0    : in STD_LOGIC_VECTOR(63 downto 0); -- sel == 0
         in1    : in STD_LOGIC_VECTOR(63 downto 0); -- sel == 1
         sel    : in STD_LOGIC; -- selects in0 or in1
         output : out STD_LOGIC_VECTOR(63 downto 0)
    );
    end component;

    component PC is
         port(
              clk          : in  STD_LOGIC; -- Propogate AddressIn to AddressOut on rising edge of clock
              write_enable : in  STD_LOGIC; -- Only write if '1'
              rst          : in  STD_LOGIC; -- Asynchronous reset! Sets AddressOut to 0x0
              AddressIn    : in  STD_LOGIC_VECTOR(63 downto 0); -- Next PC address
              AddressOut   : out STD_LOGIC_VECTOR(63 downto 0) -- Current PC address
         );
    end component;

    component registers is
         port(RR1      : in  STD_LOGIC_VECTOR (4 downto 0); --which register for r1
              RR2      : in  STD_LOGIC_VECTOR (4 downto 0); --
              WR       : in  STD_LOGIC_VECTOR (4 downto 0); --register to write to 
              WD       : in  STD_LOGIC_VECTOR (63 downto 0); --data to write to 
              RegWrite : in  STD_LOGIC;
              Clock    : in  STD_LOGIC;
              RD1      : out STD_LOGIC_VECTOR (63 downto 0); --64 bit values in register
              RD2      : out STD_LOGIC_VECTOR (63 downto 0);
              --Probe ports used for testing.
              -- Notice the width of the port means that you are 
              --      reading only part of the register file. 
              -- This is only for debugging
              -- You are debugging a sebset of registers here
              -- Temp registers: $X9 & $X10 & X11 & X12 
              -- 4 refers to number of registers you are debugging
              DEBUG_TMP_REGS : out STD_LOGIC_VECTOR(255 downto 0);
              -- Saved Registers X19 & $X20 & X21 & X22 
              DEBUG_SAVED_REGS : out STD_LOGIC_VECTOR(255 downto 0)
         );
    end component;

    component ShiftLeft2 is
         port(
              x : in  STD_LOGIC_VECTOR(63 downto 0);
              y : out STD_LOGIC_VECTOR(63 downto 0) -- x << 2
         );
    
    end component;

    component SignExtend is
         port(
              x : in  STD_LOGIC_VECTOR(31 downto 0);
              Opcode : in STD_LOGIC_VECTOR(10 downto 0);
              y : out STD_LOGIC_VECTOR(63 downto 0)
         );
    end component;

    component univ_reg is
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
    end component;

    component forwarder is
     port (
          MEM_WB_REGWRITE : in std_logic;
          EX_MEM_REGWRITE : in std_logic;
          EX_MEM_REGNUM : in std_logic_vector(4 downto 0);
          MEM_WB_REGNUM : in std_logic_vector(4 downto 0);
          ID_EX_REGNUM1 : in std_logic_vector(4 downto 0);
          ID_EX_REGNUM2 : in std_logic_vector(4 downto 0);
          ForwardA : out std_logic_vector(1 downto 0);
          ForwardB : out std_logic_vector(1 downto 0)
      );
     end component;

     component HDU is
          port (
               ID_EX_MEMREAD : in std_logic;
               IF_ID_REG1 : in std_logic_vector(4 downto 0);
               IF_ID_REG2 : in std_logic_vector(4 downto 0);
               ID_EX_WBREG : in std_logic_vector(4 downto 0);
               CONT_MUX : out std_logic;
               IF_ID_WRITE : out std_logic;
               PCWRITE : out std_logic
           );
     end component;

    --SIGNALS FOR ALL INPUT VALUES TO GO NOWHERE
    signal open_sigv : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
    signal open_sig32v : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal open_sig11v : STD_LOGIC_VECTOR(10 downto 0) := (others => '0');
    signal open_sig5v : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal open_sig : STD_LOGIC := '0';

    --SIGNALS FOR IMEM
    signal IMEM_instruction_sig : STD_LOGIC_VECTOR(31 downto 0);
    signal IMEM_read_address_sig : STD_LOGIC_VECTOR(63 downto 0);

    --SIGNALS FOR CPU CONTROL
    signal Reg2Loc, UBranch, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite : STD_LOGIC;
    signal CONTROL_ALUOP : STD_LOGIC_VECTOR(1 downto 0);

    --SIGNALS FOR MUX5
    signal mux5_out : STD_LOGIC_VECTOR(4 downto 0);

    --SIGNALS FOR REGISTERS
    signal REG_WD, REG_RD1, REG_RD2 : STD_LOGIC_VECTOR(63 downto 0);

    --SIGNALS FOR SIGN EXTEND
    signal SIGN_EXTEND_OUT : STD_LOGIC_VECTOR(63 downto 0);

    --SIGNALS FOR REG_MUX64
    signal REG_MUX64_OUT : STD_LOGIC_VECTOR(63 downto 0);

    --SIGNALS FOR ALU CONTROL
    signal ALU_CONTROL_OUT : STD_LOGIC_VECTOR(3 downto 0);

    --SIGNALS FOR ALU
    signal ALU_RESULT : STD_LOGIC_VECTOR(63 downto 0);
    signal ZERO_FLAG, OVERFLOW_FLAG : STD_LOGIC;

    --SIGNALS FOR DMEM
    signal DMEM_OUT : STD_LOGIC_VECTOR(63 downto 0);

    --SIGNALS FOR DMEM_MUX64
    signal DMEM_MUX64_OUT : STD_LOGIC_VECTOR(63 downto 0);
    signal AND_GATE_OUT : STD_LOGIC := '0';

    --SIGNALS FOR OR GATE
    signal OR_GATE_OUT : STD_LOGIC := '0';

    --SIGNALS FOR SHIFT_LEFT_2
    signal SHIFT_OUT : STD_LOGIC_VECTOR(63 downto 0);

    --SIGNALS FOR RIGHT PC
    signal PC_OUT : STD_LOGIC_VECTOR(63 downto 0);
    signal PC_WE_SIG : STD_LOGIC;

    --SIGNALS FOR RIGHT ADDER
    signal RIGHT_ADD_OUT : STD_LOGIC_VECTOR(63 downto 0);
    signal RIGHT_COUT : STD_LOGIC := '0';

    --SIGNALS FOR LEFT ADDER
    signal LEFT_ADD_OUT : STD_LOGIC_VECTOR(63 downto 0);
    signal LEFT_COUT : STD_LOGIC := '0';
    
    --SIGNALS FOR PC_MUX64
    signal PC_MUX64_OUT : STD_LOGIC_VECTOR(63 downto 0);

    --SIGNALS FOR IFID REGISTER
    signal PC_OUT1 : STD_LOGIC_VECTOR(63 downto 0);
    signal IMEM_instruction_sig1 : STD_LOGIC_VECTOR(31 downto 0);

    --SIGNALS FOR IDEX REGISTER
    signal ALUSRC1 : STD_LOGIC := '0';
    signal ALUOP1 : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
    signal BRANCH1 : STD_LOGIC := '0';
    signal UBRANCH1 : STD_LOGIC := '0';
    signal MEMWRITE1 : STD_LOGIC := '0';
    signal MEMREAD1 : STD_LOGIC := '0';
    signal MEMTOREG1 : STD_LOGIC := '0';
    signal REGWRITE1 : STD_LOGIC := '0';
    signal PC_OUT2 : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
    signal RD1_1 : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
    signal RD2_1 : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
    signal SIGN_EXTEND_OUT1 : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
    signal ALU_CONTROL_IN : STD_LOGIC_VECTOR(10 downto 0) := (others => '0');
    signal WR1 : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');

    --SIGNALS FOR EXMEM REGISTER
    signal UBRANCH2 : STD_LOGIC := '0';
    signal BRANCH2 : STD_LOGIC := '0';
    signal MEMWRITE2 : STD_LOGIC := '0';
    signal MEMREAD2 : STD_LOGIC := '0';
    signal MEMTOREG2 : STD_LOGIC := '0';
    signal REGWRITE2 : STD_LOGIC := '0';
    signal ALU_RESULT1 : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
    signal RD2_2 : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
    signal RIGHT_ADD_OUT1 : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
    signal WR2 : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal ZERO_FLAG1 : STD_LOGIC := '0';
    signal BRANCH_LOGIC : STD_LOGIC_VECTOR(10 downto 0) := (others => '0');

    --SIGNALS FOR MEMWB REGISTER
    signal MEMTOREG3 : STD_LOGIC := '0';
    signal REGWRITE3 : STD_LOGIC := '0';
    signal PCSRC1 : STD_LOGIC := '0';
    signal DMEM_OUT1 : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
    signal ALU_RESULT2 : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
    signal WR3 : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal RIGHT_ADD_OUT2 : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
    signal RIGHT_ADD_OUT_1 : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');


    signal AND_GATE_IN : std_logic := '0';

    signal REGNUM1_1 : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal REGNUM2_1 : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal REGNUM1_2 : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal REGNUM2_2 : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal REGNUM1_3 : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal REGNUM2_3 : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal FORWARDA : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
    signal FORWARDB : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');

    signal CONTMUX : STD_LOGIC := '1';
    signal IFID_WRITE : STD_LOGIC := '1';
    signal PCWRITE : STD_LOGIC := '1';

    signal ALUINP1 : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
     signal ALUINP2 : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');

    signal Reg2Loc_pre, UBranch_pre, Branch_pre, MemRead_pre,
     MemtoReg_pre, MemWrite_pre, ALUSrc_pre, RegWrite_pre : STD_LOGIC;
     signal ALUOP_pre : STD_LOGIC_VECTOR(1 downto 0);

     signal REGNUM1_PRE : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
     signal REGNUM2_PRE : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');


begin

     FORWARDER_MAP : forwarder port map(MEM_WB_REGWRITE => REGWRITE3,
                                   EX_MEM_REGWRITE => REGWRITE2,
                                   EX_MEM_REGNUM => WR2,
                                   MEM_WB_REGNUM => WR3,
                                   ID_EX_REGNUM1 => REGNUM1_1,
                                   ID_EX_REGNUM2 => REGNUM2_1,
                                   ForwardA => FORWARDA,
                                   ForwardB => FORWARDB
                                   );


    HDU_MAP : HDU port map(ID_EX_MEMREAD => MEMREAD1,
                         IF_ID_REG1 => IMEM_instruction_sig1(9 downto 5),
                         IF_ID_REG2 => MUX5_OUT,
                         ID_EX_WBREG => WR1,
                         CONT_MUX => CONTMUX,
                         IF_ID_WRITE => IFID_WRITE,
                         PCWRITE => PCWRITE
                         );

    IFID : univ_reg port map(clk => clk, 
                             rst => rst, 
                             PC_IN => PC_OUT, 
                             PC_OUT => PC_OUT1, 
                             IMEM_IN => IMEM_instruction_sig, 
                             IMEM_OUT => IMEM_instruction_sig1, --REST ARE OPEN
                             ALUSRC_IN => open_sig,
                             ALUSRC_OUT => open,
                             ALUOP_IN => open_sig & open_sig,
                             ALUOP_OUT => open,
                             BRANCH_IN => open_sig,
                             BRANCH_OUT => open,
                             UBRANCH_IN => open_sig,
                             UBRANCH_OUT => open,
                             MEMWRITE_IN => open_sig,
                             MEMWRITE_OUT => open,
                             MEMREAD_IN => open_sig,
                             MEMREAD_OUT => open,
                             MEMTOREG_IN => open_sig,
                             MEMTOREG_OUT => open,
                             REGWRITE_IN => open_sig,
                             REGWRITE_OUT => open,
                             READ_DATA1_IN => open_sigv,
                             READ_DATA1_OUT => open,
                             READ_DATA2_IN => open_sigv,
                             READ_DATA2_OUT => open,
                             SIGN_EXTEND_IN => open_sigv,
                             SIGN_EXTEND_OUT => open,
                             INS_31_21_IN => open_sig11v,
                             INS_31_21_OUT => open,
                             WRITE_REG_IN => open_sig5v,
                             WRITE_REG_OUT => open,
                             RIGHT_ADD_IN => open_sigv,
                             RIGHT_ADD_OUT => open,
                             ZERO_FLAG_IN => open_sig,
                             ZERO_FLAG_OUT => open,
                             ALU_RESULT_IN => open_sigv,
                             ALU_RESULT_OUT => open,
                             OR_GATE_IN => open_sig,
                             OR_GATE_OUT => open,
                             READ_DATA_IN => open_sigv,
                             READ_DATA_OUT => open,
                             PCSRC_IN => open_sig,
                             PCSRC_OUT => open,
                             REGNUM1_IN => open_sig5v,
                             REGNUM1_OUT => open,
                             REGNUM2_IN => open_sig5v,
                             REGNUM2_OUT => open,
                             UNIV_REGWRITE => IFID_WRITE
                             );

    IDEX : univ_reg port map(clk => clk,
                             rst => rst,
                             ALUSRC_IN => ALUSrc,
                             ALUSRC_OUT => ALUSRC1,
                             ALUOP_IN => CONTROL_ALUOP,
                             ALUOP_OUT => ALUOP1,
                             BRANCH_IN => Branch,
                             BRANCH_OUT => BRANCH1,
                             UBRANCH_IN => UBranch,
                             UBRANCH_OUT => UBRANCH1,
                             MEMWRITE_IN => MemWrite,
                             MEMWRITE_OUT => MEMWRITE1,
                             MEMREAD_IN => MemRead,
                             MEMREAD_OUT => MEMREAD1,
                             MEMTOREG_IN => MemtoReg,
                             MEMTOREG_OUT => MEMTOREG1,
                             REGWRITE_IN => RegWrite,
                             REGWRITE_OUT => REGWRITE1,
                             PC_IN => PC_OUT1,
                             PC_OUT => PC_OUT2,
                             READ_DATA1_IN => REG_RD1,
                             READ_DATA1_OUT => RD1_1,
                             READ_DATA2_IN => REG_RD2,
                             READ_DATA2_OUT => RD2_1,
                             SIGN_EXTEND_IN => SIGN_EXTEND_OUT,
                             SIGN_EXTEND_OUT => SIGN_EXTEND_OUT1,
                             INS_31_21_IN => IMEM_instruction_sig1(31 downto 21),
                             INS_31_21_OUT => ALU_CONTROL_IN,
                             WRITE_REG_IN => IMEM_instruction_sig1(4 downto 0),
                             WRITE_REG_OUT => WR1, 
                             REGNUM1_IN => REGNUM1_PRE,
                             REGNUM1_OUT => REGNUM1_1,
                             REGNUM2_IN => REGNUM2_PRE,
                             REGNUM2_OUT => REGNUM2_1,--REST ARE OPEN
                             IMEM_IN => open_sig32v,
                             IMEM_OUT => open,
                             OR_GATE_IN => open_sig,
                             OR_GATE_OUT => open,
                             RIGHT_ADD_IN => open_sigv,
                             RIGHT_ADD_OUT => open,
                             ZERO_FLAG_IN => open_sig,
                             ZERO_FLAG_OUT => open,
                             ALU_RESULT_IN => open_sigv,
                             ALU_RESULT_OUT => open,
                             READ_DATA_IN => open_sigv,
                             READ_DATA_OUT => open,
                             PCSRC_IN => open_sig,
                             PCSRC_OUT => open,
                             UNIV_REGWRITE => '1'
                             );


    EXMEM : univ_reg port map(clk => clk,
                             rst => rst,
                             UBRANCH_IN => UBRANCH1,
                             UBRANCH_OUT => UBRANCH2,
                             MEMWRITE_IN => MEMWRITE1,
                             MEMWRITE_OUT => MEMWRITE2,
                             MEMREAD_IN => MEMREAD1,
                             MEMREAD_OUT => MEMREAD2,
                             MEMTOREG_IN => MEMTOREG1,
                             MEMTOREG_OUT => MEMTOREG2,
                             REGWRITE_IN => REGWRITE1,
                             REGWRITE_OUT => REGWRITE2,
                             ALU_RESULT_IN => ALU_RESULT,
                             ALU_RESULT_OUT => ALU_RESULT1,
                             RIGHT_ADD_IN => RIGHT_ADD_OUT,
                             RIGHT_ADD_OUT => RIGHT_ADD_OUT1,
                             READ_DATA2_IN => RD2_1,
                             READ_DATA2_OUT => RD2_2,
                             WRITE_REG_IN => WR1,
                             WRITE_REG_OUT => WR2, 
                             ZERO_FLAG_IN => ZERO_FLAG,
                             ZERO_FLAG_OUT => ZERO_FLAG1,
                             INS_31_21_IN => ALU_CONTROL_IN,
                             INS_31_21_OUT => BRANCH_LOGIC,
                             BRANCH_IN => BRANCH1,
                             BRANCH_OUT => BRANCH2,
                             REGNUM1_IN => REGNUM1_1,
                             REGNUM1_OUT => REGNUM1_2,
                             REGNUM2_IN => REGNUM2_1,
                             REGNUM2_OUT => REGNUM2_2,--REST ARE OPEN
                             PC_IN => open_sigv,
                             PC_OUT => open,
                             IMEM_IN => open_sig32v,
                             IMEM_OUT => open,
                             ALUSRC_IN => open_sig,
                             ALUSRC_OUT => open,
                             ALUOP_IN => open_sig & open_sig,
                             ALUOP_OUT => open,
                             READ_DATA1_IN => open_sigv,
                             READ_DATA1_OUT => open,
                             SIGN_EXTEND_IN => open_sigv,
                             SIGN_EXTEND_OUT => open,
                             OR_GATE_IN => open_sig,
                             OR_GATE_OUT => open,
                             READ_DATA_IN => open_sigv,
                             READ_DATA_OUT => open,
                             PCSRC_IN => open_sig,
                             PCSRC_OUT => open,
                             UNIV_REGWRITE => '1'
                             );

    MEMWB : univ_reg port map(clk => clk,
                             rst => rst,
                             MEMTOREG_IN => MEMTOREG2,
                             MEMTOREG_OUT => MEMTOREG3,
                             REGWRITE_IN => REGWRITE2,
                             REGWRITE_OUT => REGWRITE3,
                             READ_DATA1_IN => DMEM_OUT,
                             READ_DATA1_OUT => DMEM_OUT1,
                             ALU_RESULT_IN => ALU_RESULT1,
                             ALU_RESULT_OUT => ALU_RESULT2,
                             WRITE_REG_IN => WR2,
                             WRITE_REG_OUT => WR3, 
                             REGNUM1_IN => REGNUM1_2,
                             REGNUM1_OUT => REGNUM1_3,
                             REGNUM2_IN => REGNUM2_2,
                             REGNUM2_OUT => REGNUM2_3,--REST ARE OPEN
                             PC_IN => open_sigv,
                             PC_OUT => open,
                             IMEM_IN => open_sig32v,
                             IMEM_OUT => open,
                             ALUSRC_IN => open_sig,
                             ALUSRC_OUT => open,
                             ALUOP_IN => open_sig & open_sig,
                             ALUOP_OUT => open,
                             BRANCH_IN => open_sig,
                             BRANCH_OUT => open,
                             UBRANCH_IN => open_sig,
                             UBRANCH_OUT => open,
                             MEMWRITE_IN => open_sig,
                             MEMWRITE_OUT => open,
                             MEMREAD_IN => open_sig,
                             MEMREAD_OUT => open,
                             READ_DATA2_IN => open_sigv,
                             READ_DATA2_OUT => open,
                             SIGN_EXTEND_IN => open_sigv,
                             SIGN_EXTEND_OUT => open,
                             INS_31_21_IN => open_sig11v,
                             INS_31_21_OUT => open,
                             ZERO_FLAG_IN => open_sig,
                             ZERO_FLAG_OUT => open,
                             OR_GATE_IN => open_sig,
                             OR_GATE_OUT => open,
                             READ_DATA_IN => open_sigv,
                             READ_DATA_OUT => open,
                             RIGHT_ADD_IN => open_sigv,
                             RIGHT_ADD_OUT => open,
                             PCSRC_IN => open_sig,
                             PCSRC_OUT => open,
                             UNIV_REGWRITE => '1'
    );




    IMEM_MAP : IMEM port map(Address => PC_OUT, ReadData => IMEM_instruction_sig);

    REGISTER_MAP : registers port map(RR1 => IMEM_instruction_sig1(9 downto 5), RR2 => mux5_out, 
    WR => WR3, WD => DMEM_MUX64_OUT, RegWrite => RegWrite3, Clock => clk, 
    RD1 => REG_RD1, RD2 => REG_RD2, DEBUG_TMP_REGS => DEBUG_TMP_REGS, DEBUG_SAVED_REGS => DEBUG_SAVED_REGS);

    CONTROL_MAP : CPUControl port map(Opcode => IMEM_instruction_sig1(31 downto 21), Reg2Loc => Reg2Loc_pre, 
    CBranch => Branch_pre, MemRead => MemRead_pre, MemtoReg => MemtoReg_pre, MemWrite => MemWrite_pre, ALUSrc => ALUSrc_pre, 
    RegWrite => RegWrite_pre, UBranch => UBranch_pre, ALUOp => ALUOP_pre);

    MUX5_MAP : MUX5 port map(in0 => IMEM_instruction_sig1(20 downto 16), 
    in1 => IMEM_instruction_sig1(4 downto 0), sel => Reg2Loc_pre, output => mux5_out);

    SIGN_EXTEND_MAP : SignExtend port map(x => IMEM_instruction_sig1, 
                                          Opcode => IMEM_instruction_sig1(31 downto 21),
                                          y => SIGN_EXTEND_OUT);

    REG_MUX64 : MUX64 port map(in0 => RD2_1, in1 => SIGN_EXTEND_OUT1, sel => ALUSrc1, output => REG_MUX64_OUT);

    ALU_CONTROL_MAP : ALUControl port map(ALUOp => ALUOp1, Opcode => ALU_CONTROL_IN, 
    Operation => ALU_CONTROL_OUT);

    ALU_MAP : ALU port map(in0 => ALUINP1, in1 => ALUINP2, operation => ALU_CONTROL_OUT, result => ALU_RESULT,
    zero => ZERO_FLAG, overflow => OVERFLOW_FLAG);

    DMEM_MAP : DMEM port map(WriteData => RD2_2, 
    Address => ALU_RESULT1, 
    MemRead => MemRead2, 
    MemWrite => MemWrite2,
    clock => clk, 
    ReadData => DMEM_OUT, 
    DEBUG_MEM_CONTENTS => DEBUG_MEM_CONTENTS);

    DMEM_MUX64 : MUX64 port map(in0 => ALU_RESULT2, in1 => DMEM_OUT1, sel => MemtoReg3, output => DMEM_MUX64_OUT);

    SHIFT_LEFT_MAP : ShiftLeft2 port map(x => SIGN_EXTEND_OUT1, y => SHIFT_OUT);

    PC_MAP : PC port map(clk => clk, write_enable => PCWRITE, rst => rst, AddressIn => PC_MUX64_OUT, 
    AddressOut => PC_OUT);

    RIGHT_ADD_MAP : ADD port map(carry_in => '0', in0 => PC_OUT2, in1 => SHIFT_OUT, output => RIGHT_ADD_OUT, 
    carry_out => RIGHT_COUT);

    LEFT_ADD_MAP : ADD port map(carry_in => '0', in0 => PC_OUT, in1 => x"0000000000000004", output => LEFT_ADD_OUT,
    carry_out => LEFT_COUT);

    PC_MUX_MAP : MUX64 port map(in0 => LEFT_ADD_OUT, in1 => RIGHT_ADD_OUT1, sel => OR_GATE_OUT, output => PC_MUX64_OUT);

    AND_GATE_IN <= not Zero_FLAG1 when BRANCH_LOGIC = "10110101000" else Zero_FLAG1;

    ALUINP1 <= RD1_1 when FORWARDA = "00" else
               ALU_RESULT1 when FORWARDA = "10" else
               DMEM_MUX64_OUT when FORWARDA = "01" else
               open_sigv;
     
     ALUINP2 <= REG_MUX64_OUT when FORWARDB = "00" else
               ALU_RESULT1 when FORWARDB = "10" else
               DMEM_MUX64_OUT when FORWARDB = "01" else
               open_sigv;

     Reg2Loc <= Reg2Loc_pre when (CONTMUX = '1') else '0';
     UBranch <= UBranch_pre when (CONTMUX = '1') else '0';
     Branch <= Branch_pre when (CONTMUX = '1') else '0';
     MemRead <= MemRead_pre when (CONTMUX = '1') else '0';
     MemtoReg <= MemtoReg_pre when (CONTMUX = '1') else '0';
     MemWrite <= MemWrite_pre when (CONTMUX = '1') else '0';
     ALUSrc <= ALUSrc_pre when (CONTMUX = '1') else '0';
     RegWrite <= RegWrite_pre when (CONTMUX = '1') else '0';
     CONTROL_ALUOP <= ALUOP_pre when (CONTMUX = '1') else (others => '0');
     
     REGNUM1_PRE <= IMEM_instruction_sig1(9 downto 5) when (CONTMUX = '1') else (others => '1');
     REGNUM2_PRE <= MUX5_OUT when (CONTMUX = '1') else (others => '1');

    AND_GATE_OUT <= AND_GATE_IN and Branch2;

    OR_GATE_OUT <= AND_GATE_OUT or UBranch2;

    DEBUG_PC <= PC_OUT;

    DEBUG_INSTRUCTION <= IMEM_instruction_sig;
    




    --CHANGE
     DEBUG_FORWARDA <= FORWARDA;
     DEBUG_FORWARDB <= FORWARDB;  
     DEBUG_PC_WRITE_ENABLE <= PCWRITE; 


end structural;