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

# Paths
RISC_PATH       = d:/Arara2/portfolio/risc
COMPILER_PREFIX = $(RISC_PATH)/bin/mips-elf-

# Compilers and Linker
CC       = $(COMPILER_PREFIX)gcc
AS       = $(COMPILER_PREFIX)as
LD       = $(COMPILER_PREFIX)ld
SRAM_GEN = $(RISC_PATH)/bin/sram_gen
BIN_GEN  = $(RISC_PATH)/bin/mips-objcopy
DIS      = $(RISC_PATH)/bin/dis-ref

RISC_FLAGS = -mips1
CFLAGS     = $(RISC_FLAGS) -D_RISC_TESTING_ -Wall -Wextra -Werror -B$(COMPILER_PREFIX)
AFLAGS     = $(RISC_FLAGS)
LFLAGS     = --fatal-warnings -T risc_script.ld
BGFLAGS    = -O binary -j .text
RM         = rm -f


CTARGETS   := j_test/j_test.vhd sha1/sha1.vhd topcoder/topcoder.vhd j_test/j_test.ss sha1/sha1.ss topcoder/topcoder.ss
ATARGETS   := alu_test/alu_test.vhd load_store_test/load_store_test.vhd b_test/b_test.vhd alu_test/alu_test.ss load_store_test/load_store_test.ss b_test/b_test.ss

TARGETS_O1 := $(CTARGETS:.vhd=.o1.vhd)
TARGETS_O2 := $(CTARGETS:.vhd=.o2.vhd)
TARGETS_O3 := $(CTARGETS:.vhd=.o3.vhd)
TARGETS_OS := $(CTARGETS:.vhd=.os.vhd)

%.ss: %.bin
	$(DIS) $< $@
%.vhd: %.elf
	$(SRAM_GEN) $< $@

%.bin: %.elf
	$(BIN_GEN) $(BGFLAGS) $< $@

%.elf: %.o crt0.o
	$(LD) $(LFLAGS) $< -o $@

%.os.o: %.c
	$(CC) -c $< $(CFLAGS) -Os -o $@

%.o3.o: %.c
	$(CC) -c $< $(CFLAGS) -O3 -o $@

%.o2.o: %.c
	$(CC) -c $< $(CFLAGS) -O2 -o $@

%.o1.o: %.c
	$(CC) -c $< $(CFLAGS) -O1 -o $@

%.o: %.c
	$(CC) -c $< $(CFLAGS) -o $@


%.os.s: %.c
	$(CC) -S $< $(CFLAGS) -Os -o $@	

%.o3.s: %.c
	$(CC) -S $< $(CFLAGS) -O3 -o $@	

%.o2.s: %.c
	$(CC) -S $< $(CFLAGS) -O2 -o $@	

%.o1.s: %.c
	$(CC) -S $< $(CFLAGS) -O1 -o $@	

%.s: %.c
	$(CC) -S $< $(CFLAGS) -o $@	

%.o: %.s
	$(AS) $< $(AFLAGS) -o $@	


	
# por defecto compila sin ninguna optimizacion
all: $(ATARGETS) $(CTARGETS)

opt1: $(TARGETS_O1)
opt2: $(TARGETS_O2)
opt3: $(TARGETS_O3)
opts: $(TARGETS_OS)


clean-vhd:
	$(RM) $(ATARGETS)
	$(RM) $(CTARGETS)
	$(RM) $(TARGETS_O1)
	$(RM) $(TARGETS_O2)
	$(RM) $(TARGETS_O3)
	$(RM) $(TARGETS_OS)


.PHONY: all opt1 opt2 opt3 opts clean-vhd
