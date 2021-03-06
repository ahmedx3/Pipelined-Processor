
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Main IS
        PORT (
        CLK,RST : IN STD_LOGIC;
        INPUT_PORT : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        OUTPUT_PORT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
END Main;

ARCHITECTURE arch_main OF Main IS

----------------------
----------------------
-- MAIN SIGNALS
----------------------
----------------------

SIGNAL PC, SP : STD_LOGIC_VECTOR(31 DOWNTO 0);



----------------------
----------------------
-- STAGES
----------------------
----------------------

COMPONENT FetchStage IS
        PORT (
        CLK, RST, LOAD_USE_STALL : IN STD_LOGIC;
        PC_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        BRANCH, BRANCH_RETURN : IN STD_LOGIC;
        BRANCH_VALUE, MEMORY_VALUE : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        PC_OUT, NEXT_PC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        INSTRUCTION : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        IMMEDIATE_VALUE : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        PC_WR_EN: OUT STD_LOGIC
        );
END COMPONENT;

COMPONENT DecodeStage IS
    PORT (
    CLK, RST: IN STD_LOGIC;
    INSTRUCTION_IN: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    RSRC_INDEX_OUT, RDST_INDEX_OUT : OUT  STD_LOGIC_VECTOR(4 DOWNTO 0); 
    CTRL_SIG : OUT STD_LOGIC_VECTOR(20 DOWNTO 0)
    );
END COMPONENT;

COMPONENT ExecutionStage IS
	PORT (
		CLK, RST : IN STD_LOGIC;
		RSRC_VAL, RDST_VAL, IN_PORT  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        RSRC_SHIFT : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        IMMEDIATE : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        CTRL_SIG_IN : IN STD_LOGIC_VECTOR(20 DOWNTO 0);
        DATA_FORWARD_EN_RSRC, DATA_FORWARD_EN_RDST: IN STD_LOGIC;
		DATA_FORWARD_RSRC, DATA_FORWARD_RDST: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		RSRC_VAL_EX, RDST_VAL_EX, EX_OUT  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        BRANCH : OUT STD_LOGIC;
        BRANCH_VALUE : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
END COMPONENT;


COMPONENT MemoryStage IS
    PORT (
        -- INPUTS
        CLK, RST : IN STD_LOGIC;
        Rsrc_value_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        Rdst_value_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        SP_IN, PC_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        Control_Signals_IN : IN STD_LOGIC_VECTOR(20 DOWNTO 0);
        ALU_Output_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        -- OUTPUTS
        SP_ENABLE, BRANCH_RETURN : OUT STD_LOGIC;
        SP_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        MemOutput_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END COMPONENT;


COMPONENT WriteBackStage IS
	PORT (
		EX_OUT, MEM_OUT  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        RDST_INDEX_IN: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        CTRL_SIG_IN : IN STD_LOGIC_VECTOR(20 DOWNTO 0);
		WRITEDATA  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        RDST_INDEX_OUT: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        REG_WRITE_ENABLE, PORT_WRITE_ENABLE : OUT STD_LOGIC);
END COMPONENT;

----------------------
----------------------
-- BUFFERS
----------------------
----------------------

COMPONENT IF_ID IS
	PORT (
		CLK, RST, WRITE_ENABLE, LOAD_USE_STALL : IN STD_LOGIC;
		PC_IN  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        INSTRUCTION_IN, IMMEDIATE_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		PC_OUT  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        INSTRUCTION_OUT, IMMEDIATE_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END COMPONENT;

COMPONENT ID_EX IS
	PORT (
		CLK, RST, WRITE_ENABLE, LOAD_USE_STALL : IN STD_LOGIC;
		PC_IN, RSRC_VAL_IN, RDST_VAL_IN  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        CTRL_SIG_IN : IN STD_LOGIC_VECTOR(20 DOWNTO 0);
        RSRC_INDEX_IN, RDST_INDEX_IN : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        IMMEDIATE_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		PC_OUT, RSRC_VAL_OUT, RDST_VAL_OUT  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        RSRC_INDEX_OUT, RDST_INDEX_OUT : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
        IMMEDIATE_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        CTRL_SIG_OUT : OUT STD_LOGIC_VECTOR(20 DOWNTO 0));
END COMPONENT;

COMPONENT EX_MEM IS
	PORT (
		CLK, RST, WRITE_ENABLE : IN STD_LOGIC;
		PC_IN, RSRC_VAL_IN, RDST_VAL_IN, EX_IN  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        CTRL_SIG_IN : IN STD_LOGIC_VECTOR(20 DOWNTO 0);
        RSRC_INDEX_IN, RDST_INDEX_IN : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		PC_OUT, RSRC_VAL_OUT, RDST_VAL_OUT, EX_OUT  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        RSRC_INDEX_OUT, RDST_INDEX_OUT  : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
        CTRL_SIG_OUT : OUT STD_LOGIC_VECTOR(20 DOWNTO 0));
END COMPONENT;

COMPONENT MEM_WB IS
	PORT (
		CLK, RST, WRITE_ENABLE : IN STD_LOGIC;
		PC_IN, EX_IN, MEM_IN   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        CTRL_SIG_IN : IN STD_LOGIC_VECTOR(20 DOWNTO 0);
        RDST_INDEX_IN  : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		PC_OUT, EX_OUT, MEM_OUT  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        RDST_INDEX_OUT : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
        CTRL_SIG_OUT : OUT STD_LOGIC_VECTOR(20 DOWNTO 0));
END COMPONENT;

----------------------
----------------------
------ HAZARDS -------
----------------------
----------------------

COMPONENT DataForward IS
	PORT (
        REG_WRITE_EX, REG_WRITE_MEM, MEM_TO_REG, MEM_READ_ID_EX : IN STD_LOGIC;
        RDST_INDEX_EX, RDST_INDEX_MEM, RSRC_INDEX_ID, RDST_INDEX_ID_EX : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        RSRC_INDEX_OUT_ID, RDST_INDEX_OUT_ID : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        ALU_OUT_EX, ALU_OUT_MEM, MEM_OUT_MEM: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        DATA_FORWARD_EN_RSRC, DATA_FORWARD_EN_RDST, LOAD_USE_STALL: OUT STD_LOGIC;
        DATA_FORWARD_OUT_RSRC, DATA_FORWARD_OUT_RDST: OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
END COMPONENT;

----------------------
----------------------
-- REGISTER FILES
----------------------
----------------------

COMPONENT mREGISTER IS
	GENERIC (N : INTEGER := 32);
	PORT (
		CLK, RST, ENABLE : IN STD_LOGIC;
		D : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		Q : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
END COMPONENT;

COMPONENT RegisterFile IS
	GENERIC (N : INTEGER := 32);
	PORT (
		CLK, RST, ENABLE : IN STD_LOGIC;
		InputBus : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        writeIndex, readIndex1, readIndex2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		OutputBus1, OutputBus2 : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
END COMPONENT;

----------------------
----------------------
-- TEMPORARY SIGNALS
----------------------
----------------------

-- Fetch Stage
SIGNAL PC_IF, NEXT_PC : STD_LOGIC_VECTOR(31 DOWNTO 0):= (OTHERS => '0');
SIGNAL INSTRUCTION_IF, IMMEDIATE_VALUE_IF  : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
-- SIGNAL TWO_ONE_INSTRUCTION: STD_LOGIC := '0';
SIGNAL PC_ENABLE: STD_LOGIC := '0';
 
-- IF/ID
SIGNAL BUFFER_WRITE_ENABLE: STD_LOGIC := '0';
SIGNAL PC_IF_ID: STD_LOGIC_VECTOR(31 DOWNTO 0):= (OTHERS => '0');
SIGNAL INSTRUCTION_IF_ID, IMMEDIATE_IF_ID : STD_LOGIC_VECTOR(15 DOWNTO 0):= (OTHERS => '0');

-- Decode Stage
SIGNAL RSRC_INDEX_OUT_ID, RDST_INDEX_OUT_ID : STD_LOGIC_VECTOR(4 DOWNTO 0):= (OTHERS => '0');
SIGNAL CTRL_SIG_ID: STD_LOGIC_VECTOR(20 DOWNTO 0):= (OTHERS => '0');
 
-- Register File
SIGNAL RSRC_VALUE_OUT_ID, RDST_VALUE_OUT_ID : STD_LOGIC_VECTOR(31 DOWNTO 0):= (OTHERS => '0');
 
-- ID/EX
SIGNAL PC_ID_EX, RSRC_VAL_OUT_ID_EX, RDST_VAL_OUT_ID_EX: STD_LOGIC_VECTOR(31 DOWNTO 0):= (OTHERS => '0');
SIGNAL RSRC_INDEX_OUT_ID_EX, RDST_INDEX_OUT_ID_EX : STD_LOGIC_VECTOR(4 DOWNTO 0):= (OTHERS => '0');
SIGNAL IMMEDIATE_OUT_ID_EX : STD_LOGIC_VECTOR(15 DOWNTO 0):= (OTHERS => '0');
SIGNAL CTRL_SIG_OUT_ID_EX : STD_LOGIC_VECTOR(20 DOWNTO 0):= (OTHERS => '0');
 
-- Execution Stage
SIGNAL RSRC_VAL_EX, RDST_VAL_EX, ALU_OUT_EX : STD_LOGIC_VECTOR(31 DOWNTO 0):= (OTHERS => '0');
SIGNAL BRANCH : STD_LOGIC;
SIGNAL BRANCH_VALUE : STD_LOGIC_VECTOR(31 DOWNTO 0);
-- EX/MEM
SIGNAL PC_EX_MEM, RSRC_VAL_OUT_EX_MEM, RDST_VAL_OUT_EX_MEM, ALU_OUT_EX_MEM, SP_IN, SP_OUT: STD_LOGIC_VECTOR(31 DOWNTO 0):= (OTHERS => '0');
SIGNAL RSRC_INDEX_OUT_EX_MEM, RDST_INDEX_OUT_EX_MEM : STD_LOGIC_VECTOR(4 DOWNTO 0):= (OTHERS => '0');
SIGNAL CTRL_SIG_OUT_EX_MEM : STD_LOGIC_VECTOR(20 DOWNTO 0):= (OTHERS => '0');
SIGNAL SP_ENABLE : STD_LOGIC := '0';

-- Memory Stage
SIGNAL MEM_OUT_MEM : STD_LOGIC_VECTOR(31 DOWNTO 0):= (OTHERS => '0');
SIGNAL BRANCH_RETURN : STD_LOGIC;

-- MEM/WB
SIGNAL PC_MEM_WB, ALU_OUT_MEM_WB, MEM_OUT_MEM_WB: STD_LOGIC_VECTOR(31 DOWNTO 0):= (OTHERS => '0');
SIGNAL RDST_INDEX_OUT_MEM_WB : STD_LOGIC_VECTOR(4 DOWNTO 0):= (OTHERS => '0');
SIGNAL CTRL_SIG_OUT_MEM_WB : STD_LOGIC_VECTOR(20 DOWNTO 0):= (OTHERS => '0');

-- WB
SIGNAL InputBus_WB : STD_LOGIC_VECTOR(31 DOWNTO 0):= (OTHERS => '0');
SIGNAL writeIndex_WB : STD_LOGIC_VECTOR(2 DOWNTO 0):= (OTHERS => '0');
SIGNAL ENABLE_WB, PORT_WRITE_ENABLE : STD_LOGIC := '0';

-- FORWARDING
SIGNAL DATA_FORWARD_EN_RSRC, DATA_FORWARD_EN_RDST, LOAD_USE_STALL: STD_LOGIC;
SIGNAL DATA_FORWARD_OUT_RSRC, DATA_FORWARD_OUT_RDST: STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN
    
    -- PORTMAPS
    FetchStage_PORTMAP: FetchStage PORT MAP(
        CLK, RST, LOAD_USE_STALL,
        PC,
        BRANCH, BRANCH_RETURN,
        BRANCH_VALUE, MEM_OUT_MEM,
        PC_IF, NEXT_PC,
        INSTRUCTION_IF,
        IMMEDIATE_VALUE_IF,
        PC_ENABLE
    );

    IF_ID_MAP : IF_ID  PORT MAP (
		CLK, RST, BUFFER_WRITE_ENABLE, LOAD_USE_STALL,
		PC_IF,
        INSTRUCTION_IF, IMMEDIATE_VALUE_IF,
		PC_IF_ID,
        INSTRUCTION_IF_ID, IMMEDIATE_IF_ID
    );

    DecodeStage_PORTMAP: DecodeStage PORT MAP (
		CLK, RST,
        INSTRUCTION_IF_ID,
        RSRC_INDEX_OUT_ID, RDST_INDEX_OUT_ID,
        CTRL_SIG_ID
    );

    RegisterFile_PORTMAP: RegisterFile PORT MAP (
		CLK, RST, ENABLE_WB,
		InputBus_WB, 
        writeIndex_WB, RSRC_INDEX_OUT_ID(2 DOWNTO 0), RDST_INDEX_OUT_ID(2 DOWNTO 0), 
		RSRC_VALUE_OUT_ID, RDST_VALUE_OUT_ID
    );

    ID_EX_PORTMAP: ID_EX PORT MAP (
		CLK, RST, BUFFER_WRITE_ENABLE, LOAD_USE_STALL,
		PC_IF_ID, RSRC_VALUE_OUT_ID, RDST_VALUE_OUT_ID ,
        CTRL_SIG_ID,
        RSRC_INDEX_OUT_ID, RDST_INDEX_OUT_ID,
        IMMEDIATE_IF_ID ,
		PC_ID_EX, RSRC_VAL_OUT_ID_EX, RDST_VAL_OUT_ID_EX ,
        RSRC_INDEX_OUT_ID_EX, RDST_INDEX_OUT_ID_EX,
        IMMEDIATE_OUT_ID_EX,
        CTRL_SIG_OUT_ID_EX
    );

    ExecutionStage_PORTMAP: ExecutionStage PORT MAP (
		CLK, RST,
		RSRC_VAL_OUT_ID_EX, RDST_VAL_OUT_ID_EX, INPUT_PORT,
        RSRC_INDEX_OUT_ID_EX,
        IMMEDIATE_OUT_ID_EX,
        CTRL_SIG_OUT_ID_EX,
        DATA_FORWARD_EN_RSRC, DATA_FORWARD_EN_RDST,
        DATA_FORWARD_OUT_RSRC, DATA_FORWARD_OUT_RDST,
		RSRC_VAL_EX, RDST_VAL_EX, ALU_OUT_EX,
        BRANCH,
        BRANCH_VALUE
    );
  
    EX_MEM_PORTMAP: EX_MEM PORT MAP (
        CLK, RST, BUFFER_WRITE_ENABLE, 
        PC_ID_EX, RSRC_VAL_EX, RDST_VAL_EX, ALU_OUT_EX,
        CTRL_SIG_OUT_ID_EX ,
        RSRC_INDEX_OUT_ID_EX, RDST_INDEX_OUT_ID_EX,
        PC_EX_MEM, RSRC_VAL_OUT_EX_MEM, RDST_VAL_OUT_EX_MEM, ALU_OUT_EX_MEM,
        RSRC_INDEX_OUT_EX_MEM, RDST_INDEX_OUT_EX_MEM,
        CTRL_SIG_OUT_EX_MEM
    );

    MemoryStage_PORTMAP: MemoryStage PORT MAP (
        -- INPUTS
        CLK, RST,
        RSRC_VAL_OUT_EX_MEM,
        RDST_VAL_OUT_EX_MEM,
        SP_IN, PC_EX_MEM,
        CTRL_SIG_OUT_EX_MEM,
        ALU_OUT_EX_MEM,
        -- OUTPUTS
        SP_ENABLE, BRANCH_RETURN,
        SP_OUT,
        MEM_OUT_MEM
    );

    MEM_WB_PORTMAP: MEM_WB PORT MAP (
        CLK, RST, BUFFER_WRITE_ENABLE,
        PC_EX_MEM, ALU_OUT_EX_MEM, MEM_OUT_MEM ,
        CTRL_SIG_OUT_EX_MEM,
        RDST_INDEX_OUT_EX_MEM ,
        PC_MEM_WB, ALU_OUT_MEM_WB, MEM_OUT_MEM_WB,
        RDST_INDEX_OUT_MEM_WB,
        CTRL_SIG_OUT_MEM_WB
    );

    WriteBackStage_PORTMAP: WriteBackStage PORT MAP (
		ALU_OUT_MEM_WB, MEM_OUT_MEM_WB,
        RDST_INDEX_OUT_MEM_WB,
        CTRL_SIG_OUT_MEM_WB ,
		InputBus_WB ,
        writeIndex_WB,
        ENABLE_WB, PORT_WRITE_ENABLE 
    );

    DataForward_PORTMAP: DataForward PORT MAP (
		CTRL_SIG_OUT_EX_MEM(4), CTRL_SIG_OUT_MEM_WB(4), CTRL_SIG_OUT_MEM_WB(5), CTRL_SIG_OUT_ID_EX(6),
        RDST_INDEX_OUT_EX_MEM, RDST_INDEX_OUT_MEM_WB, RSRC_INDEX_OUT_ID_EX, RDST_INDEX_OUT_ID_EX,
        RSRC_INDEX_OUT_ID, RDST_INDEX_OUT_ID,
        ALU_OUT_EX_MEM, ALU_OUT_MEM_WB, MEM_OUT_MEM_WB,
        DATA_FORWARD_EN_RSRC, DATA_FORWARD_EN_RDST, LOAD_USE_STALL,
        DATA_FORWARD_OUT_RSRC, DATA_FORWARD_OUT_RDST
    );
    
    ----------------------
    ----------------------
    -- LOGIC
    ----------------------
    ----------------------
    OUTPUT_PORT <= InputBus_WB WHEN PORT_WRITE_ENABLE = '1' else x"00000000";
    -------------------
    -- NEEDS ATTENTION
    -------------------
    -- SP <= X"00000010" WHEN RST = '1'
    -- ELSE SP_OUT;

	SP0: mREGISTER PORT MAP(CLK, RST, SP_ENABLE, SP_OUT, SP_IN);
	PC0: mREGISTER PORT MAP(CLK, RST, PC_ENABLE, NEXT_PC, PC);

    PROCESS (RST, CLK)
    BEGIN
        IF RST = '1' THEN
            BUFFER_WRITE_ENABLE <= '0';
        ELSIF (Clk = '1') then
            BUFFER_WRITE_ENABLE <= '1';      
        END IF;

    END PROCESS;

END arch_main;