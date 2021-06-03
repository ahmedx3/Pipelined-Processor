LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY MemoryStage IS
        PORT (
        -- INPUTS
        CLK,RST : IN STD_LOGIC;
        Rsrc_value_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        Rdst_value_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        Control_Signals_IN : IN STD_LOGIC_VECTOR(20 DOWNTO 0);
        ALU_Output_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        -- OUTPUTS
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
    SIGNAL SP : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL MEM_WRITE_SIGNAL, MEM_READ_SIGNAL, ALU_SP_MEMORY_ADDRESS: STD_LOGIC := '0';
    
BEGIN
        DATA_RAM:   RAM GENERIC MAP(16,1000) PORT MAP(CLK, RST, readOrWrite, Memory_Enable, Address, Data_From_Memory, Data_To_Memory );
        
        -- Extract Control Signals from Buffer
        -- @TODO Check Control Signals Index
        MEM_WRITE_SIGNAL <= Control_Signals_IN(7);
        MEM_READ_SIGNAL <= Control_Signals_IN(6);
        ALU_SP_MEMORY_ADDRESS <= Control_Signals_IN(10);


        -- @TODO CHECK WHICH SIGNALS WRITES WHAT TO WHERE AND READS WHAT TO WHERE
        PROCESS (CLK, RST) IS
        BEGIN
                -- RESET SIGNALS
                IF RST = '1' THEN
                Data_From_Memory <= (OTHERS => '0');
                ELSIF falling_edge(CLK) THEN
                    Memory_Enable <= '0';
                END IF;

                IF CLK = '1' THEN
                    IF MEM_READ_SIGNAL = '1' THEN
                        -- SP is the Memory Address
                        IF ALU_SP_MEMORY_ADDRESS = '1' THEN
                            --Send Signals to Memory to Read
                            readOrWrite <= '0';
                            Memory_Enable <= '1';
                            
                            -- ???
                            Address <= SP;
                        -- ALU Output is the Memory Address
                        ELSE 
                            --Send Signals to Memory to Read
                            readOrWrite <= '0';
                            Memory_Enable <= '1';
                            
                            -- ???
                            Address <= ALU_Output_IN;
                        END IF;
                    ELSIF MEM_WRITE_SIGNAL = '1' THEN
                        -- SP is the Memory Address
                        IF ALU_SP_MEMORY_ADDRESS = '1' THEN
                            --Send Signals to Memory to Write
                            readOrWrite <= '1';
                            Memory_Enable <= '1';
                            
                            -- ???
                            Address <= SP;
                            Data_To_Memory <= Rsrc_value_IN;
                        -- ALU Output is the Memory Address
                        ELSE 
                            --Send Signals to Memory to Write
                            readOrWrite <= '1';
                            Memory_Enable <= '1';

                            -- ???
                            Address <= ALU_Output_IN;
                            Data_To_Memory <= Rsrc_value_IN;
                        END IF;
                    END IF;
                            
                END IF;
        END PROCESS;

        -- Send Outputs to Next Stage Buffer
        MemOutput_OUT <= Data_From_Memory;

END arch_MemoryStage;