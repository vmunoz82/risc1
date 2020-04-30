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

.set noat
.set noreorder
.global _start .text
.extern stack_start

.text
_start:
# limpia la seccion .bss
	la      $t0, __bss_start
	la      $t1, __bss_end
clear_bss_loop:
	beq	    $t0, $t1, clear_bss_loop_end
	addiu	$t0, $t0,4
	j		clear_bss_loop
	sw	    $zero, -4($t0)
clear_bss_loop_end:
	
# limpia registros de proposito general
	addu	$at, $zero, $zero
	addu	$v0, $zero, $zero
	addu	$v1, $zero, $zero
	addu	$a0, $zero, $zero
	addu	$a1, $zero, $zero
	addu	$a2, $zero, $zero
	addu	$a3, $zero, $zero
	addu	$t0, $zero, $zero
	addu	$t1, $zero, $zero
	addu	$t2, $zero, $zero
	addu	$t3, $zero, $zero
	addu	$t4, $zero, $zero
	addu	$t5, $zero, $zero
	addu	$t6, $zero, $zero
	addu	$t7, $zero, $zero
	addu	$s0, $zero, $zero
	addu	$s1, $zero, $zero
	addu	$s2, $zero, $zero
	addu	$s3, $zero, $zero
	addu	$s4, $zero, $zero
	addu	$s5, $zero, $zero
	addu	$s6, $zero, $zero
	addu	$s7, $zero, $zero
	addu	$t8, $zero, $zero
	addu	$t9, $zero, $zero
	addu	$k0, $zero, $zero
	addu	$k1, $zero, $zero
	addu	$gp, $zero, $zero
	addu	$ra, $zero, $zero
		
# inicializa stack y frame pointer y llama a la funcion principal
	la 		$sp, __stack_start
	jal 	main
	addu	$fp, $sp, $zero

# muere!! en el mundo ideal tendriamos una funcion halt!
hang:
    j		hang
	nop
