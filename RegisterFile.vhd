LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;

ENTITY RegisterFile IS
	GENERIC (N : INTEGER := 32);
	PORT (
		CLK, RST, ENABLE : IN STD_LOGIC;
		InputBus : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        writeIndex, readIndex1, readIndex2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		OutputBus1, OutputBus2 : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
END RegisterFile;

ARCHITECTURE archRegisterFile OF RegisterFile IS
    TYPE REGISTER_TYPE IS ARRAY(0 TO 7) OF STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    SIGNAL REGISTERS: REGISTER_TYPE := (OTHERS => X"00000000");
BEGIN
	PROCESS (CLK, ENABLE, RST)
	BEGIN
		IF RST = '1' THEN
            REGISTERS <= (OTHERS => X"00000000");
		ELSIF rising_edge(CLK) AND ENABLE = '1' THEN
        REGISTERS(to_integer(unsigned( writeIndex ))) <= InputBus;
		END IF;
	END PROCESS;
    OutputBus1 <= REGISTERS(to_integer(unsigned( readIndex1 )));
    OutputBus2 <= REGISTERS(to_integer(unsigned( readIndex2 )));
END archRegisterFile;