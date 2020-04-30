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
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

ENTITY TB IS
END ENTITY;


ARCHITECTURE TESTBENCH_ARCH OF TB IS
    COMPONENT SYSTEM
    PORT (
        CLK: IN STD_LOGIC
    );
    END COMPONENT;

    SIGNAL CLK: STD_LOGIC := '0';

BEGIN
    UUT : SYSTEM
    PORT MAP (
        CLK => CLK
    );

    PROCESS    -- CLOCK PROCESS FOR CLK
    BEGIN
        WAIT FOR 100 NS;
        CLOCK_LOOP : LOOP
            CLK <= '0';
            WAIT FOR 10 NS;
            CLK <= '1';
            WAIT FOR 10 NS;
        END LOOP CLOCK_LOOP;
    END PROCESS;

END TESTBENCH_ARCH;
