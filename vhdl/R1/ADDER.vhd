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

ENTITY ADDER IS
    PORT(
        CLK:      IN  STD_LOGIC;
        E:        IN  STD_LOGIC;
        A:        IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        B:        IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        CI:       IN  STD_LOGIC;
        R:        OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        CO:       OUT STD_LOGIC
    );
END ADDER;

--------------------------------------------------------------

ARCHITECTURE BEHAV OF ADDER IS
    SIGNAL I: STD_LOGIC_VECTOR(32 DOWNTO 0):= "000000000000000000000000000000000";
BEGIN
    R  <= I(31 DOWNTO 0);
    CO <= I(32);
    PROCESS(CLK)
    BEGIN
        IF (CLK'EVENT AND CLK='1') THEN
            IF(E = '1') THEN
                I <= ("0" & A) + ("0" & B) + CI;
            END IF;
        END IF;
    END PROCESS;
END BEHAV;

