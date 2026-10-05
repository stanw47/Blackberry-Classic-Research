/* Linker script for WS1 shim - forces all literal pools into RW segment */
OUTPUT_FORMAT(elf32-littlearm)
SECTIONS
{
  . = 0x00008000;
  .interp : { *(.interp) }
  . = ALIGN(4);
  .note : { *(.note) }
  . = ALIGN(4);
  .note.gnu.build-id : { *(.note.gnu.build-id) }
  .hash : { *(.hash) }
  .gnu.hash : { *(.gnu.hash) }
  .dynsym : { *(.dynsym) }
  .dynstr : { *(.dynstr) }
  .rel.dyn : { *(.rel.dyn) }
  .rel.plt : { *(.rel.plt) }
  .plt : { *(.plt) }
  .text : { *(.text .text.*) }
  .rodata : { *(.rodata .rodata.*) }
  . = ALIGN(0x1000);
  .data.rel.ro : { *(.data.rel.ro*) *(.rodata*) } 
  . = ALIGN(4);
  .data : { *(.data .data.*) }
  .data.ws1slots : { *(.data.ws1slots) }
  .got : { *(.got .got.plt) }
  .dynamic : { *(.dynamic) }
  .bss : { *(.bss .bss.*) }
}
