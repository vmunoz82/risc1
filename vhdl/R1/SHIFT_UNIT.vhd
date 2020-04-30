----------------------------------------------------------
--
-- 32 bits pipelined RISC processor
-- Copyright (c) 2010 Victor Munoz. All rights reserved.
-- derechos reservados, prohibida su reproduccion
--
-- Author: Victor Munoz
-- Contact: vmunoz@ingenieria-inversa.cl
--
----------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY SHIFT_UNIT IS
    PORT(
        A:        IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        H:        IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
        OP:       IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        R:        OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END SHIFT_UNIT;

--------------------------------------------------------------

ARCHITECTURE BEHAV OF SHIFT_UNIT IS

    SIGNAL I:             STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL Q16:           STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL Q8:            STD_LOGIC_VECTOR( 7 DOWNTO 0);
    SIGNAL Q4:            STD_LOGIC_VECTOR( 3 DOWNTO 0);
    SIGNAL Q2:            STD_LOGIC_VECTOR( 1 DOWNTO 0);
    SIGNAL Q1:            STD_LOGIC;

    SIGNAL SR16:          STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL SR8:           STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL SR4:           STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL SR2:           STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL SR1:           STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL SL16:          STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL SL8:           STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL SL4:           STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL SL2:           STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL SL1:           STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN
   
    Q1  <= OP(0) AND A(31);
    Q2  <= "11"               WHEN Q1 = '1' ELSE "00";
    Q4  <= "1111"             WHEN Q1 = '1' ELSE "0000";
    Q8  <= "11111111"         WHEN Q1 = '1' ELSE "00000000";
    Q16 <= "1111111111111111" WHEN Q1 = '1' ELSE "0000000000000000";

    --TODO: I'VE TO LOOK IF IS CHEAPER DO THIS CONNECTING INVERSE, OR ALSO 
    --I COULD BE GIVE A TRY TO NEGATE THE SHIFT AMOUNT AND MASKING
    
    SR16 <= Q16 &    A(31 DOWNTO 16) WHEN H(4) = '1' ELSE A;
    SR8  <=  Q8 & SR16(31 DOWNTO 8)  WHEN H(3) = '1' ELSE SR16;
    SR4  <=  Q4 &  SR8(31 DOWNTO 4)  WHEN H(2) = '1' ELSE SR8;
    SR2  <=  Q2 &  SR4(31 DOWNTO 2)  WHEN H(1) = '1' ELSE SR4;
    SR1  <=  Q1 &  SR2(31 DOWNTO 1)  WHEN H(0) = '1' ELSE SR2;

    SL16 <=    A(15 DOWNTO 0) & Q16  WHEN H(4) = '1' ELSE A;
    SL8  <= SL16(23 DOWNTO 0)  & Q8  WHEN H(3) = '1' ELSE SL16;
    SL4  <=  SL8(27 DOWNTO 0)  & Q4  WHEN H(2) = '1' ELSE SL8;
    SL2  <=  SL4(29 DOWNTO 0)  & Q2  WHEN H(1) = '1' ELSE SL4;
    SL1  <=  SL2(30 DOWNTO 0)  & Q1  WHEN H(0) = '1' ELSE SL2;

    R    <= SR1 WHEN OP(1) = '1' ELSE SL1;
    
END BEHAV;

