LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY MemoryStage IS
        PORT (
        -- INPUTS
        CLK,RST : IN STD_LOGIC;
        Rsrc_value_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        Rdst_value_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        SP_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        Control_Signals_IN : IN STD_LOGIC_VECTOR(20 DOWNTO 0);
        ALU_Output_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        -- OUTPUTS
        SP_ENABLE : OUT STD_LOGIC;
        SP_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        MemOutput_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
END MemoryStage;

ARCHITECTURE arch_MemoryStage OF MemoryStage IS

    component RAM IS
    GENERIC (N : INTEGER := 16; SIZE :INTEGER := 1000000000);
        PORT (
            CLK,RST : IN STD_LOGIC;
            WriteOrRead : IN STD_LOGIC;
            Memory_Enable : IN STD_LOGIC;
            address : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0)
            );
    END component;

    SIGNAL readOrWrite, Memory_Enable : STD_LOGIC := '0';
    SIGNAL Address, Data_From_Memory, Data_To_Memory : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL SP : STD_LOGIC_VECTOR(31 DOWNTO 0) := X"00000010";
    SIGNAL MEM_WRITE_SIGNAL, MEM_READ_SIGNAL, ALU_SP_MEMORY_ADDRESS: STD_LOGIC := '0';
    
BEGIN
        DATA_RAM:   RAM GENERIC MAP(16,1000) PORT MAP(CLK, RST, readOrWrite, Memory_Enable, Address, Data_From_Memory, Data_To_Memory );
        
        -- Extract Control Signals from Buffer
        -- @TODO Check Control Signals Index
        MEM_WRITE_SIGNAL <= Control_Signals_IN(7);
        MEM_READ_SIGNAL <= Control_Signals_IN(6);
        ALU_SP_MEMORY_ADDRESS <= Control_Signals_IN(10);


        readOrWrite <= '1' WHEN MEM_READ_SIGNAL = '1'
        ELSE '0' WHEN MEM_WRITE_SIGNAL = '1';

        Memory_Enable <= '1' WHEN MEM_READ_SIGNAL = '1' OR MEM_WRITE_SIGNAL = '1'
        ELSE '0';

        SP_ENABLE <= '1' WHEN ALU_SP_MEMORY_ADDRESS = '1'
        ELSE '0';

        SP <= std_logic_vector(to_unsigned(to_integer(unsigned(SP_IN)) + 2,SP'LENGTH )) WHEN MEM_READ_SIGNAL = '1' AND  ALU_SP_MEMORY_ADDRESS = '1' AND CLK = '1'
        ELSE std_logic_vector(to_unsigned(to_integer(unsigned(SP_IN)) - 2,SP'LENGTH )) WHEN MEM_WRITE_SIGNAL = '1' AND  ALU_SP_MEMORY_ADDRESS = '1' AND CLK = '1'
 
        ELSE X"00000010" WHEN RST = '1';

        Address <= SP WHEN MEM_READ_SIGNAL = '1' AND  ALU_SP_MEMORY_ADDRESS = '1'
        ELSE SP_IN WHEN MEM_WRITE_SIGNAL = '1' AND  ALU_SP_MEMORY_ADDRESS = '1'  
        ELSE ALU_Output_IN WHEN  ALU_SP_MEMORY_ADDRESS = '0' AND (MEM_READ_SIGNAL = '1' OR MEM_WRITE_SIGNAL = '1')
        ELSE (OTHERS => '0');
                            
        Data_To_Memory <= Rsrc_value_IN;
        -- Send Outputs to Next Stage Buffer
        MemOutput_OUT <= (OTHERS => '0') WHEN RST = '1'
        ELSE Data_From_Memory;
        SP_OUT <= SP;
END arch_MemoryStage;