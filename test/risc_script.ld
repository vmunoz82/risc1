  OUTPUT_FORMAT("elf32-bigmips")
  OUTPUT_ARCH(mips)
  MEMORY
  {
    code_sram (rx) : ORIGIN = 0x000, LENGTH = 0x800
    data_sram (rw) : ORIGIN = 0x800, LENGTH = 0x800
  }
  PROVIDE (__stack_start = 0x800 + 0x800 - 8);
  STARTUP (crt0.o);
  ENTRY (_start);
  SECTIONS
  {
    .text   : { *(.text) } > code_sram
  
    .rodata : { *(.rodata) } > data_sram
    .data   : { *(.data) } > data_sram
    .bss    : { __bss_start = . ; *(.bss) *(.scommon); __bss_end = . ;} > data_sram
  }