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

----------------------------------------------------------

ENTITY SRAM IS
    GENERIC(
        ADDR:     INTEGER:= (9+2);
        DEPTH:    INTEGER:= 512
    );
    PORT(
        CLK:      IN  STD_LOGIC;
        ENABLE:   IN  STD_LOGIC;
        R:        IN  STD_LOGIC;
        W:        IN  STD_LOGIC;
        RADDR:    IN  STD_LOGIC_VECTOR(ADDR-1 DOWNTO 0);
        WADDR:    IN  STD_LOGIC_VECTOR(ADDR-1 DOWNTO 0);
        DATA_IN:  IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        MODE:     IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        ISSIGNED: IN  STD_LOGIC;
        DATA_OUT: OUT STD_LOGIC_VECTOR(31 DOWNTO 0):= "00000000000000000000000000000000"
    );
END SRAM;

--------------------------------------------------------------

ARCHITECTURE BEHAV_CODE OF SRAM IS

    TYPE RAM_TYPE IS ARRAY (0 TO DEPTH-1) OF STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL TMP_RAM: RAM_TYPE := (

         0 => x"3C080000", -- lui $t0, 0000
         1 => x"25080880", -- addiu $t0, $t0, 2176
         2 => x"3C090000", -- lui $t1, 0000
         3 => x"25290880", -- addiu $t1, $t1, 2176
         4 => x"11090003", -- beq $t0, $t1, 3
         5 => x"25080004", -- addiu $t0, $t0, 4
         6 => x"08000004", -- j 4
         7 => x"AD00FFFC", -- sw $zero, -4(t0)
         8 => x"00000821", -- addu $at, $zero, $zero
         9 => x"00001021", -- addu $v0, $zero, $zero
        10 => x"00001821", -- addu $v1, $zero, $zero
        11 => x"00002021", -- addu $a0, $zero, $zero
        12 => x"00002821", -- addu $a1, $zero, $zero
        13 => x"00003021", -- addu $a2, $zero, $zero
        14 => x"00003821", -- addu $a3, $zero, $zero
        15 => x"00004021", -- addu $t0, $zero, $zero
        16 => x"00004821", -- addu $t1, $zero, $zero
        17 => x"00005021", -- addu $t2, $zero, $zero
        18 => x"00005821", -- addu $t3, $zero, $zero
        19 => x"00006021", -- addu $t4, $zero, $zero
        20 => x"00006821", -- addu $t5, $zero, $zero
        21 => x"00007021", -- addu $t6, $zero, $zero
        22 => x"00007821", -- addu $t7, $zero, $zero
        23 => x"00008021", -- addu $s0, $zero, $zero
        24 => x"00008821", -- addu $s1, $zero, $zero
        25 => x"00009021", -- addu $s2, $zero, $zero
        26 => x"00009821", -- addu $s3, $zero, $zero
        27 => x"0000A021", -- addu $s4, $zero, $zero
        28 => x"0000A821", -- addu $s5, $zero, $zero
        29 => x"0000B021", -- addu $s6, $zero, $zero
        30 => x"0000B821", -- addu $s7, $zero, $zero
        31 => x"0000C021", -- addu $t8, $zero, $zero
        32 => x"0000C821", -- addu $t9, $zero, $zero
        33 => x"0000D021", -- addu $k0, $zero, $zero
        34 => x"0000D821", -- addu $k1, $zero, $zero
        35 => x"0000E021", -- addu $gp, $zero, $zero
        36 => x"0000F821", -- addu $ra, $zero, $zero
        37 => x"3C1D0000", -- lui $sp, 0000
        38 => x"27BD0FF8", -- addiu $sp, $sp, 4088
        39 => x"0C00002B", -- jal 43
        40 => x"03A0F021", -- addu $fp, $sp, $zero
        41 => x"08000029", -- j 41
        42 => x"00000000", -- nop
        43 => x"27BDFFFC", -- addiu $sp, $sp, -4
        44 => x"AFBF0000", -- sw $ra, 0(sp)
        45 => x"3C081234", -- lui $t0, 1234
        46 => x"35085678", -- ori $t0, $t0, 5678
        47 => x"3C09BEBE", -- lui $t1, bebe
        48 => x"3529CAFE", -- ori $t1, $t1, cafe
        49 => x"340A7FFF", -- ori $t2, $zero, 7fff
        50 => x"3C0C0000", -- lui $t4, 0000
        51 => x"258C0800", -- addiu $t4, $t4, 2048
        52 => x"21505555", -- addi $s0, $t2, 21845
        53 => x"2151D555", -- addi $s1, $t2, -10923
        54 => x"25525555", -- addiu $s2, $t2, 21845
        55 => x"2553D555", -- addiu $s3, $t2, -10923
        56 => x"29545555", -- slti $s4, $t2, 21845
        57 => x"2955D555", -- slti $s5, $t2, -10923
        58 => x"2D565555", -- sltiu $s6, $t2, 21845
        59 => x"2D57D555", -- sltiu $s7, $t2, -10923
        60 => x"AD900000", -- sw $s0, 0(t4)
        61 => x"AD910004", -- sw $s1, 4(t4)
        62 => x"AD920008", -- sw $s2, 8(t4)
        63 => x"AD93000C", -- sw $s3, 12(t4)
        64 => x"AD940010", -- sw $s4, 16(t4)
        65 => x"AD950014", -- sw $s5, 20(t4)
        66 => x"AD960018", -- sw $s6, 24(t4)
        67 => x"AD97001C", -- sw $s7, 28(t4)
        68 => x"31105555", -- andi $s0, $t0, 5555
        69 => x"35115555", -- ori $s1, $t0, 5555
        70 => x"39125555", -- xori $s2, $t0, 5555
        71 => x"3C135555", -- lui $s3, 5555
        72 => x"0109A020", -- add $s4, $t0, $t1
        73 => x"0109A821", -- addu $s5, $t0, $t1
        74 => x"0109B022", -- sub $s6, $t0, $t1
        75 => x"0109B823", -- subu $s7, $t0, $t1
        76 => x"AD900020", -- sw $s0, 32(t4)
        77 => x"AD910024", -- sw $s1, 36(t4)
        78 => x"AD920028", -- sw $s2, 40(t4)
        79 => x"AD93002C", -- sw $s3, 44(t4)
        80 => x"AD940030", -- sw $s4, 48(t4)
        81 => x"AD950034", -- sw $s5, 52(t4)
        82 => x"AD960038", -- sw $s6, 56(t4)
        83 => x"AD97003C", -- sw $s7, 60(t4)
        84 => x"0109802A", -- slt $s0, $t0, $t1
        85 => x"010A882A", -- slt $s1, $t0, $t2
        86 => x"0109902B", -- sltu $s2, $t0, $t1
        87 => x"010A982B", -- sltu $s3, $t0, $t2
        88 => x"0109A024", -- and $s4, $t0, $t1
        89 => x"0109A825", -- or $s5, $t0, $t1
        90 => x"0109B026", -- xor $s6, $t0, $t1
        91 => x"0109B827", -- nor $s7, $t0, $t1
        92 => x"AD900040", -- sw $s0, 64(t4)
        93 => x"AD910044", -- sw $s1, 68(t4)
        94 => x"AD920048", -- sw $s2, 72(t4)
        95 => x"AD93004C", -- sw $s3, 76(t4)
        96 => x"AD940050", -- sw $s4, 80(t4)
        97 => x"AD950054", -- sw $s5, 84(t4)
        98 => x"AD960058", -- sw $s6, 88(t4)
        99 => x"AD97005C", -- sw $s7, 92(t4)
       100 => x"00088100", -- sll $s0, $t0, 8
       101 => x"00088942", -- srl $s1, $t0, 10
       102 => x"00089183", -- sra $s2, $t0, 12
       103 => x"340B0006", -- ori $t3, $zero, 0006
       104 => x"01689804", -- sllv $s3, $t0, $t3
       105 => x"340B0005", -- ori $t3, $zero, 0005
       106 => x"0168A006", -- srlv $s4, $t0, $t3
       107 => x"340B0004", -- ori $t3, $zero, 0004
       108 => x"0168A807", -- srav $s5, $t0, $t3
       109 => x"AD900060", -- sw $s0, 96(t4)
       110 => x"AD910064", -- sw $s1, 100(t4)
       111 => x"AD920068", -- sw $s2, 104(t4)
       112 => x"AD93006C", -- sw $s3, 108(t4)
       113 => x"AD940070", -- sw $s4, 112(t4)
       114 => x"AD950074", -- sw $s5, 116(t4)
       115 => x"8FBF0000", -- lw $ra, 0(sp)
       116 => x"03E00008", -- jr $ra
       117 => x"27BD0004", -- addiu $sp, $sp, 4
       118 => x"00000000", -- nop
       119 => x"00000000", -- nop
       120 => x"00000000", -- nop
       121 => x"00000000", -- nop
       122 => x"00000000", -- nop
       123 => x"00000000", -- nop
       124 => x"00000000", -- nop
       125 => x"00000000", -- nop
       126 => x"00000000", -- nop
       127 => x"00000000", -- nop
       128 => x"00000000", -- nop
       129 => x"00000000", -- nop
       130 => x"00000000", -- nop
       131 => x"00000000", -- nop
       132 => x"00000000", -- nop
       133 => x"00000000", -- nop
       134 => x"00000000", -- nop
       135 => x"00000000", -- nop
       136 => x"00000000", -- nop
       137 => x"00000000", -- nop
       138 => x"00000000", -- nop
       139 => x"00000000", -- nop
       140 => x"00000000", -- nop
       141 => x"00000000", -- nop
       142 => x"00000000", -- nop
       143 => x"00000000", -- nop
       144 => x"00000000", -- nop
       145 => x"00000000", -- nop
       146 => x"00000000", -- nop
       147 => x"00000000", -- nop
       148 => x"00000000", -- nop
       149 => x"00000000", -- nop
       150 => x"00000000", -- nop
       151 => x"00000000", -- nop
       152 => x"00000000", -- nop
       153 => x"00000000", -- nop
       154 => x"00000000", -- nop
       155 => x"00000000", -- nop
       156 => x"00000000", -- nop
       157 => x"00000000", -- nop
       158 => x"00000000", -- nop
       159 => x"00000000", -- nop
       160 => x"00000000", -- nop
       161 => x"00000000", -- nop
       162 => x"00000000", -- nop
       163 => x"00000000", -- nop
       164 => x"00000000", -- nop
       165 => x"00000000", -- nop
       166 => x"00000000", -- nop
       167 => x"00000000", -- nop
       168 => x"00000000", -- nop
       169 => x"00000000", -- nop
       170 => x"00000000", -- nop
       171 => x"00000000", -- nop
       172 => x"00000000", -- nop
       173 => x"00000000", -- nop
       174 => x"00000000", -- nop
       175 => x"00000000", -- nop
       176 => x"00000000", -- nop
       177 => x"00000000", -- nop
       178 => x"00000000", -- nop
       179 => x"00000000", -- nop
       180 => x"00000000", -- nop
       181 => x"00000000", -- nop
       182 => x"00000000", -- nop
       183 => x"00000000", -- nop
       184 => x"00000000", -- nop
       185 => x"00000000", -- nop
       186 => x"00000000", -- nop
       187 => x"00000000", -- nop
       188 => x"00000000", -- nop
       189 => x"00000000", -- nop
       190 => x"00000000", -- nop
       191 => x"00000000", -- nop
       192 => x"00000000", -- nop
       193 => x"00000000", -- nop
       194 => x"00000000", -- nop
       195 => x"00000000", -- nop
       196 => x"00000000", -- nop
       197 => x"00000000", -- nop
       198 => x"00000000", -- nop
       199 => x"00000000", -- nop
       200 => x"00000000", -- nop
       201 => x"00000000", -- nop
       202 => x"00000000", -- nop
       203 => x"00000000", -- nop
       204 => x"00000000", -- nop
       205 => x"00000000", -- nop
       206 => x"00000000", -- nop
       207 => x"00000000", -- nop
       208 => x"00000000", -- nop
       209 => x"00000000", -- nop
       210 => x"00000000", -- nop
       211 => x"00000000", -- nop
       212 => x"00000000", -- nop
       213 => x"00000000", -- nop
       214 => x"00000000", -- nop
       215 => x"00000000", -- nop
       216 => x"00000000", -- nop
       217 => x"00000000", -- nop
       218 => x"00000000", -- nop
       219 => x"00000000", -- nop
       220 => x"00000000", -- nop
       221 => x"00000000", -- nop
       222 => x"00000000", -- nop
       223 => x"00000000", -- nop
       224 => x"00000000", -- nop
       225 => x"00000000", -- nop
       226 => x"00000000", -- nop
       227 => x"00000000", -- nop
       228 => x"00000000", -- nop
       229 => x"00000000", -- nop
       230 => x"00000000", -- nop
       231 => x"00000000", -- nop
       232 => x"00000000", -- nop
       233 => x"00000000", -- nop
       234 => x"00000000", -- nop
       235 => x"00000000", -- nop
       236 => x"00000000", -- nop
       237 => x"00000000", -- nop
       238 => x"00000000", -- nop
       239 => x"00000000", -- nop
       240 => x"00000000", -- nop
       241 => x"00000000", -- nop
       242 => x"00000000", -- nop
       243 => x"00000000", -- nop
       244 => x"00000000", -- nop
       245 => x"00000000", -- nop
       246 => x"00000000", -- nop
       247 => x"00000000", -- nop
       248 => x"00000000", -- nop
       249 => x"00000000", -- nop
       250 => x"00000000", -- nop
       251 => x"00000000", -- nop
       252 => x"00000000", -- nop
       253 => x"00000000", -- nop
       254 => x"00000000", -- nop
       255 => x"00000000", -- nop
       256 => x"00000000", -- nop
       257 => x"00000000", -- nop
       258 => x"00000000", -- nop
       259 => x"00000000", -- nop
       260 => x"00000000", -- nop
       261 => x"00000000", -- nop
       262 => x"00000000", -- nop
       263 => x"00000000", -- nop
       264 => x"00000000", -- nop
       265 => x"00000000", -- nop
       266 => x"00000000", -- nop
       267 => x"00000000", -- nop
       268 => x"00000000", -- nop
       269 => x"00000000", -- nop
       270 => x"00000000", -- nop
       271 => x"00000000", -- nop
       272 => x"00000000", -- nop
       273 => x"00000000", -- nop
       274 => x"00000000", -- nop
       275 => x"00000000", -- nop
       276 => x"00000000", -- nop
       277 => x"00000000", -- nop
       278 => x"00000000", -- nop
       279 => x"00000000", -- nop
       280 => x"00000000", -- nop
       281 => x"00000000", -- nop
       282 => x"00000000", -- nop
       283 => x"00000000", -- nop
       284 => x"00000000", -- nop
       285 => x"00000000", -- nop
       286 => x"00000000", -- nop
       287 => x"00000000", -- nop
       288 => x"00000000", -- nop
       289 => x"00000000", -- nop
       290 => x"00000000", -- nop
       291 => x"00000000", -- nop
       292 => x"00000000", -- nop
       293 => x"00000000", -- nop
       294 => x"00000000", -- nop
       295 => x"00000000", -- nop
       296 => x"00000000", -- nop
       297 => x"00000000", -- nop
       298 => x"00000000", -- nop
       299 => x"00000000", -- nop
       300 => x"00000000", -- nop
       301 => x"00000000", -- nop
       302 => x"00000000", -- nop
       303 => x"00000000", -- nop
       304 => x"00000000", -- nop
       305 => x"00000000", -- nop
       306 => x"00000000", -- nop
       307 => x"00000000", -- nop
       308 => x"00000000", -- nop
       309 => x"00000000", -- nop
       310 => x"00000000", -- nop
       311 => x"00000000", -- nop
       312 => x"00000000", -- nop
       313 => x"00000000", -- nop
       314 => x"00000000", -- nop
       315 => x"00000000", -- nop
       316 => x"00000000", -- nop
       317 => x"00000000", -- nop
       318 => x"00000000", -- nop
       319 => x"00000000", -- nop
       320 => x"00000000", -- nop
       321 => x"00000000", -- nop
       322 => x"00000000", -- nop
       323 => x"00000000", -- nop
       324 => x"00000000", -- nop
       325 => x"00000000", -- nop
       326 => x"00000000", -- nop
       327 => x"00000000", -- nop
       328 => x"00000000", -- nop
       329 => x"00000000", -- nop
       330 => x"00000000", -- nop
       331 => x"00000000", -- nop
       332 => x"00000000", -- nop
       333 => x"00000000", -- nop
       334 => x"00000000", -- nop
       335 => x"00000000", -- nop
       336 => x"00000000", -- nop
       337 => x"00000000", -- nop
       338 => x"00000000", -- nop
       339 => x"00000000", -- nop
       340 => x"00000000", -- nop
       341 => x"00000000", -- nop
       342 => x"00000000", -- nop
       343 => x"00000000", -- nop
       344 => x"00000000", -- nop
       345 => x"00000000", -- nop
       346 => x"00000000", -- nop
       347 => x"00000000", -- nop
       348 => x"00000000", -- nop
       349 => x"00000000", -- nop
       350 => x"00000000", -- nop
       351 => x"00000000", -- nop
       352 => x"00000000", -- nop
       353 => x"00000000", -- nop
       354 => x"00000000", -- nop
       355 => x"00000000", -- nop
       356 => x"00000000", -- nop
       357 => x"00000000", -- nop
       358 => x"00000000", -- nop
       359 => x"00000000", -- nop
       360 => x"00000000", -- nop
       361 => x"00000000", -- nop
       362 => x"00000000", -- nop
       363 => x"00000000", -- nop
       364 => x"00000000", -- nop
       365 => x"00000000", -- nop
       366 => x"00000000", -- nop
       367 => x"00000000", -- nop
       368 => x"00000000", -- nop
       369 => x"00000000", -- nop
       370 => x"00000000", -- nop
       371 => x"00000000", -- nop
       372 => x"00000000", -- nop
       373 => x"00000000", -- nop
       374 => x"00000000", -- nop
       375 => x"00000000", -- nop
       376 => x"00000000", -- nop
       377 => x"00000000", -- nop
       378 => x"00000000", -- nop
       379 => x"00000000", -- nop
       380 => x"00000000", -- nop
       381 => x"00000000", -- nop
       382 => x"00000000", -- nop
       383 => x"00000000", -- nop
       384 => x"00000000", -- nop
       385 => x"00000000", -- nop
       386 => x"00000000", -- nop
       387 => x"00000000", -- nop
       388 => x"00000000", -- nop
       389 => x"00000000", -- nop
       390 => x"00000000", -- nop
       391 => x"00000000", -- nop
       392 => x"00000000", -- nop
       393 => x"00000000", -- nop
       394 => x"00000000", -- nop
       395 => x"00000000", -- nop
       396 => x"00000000", -- nop
       397 => x"00000000", -- nop
       398 => x"00000000", -- nop
       399 => x"00000000", -- nop
       400 => x"00000000", -- nop
       401 => x"00000000", -- nop
       402 => x"00000000", -- nop
       403 => x"00000000", -- nop
       404 => x"00000000", -- nop
       405 => x"00000000", -- nop
       406 => x"00000000", -- nop
       407 => x"00000000", -- nop
       408 => x"00000000", -- nop
       409 => x"00000000", -- nop
       410 => x"00000000", -- nop
       411 => x"00000000", -- nop
       412 => x"00000000", -- nop
       413 => x"00000000", -- nop
       414 => x"00000000", -- nop
       415 => x"00000000", -- nop
       416 => x"00000000", -- nop
       417 => x"00000000", -- nop
       418 => x"00000000", -- nop
       419 => x"00000000", -- nop
       420 => x"00000000", -- nop
       421 => x"00000000", -- nop
       422 => x"00000000", -- nop
       423 => x"00000000", -- nop
       424 => x"00000000", -- nop
       425 => x"00000000", -- nop
       426 => x"00000000", -- nop
       427 => x"00000000", -- nop
       428 => x"00000000", -- nop
       429 => x"00000000", -- nop
       430 => x"00000000", -- nop
       431 => x"00000000", -- nop
       432 => x"00000000", -- nop
       433 => x"00000000", -- nop
       434 => x"00000000", -- nop
       435 => x"00000000", -- nop
       436 => x"00000000", -- nop
       437 => x"00000000", -- nop
       438 => x"00000000", -- nop
       439 => x"00000000", -- nop
       440 => x"00000000", -- nop
       441 => x"00000000", -- nop
       442 => x"00000000", -- nop
       443 => x"00000000", -- nop
       444 => x"00000000", -- nop
       445 => x"00000000", -- nop
       446 => x"00000000", -- nop
       447 => x"00000000", -- nop
       448 => x"00000000", -- nop
       449 => x"00000000", -- nop
       450 => x"00000000", -- nop
       451 => x"00000000", -- nop
       452 => x"00000000", -- nop
       453 => x"00000000", -- nop
       454 => x"00000000", -- nop
       455 => x"00000000", -- nop
       456 => x"00000000", -- nop
       457 => x"00000000", -- nop
       458 => x"00000000", -- nop
       459 => x"00000000", -- nop
       460 => x"00000000", -- nop
       461 => x"00000000", -- nop
       462 => x"00000000", -- nop
       463 => x"00000000", -- nop
       464 => x"00000000", -- nop
       465 => x"00000000", -- nop
       466 => x"00000000", -- nop
       467 => x"00000000", -- nop
       468 => x"00000000", -- nop
       469 => x"00000000", -- nop
       470 => x"00000000", -- nop
       471 => x"00000000", -- nop
       472 => x"00000000", -- nop
       473 => x"00000000", -- nop
       474 => x"00000000", -- nop
       475 => x"00000000", -- nop
       476 => x"00000000", -- nop
       477 => x"00000000", -- nop
       478 => x"00000000", -- nop
       479 => x"00000000", -- nop
       480 => x"00000000", -- nop
       481 => x"00000000", -- nop
       482 => x"00000000", -- nop
       483 => x"00000000", -- nop
       484 => x"00000000", -- nop
       485 => x"00000000", -- nop
       486 => x"00000000", -- nop
       487 => x"00000000", -- nop
       488 => x"00000000", -- nop
       489 => x"00000000", -- nop
       490 => x"00000000", -- nop
       491 => x"00000000", -- nop
       492 => x"00000000", -- nop
       493 => x"00000000", -- nop
       494 => x"00000000", -- nop
       495 => x"00000000", -- nop
       496 => x"00000000", -- nop
       497 => x"00000000", -- nop
       498 => x"00000000", -- nop
       499 => x"00000000", -- nop
       500 => x"00000000", -- nop
       501 => x"00000000", -- nop
       502 => x"00000000", -- nop
       503 => x"00000000", -- nop
       504 => x"00000000", -- nop
       505 => x"00000000", -- nop
       506 => x"00000000", -- nop
       507 => x"00000000", -- nop
       508 => x"00000000", -- nop
       509 => x"00000000", -- nop
       510 => x"00000000", -- nop
       511 => x"00000000"  -- nop
    );

