/* Informs linker with symbol that is used.
It is referenced in elf output file as entrypoint
It causes that linker garbage collector not remove this section,
because it is never referenced.
To consider if it should be changed to symbol _start  because
flash configuration is needed to make code working.
*/
ENTRY(_start);

MEMORY
{
    flash(rx) : ORIGIN = 0x10000000, LENGTH = 2048k 
    sram(rwx) : ORIGIN = 0x20000000, LENGTH = 256k
}

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
        KEEP(*(.crc*))                          /* 4 Byte CRC32 value */
        . = 0x100;
        *(.text*)                          
    } > flash
}