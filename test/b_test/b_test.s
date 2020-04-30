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

#.set noreorder
.global main .text

.text
main:

addiu  $sp, $sp, -4
sw     $ra, 0($sp)

li     $s0, 0

li     $t0, 0
li     $t1, 1
li     $t2, -1
li     $t3, 2
li     $t4, -2
li     $t5, 1
li     $t6, -1

bgez   $t2, bad_implementation
bgez   $t4, bad_implementation
bltz   $t0, bad_implementation
bltz   $t1, bad_implementation
bltz   $t3, bad_implementation
bgezal $t2, bad_implementation
bgezal $t4, bad_implementation
bltzal $t0, bad_implementation
bltzal $t1, bad_implementation
bltzal $t3, bad_implementation
beq    $t0, $t1, bad_implementation
beq    $t1, $t2, bad_implementation
beq    $t2, $t3, bad_implementation
beq    $t3, $t4, bad_implementation
bne    $t0, $zero, bad_implementation
bne    $zero, $t0, bad_implementation
blez   $t1, bad_implementation
blez   $t3, bad_implementation
bgtz   $t0, bad_implementation
bgtz   $t2, bad_implementation
bgtz   $t4, bad_implementation

bgez   $t0, $bgez2
J      bad_implementation
$bgez2:
bgez   $t1, $bgez3
J      bad_implementation
$bgez3:
bgez   $t3, $bltz1
J      bad_implementation

$bltz1:
bltz   $t2, $bltz2
J      bad_implementation
$bltz2:
bltz   $t4, $bgezal1
J      bad_implementation

$bgezal1:
bgezal $t0, dummy
bgezal $t1, dummy
bgezal $t3, dummy
bltzal $t2, dummy
bltzal $t4, dummy

beq    $t0, $zero, $beq2
J      bad_implementation
$beq2:
beq    $zero, $t0, $beq3
J      bad_implementation
$beq3:
beq    $t1, $t5, $beq4
J      bad_implementation
$beq4:
beq    $t2, $t6, $beq5
J      bad_implementation
$beq5:
beq    $t3, $t3, $beq6
J      bad_implementation
$beq6:
beq    $t4, $t4, $bne1
J      bad_implementation

$bne1:
bne    $t0, $t1, $bne2
J      bad_implementation
$bne2:
bne    $t1, $t2, $bne3
J      bad_implementation
$bne3:
bne    $t2, $t3, $bne4
J      bad_implementation
$bne4:
bne    $t3, $t4, $blez1
J      bad_implementation

$blez1:
blez   $t0, $blez2
J      bad_implementation
$blez2:
blez   $t2, $blez3
J      bad_implementation
$blez3:
blez   $t4, $bgtz1
J      bad_implementation

$bgtz1:
bgtz   $t1, $bgtz2
J      bad_implementation
$bgtz2:
bgtz   $t3, $next
J      bad_implementation

# todo OK :)
$next:
li     $t0, 0x12345678
li     $t1, 0xBEBECAFE
addu   $t2, $s0, $zero  # contador de saltos con links

lw     $ra, 0($sp)
jr     $ra
addiu  $sp, $sp, 4

# todo MAL :(
bad_implementation:
j      bad_implementation

dummy:
addi   $s0, $s0, 1
jr     $ra
