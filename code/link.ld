ENTRY(main)
SECTIONS
{
    . = 0x1000;      /* کرنل در آدرس 0x1000 بارگذاری می‌شود */
    .text : { *(.text*) }
    .rodata : { *(.rodata*) }
    .data : { *(.data*) }
    .bss : { *(.bss*) }
}
