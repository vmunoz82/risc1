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

ENTITY MIPS1 IS
    PORT(
        CLK:         IN  STD_LOGIC;
        HALT:        IN  STD_LOGIC;

        CB_RDATA:    IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        CB_WDATA:    OUT STD_LOGIC_VECTOR(31 DOWNTO 0):= x"00000000";
        CB_W:        OUT STD_LOGIC:= '0';
        CB_R:        OUT STD_LOGIC:= '1';
        CB_WADDR:    OUT STD_LOGIC_VECTOR(31 DOWNTO 0):= x"00000000";
        CB_RADDR:    OUT STD_LOGIC_VECTOR(31 DOWNTO 0):= x"00000000";
        CB_ENABLE:   OUT STD_LOGIC:= '1';

        DB_RDATA:    IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        DB_WDATA:    OUT STD_LOGIC_VECTOR(31 DOWNTO 0):= x"00000000";
        DB_W:        OUT STD_LOGIC;
        DB_R:        OUT STD_LOGIC;
        DB_WADDR:    OUT STD_LOGIC_VECTOR(31 DOWNTO 0):= x"00000000";
        DB_RADDR:    OUT STD_LOGIC_VECTOR(31 DOWNTO 0):= x"00000000";
        DB_ENABLE:   OUT STD_LOGIC:= '0';
        DB_MODE:     OUT STD_LOGIC_VECTOR(2 DOWNTO 0):= "001";
        DB_ISSIGNED: OUT STD_LOGIC:= '0'
    );
END MIPS1;

