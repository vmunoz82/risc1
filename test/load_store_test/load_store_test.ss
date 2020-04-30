00000000: 3c080000 unknown
00000004: 25080848 addiu $t0, $t0, 0x0848
00000008: 3c090000 unknown
0000000c: 25290848 addiu $t1, $t1, 0x0848
00000010: 11090003 beq $t0, $t1, 00000020
00000014: 25080004 addiu $t0, $t0, 0x0004
00000018: 08000004 j 00000010
0000001c: ad00fffc sw $zero, 0xfffc ($t0)
00000020: 00000821 addu $at, $zero, $zero
00000024: 00001021 addu $v0, $zero, $zero
00000028: 00001821 addu $v1, $zero, $zero
0000002c: 00002021 addu $a0, $zero, $zero
00000030: 00002821 addu $a1, $zero, $zero
00000034: 00003021 addu $a2, $zero, $zero
00000038: 00003821 addu $a3, $zero, $zero
0000003c: 00004021 addu $t0, $zero, $zero
00000040: 00004821 addu $t1, $zero, $zero
00000044: 00005021 addu $t2, $zero, $zero
00000048: 00005821 addu $t3, $zero, $zero
0000004c: 00006021 addu $t4, $zero, $zero
00000050: 00006821 addu $t5, $zero, $zero
00000054: 00007021 addu $t6, $zero, $zero
00000058: 00007821 addu $t7, $zero, $zero
0000005c: 00008021 addu $s0, $zero, $zero
00000060: 00008821 addu $s1, $zero, $zero
00000064: 00009021 addu $s2, $zero, $zero
00000068: 00009821 addu $s3, $zero, $zero
0000006c: 0000a021 addu $s4, $zero, $zero
00000070: 0000a821 addu $s5, $zero, $zero
00000074: 0000b021 addu $s6, $zero, $zero
00000078: 0000b821 addu $s7, $zero, $zero
0000007c: 0000c021 addu $t8, $zero, $zero
00000080: 0000c821 addu $t9, $zero, $zero
00000084: 0000d021 addu $k0, $zero, $zero
00000088: 0000d821 addu $k1, $zero, $zero
0000008c: 0000e021 addu $gp, $zero, $zero
00000090: 0000f821 addu $ra, $zero, $zero
00000094: 3c1d0000 unknown
00000098: 27bd0ff8 addiu $sp, $sp, 0x0ff8
0000009c: 0c00002b jal 000000ac
000000a0: 03a0f021 addu $fp, $sp, $zero
000000a4: 08000029 j 000000a4
000000a8: 00000000 sll $zero, $zero, 0
000000ac: 27bdfffc addiu $sp, $sp, 0xfffc
000000b0: afbf0000 sw $ra, 0x0000 ($sp)
000000b4: 3c090000 unknown
000000b8: 25290800 addiu $t1, $t1, 0x0800
000000bc: 3c0a0000 unknown
000000c0: 254a0814 addiu $t2, $t2, 0x0814
000000c4: 8d280000 lw $t0, 0x0000 ($t1)
000000c8: 00000000 sll $zero, $zero, 0
000000cc: ad480000 sw $t0, 0x0000 ($t2)
000000d0: 8d280004 lw $t0, 0x0004 ($t1)
000000d4: ad480004 sw $t0, 0x0004 ($t2)
000000d8: 812b0008 lb $t3, 0x0008 ($t1)
000000dc: 912c0008 lbu $t4, 0x0008 ($t1)
000000e0: ad4b0008 sw $t3, 0x0008 ($t2)
000000e4: ad4c000c sw $t4, 0x000c ($t2)
000000e8: 812b0009 lb $t3, 0x0009 ($t1)
000000ec: 912c0009 lbu $t4, 0x0009 ($t1)
000000f0: ad4b0010 sw $t3, 0x0010 ($t2)
000000f4: ad4c0014 sw $t4, 0x0014 ($t2)
000000f8: 852b0004 lh $t3, 0x0004 ($t1)
000000fc: 952c0004 lhu $t4, 0x0004 ($t1)
00000100: ad4b0018 sw $t3, 0x0018 ($t2)
00000104: ad4c001c sw $t4, 0x001c ($t2)
00000108: 852b0006 lh $t3, 0x0006 ($t1)
0000010c: 952c0006 lhu $t4, 0x0006 ($t1)
00000110: ad4b0020 sw $t3, 0x0020 ($t2)
00000114: ad4c0024 sw $t4, 0x0024 ($t2)
00000118: 3c0baaaa unknown
0000011c: 356baaaa ori $t3, $t3, 0xaaaa
00000120: ad4b0028 sw $t3, 0x0028 ($t2)
00000124: ad4b002c sw $t3, 0x002c ($t2)
00000128: ad4b0030 sw $t3, 0x0030 ($t2)
0000012c: 8d2b0000 lw $t3, 0x0000 ($t1)
00000130: 00000000 sll $zero, $zero, 0
00000134: a14b0028 sb $t3, 0x0028 ($t2)
00000138: a14b002d sb $t3, 0x002d ($t2)
0000013c: a54b0032 sh $t3, 0x0032 ($t2)
00000140: 03e00008 jr $ra
00000144: 27bd0004 addiu $sp, $sp, 0x0004
