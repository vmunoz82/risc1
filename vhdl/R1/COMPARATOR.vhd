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

ENTITY COMPARATOR IS
    PORT(
        A:        IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        B:        IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        Z:        OUT STD_LOGIC
    );
END COMPARATOR;

--------------------------------------------------------------

ARCHITECTURE BEHAV OF COMPARATOR IS
    COMPONENT ZERO_CHECK
    PORT(
        A:        IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        Z:        OUT STD_LOGIC
    );
END COMPONENT;
    SIGNAL T: STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
    T <= A XOR B;
    IS_ZERO : ZERO_CHECK PORT MAP(
        A => T,
        Z => Z
    );
END BEHAV;
