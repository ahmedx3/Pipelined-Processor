LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY FetchStage IS
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
                
        END PROCESS;

        -- Send Signal
        NEXT_PC <= BRANCH_VALUE WHEN BRANCH = '1'
        ELSE MEMORY_VALUE WHEN BRANCH_RETURN = '1'
        ELSE x"0000" & Data_From_Memory(31 DOWNTO 16) WHEN RST = '1'
        ELSE std_logic_vector(to_unsigned(to_integer(unsigned(PC_IN)) + 2,NEXT_PC'LENGTH )) WHEN Data_From_Memory(31 DOWNTO 26) = "011010" OR Data_From_Memory(31 DOWNTO 26) = "011101" OR Data_From_Memory(31 DOWNTO 26) = "011110" OR Data_From_Memory(31 DOWNTO 26) = "011111" 
        ELSE std_logic_vector(to_unsigned(to_integer(unsigned(PC_IN)) + 1,NEXT_PC'LENGTH ));

        -- DEPENDS ON HAZARDS
        PC_WR_EN <= NOT LOAD_USE_STALL;

        -- Send Outputs to Next Stage Buffer
        PC_OUT <= PC_IN;
        INSTRUCTION <= Data_From_Memory(31 DOWNTO 16);
        IMMEDIATE_VALUE <= Data_From_Memory(15 DOWNTO 0);


END arch_FetchStage;