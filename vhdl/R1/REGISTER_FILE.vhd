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

--------------------------------------------------------------

ENTITY REGISTER_FILE IS
    PORT(
        CLK:   IN STD_LOGIC;

        RA_R:  IN STD_LOGIC;
        RA_W:  IN STD_LOGIC;
        RB_R:  IN STD_LOGIC;

        RA_AR: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        RB_AR: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        RA_AW: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        RA_DW: IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        RA_DR: OUT STD_LOGIC_VECTOR(31 DOWNTO 0):= "00000000000000000000000000000000";
        RB_DR: OUT STD_LOGIC_VECTOR(31 DOWNTO 0):= "00000000000000000000000000000000"
    );
END REGISTER_FILE;

--------------------------------------------------------------

ARCHITECTURE BEHAV OF REGISTER_FILE IS

    TYPE T_R32 IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL REGS: T_R32:= (
         0 => x"00000000", --ZERO
         1 => x"00000000", --AT
         2 => x"00000000", --V0
         3 => x"00000000", --V1
         4 => x"00000000", --A0
         5 => x"00000000", --A1
         6 => x"00000000", --A2
         7 => x"00000000", --A3
         8 => x"00000000", --T0
         9 => x"00000000", --T1
        10 => x"00000000", --T2
        11 => x"00000000", --T3
        12 => x"00000000", --T4
        13 => x"00000000", --T5
        14 => x"00000000", --T6
        15 => x"00000000", --T7
        16 => x"00000000", --S0
        17 => x"00000000", --S1
        18 => x"00000000", --S2
        19 => x"00000000", --S3
        20 => x"00000000", --S4
        21 => x"00000000", --S5
        22 => x"00000000", --S6
        23 => x"00000000", --S7
        24 => x"00000000", --T8
        25 => x"00000000", --T9
        26 => x"00000000", --K0
        27 => x"00000000", --K1
        28 => x"00000000", --GP
        29 => x"00000000", --SP
        30 => x"00000000", --FP
        31 => x"00000000"  --RA
        );

BEGIN
    PROCESS(CLK)
    BEGIN
    IF (CLK'EVENT AND CLK='1') THEN
        IF RA_R = '1' THEN
            RA_DR <= REGS(CONV_INTEGER(UNSIGNED(RA_AR)));
            IF RA_W = '1' AND RA_AR = RA_AW THEN
                RA_DR <= RA_DW;  -- AVOID SOME DATA HAZARDS AND SAVE SOME POLAR BEARS TOO :)
            END IF;
        END IF;

        IF RB_R='1' THEN
            RB_DR <= REGS(CONV_INTEGER(UNSIGNED(RB_AR)));
            IF RA_W = '1' AND RB_AR = RA_AW THEN
                RB_DR <= RA_DW;  -- AVOID SOME DATA HAZARDS AND SAVE SOME POLAR BEARS TOO :)
            END IF;
        END IF;

        IF RA_W = '1' AND NOT(RA_AW = "00000") THEN
            REGS(CONV_INTEGER(UNSIGNED(RA_AW))) <= RA_DW;
        END IF;

    END IF;
    END PROCESS;
END BEHAV;
