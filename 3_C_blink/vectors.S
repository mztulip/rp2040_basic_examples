.thumb
.syntax unified
.cpu cortex-m0plus

.global vector_table
.section .vectors
vector_table:
	.long  0x2003ffff //Set stack pointer to last address in RAM
	.long   _reset_handler //Reset_Handler
	.long   fault //NMI_Handler
	.long   fault //HardFault_Handler


.global _reset_handler
.section .text
.thumb_func
_reset_handler:
	//Plan is to put here bss and data init
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	//Current example assumes that section data and bss is zero
	bl main

.thumb_func
fault:
	b fault