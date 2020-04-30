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

ENTITY MIPS_ALU IS
    PORT(
        CLK:       IN STD_LOGIC;
        E:         IN STD_LOGIC;
        A:         IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        B:         IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        OP:        IN STD_LOGIC_VECTOR( 5 DOWNTO 0);
        R:        OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        O:        OUT STD_LOGIC
    );
END MIPS_ALU;

ARCHITECTURE BEHAV OF MIPS_ALU IS
    COMPONENT ADDER
    PORT(
        CLK:       IN STD_LOGIC;
        E:         IN STD_LOGIC;
        A:         IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        B:         IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        CI:        IN STD_LOGIC;
        R:        OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        CO:       OUT STD_LOGIC
    );
    END COMPONENT;

    COMPONENT SHIFT_UNIT
    PORT(
        A:         IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        H:         IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        OP:        IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        R:        OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
    END COMPONENT;

    SIGNAL I:           STD_LOGIC_VECTOR(31 DOWNTO 0):= x"00000000";
    

    SIGNAL ADDER_B:     STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ADDER_R:     STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ADDER_CI:    STD_LOGIC;
    SIGNAL ADDER_E:     STD_LOGIC;
    SIGNAL ADDER_E2:    STD_LOGIC:= '0';

    SIGNAL ADDING:      STD_LOGIC;
    SIGNAL SUBING:      STD_LOGIC;
    SIGNAL SUBING2:     STD_LOGIC:= '0';

    SIGNAL OP2:         STD_LOGIC_VECTOR(2 DOWNTO 0):= "000";
    SIGNAL RES:         STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL LT2:         STD_LOGIC:= '0';
    SIGNAL ADDER_CO:    STD_LOGIC;
    SIGNAL UNSIGNED2:   STD_LOGIC:= '0';
    
    SIGNAL SHIFTER_E:   STD_LOGIC;
    SIGNAL SHIFTER_H:   STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL SHIFTER_OP:  STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL SHIFTER_R:   STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL SHIFTER_E2:  STD_LOGIC:= '0';
    SIGNAL SHIFTER_R2:  STD_LOGIC_VECTOR(31 DOWNTO 0):= x"00000000";
BEGIN
    ADD : ADDER
    PORT MAP(
        CLK  => CLK,
        E    => ADDER_E,
        A    => A,
        B    => ADDER_B,
        CI   => ADDER_CI,
        R    => ADDER_R,
        CO   => ADDER_CO
    );

    SHIFTER : SHIFT_UNIT
    PORT MAP(
        A   => B,
        H   => SHIFTER_H,
        OP  => SHIFTER_OP,
        R   => SHIFTER_R
    );

    ADDING     <= '1' WHEN (E = '1' AND OP(2 DOWNTO 1) = "00") ELSE '0'; -- (100_00_X) ADD  ADDU
    SUBING     <= '1' WHEN (E = '1' AND OP(2 DOWNTO 1) = "01") ELSE '0'; -- (101_00_X) ADDI ADDIU
                                                                         -- (100_01_X) SUB  SUBU
                                                                         -- (101_01_X) SLT  SLTU
                                                                         -- (001_01_X) SLTI SLTIU
                                      
    ADDER_E    <= NOT(SHIFTER_E) AND (ADDING OR SUBING);
    ADDER_CI   <= SUBING;
    ADDER_B    <= NOT(B) WHEN SUBING = '1' ELSE B;


    RES        <= "0000000000000000000000000000000" & NOT(LT2 XOR ADDER_CO)
                  WHEN (SUBING2 = '1' AND (OP2 = "101" OR OP2 = "001")) -- 101: SLT, SLTU; 001: SLTI, SLTIU
                  ELSE ADDER_R;

    R          <= RES WHEN ADDER_E2 = '1'
                  ELSE SHIFTER_R2 WHEN SHIFTER_E2 = '1'
                  ELSE I;

    -- OVERFLOW AKA CARRY OUT
    O          <= ADDER_CO WHEN (ADDER_E2 AND NOT(UNSIGNED2))= '1' ELSE '0';


    SHIFTER_E  <= E AND NOT(OP(5) OR OP(4) OR OP(3));
    SHIFTER_H  <= A(4 DOWNTO 0);
    SHIFTER_OP <= OP(1 DOWNTO 0);

    PROCESS(CLK)
    BEGIN
    IF (CLK'EVENT AND CLK='1') THEN
        IF(E = '1') THEN
                LT2 <= (A(31) XOR B(31)) AND NOT OP(0);
                ADDER_E2 <= ADDER_E;
                OP2      <= OP(5 DOWNTO 3);
                SUBING2  <= SUBING;
                UNSIGNED2 <= OP(0);
                SHIFTER_E2 <= SHIFTER_E;
                SHIFTER_R2 <= SHIFTER_R;
            IF    (OP(2 DOWNTO 0) = "100") THEN --AND
                I <= A AND B;
            ELSIF (OP(2 DOWNTO 0) = "101") THEN --OR
                I <= A OR B;
            ELSIF (OP(2 DOWNTO 0) = "110") THEN --XOR
                I <= A XOR B;
            ELSIF (OP(2 DOWNTO 0) = "111") THEN --NOR LUI
                IF (OP(5 DOWNTO 3) = "100") THEN   -- NOR
                    I <= A NOR B;
                END IF;
                IF (OP(5 DOWNTO 3) = "001") THEN   -- LUI
                    I <= B(15 DOWNTO 0) & x"0000";
                END IF;
            END IF;
        ELSE
            -- DO WE NEED TRISTATES IN THIS DESIGN?
            I <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
        END IF;

    END IF;
    END PROCESS;
END BEHAV;


