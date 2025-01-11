.thumb
.syntax unified
.cpu cortex-m0plus

.global vector_table
.section .vectors
vector_table:
	.long  __StackTop //Set stack pointer to last address in RAM
	.long   _reset_handler //Reset_Handler
	.long   fault //NMI_Handler
	.long   fault //HardFault_Handler


.global _reset_handler
.section .text
.thumb_func
_reset_handler:
	//Plan is to put here bss and data init

	//Initalise data section in RAM - copy constants from flash to RAM
	//__etext: symbol represent address of LMA of start of the section to copy from. Usually end of text
	//__data_start__: symbol containing address of VMA of start of the section to copy to.
	//__bss_start__: VMA of end of the section to copy to. Normally __data_end__ is used, but by using __bss_start__
	//                the user can add their own initialized data section before BSS section with the INSERT AFTER command.
	//				https://maskray.me/blog/2021-07-04-sections-and-overwrite-sections
	ldr r1, =__etext
	ldr r2, =__data_start__
	ldr r3, =__bss_start__
	//r3 contains lenght of data to copy
	subs r3, r2
	//If zero jump over the loop
    ble .data_init_loop_done
	

.data_init_loop:
	//decrease r3 by 4bytes because in single load store 4 bytes are copied
    subs r3, #4
    ldr r0, [r1,r3]
    str r0, [r2,r3]
	//branch until r3 is greater then zero
    bgt .data_init_loop
.data_init_loop_done:

	//Initializing BSS
	//In C BSS represents statically allocated objects without an explicit initializer which are initialized to zero 
	//__bss_start__ represents start address of the bss section
	//__bss_end__ represents end address of the bss section
	ldr r1, =__bss_start__
	ldr r2, =__bss_end__
	movs r0, 0
	subs r2, r1
	ble .bss_init_done
.bss_init_loop:
	//r2 is used as loop counter with 4bytes incrementation
	subs r2, #4
	str r0, [r1, r2]
	bgt .bss_init_loop
.bss_init_done:

	bl main

.thumb_func
fault:
	b fault