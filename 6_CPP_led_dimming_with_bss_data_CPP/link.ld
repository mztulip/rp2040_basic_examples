/* Informs linker with symbol that is used.
It is referenced in elf output file as entrypoint
It causes that linker garbage collector not remove this section,
because it is never referenced.
*/
ENTRY(Reset_Handler);

MEMORY
{
    flash(rx) : ORIGIN = 0x10000000, LENGTH = 2048k 
    sram(rwx) : ORIGIN = 0x20000000, LENGTH = 256k
}

_minimum_stack_size = 2048;

SECTIONS
{
    .text :                            
    {
        _start_boot2 = .;
        /* First * means all files, part in (.boot2_section) means all boot2_section sections*/
        KEEP(build/boot2.o(.text))
        _end_boot2 = .;
        . = . + (252 - (_end_boot2 - _start_boot2));    /* Pad zeros, addCounter = addCounter + (252 - sizeOfBoot2) */
        /* Keep informs linker to not remove this section when is not referenced
        this is true that it is not referenced in code, it is only placed here.
         */
        KEEP(*(.crc*))   /* 4 Byte CRC32 value */
        . = 0x100;
        KEEP(*(.vectors*))
        *(.text*)                          
    } > flash


    .preinit_array ALIGN(4): 
    {
        __preinit_array_start = .;
        KEEP(*(.preinit_array))
        __preinit_array_end = .;
    } > flash


    .init_array ALIGN(4): 
    {
        __init_array_start = .;
        KEEP(*(.init_array))
        __init_array_end = .;
    } > flash

    __start_data_at_flash = .;

    .data : AT (__start_data_at_flash)
	{
		__data_start__ = .;
        . = ALIGN(4);
		*(.data*)
		
		
		__data_end__ = .;

	} > sram

    /* https://en.wikipedia.org/wiki/.bss */
    .bss :
	{
		. = ALIGN(4);
		__bss_start__ = .;
		*(.bss*)
		*(COMMON)
		. = ALIGN(4);
		__bss_end__ = .;
	} > sram

    __StackTop = ORIGIN(sram) + LENGTH(sram);

    ASSERT(__bss_end__ + _minimum_stack_size <= __StackTop,
        "There is not enough space in RAM for stack.")
}