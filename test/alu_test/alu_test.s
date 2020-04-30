#########################################################
#
# 32 bits pipelined RISC processor
# Copyright (c) 2010 Victor Munoz. All rights reserved.
# derechos reservados, prohibida su reproduccion
#
# Author: Victor Munoz
# Contact: vmunoz@ingenieria-inversa.cl
#
#########################################################

.set noreorder
.global main .text

.text
main:

addiu  $sp, $sp, -4
sw     $ra, 0($sp)


lui    $t0, 0x1234
ori    $t0, $t0, 0x5678
lui    $t1, 0xBEBE
ori    $t1, $t1, 0xCAFE

ori    $t2, $zero, 0x7FFF

la     $t4, resultado

addi   $s0, $t2, 0x5555
addi   $s1, $t2, 0xD555
addiu  $s2, $t2, 0x5555
addiu  $s3, $t2, 0xD555
slti   $s4, $t2, 0x5555
slti   $s5, $t2, 0xD555
sltiu  $s6, $t2, 0x5555
sltiu  $s7, $t2, 0xD555

sw     $s0,  0($t4)
sw     $s1,  4($t4)
sw     $s2,  8($t4)
sw     $s3, 12($t4)
sw     $s4, 16($t4)
sw     $s5, 20($t4)
sw     $s6, 24($t4)
sw     $s7, 28($t4)

andi   $s0, $t0, 0x5555
ori    $s1, $t0, 0x5555
xori   $s2, $t0, 0x5555
lui    $s3, 0x5555

add    $s4, $t0, $t1
addu   $s5, $t0, $t1
sub    $s6, $t0, $t1
subu   $s7, $t0, $t1

sw     $s0, 32($t4)
sw     $s1, 36($t4)
sw     $s2, 40($t4)
sw     $s3, 44($t4)
sw     $s4, 48($t4)
sw     $s5, 52($t4)
sw     $s6, 56($t4)
sw     $s7, 60($t4)

slt    $s0, $t0, $t1
slt    $s1, $t0, $t2
sltu   $s2, $t0, $t1
sltu   $s3, $t0, $t2
and    $s4, $t0, $t1
or     $s5, $t0, $t1
xor    $s6, $t0, $t1
nor    $s7, $t0, $t1

sw     $s0, 64($t4)
sw     $s1, 68($t4)
sw     $s2, 72($t4)
sw     $s3, 76($t4)
sw     $s4, 80($t4)
sw     $s5, 84($t4)
sw     $s6, 88($t4)
sw     $s7, 92($t4)

sll    $s0, $t0, 4
srl    $s1, $t0, 5
sra    $s2, $t0, 6

ori    $t3, $zero, 6
sllv   $s3, $t0, $t3
ori    $t3, $zero, 5
srlv   $s4, $t0, $t3
ori    $t3, $zero, 4
srav   $s5, $t0, $t3

sw     $s0,  96($t4)
sw     $s1, 100($t4)
sw     $s2, 104($t4)
sw     $s3, 108($t4)
sw     $s4, 112($t4)
sw     $s5, 116($t4)


lw     $ra, 0($sp)
jr     $ra
addiu  $sp, $sp, 4

.data
resultado:
.word  0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000
.word  0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000
.word  0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000
.word  0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000

