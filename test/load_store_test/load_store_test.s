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

la    $t1, origen
la    $t2, destino

lw    $t0, 0($t1)
nop
sw    $t0, 0($t2)

lw    $t0, 4($t1)
sw    $t0, 4($t2) # $t0 contiene el antiguo valor porque no lw necesita un ciclo adicional para ser efectivo


# byte alineado
lb    $t3,  8($t1)
lbu   $t4,  8($t1)
sw    $t3,  8($t2)
sw    $t4, 12($t2)

# byte desalineado
lb    $t3,  9($t1)
lbu   $t4,  9($t1)
sw    $t3, 16($t2)
sw    $t4, 20($t2)

# half alineado
lh    $t3,  4($t1)
lhu   $t4,  4($t1)
sw    $t3, 24($t2)
sw    $t4, 28($t2)

# half desalineado
lh    $t3,  6($t1)
lhu   $t4,  6($t1)
sw    $t3, 32($t2)
sw    $t4, 36($t2)

# escribe bytes y halfs
li    $t3, 0xAAAAAAAA
sw    $t3, 40($t2)
sw    $t3, 44($t2)
sw    $t3, 48($t2)

lw    $t3,  0($t1)
nop
sb    $t3, 40($t2)
sb    $t3, 45($t2)
sh    $t3, 50($t2)

jr     $ra
addiu  $sp, $sp, 4

.data
origen:
.word 0x12345678
.word 0xBEBECAFE
.word 0xDEADBEEF
.word 0x66666666
.word 0x88888888
destino:
.word 0x00000000 # +0
.word 0x00000000 # +4
.word 0x00000000 # +8
.word 0x00000000 # +12
.word 0x00000000 # +16
.word 0x00000000 # +20
.word 0x00000000 # +24
.word 0x00000000 # +28
.word 0x00000000 # +32
.word 0x00000000 # +36
.word 0x00000000 # +40
.word 0x00000000 # +44
.word 0x00000000 # +48

