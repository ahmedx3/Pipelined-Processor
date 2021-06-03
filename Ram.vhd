LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY RAM IS
        GENERIC (N : INTEGER := 16; SIZE :INTEGER := 1000);
        PORT (
                clk,RST : IN STD_LOGIC;
                WriteOrRead : IN STD_LOGIC;
                Memory_Enable : IN STD_LOGIC;
                address : IN STD_LOGIC_VECTOR( (2*N - 1) DOWNTO 0);
                data_out : OUT STD_LOGIC_VECTOR( (2*N - 1) DOWNTO 0);
                data_in : IN STD_LOGIC_VECTOR( (2*N - 1) DOWNTO 0)
        );
END RAM;

ARCHITECTURE arch_ram OF ram IS

        TYPE ram_type IS ARRAY(0 TO SIZE) OF STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        SIGNAL ram : ram_type := (others => "0000000000000000");

BEGIN
        PROCESS (clk, RST) IS
        BEGIN
                IF RST = '1' THEN
                        data_out <= ram(0)& ram(1);
                ELSIF falling_edge(clk) AND Memory_Enable = '1' THEN
                        IF WriteOrRead = '0' THEN
                                ram(to_integer(unsigned(address))) <= data_in(31 DOWNTO 16);
                                ram(to_integer(unsigned(address)) + 1) <= data_in(15 DOWNTO 0);
                        ELSE
                                data_out <= ram(to_integer(unsigned(address))) & ram(to_integer(unsigned(address)) + 1);
                        END IF;
                END IF;
        END PROCESS;
END arch_ram;