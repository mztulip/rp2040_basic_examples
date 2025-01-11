
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
10000100:	20040000 	.word	0x20040000
10000104:	10000261 	.word	0x10000261
10000108:	10000287 	.word	0x10000287
1000010c:	10000287 	.word	0x10000287

10000110 <failed>:
        // SIO: GPIO_OUT_XOR Register
        // Offset: 0x01c
        // Description
        // GPIO output value XO
        // xor bit for GPIO 25 changing led state
        *(volatile uint32_t *) (SIO_BASE+0x1c) |= 1 << 25;
10000110:	2080      	movs	r0, #128	@ 0x80
{
10000112:	b510      	push	{r4, lr}
    for (volatile uint32_t i = 0; i < 123456/8; ++i)
10000114:	2400      	movs	r4, #0
10000116:	4a09      	ldr	r2, [pc, #36]	@ (1000013c <failed+0x2c>)
        *(volatile uint32_t *) (SIO_BASE+0x1c) |= 1 << 25;
10000118:	4909      	ldr	r1, [pc, #36]	@ (10000140 <failed+0x30>)
{
1000011a:	b082      	sub	sp, #8
        *(volatile uint32_t *) (SIO_BASE+0x1c) |= 1 << 25;
1000011c:	0480      	lsls	r0, r0, #18
    for (volatile uint32_t i = 0; i < 123456/8; ++i)
1000011e:	9401      	str	r4, [sp, #4]
10000120:	9b01      	ldr	r3, [sp, #4]
10000122:	4293      	cmp	r3, r2
10000124:	d805      	bhi.n	10000132 <failed+0x22>
10000126:	9b01      	ldr	r3, [sp, #4]
10000128:	3301      	adds	r3, #1
1000012a:	9301      	str	r3, [sp, #4]
1000012c:	9b01      	ldr	r3, [sp, #4]
1000012e:	4293      	cmp	r3, r2
10000130:	d9f9      	bls.n	10000126 <failed+0x16>
        *(volatile uint32_t *) (SIO_BASE+0x1c) |= 1 << 25;
10000132:	680b      	ldr	r3, [r1, #0]
10000134:	4303      	orrs	r3, r0
10000136:	600b      	str	r3, [r1, #0]
        delay();
10000138:	e7f1      	b.n	1000011e <failed+0xe>
1000013a:	46c0      	nop			@ (mov r8, r8)
1000013c:	00003c47 	.word	0x00003c47
10000140:	d000001c 	.word	0xd000001c

10000144 <main>:
}

extern uint32_t __StackTop;

int main(void)
{
10000144:	b5f0      	push	{r4, r5, r6, r7, lr}
10000146:	46de      	mov	lr, fp
10000148:	4657      	mov	r7, sl
1000014a:	464e      	mov	r6, r9
1000014c:	4645      	mov	r5, r8
    *(volatile uint32_t *) (RESETS_BASE) &= ~(1 << 5);
1000014e:	2120      	movs	r1, #32
10000150:	4a37      	ldr	r2, [pc, #220]	@ (10000230 <main+0xec>)
{
10000152:	b5e0      	push	{r5, r6, r7, lr}
    *(volatile uint32_t *) (RESETS_BASE) &= ~(1 << 5);
10000154:	6813      	ldr	r3, [r2, #0]
{
10000156:	b083      	sub	sp, #12
    *(volatile uint32_t *) (RESETS_BASE) &= ~(1 << 5);
10000158:	438b      	bics	r3, r1
1000015a:	6013      	str	r3, [r2, #0]
    while (!( *(volatile uint32_t *) (RESETS_BASE+0x08) & (1 << 5)));
1000015c:	2220      	movs	r2, #32
1000015e:	4935      	ldr	r1, [pc, #212]	@ (10000234 <main+0xf0>)
10000160:	680b      	ldr	r3, [r1, #0]
10000162:	421a      	tst	r2, r3
10000164:	d0fc      	beq.n	10000160 <main+0x1c>
    *(volatile uint32_t *) (IO_BANK0_BASE+0xcc) = 5;
10000166:	2205      	movs	r2, #5
    *(volatile uint32_t *) (SIO_BASE+0x24) |= 1 << 25;
10000168:	2180      	movs	r1, #128	@ 0x80
    *(volatile uint32_t *) (IO_BANK0_BASE+0xcc) = 5;
1000016a:	4b33      	ldr	r3, [pc, #204]	@ (10000238 <main+0xf4>)
    *(volatile uint32_t *) (SIO_BASE+0x24) |= 1 << 25;
1000016c:	0489      	lsls	r1, r1, #18
    *(volatile uint32_t *) (IO_BANK0_BASE+0xcc) = 5;
1000016e:	601a      	str	r2, [r3, #0]
    *(volatile uint32_t *) (SIO_BASE+0x24) |= 1 << 25;
10000170:	4a32      	ldr	r2, [pc, #200]	@ (1000023c <main+0xf8>)
10000172:	6813      	ldr	r3, [r2, #0]
10000174:	430b      	orrs	r3, r1
10000176:	6013      	str	r3, [r2, #0]
    init_led_gpio();

    //Check if stap top is correctly defined in linker script
    if(&__StackTop != (uint32_t*)0x20040000)
10000178:	4b31      	ldr	r3, [pc, #196]	@ (10000240 <main+0xfc>)
1000017a:	4a32      	ldr	r2, [pc, #200]	@ (10000244 <main+0x100>)
1000017c:	4293      	cmp	r3, r2
1000017e:	d001      	beq.n	10000184 <main+0x40>
    {
        failed();
10000180:	f7ff ffc6 	bl	10000110 <failed>
    }

    //Check if bss init loop works
    if (counter != 0)
10000184:	4b30      	ldr	r3, [pc, #192]	@ (10000248 <main+0x104>)
10000186:	681d      	ldr	r5, [r3, #0]
10000188:	4699      	mov	r9, r3
1000018a:	2d00      	cmp	r5, #0
1000018c:	d1f8      	bne.n	10000180 <main+0x3c>
    {
        failed();
    }

    //Check if data init loop works
    if (counter_compare_value != 100)
1000018e:	4b2f      	ldr	r3, [pc, #188]	@ (1000024c <main+0x108>)
10000190:	681c      	ldr	r4, [r3, #0]
10000192:	4698      	mov	r8, r3
10000194:	2c64      	cmp	r4, #100	@ 0x64
10000196:	d1f3      	bne.n	10000180 <main+0x3c>
10000198:	4a2d      	ldr	r2, [pc, #180]	@ (10000250 <main+0x10c>)
1000019a:	4f2e      	ldr	r7, [pc, #184]	@ (10000254 <main+0x110>)
1000019c:	6813      	ldr	r3, [r2, #0]
    if (counter >= counter_max)
1000019e:	26fa      	movs	r6, #250	@ 0xfa
100001a0:	9301      	str	r3, [sp, #4]
    *(volatile uint32_t *) (SIO_BASE+0x14) |= 1 << 25;
100001a2:	4b2d      	ldr	r3, [pc, #180]	@ (10000258 <main+0x114>)
    if (counter >= counter_max)
100001a4:	0076      	lsls	r6, r6, #1
    *(volatile uint32_t *) (SIO_BASE+0x14) |= 1 << 25;
100001a6:	469b      	mov	fp, r3
    *(volatile uint32_t *) (SIO_BASE+0x18) |= 1 << 25;
100001a8:	4b2c      	ldr	r3, [pc, #176]	@ (1000025c <main+0x118>)
100001aa:	469a      	mov	sl, r3
100001ac:	003b      	movs	r3, r7
100001ae:	4647      	mov	r7, r8
100001b0:	4698      	mov	r8, r3
    

 
    while (true)
    {
        counter++;
100001b2:	464b      	mov	r3, r9
100001b4:	3501      	adds	r5, #1
100001b6:	601d      	str	r5, [r3, #0]
    if (counter >= counter_max)
100001b8:	42b5      	cmp	r5, r6
100001ba:	d30c      	bcc.n	100001d6 <main+0x92>
        counter = 0;
100001bc:	464b      	mov	r3, r9
100001be:	2200      	movs	r2, #0
100001c0:	601a      	str	r2, [r3, #0]
    *(volatile uint32_t *) (SIO_BASE+0x14) |= 1 << 25;
100001c2:	465b      	mov	r3, fp
100001c4:	681a      	ldr	r2, [r3, #0]
100001c6:	2380      	movs	r3, #128	@ 0x80
100001c8:	049b      	lsls	r3, r3, #18
100001ca:	431a      	orrs	r2, r3
100001cc:	465b      	mov	r3, fp
100001ce:	601a      	str	r2, [r3, #0]
    if(counter >= counter_compare_value)
100001d0:	464b      	mov	r3, r9
100001d2:	683c      	ldr	r4, [r7, #0]
100001d4:	681d      	ldr	r5, [r3, #0]
100001d6:	42a5      	cmp	r5, r4
100001d8:	d308      	bcc.n	100001ec <main+0xa8>
    *(volatile uint32_t *) (SIO_BASE+0x18) |= 1 << 25;
100001da:	4653      	mov	r3, sl
100001dc:	681a      	ldr	r2, [r3, #0]
100001de:	2380      	movs	r3, #128	@ 0x80
100001e0:	049b      	lsls	r3, r3, #18
100001e2:	431a      	orrs	r2, r3
100001e4:	4653      	mov	r3, sl
100001e6:	601a      	str	r2, [r3, #0]
    if(counter%100 == 0)
100001e8:	464b      	mov	r3, r9
100001ea:	681d      	ldr	r5, [r3, #0]
        pwm_setpoint+=inc_step;
100001ec:	4643      	mov	r3, r8
100001ee:	2164      	movs	r1, #100	@ 0x64
100001f0:	0028      	movs	r0, r5
100001f2:	681c      	ldr	r4, [r3, #0]
100001f4:	f000 f88c 	bl	10000310 <__aeabi_uidivmod>
    if(counter%100 == 0)
100001f8:	2900      	cmp	r1, #0
100001fa:	d104      	bne.n	10000206 <main+0xc2>
        pwm_setpoint+=inc_step;
100001fc:	9b01      	ldr	r3, [sp, #4]
100001fe:	469c      	mov	ip, r3
10000200:	4643      	mov	r3, r8
10000202:	4464      	add	r4, ip
10000204:	601c      	str	r4, [r3, #0]
    if(pwm_setpoint >= counter_max)
10000206:	42b4      	cmp	r4, r6
10000208:	db07      	blt.n	1000021a <main+0xd6>
        inc_step=-1;
1000020a:	2301      	movs	r3, #1
        counter++;
1000020c:	3501      	adds	r5, #1
        inc_step=-1;
1000020e:	425b      	negs	r3, r3
    counter_compare_value = setpoint;
10000210:	603e      	str	r6, [r7, #0]
        inc_step=-1;
10000212:	9301      	str	r3, [sp, #4]
    if (counter >= counter_max)
10000214:	42b5      	cmp	r5, r6
10000216:	d2d1      	bcs.n	100001bc <main+0x78>
10000218:	e7e8      	b.n	100001ec <main+0xa8>
    else if(pwm_setpoint <= 0)
1000021a:	2c00      	cmp	r4, #0
1000021c:	dc01      	bgt.n	10000222 <main+0xde>
        inc_step=1;
1000021e:	2301      	movs	r3, #1
10000220:	9301      	str	r3, [sp, #4]
    if(setpoint > counter_max)
10000222:	42b4      	cmp	r4, r6
10000224:	d901      	bls.n	1000022a <main+0xe6>
10000226:	24fa      	movs	r4, #250	@ 0xfa
10000228:	0064      	lsls	r4, r4, #1
    counter_compare_value = setpoint;
1000022a:	603c      	str	r4, [r7, #0]
}
1000022c:	e7c1      	b.n	100001b2 <main+0x6e>
1000022e:	46c0      	nop			@ (mov r8, r8)
10000230:	4000c000 	.word	0x4000c000
10000234:	4000c008 	.word	0x4000c008
10000238:	400140cc 	.word	0x400140cc
1000023c:	d0000024 	.word	0xd0000024
10000240:	20040000 	.word	0x20040000
10000244:	20040000 	.word	0x20040000
10000248:	2000000c 	.word	0x2000000c
1000024c:	20000004 	.word	0x20000004
10000250:	20000000 	.word	0x20000000
10000254:	20000008 	.word	0x20000008
10000258:	d0000014 	.word	0xd0000014
1000025c:	d0000018 	.word	0xd0000018

10000260 <_reset_handler>:
	//__etext: symbol represent address of LMA of start of the section to copy from. Usually end of text
	//__data_start__: symbol containing address of VMA of start of the section to copy to.
	//__bss_start__: VMA of end of the section to copy to. Normally __data_end__ is used, but by using __bss_start__
	//                the user can add their own initialized data section before BSS section with the INSERT AFTER command.
	//				https://maskray.me/blog/2021-07-04-sections-and-overwrite-sections
	ldr r1, =__etext
10000260:	4909      	ldr	r1, [pc, #36]	@ (10000288 <fault+0x2>)
	ldr r2, =__data_start__
10000262:	4a0a      	ldr	r2, [pc, #40]	@ (1000028c <fault+0x6>)
	ldr r3, =__bss_start__
10000264:	4b0a      	ldr	r3, [pc, #40]	@ (10000290 <fault+0xa>)
	//r3 contains lenght of data to copy
	subs r3, r2
10000266:	1a9b      	subs	r3, r3, r2
	//If zero jump over the loop
    ble .data_init_loop_done
10000268:	dd03      	ble.n	10000272 <.data_init_loop_done>

1000026a <.data_init_loop>:
	

.data_init_loop:
	//decrease r3 by 4bytes because in single load store 4 bytes are copied
    subs r3, #4
1000026a:	3b04      	subs	r3, #4
    ldr r0, [r1,r3]
1000026c:	58c8      	ldr	r0, [r1, r3]
    str r0, [r2,r3]
1000026e:	50d0      	str	r0, [r2, r3]
	//branch until r3 is greater then zero
    bgt .data_init_loop
10000270:	dcfb      	bgt.n	1000026a <.data_init_loop>

10000272 <.data_init_loop_done>:

	//Initializing BSS
	//In C BSS represents statically allocated objects without an explicit initializer which are initialized to zero 
	//__bss_start__ represents start address of the bss section
	//__bss_end__ represents end address of the bss section
	ldr r1, =__bss_start__
10000272:	4907      	ldr	r1, [pc, #28]	@ (10000290 <fault+0xa>)
	ldr r2, =__bss_end__
10000274:	4a07      	ldr	r2, [pc, #28]	@ (10000294 <fault+0xe>)
	movs r0, 0
10000276:	2000      	movs	r0, #0
	subs r2, r1
10000278:	1a52      	subs	r2, r2, r1
	ble .bss_init_done
1000027a:	dd02      	ble.n	10000282 <.bss_init_done>

1000027c <.bss_init_loop>:
.bss_init_loop:
	//r2 is used as loop counter with 4bytes incrementation
	subs r2, #4
1000027c:	3a04      	subs	r2, #4
	str r0, [r1, r2]
1000027e:	5088      	str	r0, [r1, r2]
	bgt .bss_init_loop
10000280:	dcfc      	bgt.n	1000027c <.bss_init_loop>

10000282 <.bss_init_done>:
.bss_init_done:

	bl main
10000282:	f7ff ff5f 	bl	10000144 <main>

10000286 <fault>:

.thumb_func
fault:
10000286:	e7fe      	b.n	10000286 <fault>
	ldr r1, =__etext
10000288:	10000328 	.word	0x10000328
	ldr r2, =__data_start__
1000028c:	20000000 	.word	0x20000000
	ldr r3, =__bss_start__
10000290:	20000008 	.word	0x20000008
	ldr r2, =__bss_end__
10000294:	20000010 	.word	0x20000010

10000298 <__udivsi3>:
10000298:	2900      	cmp	r1, #0
1000029a:	d034      	beq.n	10000306 <.udivsi3_skip_div0_test+0x6a>

1000029c <.udivsi3_skip_div0_test>:
1000029c:	2301      	movs	r3, #1
1000029e:	2200      	movs	r2, #0
100002a0:	b410      	push	{r4}
100002a2:	4288      	cmp	r0, r1
100002a4:	d32c      	bcc.n	10000300 <.udivsi3_skip_div0_test+0x64>
100002a6:	2401      	movs	r4, #1
100002a8:	0724      	lsls	r4, r4, #28
100002aa:	42a1      	cmp	r1, r4
100002ac:	d204      	bcs.n	100002b8 <.udivsi3_skip_div0_test+0x1c>
100002ae:	4281      	cmp	r1, r0
100002b0:	d202      	bcs.n	100002b8 <.udivsi3_skip_div0_test+0x1c>
100002b2:	0109      	lsls	r1, r1, #4
100002b4:	011b      	lsls	r3, r3, #4
100002b6:	e7f8      	b.n	100002aa <.udivsi3_skip_div0_test+0xe>
100002b8:	00e4      	lsls	r4, r4, #3
100002ba:	42a1      	cmp	r1, r4
100002bc:	d204      	bcs.n	100002c8 <.udivsi3_skip_div0_test+0x2c>
100002be:	4281      	cmp	r1, r0
100002c0:	d202      	bcs.n	100002c8 <.udivsi3_skip_div0_test+0x2c>
100002c2:	0049      	lsls	r1, r1, #1
100002c4:	005b      	lsls	r3, r3, #1
100002c6:	e7f8      	b.n	100002ba <.udivsi3_skip_div0_test+0x1e>
100002c8:	4288      	cmp	r0, r1
100002ca:	d301      	bcc.n	100002d0 <.udivsi3_skip_div0_test+0x34>
100002cc:	1a40      	subs	r0, r0, r1
100002ce:	431a      	orrs	r2, r3
100002d0:	084c      	lsrs	r4, r1, #1
100002d2:	42a0      	cmp	r0, r4
100002d4:	d302      	bcc.n	100002dc <.udivsi3_skip_div0_test+0x40>
100002d6:	1b00      	subs	r0, r0, r4
100002d8:	085c      	lsrs	r4, r3, #1
100002da:	4322      	orrs	r2, r4
100002dc:	088c      	lsrs	r4, r1, #2
100002de:	42a0      	cmp	r0, r4
100002e0:	d302      	bcc.n	100002e8 <.udivsi3_skip_div0_test+0x4c>
100002e2:	1b00      	subs	r0, r0, r4
100002e4:	089c      	lsrs	r4, r3, #2
100002e6:	4322      	orrs	r2, r4
100002e8:	08cc      	lsrs	r4, r1, #3
100002ea:	42a0      	cmp	r0, r4
100002ec:	d302      	bcc.n	100002f4 <.udivsi3_skip_div0_test+0x58>
100002ee:	1b00      	subs	r0, r0, r4
100002f0:	08dc      	lsrs	r4, r3, #3
100002f2:	4322      	orrs	r2, r4
100002f4:	2800      	cmp	r0, #0
100002f6:	d003      	beq.n	10000300 <.udivsi3_skip_div0_test+0x64>
100002f8:	091b      	lsrs	r3, r3, #4
100002fa:	d001      	beq.n	10000300 <.udivsi3_skip_div0_test+0x64>
100002fc:	0909      	lsrs	r1, r1, #4
100002fe:	e7e3      	b.n	100002c8 <.udivsi3_skip_div0_test+0x2c>
10000300:	0010      	movs	r0, r2
10000302:	bc10      	pop	{r4}
10000304:	4770      	bx	lr
10000306:	b501      	push	{r0, lr}
10000308:	2000      	movs	r0, #0
1000030a:	f000 f80b 	bl	10000324 <__aeabi_idiv0>
1000030e:	bd02      	pop	{r1, pc}

10000310 <__aeabi_uidivmod>:
10000310:	2900      	cmp	r1, #0
10000312:	d0f8      	beq.n	10000306 <.udivsi3_skip_div0_test+0x6a>
10000314:	b503      	push	{r0, r1, lr}
10000316:	f7ff ffc1 	bl	1000029c <.udivsi3_skip_div0_test>
1000031a:	bc0e      	pop	{r1, r2, r3}
1000031c:	4342      	muls	r2, r0
1000031e:	1a89      	subs	r1, r1, r2
10000320:	4718      	bx	r3
10000322:	46c0      	nop			@ (mov r8, r8)

10000324 <__aeabi_idiv0>:
10000324:	4770      	bx	lr
10000326:	46c0      	nop			@ (mov r8, r8)
