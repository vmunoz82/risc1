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

ENTITY SYSTEM IS
    PORT(
        CLK: IN STD_LOGIC
    );
END SYSTEM;

ARCHITECTURE BEHAV OF SYSTEM IS
    COMPONENT MIPS1
    PORT(
        CLK:             IN  STD_LOGIC;
        HALT:            IN  STD_LOGIC;

        CB_RDATA:        IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        CB_WDATA:        OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        CB_W:            OUT STD_LOGIC;
        CB_R:            OUT STD_LOGIC;
        CB_WADDR:        OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        CB_RADDR:        OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        CB_ENABLE:       OUT STD_LOGIC;

        DB_RDATA:        IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        DB_WDATA:        OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        DB_W:            OUT STD_LOGIC;
        DB_R:            OUT STD_LOGIC;
        DB_WADDR:        OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        DB_RADDR:        OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        DB_ENABLE:       OUT STD_LOGIC;
        DB_MODE:         OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        DB_ISSIGNED:     OUT STD_LOGIC
    );
    END COMPONENT;

    COMPONENT SRAM
        GENERIC(
            ADDR:  INTEGER := (9+2);
            DEPTH: INTEGER := 512
        );
        PORT (
            CLK:      IN  STD_LOGIC;
            ENABLE:   IN  STD_LOGIC;
            R:        IN  STD_LOGIC;
            W:        IN  STD_LOGIC;
            RADDR:    IN  STD_LOGIC_VECTOR(ADDR-1 DOWNTO 0);
            WADDR:    IN  STD_LOGIC_VECTOR(ADDR-1 DOWNTO 0);
            DATA_IN:  IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            MODE:     IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            ISSIGNED: IN  STD_LOGIC;
            DATA_OUT: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;
    FOR CODE_SRAM: SRAM USE ENTITY WORK.SRAM(BEHAV_CODE);
    FOR DATA_SRAM: SRAM USE ENTITY WORK.SRAM(BEHAV_DATA);

    SIGNAL CS_ENABLE: STD_LOGIC;
    SIGNAL CS_W: STD_LOGIC;
    SIGNAL CS_R: STD_LOGIC;

    SIGNAL CBUS_ADDR_FROM: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL CBUS_ADDR_TO: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL CBUS_DATA_FROM: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL CBUS_DATA_TO: STD_LOGIC_VECTOR(31 DOWNTO 0);


    SIGNAL DS_ENABLE: STD_LOGIC;
    SIGNAL DS_W: STD_LOGIC;
    SIGNAL DS_R: STD_LOGIC;

    SIGNAL DBUS_ADDR_FROM: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL DBUS_ADDR_TO: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL DBUS_DATA_FROM: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL DBUS_DATA_TO: STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL DS_MODE:      STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL DS_ISSIGNED:  STD_LOGIC;

BEGIN

    CPU : MIPS1
    PORT MAP(
        CB_RADDR     => CBUS_ADDR_FROM,
        CB_WADDR     => CBUS_ADDR_TO,
        CB_RDATA     => CBUS_DATA_FROM,
        CB_WDATA     => CBUS_DATA_TO,
        CB_ENABLE    => CS_ENABLE,
        CB_R         => CS_R,
        CB_W         => CS_W,

        DB_RADDR     => DBUS_ADDR_FROM,
        DB_WADDR     => DBUS_ADDR_TO,
        DB_RDATA     => DBUS_DATA_FROM,
        DB_WDATA     => DBUS_DATA_TO,
        DB_ENABLE    => DS_ENABLE,
        DB_R         => DS_R,
        DB_W         => DS_W,

        DB_MODE      => DS_MODE,
        DB_ISSIGNED  => DS_ISSIGNED,

        CLK          => CLK,
        HALT         => '0'
    );

    CODE_SRAM : SRAM
    PORT MAP(
        CLK      => CLK,
        DATA_IN  => CBUS_DATA_TO,
        DATA_OUT => CBUS_DATA_FROM,
        ENABLE   => CS_ENABLE,
        R        => CS_R,
        RADDR    => CBUS_ADDR_FROM(10 DOWNTO 0),
        W        => CS_W,
        WADDR    => CBUS_ADDR_TO(10 DOWNTO 0),
        MODE     => "001",
        ISSIGNED => '0'
    );

    DATA_SRAM : SRAM
    PORT MAP(
        CLK      => CLK,
        DATA_IN  => DBUS_DATA_TO,
        DATA_OUT => DBUS_DATA_FROM,
        ENABLE   => DS_ENABLE,
        R        => DS_R,
        RADDR    => DBUS_ADDR_FROM(10 DOWNTO 0),
        W        => DS_W,
        WADDR    => DBUS_ADDR_TO(10 DOWNTO 0),
        MODE     => DS_MODE,
        ISSIGNED => DS_ISSIGNED

    );
END BEHAV;