BEGIN

    PROCESS(CLK)
    BEGIN
    IF (CLK'EVENT AND CLK='1') THEN
        IF ENABLE='1' THEN
            IF R='1' THEN
                DATA_OUT <= TMP_RAM(CONV_INTEGER(UNSIGNED(RADDR(ADDR-1 DOWNTO 2))));
            ELSE
                DATA_OUT <= (DATA_OUT'RANGE => 'Z');
            END IF;
        END IF;
    END IF;
    END PROCESS;

    PROCESS(CLK)
    BEGIN
    IF (CLK'EVENT AND CLK='1') THEN
        IF ENABLE='1' THEN
            IF W='1' THEN
                TMP_RAM(CONV_INTEGER(UNSIGNED(WADDR(ADDR-1 DOWNTO 2)))) <= DATA_IN;
            END IF;
        END IF;
    END IF;
    END PROCESS;

END BEHAV_CODE;

ARCHITECTURE BEHAV_DATA OF SRAM IS

    TYPE RAM_TYPE IS ARRAY (0 TO DEPTH-1) OF STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL IBYTE0:     STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL IBYTE1:     STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL IBYTE2:     STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL IBYTE3:     STD_LOGIC_VECTOR(7 DOWNTO 0);

    SIGNAL OBYTE:      STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL OHALF:      STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL SBYTE:      STD_LOGIC_VECTOR(23 DOWNTO 0);
    SIGNAL SHALF:      STD_LOGIC_VECTOR(15 DOWNTO 0);

    SIGNAL RWORD:      STD_LOGIC_VECTOR(31 DOWNTO 0):= x"00000000";

    SIGNAL RADDR2:     STD_LOGIC_VECTOR(1 DOWNTO 0):= "00";
    SIGNAL MODE2:      STD_LOGIC_VECTOR(2 DOWNTO 0):= "000";
    SIGNAL ISSIGNED2:  STD_LOGIC:= '0';

    SIGNAL W0:         STD_LOGIC;
    SIGNAL W1:         STD_LOGIC;
    SIGNAL W2:         STD_LOGIC;
    SIGNAL W3:         STD_LOGIC;

    SIGNAL TMP_RAM: RAM_TYPE := (

         0 => x"00000000",
         1 => x"00000000",
         2 => x"00000000",
         3 => x"00000000",
         4 => x"00000000",
         5 => x"00000000",
         6 => x"00000000",
         7 => x"00000000",
         8 => x"00000000",
         9 => x"00000000",
        10 => x"00000000",
        11 => x"00000000",
        12 => x"00000000",
        13 => x"00000000",
        14 => x"00000000",
        15 => x"00000000",
        16 => x"00000000",
        17 => x"00000000",
        18 => x"00000000",
        19 => x"00000000",
        20 => x"00000000",
        21 => x"00000000",
        22 => x"00000000",
        23 => x"00000000",
        24 => x"00000000",
        25 => x"00000000",
        26 => x"00000000",
        27 => x"00000000",
        28 => x"00000000",
        29 => x"00000000",
        30 => x"00000000",
        31 => x"00000000",
        32 => x"55555555",
        33 => x"55555555",
        34 => x"55555555",
        35 => x"55555555",
        36 => x"55555555",
        37 => x"55555555",
        38 => x"55555555",
        39 => x"55555555",
        40 => x"55555555",
        41 => x"55555555",
        42 => x"55555555",
        43 => x"55555555",
        44 => x"55555555",
        45 => x"55555555",
        46 => x"55555555",
        47 => x"55555555",
        48 => x"55555555",
        49 => x"55555555",
        50 => x"55555555",
        51 => x"55555555",
        52 => x"55555555",
        53 => x"55555555",
        54 => x"55555555",
        55 => x"55555555",
        56 => x"55555555",
        57 => x"55555555",
        58 => x"55555555",
        59 => x"55555555",
        60 => x"55555555",
        61 => x"55555555",
        62 => x"55555555",
        63 => x"55555555",
        64 => x"55555555",
        65 => x"55555555",
        66 => x"55555555",
        67 => x"55555555",
        68 => x"55555555",
        69 => x"55555555",
        70 => x"55555555",
        71 => x"55555555",
        72 => x"55555555",
        73 => x"55555555",
        74 => x"55555555",
        75 => x"55555555",
        76 => x"55555555",
        77 => x"55555555",
        78 => x"55555555",
        79 => x"55555555",
        80 => x"55555555",
        81 => x"55555555",
        82 => x"55555555",
        83 => x"55555555",
        84 => x"55555555",
        85 => x"55555555",
        86 => x"55555555",
        87 => x"55555555",
        88 => x"55555555",
        89 => x"55555555",
        90 => x"55555555",
        91 => x"55555555",
        92 => x"55555555",
        93 => x"55555555",
        94 => x"55555555",
        95 => x"55555555",
        96 => x"55555555",
        97 => x"55555555",
        98 => x"55555555",
        99 => x"55555555",
       100 => x"55555555",
       101 => x"55555555",
       102 => x"55555555",
       103 => x"55555555",
       104 => x"55555555",
       105 => x"55555555",
       106 => x"55555555",
       107 => x"55555555",
       108 => x"55555555",
       109 => x"55555555",
       110 => x"55555555",
       111 => x"55555555",
       112 => x"55555555",
       113 => x"55555555",
       114 => x"55555555",
       115 => x"55555555",
       116 => x"55555555",
       117 => x"55555555",
       118 => x"55555555",
       119 => x"55555555",
       120 => x"55555555",
       121 => x"55555555",
       122 => x"55555555",
       123 => x"55555555",
       124 => x"55555555",
       125 => x"55555555",
       126 => x"55555555",
       127 => x"55555555",
       128 => x"55555555",
       129 => x"55555555",
       130 => x"55555555",
       131 => x"55555555",
       132 => x"55555555",
       133 => x"55555555",
       134 => x"55555555",
       135 => x"55555555",
       136 => x"55555555",
       137 => x"55555555",
       138 => x"55555555",
       139 => x"55555555",
       140 => x"55555555",
       141 => x"55555555",
       142 => x"55555555",
       143 => x"55555555",
       144 => x"55555555",
       145 => x"55555555",
       146 => x"55555555",
       147 => x"55555555",
       148 => x"55555555",
       149 => x"55555555",
       150 => x"55555555",
       151 => x"55555555",
       152 => x"55555555",
       153 => x"55555555",
       154 => x"55555555",
       155 => x"55555555",
       156 => x"55555555",
       157 => x"55555555",
       158 => x"55555555",
       159 => x"55555555",
       160 => x"55555555",
       161 => x"55555555",
       162 => x"55555555",
       163 => x"55555555",
       164 => x"55555555",
       165 => x"55555555",
       166 => x"55555555",
       167 => x"55555555",
       168 => x"55555555",
       169 => x"55555555",
       170 => x"55555555",
       171 => x"55555555",
       172 => x"55555555",
       173 => x"55555555",
       174 => x"55555555",
       175 => x"55555555",
       176 => x"55555555",
       177 => x"55555555",
       178 => x"55555555",
       179 => x"55555555",
       180 => x"55555555",
       181 => x"55555555",
       182 => x"55555555",
       183 => x"55555555",
       184 => x"55555555",
       185 => x"55555555",
       186 => x"55555555",
       187 => x"55555555",
       188 => x"55555555",
       189 => x"55555555",
       190 => x"55555555",
       191 => x"55555555",
       192 => x"55555555",
       193 => x"55555555",
       194 => x"55555555",
       195 => x"55555555",
       196 => x"55555555",
       197 => x"55555555",
       198 => x"55555555",
       199 => x"55555555",
       200 => x"55555555",
       201 => x"55555555",
       202 => x"55555555",
       203 => x"55555555",
       204 => x"55555555",
       205 => x"55555555",
       206 => x"55555555",
       207 => x"55555555",
       208 => x"55555555",
       209 => x"55555555",
       210 => x"55555555",
       211 => x"55555555",
       212 => x"55555555",
       213 => x"55555555",
       214 => x"55555555",
       215 => x"55555555",
       216 => x"55555555",
       217 => x"55555555",
       218 => x"55555555",
       219 => x"55555555",
       220 => x"55555555",
       221 => x"55555555",
       222 => x"55555555",
       223 => x"55555555",
       224 => x"55555555",
       225 => x"55555555",
       226 => x"55555555",
       227 => x"55555555",
       228 => x"55555555",
       229 => x"55555555",
       230 => x"55555555",
       231 => x"55555555",
       232 => x"55555555",
       233 => x"55555555",
       234 => x"55555555",
       235 => x"55555555",
       236 => x"55555555",
       237 => x"55555555",
       238 => x"55555555",
       239 => x"55555555",
       240 => x"55555555",
       241 => x"55555555",
       242 => x"55555555",
       243 => x"55555555",
       244 => x"55555555",
       245 => x"55555555",
       246 => x"55555555",
       247 => x"55555555",
       248 => x"55555555",
       249 => x"55555555",
       250 => x"55555555",
       251 => x"55555555",
       252 => x"55555555",
       253 => x"55555555",
       254 => x"55555555",
       255 => x"55555555",
       256 => x"55555555",
       257 => x"55555555",
       258 => x"55555555",
       259 => x"55555555",
       260 => x"55555555",
       261 => x"55555555",
       262 => x"55555555",
       263 => x"55555555",
       264 => x"55555555",
       265 => x"55555555",
       266 => x"55555555",
       267 => x"55555555",
       268 => x"55555555",
       269 => x"55555555",
       270 => x"55555555",
       271 => x"55555555",
       272 => x"55555555",
       273 => x"55555555",
       274 => x"55555555",
       275 => x"55555555",
       276 => x"55555555",
       277 => x"55555555",
       278 => x"55555555",
       279 => x"55555555",
       280 => x"55555555",
       281 => x"55555555",
       282 => x"55555555",
       283 => x"55555555",
       284 => x"55555555",
       285 => x"55555555",
       286 => x"55555555",
       287 => x"55555555",
       288 => x"55555555",
       289 => x"55555555",
       290 => x"55555555",
       291 => x"55555555",
       292 => x"55555555",
       293 => x"55555555",
       294 => x"55555555",
       295 => x"55555555",
       296 => x"55555555",
       297 => x"55555555",
       298 => x"55555555",
       299 => x"55555555",
       300 => x"55555555",
       301 => x"55555555",
       302 => x"55555555",
       303 => x"55555555",
       304 => x"55555555",
       305 => x"55555555",
       306 => x"55555555",
       307 => x"55555555",
       308 => x"55555555",
       309 => x"55555555",
       310 => x"55555555",
       311 => x"55555555",
       312 => x"55555555",
       313 => x"55555555",
       314 => x"55555555",
       315 => x"55555555",
       316 => x"55555555",
       317 => x"55555555",
       318 => x"55555555",
       319 => x"55555555",
       320 => x"55555555",
       321 => x"55555555",
       322 => x"55555555",
       323 => x"55555555",
       324 => x"55555555",
       325 => x"55555555",
       326 => x"55555555",
       327 => x"55555555",
       328 => x"55555555",
       329 => x"55555555",
       330 => x"55555555",
       331 => x"55555555",
       332 => x"55555555",
       333 => x"55555555",
       334 => x"55555555",
       335 => x"55555555",
       336 => x"55555555",
       337 => x"55555555",
       338 => x"55555555",
       339 => x"55555555",
       340 => x"55555555",
       341 => x"55555555",
       342 => x"55555555",
       343 => x"55555555",
       344 => x"55555555",
       345 => x"55555555",
       346 => x"55555555",
       347 => x"55555555",
       348 => x"55555555",
       349 => x"55555555",
       350 => x"55555555",
       351 => x"55555555",
       352 => x"55555555",
       353 => x"55555555",
       354 => x"55555555",
       355 => x"55555555",
       356 => x"55555555",
       357 => x"55555555",
       358 => x"55555555",
       359 => x"55555555",
       360 => x"55555555",
       361 => x"55555555",
       362 => x"55555555",
       363 => x"55555555",
       364 => x"55555555",
       365 => x"55555555",
       366 => x"55555555",
       367 => x"55555555",
       368 => x"55555555",
       369 => x"55555555",
       370 => x"55555555",
       371 => x"55555555",
       372 => x"55555555",
       373 => x"55555555",
       374 => x"55555555",
       375 => x"55555555",
       376 => x"55555555",
       377 => x"55555555",
       378 => x"55555555",
       379 => x"55555555",
       380 => x"55555555",
       381 => x"55555555",
       382 => x"55555555",
       383 => x"55555555",
       384 => x"55555555",
       385 => x"55555555",
       386 => x"55555555",
       387 => x"55555555",
       388 => x"55555555",
       389 => x"55555555",
       390 => x"55555555",
       391 => x"55555555",
       392 => x"55555555",
       393 => x"55555555",
       394 => x"55555555",
       395 => x"55555555",
       396 => x"55555555",
       397 => x"55555555",
       398 => x"55555555",
       399 => x"55555555",
       400 => x"55555555",
       401 => x"55555555",
       402 => x"55555555",
       403 => x"55555555",
       404 => x"55555555",
       405 => x"55555555",
       406 => x"55555555",
       407 => x"55555555",
       408 => x"55555555",
       409 => x"55555555",
       410 => x"55555555",
       411 => x"55555555",
       412 => x"55555555",
       413 => x"55555555",
       414 => x"55555555",
       415 => x"55555555",
       416 => x"55555555",
       417 => x"55555555",
       418 => x"55555555",
       419 => x"55555555",
       420 => x"55555555",
       421 => x"55555555",
       422 => x"55555555",
       423 => x"55555555",
       424 => x"55555555",
       425 => x"55555555",
       426 => x"55555555",
       427 => x"55555555",
       428 => x"55555555",
       429 => x"55555555",
       430 => x"55555555",
       431 => x"55555555",
       432 => x"55555555",
       433 => x"55555555",
       434 => x"55555555",
       435 => x"55555555",
       436 => x"55555555",
       437 => x"55555555",
       438 => x"55555555",
       439 => x"55555555",
       440 => x"55555555",
       441 => x"55555555",
       442 => x"55555555",
       443 => x"55555555",
       444 => x"55555555",
       445 => x"55555555",
       446 => x"55555555",
       447 => x"55555555",
       448 => x"55555555",
       449 => x"55555555",
       450 => x"55555555",
       451 => x"55555555",
       452 => x"55555555",
       453 => x"55555555",
       454 => x"55555555",
       455 => x"55555555",
       456 => x"55555555",
       457 => x"55555555",
       458 => x"55555555",
       459 => x"55555555",
       460 => x"55555555",
       461 => x"55555555",
       462 => x"55555555",
       463 => x"55555555",
       464 => x"55555555",
       465 => x"55555555",
       466 => x"55555555",
       467 => x"55555555",
       468 => x"55555555",
       469 => x"55555555",
       470 => x"55555555",
       471 => x"55555555",
       472 => x"55555555",
       473 => x"55555555",
       474 => x"55555555",
       475 => x"55555555",
       476 => x"55555555",
       477 => x"55555555",
       478 => x"55555555",
       479 => x"55555555",
       480 => x"55555555",
       481 => x"55555555",
       482 => x"55555555",
       483 => x"55555555",
       484 => x"55555555",
       485 => x"55555555",
       486 => x"55555555",
       487 => x"55555555",
       488 => x"55555555",
       489 => x"55555555",
       490 => x"55555555",
       491 => x"55555555",
       492 => x"55555555",
       493 => x"55555555",
       494 => x"55555555",
       495 => x"55555555",
       496 => x"55555555",
       497 => x"55555555",
       498 => x"55555555",
       499 => x"55555555",
       500 => x"55555555",
       501 => x"55555555",
       502 => x"55555555",
       503 => x"55555555",
       504 => x"55555555",
       505 => x"55555555",
       506 => x"55555555",
       507 => x"55555555",
       508 => x"55555555",
       509 => x"55555555",
       510 => x"55555555",
       511 => x"55555555"
    );

BEGIN
    -- READ LOGIC
    OBYTE    <=      RWORD(31 DOWNTO 24) WHEN RADDR2(1 DOWNTO 0) = "00"
                ELSE RWORD(23 DOWNTO 16) WHEN RADDR2(1 DOWNTO 0) = "01"
                ELSE RWORD(15 DOWNTO  8) WHEN RADDR2(1 DOWNTO 0) = "10"
                ELSE RWORD( 7 DOWNTO  0);

    OHALF    <=      RWORD(31 DOWNTO 16) WHEN RADDR2(1 DOWNTO 0) = "00"
                ELSE RWORD(15 DOWNTO  0); -- THIS IS CASE "11", WE DON'T HANDLE THE OTHER CASES


    SBYTE    <=      x"FFFFFF" WHEN (OBYTE(7)  AND ISSIGNED2) = '1' ELSE x"000000";
    SHALF    <=      x"FFFF"   WHEN (OHALF(15) AND ISSIGNED2) = '1' ELSE x"0000";


    DATA_OUT <=      SBYTE & OBYTE WHEN MODE2(2) = '1'
                ELSE SHALF & OHALF WHEN MODE2(1) = '1'
                ELSE RWORD WHEN MODE2(0) = '1';

    -- WRITE LOGIC

    IBYTE0 <= DATA_IN(7 DOWNTO  0) WHEN MODE(2)='1' ELSE DATA_IN(15 DOWNTO 8) WHEN MODE(1)='1' ELSE DATA_IN(31 DOWNTO  24);
    IBYTE1 <= DATA_IN(7 DOWNTO  0) WHEN MODE(2)='1' ELSE DATA_IN( 7 DOWNTO 0) WHEN MODE(1)='1' ELSE DATA_IN(23 DOWNTO  16);
    IBYTE2 <= DATA_IN(7 DOWNTO  0) WHEN MODE(2)='1' ELSE DATA_IN(15 DOWNTO 8) WHEN MODE(1)='1' ELSE DATA_IN(15 DOWNTO   8);
    IBYTE3 <= DATA_IN(7 DOWNTO  0) WHEN MODE(2)='1' ELSE DATA_IN( 7 DOWNTO 0) WHEN MODE(1)='1' ELSE DATA_IN( 7 DOWNTO   0);

    W0 <= (   (MODE(2) AND NOT(WADDR(1) OR   WADDR(0)))  --B: "00"
           OR (MODE(1) AND NOT(WADDR(1)))                --H: "0x"
           OR  MODE(0)) AND W;                           --W: "Xx"
    W1 <= (   (MODE(2) AND NOT(WADDR(1)) AND WADDR(0))   --B: "01"
           OR (MODE(1) AND NOT(WADDR(1)))                --H: "0x"
           OR  MODE(0)) AND W;                           --W: "Xx"
    W2 <= (   (MODE(2) AND NOT(WADDR(0)) AND WADDR(1))   --B: "10"
           OR (MODE(1) AND     WADDR(1))                 --H: "1x"
           OR  MODE(0)) AND W;                           --W: "Xx"
    W3 <= (   (MODE(2) AND     WADDR(1) AND  WADDR(0))   --B: "11"
           OR (MODE(1) AND     WADDR(1))                 --H: "1x"
           OR  MODE(0)) AND W;                           --W: "Xx"

    PROCESS(CLK)
    BEGIN
    IF (CLK'EVENT AND CLK='1') THEN
        MODE2     <= MODE;
        ISSIGNED2 <= ISSIGNED;
        RADDR2 <= RADDR(1 DOWNTO 0);
    END IF;
    END PROCESS;

    PROCESS(CLK)
    BEGIN
    IF (CLK'EVENT AND CLK='1') THEN
        IF ENABLE='1' THEN
            IF R='1' THEN
                RWORD <= TMP_RAM(CONV_INTEGER(UNSIGNED(RADDR(ADDR-1 DOWNTO 2))));
            ELSE
                RWORD <= (DATA_OUT'RANGE => 'Z');
            END IF;
        END IF;
    END IF;
    END PROCESS;

    PROCESS(CLK)
    BEGIN
    IF (CLK'EVENT AND CLK='1') THEN
        IF ENABLE='1' THEN
            IF W='1' THEN
                IF W0 = '1' THEN
                    TMP_RAM(CONV_INTEGER(UNSIGNED(WADDR(ADDR-1 DOWNTO 2))))(31 DOWNTO 24) <= IBYTE0;
                END IF;
                IF W1 = '1' THEN
                    TMP_RAM(CONV_INTEGER(UNSIGNED(WADDR(ADDR-1 DOWNTO 2))))(23 DOWNTO 16) <= IBYTE1;
                END IF;
                IF W2 = '1' THEN
                    TMP_RAM(CONV_INTEGER(UNSIGNED(WADDR(ADDR-1 DOWNTO 2))))(15 DOWNTO  8) <= IBYTE2;
                END IF;
                IF W3 = '1' THEN
                    TMP_RAM(CONV_INTEGER(UNSIGNED(WADDR(ADDR-1 DOWNTO 2))))(7  DOWNTO  0) <= IBYTE3;
                END IF;
            END IF;
        END IF;
    END IF;
    END PROCESS;

END BEHAV_DATA;