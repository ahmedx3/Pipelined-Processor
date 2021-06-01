Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY my_adder IS -- single bit adder
PORT( A,B,CIN : IN std_logic;
S,COUT : OUT std_logic);
END my_adder;

ARCHITECTURE a_my_adder OF my_adder IS
BEGIN
S <= A XOR B XOR CIN;
COUT <= (A AND B) or (CIN AND (A XOR B));
END a_my_adder;