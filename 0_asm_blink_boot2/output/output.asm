
output/output.elf:     file format elf32-littlearm


Disassembly of section .text:

10000000 <boot2_start>:
.equ GPIO25_CTRL_REG, 0x400140cc
.equ GPIO_OE_SET_REG, 0xd0000024
.equ GPIO_OUT_XOR_REG, 0xd000001c

	// Deassert IO_BANK0 bit5(after reset it is equal to 1 and periphreal is in reset state)
	ldr r0,=RESETS_BASE_REG
10000000:	4810      	ldr	r0, [pc, #64]	@ (10000044 <led_toogle+0xa>)
	ldr r2,=~(1<<5)
10000002:	4a11      	ldr	r2, [pc, #68]	@ (10000048 <led_toogle+0xe>)
	ldr r1,[r0]
10000004:	6801      	ldr	r1, [r0, #0]
	ands r1,r2
10000006:	4011      	ands	r1, r2
	str r1,[r0]
10000008:	6001      	str	r1, [r0, #0]

1000000a <check_reset_done>:

	//Wait for IO_BANK0 to be ready
check_reset_done:
	ldr r0,=RESETS_BASE_REG
1000000a:	480e      	ldr	r0, [pc, #56]	@ (10000044 <led_toogle+0xa>)
	ldr r1,[r0]
1000000c:	6801      	ldr	r1, [r0, #0]
	ldr r2,=(1<<5)
1000000e:	4a0f      	ldr	r2, [pc, #60]	@ (1000004c <led_toogle+0x12>)
	ands r2, r1
10000010:	400a      	ands	r2, r1
	bne check_reset_done
10000012:	d1fa      	bne.n	1000000a <check_reset_done>


	// Set GPIO 25 function to SIO
	ldr r0,=GPIO25_CTRL_REG
10000014:	480e      	ldr	r0, [pc, #56]	@ (10000050 <led_toogle+0x16>)
	ldr r1,=5
10000016:	490f      	ldr	r1, [pc, #60]	@ (10000054 <led_toogle+0x1a>)
	str r1,[r0]
10000018:	6001      	str	r1, [r0, #0]

	//Output enable for gpio 25 using SIO interface
	ldr r0,=GPIO_OE_SET_REG
1000001a:	480f      	ldr	r0, [pc, #60]	@ (10000058 <led_toogle+0x1e>)
	ldr r1,=(1<<25)
1000001c:	490f      	ldr	r1, [pc, #60]	@ (1000005c <led_toogle+0x22>)
	str r1,[r0]
1000001e:	6001      	str	r1, [r0, #0]

10000020 <loop>:

loop:
	nop
10000020:	46c0      	nop			@ (mov r8, r8)
	bl delay
10000022:	f000 f804 	bl	1000002e <delay>
	bl led_toogle
10000026:	f000 f808 	bl	1000003a <led_toogle>
	b loop
1000002a:	e7f9      	b.n	10000020 <loop>

1000002c <fault>:

fault:
	b fault
1000002c:	e7fe      	b.n	1000002c <fault>

1000002e <delay>:

delay:	
	ldr	r0, =200000
1000002e:	480c      	ldr	r0, [pc, #48]	@ (10000060 <led_toogle+0x26>)

10000030 <loop2>:
loop2:
	nop
10000030:	46c0      	nop			@ (mov r8, r8)
	subs	r0, #1
10000032:	3801      	subs	r0, #1
	cmp	r0, #0
10000034:	2800      	cmp	r0, #0
	bge	loop2
10000036:	dafb      	bge.n	10000030 <loop2>
	bx	lr
10000038:	4770      	bx	lr

1000003a <led_toogle>:

led_toogle:
	ldr r0,=GPIO_OUT_XOR_REG
1000003a:	480a      	ldr	r0, [pc, #40]	@ (10000064 <led_toogle+0x2a>)
	ldr r1,=(1<<25)
1000003c:	4907      	ldr	r1, [pc, #28]	@ (1000005c <led_toogle+0x22>)
	str r1,[r0]
1000003e:	6001      	str	r1, [r0, #0]
	bx lr
10000040:	4770      	bx	lr
10000042:	0000      	.short	0x0000
	ldr r0,=RESETS_BASE_REG
10000044:	4000c000 	.word	0x4000c000
	ldr r2,=~(1<<5)
10000048:	ffffffdf 	.word	0xffffffdf
	ldr r2,=(1<<5)
1000004c:	00000020 	.word	0x00000020
	ldr r0,=GPIO25_CTRL_REG
10000050:	400140cc 	.word	0x400140cc
	ldr r1,=5
10000054:	00000005 	.word	0x00000005
	ldr r0,=GPIO_OE_SET_REG
10000058:	d0000024 	.word	0xd0000024
	ldr r1,=(1<<25)
1000005c:	02000000 	.word	0x02000000
	ldr	r0, =200000
10000060:	00030d40 	.word	0x00030d40
	ldr r0,=GPIO_OUT_XOR_REG
10000064:	d000001c 	.word	0xd000001c
	...

100000fc <crc>:
100000fc:	33fae9ff                                ...3
