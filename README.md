#RISC processor implementation (MIPS R3000)

content:
  +bin      - assembler, compiler c, linker and SRAM modules generator.
  +libexec  - backend GCC.
  +src      - SRAM generator source code.
  +test     - tests, Makefile, crt0, linker script.
  +vhdl     - microprocessor VHDL files.


to compile the test files:

1. edit the RISC_PATH variable of the Makefile
2. in the test directory run make (..\bin\make is provided)

to compile the tests with -O1 optimization:

  make opt1


to compile the tests with -O2 optimization:

  make opt2


to optimize by size -Os:

  make opts


to generate just a specific target you hace to call make 
with te filename you want to generate:

make topcoder/topcoder.o2.vhd (for the -O2 version)

make topcoder/topcoder.o1.s (for the -O1 vetsion in assembler)

make topcoder/topcoder.os.elf (for the -Os version as ELF file)

