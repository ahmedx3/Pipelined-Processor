LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY IF_ID IS
	PORT (
		CLK, RST, WRITE_ENABLE, LOAD_USE_STALL : IN STD_LOGIC;
		PC_IN  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        INSTRUCTION_IN, IMMEDIATE_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		PC_OUT  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        INSTRUCTION_OUT, IMMEDIATE_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END IF_ID;

ARCHITECTURE arch_IF_ID OF IF_ID IS
BEGIN
	PROCESS (CLK, WRITE_ENABLE, RST)
	BEGIN
		IF RST = '1' THEN
			PC_OUT <= (OTHERS => '0');
			INSTRUCTION_OUT <= (OTHERS => '0');
			IMMEDIATE_OUT <= (OTHERS => '0');
		ELSIF rising_edge(CLK) AND WRITE_ENABLE = '1' AND LOAD_USE_STALL = '0' THEN
			PC_OUT <= PC_IN;
			INSTRUCTION_OUT <= INSTRUCTION_IN;
			IMMEDIATE_OUT <= IMMEDIATE_IN;
		END IF;
	END PROCESS;
END arch_IF_ID;