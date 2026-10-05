OUTPUT_FORMAT(elf32-littlearm)
ENTRY(_start)
SECTIONS
{
  . = 0x00000000;
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
  .data : { *(.data .data.*) }
  .got : { *(.got .got.plt) }
  .bss : { *(.bss .bss.*) }
}
PHDRS
{
  text PT_LOAD FLAGS(5);
  data PT_LOAD FLAGS(6);
  dynamic PT_DYNAMIC;
  interp PT_INTERP;
  note PT_NOTE;
}
