LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY DecodeStage IS
    PORT (
    CLK: IN STD_LOGIC;
    INSTRUCTION_IN, IMMEDIATE_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    PC_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

    RSRC_INDEX_OUT, RDST_INDEX_OUT : OUT  STD_LOGIC_VECTOR(4 DOWNTO 0);
    IMMEDIATE_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); 
    CTRL_SIG : OUT STD_LOGIC_VECTOR(20 DOWNTO 0);
    PC_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END DecodeStage;

ARCHITECTURE arch_DecodeStage OF DecodeStage IS

    COMPONENT ControlUnit IS
        PORT (
            clk : IN STD_LOGIC;
            instruction :IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            controlSignals : OUT std_logic_vector(20 DOWNTO 0)
            );
    END COMPONENT;

    SIGNAL instructionToCU : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL controlSignals  : STD_LOGIC_VECTOR(20 DOWNTO 0);

BEGIN
    
    CONTROL_UNIT:   ControlUnit PORT MAP(CLK, instructionToCU, controlSignals);
    
    PROCESS (CLK) IS
    BEGIN
            IF RISING_EDGE(CLK) THEN
                instructionToCU <= INSTRUCTION_IN;
            END IF;
    END PROCESS;
    

    PC_OUT <= PC_IN;
    CTRL_SIG <= controlSignals;
    IMMEDIATE_OUT <= IMMEDIATE_IN;
    RSRC_INDEX_OUT  <= INSTRUCTION_IN (9 DOWNTO 5);
    RDST_INDEX_OUT  <= INSTRUCTION_IN (4 DOWNTO 0);

END arch_DecodeStage;
