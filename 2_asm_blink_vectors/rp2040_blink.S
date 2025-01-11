//https://gcc.gnu.org/onlinedocs/gcc/ARM-Options.html
//https://sourceware.org/binutils/docs/as/ARM-Directives.html
.thumb
.syntax unified
.cpu cortex-m0

.global vector_table
.section .vectors
vector_table:
	.long  0x2003ffff //Set stack pointer to last address in RAM
	.long   _start //Reset_Handler
	.long   fault //NMI_Handler
	.long   fault //HardFault_Handler



//https://ftp.gnu.org/old-gnu/Manuals/gas-2.9.1/html_chapter/as_7.html
.thumb_func
//    LED = GPIO25
.global _start
//https://sourceware.org/binutils/docs/as/Section.html
.section .text
_start:
.equ RESETS_BASE_REG, 0x4000c000
.equ RESET_DONE_REG, 0x4000c000
.equ GPIO25_CTRL_REG, 0x400140cc
.equ GPIO_OE_SET_REG, 0xd0000024
.equ GPIO_OUT_XOR_REG, 0xd000001c

	// Deassert IO_BANK0 bit5(after reset it is equal to 1 and periphreal is in reset state)
	ldr r0,=RESETS_BASE_REG
	ldr r2,=~(1<<5)
	ldr r1,[r0]
	ands r1,r2
	str r1,[r0]

	//Wait for IO_BANK0 to be ready
check_reset_done:
	ldr r0,=RESETS_BASE_REG
	ldr r1,[r0]
	ldr r2,=(1<<5)
	ands r2, r1
	bne check_reset_done


	// Set GPIO 25 function to SIO
	ldr r0,=GPIO25_CTRL_REG
	ldr r1,=5
	str r1,[r0]

	//Output enable for gpio 25 using SIO interface
	ldr r0,=GPIO_OE_SET_REG
	ldr r1,=(1<<25)
	str r1,[r0]

loop:
	nop
	bl delay
	bl led_toogle
	b loop

delay:	
	ldr	r0, =200000
loop2:
	nop
	subs	r0, #1
	cmp	r0, #0
	bge	loop2
	bx	lr

led_toogle:
	ldr r0,=GPIO_OUT_XOR_REG
	ldr r1,=(1<<25)
	str r1,[r0]
	bx lr

.thumb_func
fault:
	b fault