
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
10000100:	2003ffff 	.word	0x2003ffff
10000104:	10000191 	.word	0x10000191
10000108:	100001a9 	.word	0x100001a9
1000010c:	100001a9 	.word	0x100001a9

10000110 <delay>:
#include <stdint.h>
#include <stdbool.h>
#include "boot2/addressmap.h"

void delay(void)
{
10000110:	b580      	push	{r7, lr}
10000112:	b082      	sub	sp, #8
10000114:	af00      	add	r7, sp, #0
    for (uint32_t i = 0; i < 123456; ++i)
10000116:	2300      	movs	r3, #0
10000118:	607b      	str	r3, [r7, #4]
1000011a:	e002      	b.n	10000122 <delay+0x12>
1000011c:	687b      	ldr	r3, [r7, #4]
1000011e:	3301      	adds	r3, #1
10000120:	607b      	str	r3, [r7, #4]
10000122:	687b      	ldr	r3, [r7, #4]
10000124:	4a03      	ldr	r2, [pc, #12]	@ (10000134 <delay+0x24>)
10000126:	4293      	cmp	r3, r2
10000128:	d9f8      	bls.n	1000011c <delay+0xc>
    {

    }
}
1000012a:	46c0      	nop			@ (mov r8, r8)
1000012c:	46c0      	nop			@ (mov r8, r8)
1000012e:	46bd      	mov	sp, r7
10000130:	b002      	add	sp, #8
10000132:	bd80      	pop	{r7, pc}
10000134:	0001e23f 	.word	0x0001e23f

10000138 <main>:

int main(void)
{
10000138:	b580      	push	{r7, lr}
1000013a:	af00      	add	r7, sp, #0
    //Activate IO_BANK0 ba setting bit 5 to 0
    //rp2040 datasheet 2.14.3. List of Registers
    *(volatile uint32_t *) (RESETS_BASE) &= ~(1 << 5);
1000013c:	4b0f      	ldr	r3, [pc, #60]	@ (1000017c <main+0x44>)
1000013e:	681a      	ldr	r2, [r3, #0]
10000140:	4b0e      	ldr	r3, [pc, #56]	@ (1000017c <main+0x44>)
10000142:	2120      	movs	r1, #32
10000144:	438a      	bics	r2, r1
10000146:	601a      	str	r2, [r3, #0]

    //RESETS: RESET_DONE Register
    //Offset: 0x8
    //Wait for IO_BANK0 to be ready bit 5 should be  set
    while (!( *(volatile uint32_t *) (RESETS_BASE+0x08) & (1 << 5)));
10000148:	46c0      	nop			@ (mov r8, r8)
1000014a:	4b0d      	ldr	r3, [pc, #52]	@ (10000180 <main+0x48>)
1000014c:	681b      	ldr	r3, [r3, #0]
1000014e:	2220      	movs	r2, #32
10000150:	4013      	ands	r3, r2
10000152:	d0fa      	beq.n	1000014a <main+0x12>

    //2.19.6. List of Registers
    //2.19.6.1. IO - User Bank
    //0x0cc GPIO25_CTRL GPIO control including function select and overrides
    // GPIO 25 BANK 0 CTRL
    *(volatile uint32_t *) (IO_BANK0_BASE+0xcc) = 5;
10000154:	4b0b      	ldr	r3, [pc, #44]	@ (10000184 <main+0x4c>)
10000156:	2205      	movs	r2, #5
10000158:	601a      	str	r2, [r3, #0]
    //SIO: GPIO_OE_SET Register
    //Offset: 0x024
    //Description
    //GPIO output enable set
    //GPIO 25 as Outputs using SIO
    *(volatile uint32_t *) (SIO_BASE+0x24) |= 1 << 25;
1000015a:	4b0b      	ldr	r3, [pc, #44]	@ (10000188 <main+0x50>)
1000015c:	681a      	ldr	r2, [r3, #0]
1000015e:	4b0a      	ldr	r3, [pc, #40]	@ (10000188 <main+0x50>)
10000160:	2180      	movs	r1, #128	@ 0x80
10000162:	0489      	lsls	r1, r1, #18
10000164:	430a      	orrs	r2, r1
10000166:	601a      	str	r2, [r3, #0]

    while (true)
    {
        delay();
10000168:	f7ff ffd2 	bl	10000110 <delay>
        // SIO: GPIO_OUT_XOR Register
        // Offset: 0x01c
        // Description
        // GPIO output value XO
        // xor bit for GPIO 25 changing led state
        *(volatile uint32_t *) (SIO_BASE+0x1c) |= 1 << 25;
1000016c:	4b07      	ldr	r3, [pc, #28]	@ (1000018c <main+0x54>)
1000016e:	681a      	ldr	r2, [r3, #0]
10000170:	4b06      	ldr	r3, [pc, #24]	@ (1000018c <main+0x54>)
10000172:	2180      	movs	r1, #128	@ 0x80
10000174:	0489      	lsls	r1, r1, #18
10000176:	430a      	orrs	r2, r1
10000178:	601a      	str	r2, [r3, #0]
        delay();
1000017a:	e7f5      	b.n	10000168 <main+0x30>
1000017c:	4000c000 	.word	0x4000c000
10000180:	4000c008 	.word	0x4000c008
10000184:	400140cc 	.word	0x400140cc
10000188:	d0000024 	.word	0xd0000024
1000018c:	d000001c 	.word	0xd000001c

10000190 <_reset_handler>:
.global _reset_handler
.section .text
.thumb_func
_reset_handler:
	//Plan is to put here bss and data init
	nop
10000190:	46c0      	nop			@ (mov r8, r8)
	nop
10000192:	46c0      	nop			@ (mov r8, r8)
	nop
10000194:	46c0      	nop			@ (mov r8, r8)
	nop
10000196:	46c0      	nop			@ (mov r8, r8)
	nop
10000198:	46c0      	nop			@ (mov r8, r8)
	nop
1000019a:	46c0      	nop			@ (mov r8, r8)
	nop
1000019c:	46c0      	nop			@ (mov r8, r8)
	nop
1000019e:	46c0      	nop			@ (mov r8, r8)
	nop
100001a0:	46c0      	nop			@ (mov r8, r8)
	nop
100001a2:	46c0      	nop			@ (mov r8, r8)
	//Current example assumes that section data and bss is zero
	bl main
100001a4:	f7ff ffc8 	bl	10000138 <main>

100001a8 <fault>:

.thumb_func
fault:
100001a8:	e7fe      	b.n	100001a8 <fault>
