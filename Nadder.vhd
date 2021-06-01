Library ieee;
Library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY my_nadder IS
GENERIC (n : integer := 32);
PORT (A, B : IN std_logic_vector(n-1 DOWNTO 0) ;
CIN : IN std_logic;
SUM : OUT std_logic_vector(n-1 DOWNTO 0);
COUT : OUT std_logic);
END my_nadder;

ARCHITECTURE a_my_nadder OF my_nadder IS

COMPONENT my_adder IS
PORT( a,b,cin : IN std_logic; s,cout : OUT std_logic);
END COMPONENT;

SIGNAL temp : std_logic_vector(n-1 DOWNTO 0);

BEGIN
f0: my_adder PORT MAP(a(0),b(0),cin,sum(0),temp(0));

loop1: FOR i IN 1 TO n-1 GENERATE
	fx: my_adder PORT MAP(a(i),b(i),temp(i-1),sum(i),temp(i));
END GENERATE;
Cout <= temp(n-1);

END a_my_nadder;
