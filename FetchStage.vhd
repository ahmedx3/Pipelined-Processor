LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY FetchStage IS
        PORT (
        CLK, RST : IN STD_LOGIC;
        PC_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        PC_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        INSTRUCTION : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        IMMEDIATE_VALUE : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        TWO_ONE_INSTRUCTION: OUT STD_LOGIC
        );
END FetchStage;

ARCHITECTURE arch_FetchStage OF FetchStage IS

    component RAM IS
    GENERIC (N : INTEGER := 16; SIZE :INTEGER := 10000);
        PORT (
            CLK, RST : IN STD_LOGIC;
            WriteOrRead : IN STD_LOGIC;
            Memory_Enable : IN STD_LOGIC;
            address : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0)
            );
    END component;

    SIGNAL WriteOrRead, Memory_Enable, TEMP_TWO_ONE_INSTRUCTION : STD_LOGIC := '0';
    SIGNAL Address, Data_From_Memory, Data_To_Memory : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    
    
BEGIN
        INSTRUCTION_RAM:   RAM GENERIC MAP(16,1000000) PORT MAP(CLK, RST, WriteOrRead, Memory_Enable, Address, Data_From_Memory, Data_To_Memory );
        
        PROCESS (CLK) IS
        BEGIN
                IF CLK = '1' THEN
                    --Send Signals to Memory to Read
                    WriteOrRead <= '1';
                    Memory_Enable <= '1';
                    Address <= PC_IN;
                END IF;   
                IF CLK = '0' THEN
                    -- IADD LDM LDD STD
                    IF (Data_From_Memory(31 DOWNTO 26) = "011010") OR (Data_From_Memory(31 DOWNTO 26) = "011101") OR (Data_From_Memory(31 DOWNTO 26) = "011110") OR (Data_From_Memory(31 DOWNTO 26) = "011111") THEN
                        TEMP_TWO_ONE_INSTRUCTION <= '0';
                    ELSE
                        TEMP_TWO_ONE_INSTRUCTION <= '1';
                    END IF;
                    		 
                END IF;
                
        END PROCESS;

        -- Send Signal 3ashan modelsim beyet2emes
        TWO_ONE_INSTRUCTION <= TEMP_TWO_ONE_INSTRUCTION;

        -- Send Outputs to Next Stage Buffer
        PC_OUT <= PC_IN;
        INSTRUCTION <= Data_From_Memory(31 DOWNTO 16);
        IMMEDIATE_VALUE <= Data_From_Memory(15 DOWNTO 0);


END arch_FetchStage;