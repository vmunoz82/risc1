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

ENTITY ZERO_CHECK IS
    PORT(
        A:        IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        Z:        OUT STD_LOGIC
    );
END ZERO_CHECK;

--------------------------------------------------------------

ARCHITECTURE BEHAV OF ZERO_CHECK IS
BEGIN
    Z <= NOT(A(31) OR A(30) OR A(29) OR A(28) OR
             A(27) OR A(26) OR A(25) OR A(24) OR
             A(23) OR A(22) OR A(21) OR A(20) OR
             A(19) OR A(18) OR A(17) OR A(16) OR
             A(15) OR A(14) OR A(13) OR A(12) OR
             A(11) OR A(10) OR A( 9) OR A( 8) OR
             A( 7) OR A( 6) OR A( 5) OR A( 4) OR
             A( 3) OR A( 2) OR A( 1) OR A( 0));
END BEHAV;
