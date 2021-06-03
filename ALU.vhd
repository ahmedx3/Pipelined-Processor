Library ieee;
Library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY ALU IS
    GENERIC (n : integer:=32);
    PORT (CLK: IN STD_LOGIC;
        A,B: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
        SEL: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        SHIFT: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        FLAG : INOUT STD_LOGIC_VECTOR (2 DOWNTO 0);
        C : OUT STD_LOGIC_VECTOR (n-1 DOWNTO 0);
        FLAG_EN,RST : IN STD_LOGIC);
END ENTITY ALU;

ARCHITECTURE ALU_arch OF ALU IS
COMPONENT my_nadder IS
	PORT (A, B : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0) ;
        CIN : IN STD_LOGIC;
        SUM : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
        COUT: OUT STD_LOGIC);
END COMPONENT;
    SIGNAL CARRY_IN,CARRY_OUT: STD_LOGIC := '0';
    SIGNAL FIRST, SECOND,ALU_OUT, ADDER_OUT: STD_LOGIC_VECTOR(n-1 DOWNTO 0):=(OTHERS => '0');
    CONSTANT ZERO: STD_LOGIC_VECTOR(n-1 DOWNTO 0):=(OTHERS => '0');
    SIGNAL SH: INTEGER;
    SIGNAL INTERNAL_FLAG: STD_LOGIC_VECTOR (2 DOWNTO 0):= "000";
BEGIN
    SH <= to_integer(unsigned( SHIFT ));

    PROCESS (CLK) BEGIN
        IF RISING_EDGE(CLK) THEN
            INTERNAL_FLAG <= FLAG;
        END IF;
    END PROCESS;

    FIRST <= A                  WHEN SEL = b"1010" OR SEL = b"1011"
        ELSE B                  WHEN SEL = b"0101" OR SEL = b"0110"
        ELSE (OTHERS => '0');

    SECOND <= B                 WHEN SEL = b"1010"
        ELSE "not"(B)           WHEN SEL = b"1011" OR SEL = b"0111"
        ELSE (OTHERS => '1')    WHEN SEL = b"0110"
        ELSE (OTHERS => '0');

    CARRY_IN  <= '1'                WHEN SEL = b"0101" OR SEL = b"1011" OR SEL = b"0111"
        ELSE '0';

    u0: my_nadder GENERIC MAP(n) PORT MAP(FIRST, SECOND, CARRY_IN, ADDER_OUT, CARRY_OUT);

    ALU_OUT <=  A                                           WHEN SEL = b"0000"
        ELSE    "NOT"(B)                                    WHEN SEL = b"0100"
        ELSE    ADDER_OUT                                   WHEN SEL = b"0101" OR SEL = b"0110" OR SEL = b"1010" OR SEL = b"1011" OR SEL = b"0111"
        ELSE    A AND B                                     WHEN SEL = b"1100"
        ELSE    A OR  B                                     WHEN SEL = b"1101"
        ELSE    B(N-2 DOWNTO 0) & INTERNAL_FLAG(0)          WHEN SEL = b"1000"
        ELSE    INTERNAL_FLAG(0) & B(N-1 DOWNTO 1)          WHEN SEL = b"1001"
        ELSE    B(N-SH-1 DOWNTO 0) & ZERO(SH-1 DOWNTO 0)    WHEN SEL = b"1110"
        ELSE    ZERO(SH-1 DOWNTO 0) & B(N-1 DOWNTO SH)      WHEN SEL = b"1111"
        ELSE    (OTHERS => '0');

    C <= (OTHERS => '0') WHEN RST = '1'
        ELSE ALU_OUT;

    FLAG(0) <=  CARRY_OUT   WHEN (SEL = b"1010" OR SEL = b"1011" OR SEL = b"0101" OR SEL = b"0110") AND FLAG_EN = '1'
        ELSE    B(N-1)      WHEN SEL = b"1000" AND FLAG_EN = '1'
        ELSE    B(0)        WHEN SEL = b"1001" AND FLAG_EN = '1'
        ELSE    B(N-SH)     WHEN SEL = b"1110" AND FLAG_EN = '1' AND SH /= 0
        ELSE    B(SH-1)     WHEN SEL = b"1111" AND FLAG_EN = '1' AND SH /= 0
        ELSE    '1'         WHEN SEL = b"0001" AND FLAG_EN = '1'
        ELSE    '0'         WHEN RST = '1' OR (SEL = b"0010" AND FLAG_EN = '1')
        ELSE    FLAG(0);

    FLAG(1) <= '1' WHEN ALU_OUT=ZERO  AND FLAG_EN = '1' 
        ELSE '0' WHEN  FLAG_EN = '1' OR RST = '1'
        ELSE FLAG(1);

    FLAG(2) <= ALU_OUT(N-1) WHEN FLAG_EN = '1'
        ELSE '0'            WHEN RST = '1'
        ELSE FLAG(2);

END ALU_arch;