ARCHITECTURE BEHAV OF MIPS1 IS
    COMPONENT REGISTER_FILE
    PORT(
        CLK:       IN  STD_LOGIC;
        RA_R:      IN  STD_LOGIC;
        RA_W:      IN  STD_LOGIC;
        RB_R:      IN  STD_LOGIC;
        RA_AR:     IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
        RB_AR:     IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
        RA_AW:     IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
        RA_DW:     IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        RA_DR:     OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        RB_DR:     OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
    END COMPONENT;

    COMPONENT MIPS_ALU
    PORT(
        CLK:       IN  STD_LOGIC;
        E:         IN  STD_LOGIC;
        A:         IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        B:         IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        OP:        IN  STD_LOGIC_VECTOR(5 DOWNTO 0);
        R:         OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        O:         OUT STD_LOGIC
    );
    END COMPONENT;

    COMPONENT ADDER
    PORT(
        CLK:       IN  STD_LOGIC;
        E:         IN  STD_LOGIC;
        A:         IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        B:         IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        CI:        IN  STD_LOGIC;
        R:         OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        CO:        OUT STD_LOGIC
    );
    END COMPONENT;

    COMPONENT COMPARATOR
    PORT(
        A:         IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        B:         IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        Z:         OUT STD_LOGIC
    );
    END COMPONENT;

    COMPONENT ZERO_CHECK
    PORT(
        A:         IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        Z:         OUT STD_LOGIC
    );
    END COMPONENT;

    -- REGISTER FILE SIGNALS
    SIGNAL REGA_R:   STD_LOGIC:= '0';
    SIGNAL REGA_W:   STD_LOGIC:= '0';
    SIGNAL REGB_R:   STD_LOGIC:= '0';
    SIGNAL REGA_RA:  STD_LOGIC_VECTOR(4 DOWNTO 0):= "00000";
    SIGNAL REGB_RA:  STD_LOGIC_VECTOR(4 DOWNTO 0):= "00000";
    SIGNAL REGA_WA:  STD_LOGIC_VECTOR(4 DOWNTO 0):= "00000";
    SIGNAL REGA_WD:  STD_LOGIC_VECTOR(31 DOWNTO 0):= x"00000000";
    SIGNAL REGA_RD:  STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL REGB_RD:  STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- ALU SIGNALS
    SIGNAL ALU_E:    STD_LOGIC:= '0';
    SIGNAL ALU_A:    STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ALU_B:    STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ALU_OP:   STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL ALU_R:    STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ALU_O:    STD_LOGIC;

    -- PC ADDER SIGNALS
    SIGNAL PC_ADDER_R:     STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL PC_ADDER_A:     STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- BRANCH ADDER SIGNALS
    SIGNAL BRANCH_ADDER_R: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL BRANCH_ADDER_B: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL BRANCH_ADDER_E: STD_LOGIC:= '0';
    SIGNAL BRANCH_ADDER_A: STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- REGISTER COMPARATOR
    SIGNAL REGEQ_Z:  STD_LOGIC;

    -- ZERO CHECK SIGNALS
    SIGNAL REGZ_Z:   STD_LOGIC;

    ----------------
    -- MAIN SIGNALS
    ----------------
    SIGNAL PC:             STD_LOGIC_VECTOR(29 DOWNTO 0):= "00" & x"0000000";


    -----------------------------------------
    -- SIGNALS THAT ONLY BELONG TO ONE STAGE
    -----------------------------------------
    SIGNAL T1_OP_TYPE_I:   STD_LOGIC;
    SIGNAL T1_OP_TYPE_R:   STD_LOGIC;

    SIGNAL T1_OI_0000:     STD_LOGIC; --(J, JAL, ETC)
    SIGNAL T1_OI_0001:     STD_LOGIC; --(BEQ, BNE, ETC)
    SIGNAL T1_OI_001X:     STD_LOGIC; --(ADDI, ADDIU, ETC)
    SIGNAL T1_OI_100X:     STD_LOGIC; --(LW, LB ETC)
    SIGNAL T1_OI_101X:     STD_LOGIC; --(SW, SB ETC)

    SIGNAL T1_OR_000:      STD_LOGIC; --(SLL, SLLV, ETC)
    SIGNAL T1_OR_001:      STD_LOGIC; --(JR, ETC)
    SIGNAL T1_OR_100:      STD_LOGIC; --(ADD, ADDU, ETC)
    SIGNAL T1_OR_101:      STD_LOGIC; --(SLT, SLTU)


    -- FOR STAGE TWO
    SIGNAL T2_REGA_RD:     STD_LOGIC_VECTOR(31 DOWNTO 0):= x"00000000";
    SIGNAL T2_REGB_RD:     STD_LOGIC_VECTOR(31 DOWNTO 0):= x"00000000";

    SIGNAL T2_BRANCH_TAKE: STD_LOGIC:= '0';

    SIGNAL T2_ALU_SEXTEND: STD_LOGIC:= '0';
    SIGNAL T2_ALU_ZEXTEND: STD_LOGIC:= '0';
    SIGNAL T2_ALU_SEXT:    STD_LOGIC_VECTOR(15 DOWNTO 0):= x"0000";


    -------------------------------------------------
    -- FLAGS THAT KEEP FOR EACH STEP IN THE PIPELINE
    -------------------------------------------------

    -- FOR STAGE ONE
    SIGNAL F1_SHIFTH:      STD_LOGIC;
    SIGNAL F1_J:           STD_LOGIC;
    SIGNAL F1_JR:          STD_LOGIC;
    SIGNAL F1_BRANCH:      STD_LOGIC;
    SIGNAL F1_BRANCH2:     STD_LOGIC;
    SIGNAL F1_LOAD:        STD_LOGIC;
    SIGNAL F1_STORE:       STD_LOGIC;
    SIGNAL F1_REG_TO_REG:  STD_LOGIC;
    SIGNAL F1_INM_TO_REG:  STD_LOGIC;
    SIGNAL F1_ALU_INM:     STD_LOGIC;
    SIGNAL F1_ALU_ENABLE:  STD_LOGIC;
    SIGNAL F1_ALU_WBACK:   STD_LOGIC;
    SIGNAL F1_LINK:        STD_LOGIC;

    -- FOR STAGE TWO
    SIGNAL F2_SHIFTH:      STD_LOGIC:= '0';
    SIGNAL F2_J:           STD_LOGIC:= '0';
    SIGNAL F2_JR:          STD_LOGIC:= '0';
    SIGNAL F2_BRANCH:      STD_LOGIC:= '0';
    SIGNAL F2_BRANCH2:     STD_LOGIC:= '0';
    SIGNAL F2_LOAD:        STD_LOGIC:= '0';
    SIGNAL F2_STORE:       STD_LOGIC:= '0';
    SIGNAL F2_REG_TO_REG:  STD_LOGIC:= '0';
    SIGNAL F2_INM_TO_REG:  STD_LOGIC:= '0';
    SIGNAL F2_ALU_ENABLE:  STD_LOGIC:= '0';
    SIGNAL F2_ALU_WBACK:   STD_LOGIC:= '0';
    SIGNAL F2_LINK:        STD_LOGIC:= '0';

    -- FOR STAGE THREE
    SIGNAL F3_LOAD:        STD_LOGIC:= '0';
    SIGNAL F3_STORE:       STD_LOGIC:= '0';
    SIGNAL F3_ALU_ENABLE:  STD_LOGIC:= '0';
    SIGNAL F3_ALU_WBACK:   STD_LOGIC:= '0';

    -- FOR STAGE FOUR
    SIGNAL F4_LOAD:        STD_LOGIC:= '0';
    SIGNAL F4_ALU_ENABLE:  STD_LOGIC:= '0';
    SIGNAL F4_ALU_WBACK:   STD_LOGIC:= '0';

    ------------------------------------------------------
    -- SIGNALS THAT KEEP DATA AMONG STEPS IN THE PIPELINE
    ------------------------------------------------------

    -- FOR STAGE ONE
    SIGNAL S1_OPCODE:      STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL S1_INS:         STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL S1_BRANCH_SEXT: STD_LOGIC_VECTOR(15 DOWNTO 0);

    -- FOR STAGE TWO
    SIGNAL S2_OPCODE:      STD_LOGIC_VECTOR(5 DOWNTO 0):= "000000";
    SIGNAL S2_INS:         STD_LOGIC_VECTOR(31 DOWNTO 0):= x"00000000";
    SIGNAL S2_REGA_RA:     STD_LOGIC_VECTOR(4 DOWNTO 0):= "00000";
    SIGNAL S2_REGB_RA:     STD_LOGIC_VECTOR(4 DOWNTO 0):= "00000";
    SIGNAL S2_LINKED:      STD_LOGIC:= '0';
    SIGNAL S2_WB_REG:      STD_LOGIC_VECTOR(4 DOWNTO 0):= "00000";

    -- FOR STAGE THREE
    SIGNAL S3_OPCODE:      STD_LOGIC_VECTOR(5 DOWNTO 0):= "000000";
    SIGNAL S3_REGB_RD:     STD_LOGIC_VECTOR(31 DOWNTO 0):= x"00000000";
    SIGNAL S3_LINK_ADDR:   STD_LOGIC_VECTOR(31 DOWNTO 0):= x"00000000";
    SIGNAL S3_LINKED:      STD_LOGIC:= '0';
    SIGNAL S3_WB_REG:      STD_LOGIC_VECTOR(4 DOWNTO 0):= "00000";

    -- FOR STAGE FOUR
    SIGNAL S4_ALU_R:       STD_LOGIC_VECTOR(31 DOWNTO 0):= x"00000000";
    SIGNAL S4_LINK_ADDR:   STD_LOGIC_VECTOR(31 DOWNTO 0):= x"00000000";
    SIGNAL S4_LINKED:      STD_LOGIC:= '0';
    SIGNAL S4_WB_REG:      STD_LOGIC_VECTOR(4 DOWNTO 0):= "00000";


BEGIN
    ----------------------
    -- CONNECTING DEVICES
    ----------------------
    REGISTERS : REGISTER_FILE
    PORT MAP(
        CLK   => CLK,
        RA_R  => REGA_R,
        RA_W  => REGA_W,
        RB_R  => REGB_R,
        RA_AR => REGA_RA,
        RB_AR => REGB_RA,
        RA_AW => REGA_WA,
        RA_DW => REGA_WD,
        RA_DR => REGA_RD,
        RB_DR => REGB_RD
    );

    ALU : MIPS_ALU
    PORT MAP(
        CLK => CLK,
        E   => ALU_E,
        A   => ALU_A,
        B   => ALU_B,
        OP  => ALU_OP,
        R   => ALU_R,
        O   => ALU_O
    );

    PC_ADDER : ADDER
    PORT MAP(
        CLK  => CLK,
        E    => '1',
        A    => PC_ADDER_A,
        B    => x"00000000",
        CI   => '1', -- ALWAYS ONE, WE ARE GOING TO USE THE CARRY IN
        R    => PC_ADDER_R
    );

    BRANCH_ADDER : ADDER
    PORT MAP(
        CLK  => CLK,
        E    => BRANCH_ADDER_E,
        A    => BRANCH_ADDER_A,
        B    => BRANCH_ADDER_B,
        CI   => '0',
        R    => BRANCH_ADDER_R
    );

    REGEQ : COMPARATOR
    PORT MAP(
        A    => T2_REGA_RD,
        B    => T2_REGB_RD,
        Z    => REGEQ_Z
    );

    REGZ : ZERO_CHECK
    PORT MAP(
        A    => T2_REGA_RD,
        Z    => REGZ_Z
    );

    --------------------------
    -- INS FETCH STAGE (ZERO)
    --------------------------
    PC_ADDER_A   <= "00" & PC;
    S1_INS       <= CB_RDATA;
    CB_RADDR     <= PC & "00";


    ----------------------------------
    -- REGISTER RETRIEVAL STAGE (ONE)
    ----------------------------------

    -- OPCODE FAMILIES EQUATIONS
    T1_OP_TYPE_I  <= S1_INS(31) OR S1_INS(30) OR S1_INS(29) 
                     OR S1_INS(28) OR S1_INS(27) OR S1_INS(26);
    T1_OP_TYPE_R  <= NOT(T1_OP_TYPE_I);

    S1_OPCODE     <=      S1_INS(31 DOWNTO 26) WHEN T1_OP_TYPE_I = '1'
                     ELSE S1_INS( 5 DOWNTO  0);

    T1_OI_0000    <= T1_OP_TYPE_I AND (NOT(S1_OPCODE(5)   OR S1_OPCODE(4)   OR S1_OPCODE(3)   OR S1_OPCODE(2)));
    T1_OI_0001    <= T1_OP_TYPE_I AND (NOT(S1_OPCODE(5)   OR S1_OPCODE(4)   OR S1_OPCODE(3)) AND S1_OPCODE(2));
    T1_OI_001X    <= T1_OP_TYPE_I AND (NOT(S1_OPCODE(5)   OR S1_OPCODE(4)) AND S1_OPCODE(3));
    T1_OI_100X    <= T1_OP_TYPE_I AND (NOT(S1_OPCODE(4)   OR S1_OPCODE(3)) AND S1_OPCODE(5));
    T1_OI_101X    <= T1_OP_TYPE_I AND (NOT(S1_OPCODE(4)) AND S1_OPCODE(5)  AND S1_OPCODE(3));

    T1_OR_000     <= T1_OP_TYPE_R AND (NOT(S1_OPCODE(5)   OR S1_OPCODE(4)   OR S1_OPCODE(3)));
    T1_OR_001     <= T1_OP_TYPE_R AND (NOT(S1_OPCODE(5)   OR S1_OPCODE(4)) AND S1_OPCODE(3));
    T1_OR_100     <= T1_OP_TYPE_R AND (NOT(S1_OPCODE(4)   OR S1_OPCODE(3)) AND S1_OPCODE(5));
    T1_OR_101     <= T1_OP_TYPE_R AND  NOT(S1_OPCODE(4)) AND S1_OPCODE(3)  AND S1_OPCODE(5);

    -- DEFINING FLAGS AT STAGE ONE
    F1_SHIFTH     <= T1_OR_000 AND NOT(S1_OPCODE(2));
    F1_J          <= T1_OI_0000 AND S1_OPCODE(1);
    F1_JR         <= T1_OR_001;
    F1_BRANCH     <= T1_OI_0001;
    F1_BRANCH2    <= T1_OI_0000 AND NOT(S1_OPCODE(1));
    F1_LOAD       <= T1_OI_100X;
    F1_STORE      <= T1_OI_101X;
    F1_REG_TO_REG <= T1_OR_100 OR T1_OR_101 OR T1_OR_000;
    F1_INM_TO_REG <= T1_OI_001X;
    F1_ALU_INM    <= F1_LOAD OR F1_STORE OR F1_INM_TO_REG;
    F1_ALU_WBACK  <= F1_REG_TO_REG OR F1_INM_TO_REG OR F1_SHIFTH;
    F1_ALU_ENABLE <= F1_ALU_WBACK OR F1_LOAD OR F1_STORE;
    F1_LINK       <= (F1_J AND S1_OPCODE(0)) OR (F1_JR AND S1_OPCODE(0));

    -- SETTING UP REGISTER RETRIEVING
    REGA_R  <= F1_JR OR F1_REG_TO_REG OR F1_ALU_INM OR F1_BRANCH OR F1_BRANCH2;
    REGB_R  <= F1_REG_TO_REG OR F1_STORE OR F1_BRANCH OR F1_BRANCH2;

    REGA_RA <= S1_INS(25 DOWNTO 21) WHEN REGA_R = '1';
    REGB_RA <= S1_INS(20 DOWNTO 16) WHEN REGB_R = '1';


    -- BRANCHING STUFF
    BRANCH_ADDER_E  <= F1_BRANCH OR F1_BRANCH2;

    S1_BRANCH_SEXT  <=     x"FFFF" WHEN S1_INS(15) = '1'
                      ELSE x"0000" WHEN NOT(S1_INS(15)) = '1';

    BRANCH_ADDER_A  <= "00" & PC;

    BRANCH_ADDER_B  <= S1_BRANCH_SEXT & S1_INS(15 DOWNTO 0);


    -----------------------
    -- ALU AND BRANCH(TWO)
    -----------------------

    -- ALU STUFF
    T2_REGA_RD      <=      ALU_R    WHEN F3_ALU_WBACK =  '1' AND S3_WB_REG = S2_REGA_RA
                       ELSE S4_ALU_R WHEN F4_ALU_WBACK =  '1' AND S4_WB_REG = S2_REGA_RA
                       ELSE DB_RDATA WHEN F4_LOAD      =  '1' AND S4_WB_REG = S2_REGA_RA
                       ELSE S4_LINK_ADDR(29 DOWNTO 0) & "00" WHEN S4_LINKED = '1' AND S4_WB_REG = S2_REGA_RA
                       ELSE REGA_RD;                                                     -- PREVENT HAZARDS

    T2_REGB_RD      <=      ALU_R    WHEN F3_ALU_WBACK =  '1' AND S3_WB_REG = S2_REGB_RA
                       ELSE S4_ALU_R WHEN F4_ALU_WBACK =  '1' AND S4_WB_REG = S2_REGB_RA
                       ELSE DB_RDATA WHEN F4_LOAD      =  '1' AND S4_WB_REG = S2_REGB_RA
                       ELSE S4_LINK_ADDR(29 DOWNTO 0) & "00" WHEN S4_LINKED = '1' AND S4_WB_REG = S2_REGB_RA
                       ELSE REGB_RD;                                                     -- PREVENT HAZARDS

    ALU_A           <= x"000000" & "000" & S2_INS(10 DOWNTO 6)  WHEN F2_SHIFTH = '1'
                       ELSE T2_REGA_RD;

    T2_ALU_SEXTEND  <= (F2_INM_TO_REG AND NOT(S2_OPCODE(2))) OR F2_LOAD OR F2_STORE;
    T2_ALU_ZEXTEND  <= F2_INM_TO_REG AND S2_OPCODE(2);
    T2_ALU_SEXT     <=      x"FFFF" WHEN T2_ALU_SEXTEND = '1' AND S2_INS(15) = '1'
                       ELSE x"0000" WHEN T2_ALU_SEXTEND = '1' AND S2_INS(15) = '0';

    ALU_B           <=      T2_REGB_RD                        WHEN F2_REG_TO_REG = '1'
                       ELSE x"0000" & S2_INS(15 DOWNTO 0)     WHEN T2_ALU_ZEXTEND = '1'
                       ELSE T2_ALU_SEXT & S2_INS(15 DOWNTO 0) WHEN T2_ALU_SEXTEND = '1'
                       ELSE x"00000000";

    ALU_OP          <=      S2_OPCODE WHEN (F2_REG_TO_REG OR F2_SHIFTH OR F2_INM_TO_REG) = '1'
                       ELSE "100000"; -- ADD AS DEFAULT (FOR LOAD AND STORE)

    ALU_E           <= F2_ALU_ENABLE;

    S2_WB_REG       <= S2_INS(20 DOWNTO 16) WHEN (F2_INM_TO_REG OR F2_LOAD) = '1'
                       ELSE S2_INS(15 DOWNTO 11) WHEN (F2_REG_TO_REG
                                                      OR (F2_JR AND S2_LINKED)) = '1' -- (JALR)
                       ELSE "11111"              WHEN (S2_LINKED) = '1' ; -- RA (JAL, BGEZAL, BLTZAL) 

    -- BRANCHING STUFF
    T2_BRANCH_TAKE  <=    (F2_BRANCH  AND NOT(S2_INS(27) OR S2_INS(26)) AND REGEQ_Z) -- BEQ
                       OR (F2_BRANCH  AND NOT(S2_INS(27) OR REGEQ_Z) AND S2_INS(26)) -- BNE
                       OR (F2_BRANCH  AND S2_INS(27) AND NOT(S2_INS(26)) AND (T2_REGA_RD(31) OR REGZ_Z)) -- BLEZ
                       OR (F2_BRANCH  AND S2_INS(27) AND S2_INS(26) AND NOT(T2_REGA_RD(31) OR REGZ_Z)) -- BGTZ
                       OR (F2_BRANCH2 AND(S2_INS(16) XOR T2_REGA_RD(31))); -- BGEZ, BLTZ, BGEZAL, BLTZAL



    PC              <=      T2_REGA_RD(31 DOWNTO 2)     WHEN F2_JR = '1' -- JR
                       ELSE "0000" & S2_INS(25 DOWNTO 0) WHEN F2_J = '1' -- JAL, J
                       ELSE BRANCH_ADDER_R(29 DOWNTO 0)  WHEN T2_BRANCH_TAKE = '1'
                       ELSE PC_ADDER_R(29 DOWNTO 0);

    S2_LINKED <= (F2_BRANCH2 AND S2_INS(20) AND T2_BRANCH_TAKE) OR ((F2_J OR F2_JR) AND F2_LINK);

    ----------------------------
    -- MEMORY R/W STAGE (THREE)
    ----------------------------

    DB_ENABLE       <= F3_LOAD OR F3_STORE;

    DB_W            <= F3_STORE;
    DB_R            <= F3_LOAD;

    DB_WADDR        <= ALU_R WHEN F3_STORE = '1';
    DB_RADDR        <= ALU_R WHEN F3_LOAD = '1';

    DB_MODE         <=      "100" WHEN (F3_LOAD OR F3_STORE) = '1' AND S3_OPCODE(1 DOWNTO 0) = "00" -- BYTE
                       ELSE "010" WHEN (F3_LOAD OR F3_STORE) = '1' AND S3_OPCODE(1 DOWNTO 0) = "01" -- HALF
                       ELSE "001" WHEN (F3_LOAD OR F3_STORE) = '1' AND S3_OPCODE(1 DOWNTO 0) = "11" -- WORD
                       ELSE "000";

    DB_ISSIGNED     <= NOT(S3_OPCODE(2));

    DB_WDATA        <= S3_REGB_RD;

    -----------------------------------------
    -- REGISTER FILE WRITE BACK STAGE (FOUR)
    -----------------------------------------
    REGA_WD         <=      S4_ALU_R                         WHEN F4_ALU_WBACK = '1'
                       ELSE DB_RDATA                         WHEN F4_LOAD = '1'
                       ELSE S4_LINK_ADDR(29 DOWNTO 0) & "00" WHEN S4_LINKED = '1';

    REGA_WA         <= S4_WB_REG;

    REGA_W          <= F4_ALU_ENABLE OR S4_LINKED;


    PROCESS(CLK)
    BEGIN
        IF (CLK'EVENT AND CLK = '1') THEN
            S2_INS         <= S1_INS;
            S2_OPCODE      <= S1_OPCODE;
            S2_REGA_RA     <= REGA_RA;
            S2_REGB_RA     <= REGB_RA;

            S3_OPCODE      <= S2_OPCODE;
            S3_LINK_ADDR   <= PC_ADDER_R;
            S3_REGB_RD     <= T2_REGB_RD;
            S3_LINKED      <= S2_LINKED;
            S3_WB_REG      <= S2_WB_REG;

            S4_ALU_R       <= ALU_R;
            S4_LINK_ADDR   <= S3_LINK_ADDR;
            S4_LINKED      <= S3_LINKED;
            S4_WB_REG      <= S3_WB_REG;

            -- SHIFT FLAGS TO NEXT STAGES
            F2_SHIFTH      <= F1_SHIFTH;
            F2_J           <= F1_J;
            F2_JR          <= F1_JR;
            F2_BRANCH      <= F1_BRANCH;
            F2_BRANCH2     <= F1_BRANCH2;
            F2_LOAD        <= F1_LOAD;
            F2_STORE       <= F1_STORE;
            F2_REG_TO_REG  <= F1_REG_TO_REG;
            F2_INM_TO_REG  <= F1_INM_TO_REG;
            F2_ALU_ENABLE  <= F1_ALU_ENABLE;
            F2_ALU_WBACK   <= F1_ALU_WBACK;
            F2_LINK        <= F1_LINK;

            F3_LOAD        <= F2_LOAD;
            F3_STORE       <= F2_STORE;
            F3_ALU_ENABLE  <= F2_ALU_ENABLE;
            F3_ALU_WBACK   <= F2_ALU_WBACK;

            F4_LOAD        <= F3_LOAD;
            F4_ALU_ENABLE  <= F3_ALU_ENABLE;
            F4_ALU_WBACK   <= F3_ALU_WBACK;
        END IF;
    END PROCESS;
END BEHAV;






