
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
10000002:	4b0c      	ldr	r3, [pc, #48]	@ (10000034 <literals>)

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
1000000c:	490a      	ldr	r1, [pc, #40]	@ (10000038 <literals+0x4>)
    str r1, [r3, #SSI_CTRLR0_OFFSET]
1000000e:	6019      	str	r1, [r3, #0]

    ldr r1, =(SPI_CTRLR0_XIP)
10000010:	490a      	ldr	r1, [pc, #40]	@ (1000003c <literals+0x8>)
    ldr r0, =(XIP_SSI_BASE + SSI_SPI_CTRLR0_OFFSET)
10000012:	480b      	ldr	r0, [pc, #44]	@ (10000040 <literals+0xc>)
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
// it assumes that at 0x10000100 is placed 4 bytes
// value of STACK pointer, end next 4 bytes repsesent of Reset handler/ code starting point
        ldr r0, =(XIP_BASE + 0x100)
10000026:	4807      	ldr	r0, [pc, #28]	@ (10000044 <literals+0x10>)
        ldr r1, =(PPB_BASE + M0PLUS_VTOR_OFFSET)
10000028:	4907      	ldr	r1, [pc, #28]	@ (10000048 <literals+0x14>)
        str r0, [r1]
1000002a:	6008      	str	r0, [r1, #0]
        //Load two 32 bit values to r0 and r1 where first is pointed by r0
        ldmia r0, {r0, r1}
1000002c:	c803      	ldmia	r0, {r0, r1}
        //Load sp=r0
        msr msp, r0
1000002e:	f380 8808 	msr	MSP, r0
        //branch to address at r1, it must containt address 
        //increased +1 to branch in thumb code
        bx r1
10000032:	4708      	bx	r1

10000034 <literals>:
    ldr r3, =XIP_SSI_BASE                // Use as base address where possible
10000034:	18000000 	.word	0x18000000
    ldr r1, =(CTRLR0_XIP)
10000038:	001f0300 	.word	0x001f0300
    ldr r1, =(SPI_CTRLR0_XIP)
1000003c:	03000218 	.word	0x03000218
    ldr r0, =(XIP_SSI_BASE + SSI_SPI_CTRLR0_OFFSET)
10000040:	180000f4 	.word	0x180000f4
        ldr r0, =(XIP_BASE + 0x100)
10000044:	10000100 	.word	0x10000100
        ldr r1, =(PPB_BASE + M0PLUS_VTOR_OFFSET)
10000048:	e000ed08 	.word	0xe000ed08

1000004c <_end_boot2>:
	...

100000fc <crc>:
100000fc:	0d21ec2c                                ,.!.

10000100 <vector_table>:
10000100:	0003ffff 	.word	0x0003ffff
10000104:	10000111 	.word	0x10000111
10000108:	1000013d 	.word	0x1000013d
1000010c:	1000013d 	.word	0x1000013d

10000110 <_start>:
.equ GPIO25_CTRL_REG, 0x400140cc
.equ GPIO_OE_SET_REG, 0xd0000024
.equ GPIO_OUT_XOR_REG, 0xd000001c

	// Deassert IO_BANK0 bit5(after reset it is equal to 1 and periphreal is in reset state)
	ldr r0,=RESETS_BASE_REG
10000110:	4810      	ldr	r0, [pc, #64]	@ (10000154 <led_toogle+0xa>)
	ldr r2,=~(1<<5)
10000112:	4a11      	ldr	r2, [pc, #68]	@ (10000158 <led_toogle+0xe>)
	ldr r1,[r0]
10000114:	6801      	ldr	r1, [r0, #0]
	ands r1,r2
10000116:	4011      	ands	r1, r2
	str r1,[r0]
10000118:	6001      	str	r1, [r0, #0]

1000011a <check_reset_done>:

	//Wait for IO_BANK0 to be ready
check_reset_done:
	ldr r0,=RESETS_BASE_REG
1000011a:	480e      	ldr	r0, [pc, #56]	@ (10000154 <led_toogle+0xa>)
	ldr r1,[r0]
1000011c:	6801      	ldr	r1, [r0, #0]
	ldr r2,=(1<<5)
1000011e:	4a0f      	ldr	r2, [pc, #60]	@ (1000015c <led_toogle+0x12>)
	ands r2, r1
10000120:	400a      	ands	r2, r1
	bne check_reset_done
10000122:	d1fa      	bne.n	1000011a <check_reset_done>


	// Set GPIO 25 function to SIO
	ldr r0,=GPIO25_CTRL_REG
10000124:	480e      	ldr	r0, [pc, #56]	@ (10000160 <led_toogle+0x16>)
	ldr r1,=5
10000126:	490f      	ldr	r1, [pc, #60]	@ (10000164 <led_toogle+0x1a>)
	str r1,[r0]
10000128:	6001      	str	r1, [r0, #0]

	//Output enable for gpio 25 using SIO interface
	ldr r0,=GPIO_OE_SET_REG
1000012a:	480f      	ldr	r0, [pc, #60]	@ (10000168 <led_toogle+0x1e>)
	ldr r1,=(1<<25)
1000012c:	490f      	ldr	r1, [pc, #60]	@ (1000016c <led_toogle+0x22>)
	str r1,[r0]
1000012e:	6001      	str	r1, [r0, #0]

10000130 <loop>:

loop:
	nop
10000130:	46c0      	nop			@ (mov r8, r8)
	bl delay
10000132:	f000 f804 	bl	1000013e <delay>
	bl led_toogle
10000136:	f000 f808 	bl	1000014a <led_toogle>
	b loop
1000013a:	e7f9      	b.n	10000130 <loop>

1000013c <fault>:

.thumb_func
fault:
	b fault
1000013c:	e7fe      	b.n	1000013c <fault>

1000013e <delay>:

delay:	
	ldr	r0, =200000
1000013e:	480c      	ldr	r0, [pc, #48]	@ (10000170 <led_toogle+0x26>)

10000140 <loop2>:
loop2:
	nop
10000140:	46c0      	nop			@ (mov r8, r8)
	subs	r0, #1
10000142:	3801      	subs	r0, #1
	cmp	r0, #0
10000144:	2800      	cmp	r0, #0
	bge	loop2
10000146:	dafb      	bge.n	10000140 <loop2>
	bx	lr
10000148:	4770      	bx	lr

1000014a <led_toogle>:

led_toogle:
	ldr r0,=GPIO_OUT_XOR_REG
1000014a:	480a      	ldr	r0, [pc, #40]	@ (10000174 <led_toogle+0x2a>)
	ldr r1,=(1<<25)
1000014c:	4907      	ldr	r1, [pc, #28]	@ (1000016c <led_toogle+0x22>)
	str r1,[r0]
1000014e:	6001      	str	r1, [r0, #0]
	bx lr
10000150:	4770      	bx	lr
10000152:	0000      	.short	0x0000
	ldr r0,=RESETS_BASE_REG
10000154:	4000c000 	.word	0x4000c000
	ldr r2,=~(1<<5)
10000158:	ffffffdf 	.word	0xffffffdf
	ldr r2,=(1<<5)
1000015c:	00000020 	.word	0x00000020
	ldr r0,=GPIO25_CTRL_REG
10000160:	400140cc 	.word	0x400140cc
	ldr r1,=5
10000164:	00000005 	.word	0x00000005
	ldr r0,=GPIO_OE_SET_REG
10000168:	d0000024 	.word	0xd0000024
	ldr r1,=(1<<25)
1000016c:	02000000 	.word	0x02000000
	ldr	r0, =200000
10000170:	00030d40 	.word	0x00030d40
	ldr r0,=GPIO_OUT_XOR_REG
10000174:	d000001c 	.word	0xd000001c
