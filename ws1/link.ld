/* Match dexopt's program header layout exactly */
OUTPUT_FORMAT(elf32-littlearm)
ENTRY(_start)
PHDRS
{
  phdr    PT_PHDR    PHDRS ;
  interp  PT_INTERP  PHDRS ;
  note    PT_NOTE    PHDRS ;
  text    PT_LOAD    PHDRS ;
  data    PT_LOAD    PHDRS ;
  dynamic PT_DYNAMIC PHDRS ;
  relro   PT_GNU_RELRO PHDRS ;
}
SECTIONS
{
  . = 0x00008000;
  .interp : { *(.interp) } :interp
  . = ALIGN(4);
  .note : { *(.note) } :note
  . = ALIGN(4);
  .note.gnu.build-id : { *(.note.gnu.build-id) } :note
  .hash : { *(.hash) }
  .gnu.hash : { *(.gnu.hash) }
  .dynsym : { *(.dynsym) }
  .dynstr : { *(.dynstr) }
  .rel.dyn : { *(.rel.dyn) }
  .rel.plt : { *(.rel.plt) }
  .plt : { *(.plt) }
  .text : { *(.text .text.*) } :text
  .rodata : { *(.rodata .rodata.*) } :text
  .data : { *(.data .data.*) } :data
  .got : { *(.got .got.plt) } :data
  .dynamic : { *(.dynamic) } :dynamic
  .bss : { *(.bss .bss.*) } :data
  .rel.plt : { *(.rel.plt) } :relro
  .got.plt : { *(.got.plt) } :relro
}
