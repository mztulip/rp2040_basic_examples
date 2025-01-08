
output/output.elf:     file format elf32-littlearm


Disassembly of section .text:

10000000 <_stage2_boot>:
// lr will be non-zero on entry if this code has been copied into RAM by user code and called
// from there, and the boot_stage2 should just return normally.
//
// r3 holds SSI base, r0...2 used as temporaries. Other GPRs not used.
regular_func _stage2_boot
    push {lr}
10000000:	b500      	push	{lr}

    ldr r3, =XIP_SSI_BASE                // Use as base address where possible
10000002:	4b0a      	ldr	r3, [pc, #40]	@ (1000002c <literals+0x2>)

    // Disable SSI to allow further config
    movs r1, #0
10000004:	2100      	movs	r1, #0
    str r1, [r3, #SSI_SSIENR_OFFSET]
10000006:	6099      	str	r1, [r3, #8]

    // Set baud rate
    movs r1, #PICO_FLASH_SPI_CLKDIV
10000008:	2104      	movs	r1, #4
    str r1, [r3, #SSI_BAUDR_OFFSET]
1000000a:	6159      	str	r1, [r3, #20]

    ldr r1, =(CTRLR0_XIP)
1000000c:	4908      	ldr	r1, [pc, #32]	@ (10000030 <literals+0x6>)
    str r1, [r3, #SSI_CTRLR0_OFFSET]
1000000e:	6019      	str	r1, [r3, #0]

    ldr r1, =(SPI_CTRLR0_XIP)
10000010:	4908      	ldr	r1, [pc, #32]	@ (10000034 <literals+0xa>)
    ldr r0, =(XIP_SSI_BASE + SSI_SPI_CTRLR0_OFFSET)
10000012:	4809      	ldr	r0, [pc, #36]	@ (10000038 <literals+0xe>)
    str r1, [r0]
10000014:	6001      	str	r1, [r0, #0]

    // NDF=0 (single 32b read)
    movs r1, #0x0
10000016:	2100      	movs	r1, #0
    str r1, [r3, #SSI_CTRLR1_OFFSET]
10000018:	6059      	str	r1, [r3, #4]

    // Re-enable SSI
    movs r1, #1
1000001a:	2101      	movs	r1, #1
    str r1, [r3, #SSI_SSIENR_OFFSET]
1000001c:	6099      	str	r1, [r3, #8]

1000001e <check_return>:

    // If entered from the bootrom, lr (which we earlier pushed) will be 0,
    // and we vector through the table at the start of the main flash image.
    // Any regular function call will have a nonzero value for lr.
    check_return:
        pop {r0}
1000001e:	bc01      	pop	{r0}
        cmp r0, #0
10000020:	2800      	cmp	r0, #0
        beq vector_into_flash
10000022:	d000      	beq.n	10000026 <vector_into_flash>
        bx r0
10000024:	4700      	bx	r0

10000026 <vector_into_flash>:
    vector_into_flash:
        ldr r0, =0x10000101
10000026:	4805      	ldr	r0, [pc, #20]	@ (1000003c <literals+0x12>)
        bx r0
10000028:	4700      	bx	r0

1000002a <literals>:
1000002a:	0000      	.short	0x0000
    ldr r3, =XIP_SSI_BASE                // Use as base address where possible
1000002c:	18000000 	.word	0x18000000
    ldr r1, =(CTRLR0_XIP)
10000030:	001f0300 	.word	0x001f0300
    ldr r1, =(SPI_CTRLR0_XIP)
10000034:	03000218 	.word	0x03000218
    ldr r0, =(XIP_SSI_BASE + SSI_SPI_CTRLR0_OFFSET)
10000038:	180000f4 	.word	0x180000f4
        ldr r0, =0x10000101
1000003c:	10000101 	.word	0x10000101

10000040 <_end_boot2>:
	...

100000fc <crc>:
100000fc:	d70cb69f                                ....

10000100 <_start>:
.equ GPIO25_CTRL_REG, 0x400140cc
.equ GPIO_OE_SET_REG, 0xd0000024
.equ GPIO_OUT_XOR_REG, 0xd000001c

	// Deassert IO_BANK0 bit5(after reset it is equal to 1 and periphreal is in reset state)
	ldr r0,=RESETS_BASE_REG
10000100:	4810      	ldr	r0, [pc, #64]	@ (10000144 <led_toogle+0xa>)
	ldr r2,=~(1<<5)
10000102:	4a11      	ldr	r2, [pc, #68]	@ (10000148 <led_toogle+0xe>)
	ldr r1,[r0]
10000104:	6801      	ldr	r1, [r0, #0]
	ands r1,r2
10000106:	4011      	ands	r1, r2
	str r1,[r0]
10000108:	6001      	str	r1, [r0, #0]

1000010a <check_reset_done>:

	//Wait for IO_BANK0 to be ready
check_reset_done:
	ldr r0,=RESETS_BASE_REG
1000010a:	480e      	ldr	r0, [pc, #56]	@ (10000144 <led_toogle+0xa>)
	ldr r1,[r0]
1000010c:	6801      	ldr	r1, [r0, #0]
	ldr r2,=(1<<5)
1000010e:	4a0f      	ldr	r2, [pc, #60]	@ (1000014c <led_toogle+0x12>)
	ands r2, r1
10000110:	400a      	ands	r2, r1
	bne check_reset_done
10000112:	d1fa      	bne.n	1000010a <check_reset_done>


	// Set GPIO 25 function to SIO
	ldr r0,=GPIO25_CTRL_REG
10000114:	480e      	ldr	r0, [pc, #56]	@ (10000150 <led_toogle+0x16>)
	ldr r1,=5
10000116:	490f      	ldr	r1, [pc, #60]	@ (10000154 <led_toogle+0x1a>)
	str r1,[r0]
10000118:	6001      	str	r1, [r0, #0]

	//Output enable for gpio 25 using SIO interface
	ldr r0,=GPIO_OE_SET_REG
1000011a:	480f      	ldr	r0, [pc, #60]	@ (10000158 <led_toogle+0x1e>)
	ldr r1,=(1<<25)
1000011c:	490f      	ldr	r1, [pc, #60]	@ (1000015c <led_toogle+0x22>)
	str r1,[r0]
1000011e:	6001      	str	r1, [r0, #0]

10000120 <loop>:

loop:
	nop
10000120:	46c0      	nop			@ (mov r8, r8)
	bl delay
10000122:	f000 f804 	bl	1000012e <delay>
	bl led_toogle
10000126:	f000 f808 	bl	1000013a <led_toogle>
	b loop
1000012a:	e7f9      	b.n	10000120 <loop>

1000012c <fault>:

fault:
	b fault
1000012c:	e7fe      	b.n	1000012c <fault>

1000012e <delay>:

delay:	
	ldr	r0, =200000
1000012e:	480c      	ldr	r0, [pc, #48]	@ (10000160 <led_toogle+0x26>)

10000130 <loop2>:
loop2:
	nop
10000130:	46c0      	nop			@ (mov r8, r8)
	subs	r0, #1
10000132:	3801      	subs	r0, #1
	cmp	r0, #0
10000134:	2800      	cmp	r0, #0
	bge	loop2
10000136:	dafb      	bge.n	10000130 <loop2>
	bx	lr
10000138:	4770      	bx	lr

1000013a <led_toogle>:

led_toogle:
	ldr r0,=GPIO_OUT_XOR_REG
1000013a:	480a      	ldr	r0, [pc, #40]	@ (10000164 <led_toogle+0x2a>)
	ldr r1,=(1<<25)
1000013c:	4907      	ldr	r1, [pc, #28]	@ (1000015c <led_toogle+0x22>)
	str r1,[r0]
1000013e:	6001      	str	r1, [r0, #0]
	bx lr
10000140:	4770      	bx	lr
10000142:	0000      	.short	0x0000
	ldr r0,=RESETS_BASE_REG
10000144:	4000c000 	.word	0x4000c000
	ldr r2,=~(1<<5)
10000148:	ffffffdf 	.word	0xffffffdf
	ldr r2,=(1<<5)
1000014c:	00000020 	.word	0x00000020
	ldr r0,=GPIO25_CTRL_REG
10000150:	400140cc 	.word	0x400140cc
	ldr r1,=5
10000154:	00000005 	.word	0x00000005
	ldr r0,=GPIO_OE_SET_REG
10000158:	d0000024 	.word	0xd0000024
	ldr r1,=(1<<25)
1000015c:	02000000 	.word	0x02000000
	ldr	r0, =200000
10000160:	00030d40 	.word	0x00030d40
	ldr r0,=GPIO_OUT_XOR_REG
10000164:	d000001c 	.word	0xd000001c
