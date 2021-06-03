LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY ControlUnit IS
	Port( clk, RST: IN std_logic;
		instruction : IN std_logic_vector(15 DOWNTO 0);
	    controlSignals: OUT std_logic_vector(20 DOWNTO 0));
END ControlUnit;

ARCHITECTURE CU OF ControlUnit IS
	SIGNAL temp : std_logic_vector(20 DOWNTO 0) := (OTHERS => '0');
BEGIN
	PROCESS(clk, RST) IS
	BEGIN
		IF (RST = '1') THEN
			temp <= (OTHERS => '0');
		ELSIF rising_edge(clk) THEN
			-- ===========================================
			-- =============== NO OPERANDS ===============
			-- ===========================================
			-- NOP  
			IF (instruction(15 DOWNTO 10) = "000000") THEN
				temp <=  (OTHERS => '0');
			-- SETC  
			ELSIF (instruction(15 DOWNTO 10) = "000001")THEN
				temp <= "000001000000100000000";
			-- CLRC  
			ELSIF (instruction(15 DOWNTO 10) = "000010")THEN
				temp <= "000010000000100000000";
			-- RET  
			ELSIF (instruction(15 DOWNTO 10) = "000011")THEN
				temp <= "000000000110001110000";

			-- RTI 000100

			-- ===========================================
			-- =============== ONE OPERAND ===============
			-- ===========================================
			-- CLR 
			ELSIF (instruction(15 DOWNTO 10) = "000101")THEN
				temp <= "000011000000100010000";
			
			-- NOT 
			ELSIF (instruction(15 DOWNTO 10) = "000110")THEN
				temp <= "000100000000100010000";

			-- INC 
			ELSIF (instruction(15 DOWNTO 10) = "000111")THEN
				temp <= "000101000000100010000";

			-- DEC 
			ELSIF (instruction(15 DOWNTO 10) = "001000")THEN
				temp <= "000110000000100010000";

			-- NEG 
			ELSIF (instruction(15 DOWNTO 10) = "001001")THEN
				temp <= "000111000000100010000";

			-- OUT 
			ELSIF (instruction(15 DOWNTO 10) = "001010")THEN
				temp <= "000000000000000001000";

            		-- IN 
			ELSIF (instruction(15 DOWNTO 10) = "001011")THEN
				temp <= "000000110000000010000";

            		-- RLC 
			ELSIF (instruction(15 DOWNTO 10) = "001100")THEN
				temp <= "001000000000100010000";

            		-- RRC 
			ELSIF (instruction(15 DOWNTO 10) = "001101")THEN
				temp <= "001001000000100010000";
            
            		-- PUSH 
			ELSIF (instruction(15 DOWNTO 10) = "001110")THEN
            	temp <= "000000001010010000000";
        
            		-- POP 
			ELSIF (instruction(15 DOWNTO 10) = "001111")THEN
				temp <= "000000000110001110000";
        
            		-- JZ 
			ELSIF (instruction(15 DOWNTO 10) = "010000")THEN
            	temp <= "100000000000000000010";
        
            		-- JN 
			ELSIF (instruction(15 DOWNTO 10) = "010001")THEN
            	temp <= "100000000000000000100";

            		-- JC 
			ELSIF (instruction(15 DOWNTO 10) = "010010")THEN
            	temp <= "100000000000000000110";
            
            		-- JMP 
			ELSIF (instruction(15 DOWNTO 10) = "010011")THEN
            	temp <= "100000000000000000000";
                
            		-- CALL 
			ELSIF (instruction(15 DOWNTO 10) = "010100")THEN
            	temp <= "000101001011010010000";

            -- ============================================
			-- =============== TWO OPERANDS ===============
			-- ============================================
            -- MOV 
			ELSIF (instruction(15 DOWNTO 10) = "010101")THEN
				temp <= "000000000000100010000";

			-- ADD 
			ELSIF (instruction(15 DOWNTO 10) = "010110")THEN
				temp <= "001010000000100010000";

			-- SUB 
			ELSIF (instruction(15 DOWNTO 10) = "010111")THEN
				temp <= "001011000000100010000";

			-- AND 
			ELSIF (instruction(15 DOWNTO 10) = "011000")THEN
				temp <= "001100000000100010000";

			-- OR 
			ELSIF (instruction(15 DOWNTO 10) = "011001")THEN
				temp <= "001101000000100010000";

			-- IADD 
			ELSIF (instruction(15 DOWNTO 10) = "011010")THEN
				temp <= "011010010000100010000";

			-- SHL 
			ELSIF (instruction(15 DOWNTO 10) = "011011")THEN
				temp <= "001110010000100010000";

			-- SHR 
			ELSIF (instruction(15 DOWNTO 10) = "011100")THEN
				temp <= "001111010000100010000";

			-- LDM 
			ELSIF (instruction(15 DOWNTO 10) = "011101")THEN
				temp <= "010000010000000010000";
	
			-- LDD 
			ELSIF (instruction(15 DOWNTO 10) = "011110")THEN
				temp <= "011010100000001110000";

			-- STD 
			ELSIF (instruction(15 DOWNTO 10) = "011111")THEN
				temp <= "011010010000010000000";

			-- RESET 
			ELSE temp <= "000011000000001110000";
			END IF;
		END IF;
	END PROCESS;
	controlSignals <= temp;
END CU;