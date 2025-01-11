
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
10000104:	10000231 	.word	0x10000231
10000108:	10000257 	.word	0x10000257
1000010c:	10000257 	.word	0x10000257

10000110 <failed>:
        // SIO: GPIO_OUT_XOR Register
        // Offset: 0x01c
        // Description
        // GPIO output value XO
        // xor bit for GPIO 25 changing led state
        *(volatile uint32_t *) (SIO_BASE+0x1c) |= 1 << 25;
10000110:	2180      	movs	r1, #128	@ 0x80
10000112:	4a03      	ldr	r2, [pc, #12]	@ (10000120 <failed+0x10>)
10000114:	0489      	lsls	r1, r1, #18
10000116:	6813      	ldr	r3, [r2, #0]
10000118:	430b      	orrs	r3, r1
1000011a:	6013      	str	r3, [r2, #0]
    while (true)
1000011c:	e7fb      	b.n	10000116 <failed+0x6>
1000011e:	46c0      	nop			@ (mov r8, r8)
10000120:	d000001c 	.word	0xd000001c

10000124 <main>:
}

void failed(void);

int main(void)
{
10000124:	b5f0      	push	{r4, r5, r6, r7, lr}
10000126:	46de      	mov	lr, fp
10000128:	4657      	mov	r7, sl
1000012a:	464e      	mov	r6, r9
1000012c:	4645      	mov	r5, r8
    *(volatile uint32_t *) (RESETS_BASE) &= ~(1 << 5);
1000012e:	2120      	movs	r1, #32
10000130:	4a35      	ldr	r2, [pc, #212]	@ (10000208 <main+0xe4>)
{
10000132:	b5e0      	push	{r5, r6, r7, lr}
    *(volatile uint32_t *) (RESETS_BASE) &= ~(1 << 5);
10000134:	6813      	ldr	r3, [r2, #0]
{
10000136:	b083      	sub	sp, #12
    *(volatile uint32_t *) (RESETS_BASE) &= ~(1 << 5);
10000138:	438b      	bics	r3, r1
1000013a:	6013      	str	r3, [r2, #0]
    while (!( *(volatile uint32_t *) (RESETS_BASE+0x08) & (1 << 5)));
1000013c:	2220      	movs	r2, #32
1000013e:	4933      	ldr	r1, [pc, #204]	@ (1000020c <main+0xe8>)
10000140:	680b      	ldr	r3, [r1, #0]
10000142:	421a      	tst	r2, r3
10000144:	d0fc      	beq.n	10000140 <main+0x1c>
    *(volatile uint32_t *) (IO_BANK0_BASE+0xcc) = 5;
10000146:	2205      	movs	r2, #5
    *(volatile uint32_t *) (SIO_BASE+0x24) |= 1 << 25;
10000148:	2180      	movs	r1, #128	@ 0x80
    *(volatile uint32_t *) (IO_BANK0_BASE+0xcc) = 5;
1000014a:	4b31      	ldr	r3, [pc, #196]	@ (10000210 <main+0xec>)
    *(volatile uint32_t *) (SIO_BASE+0x24) |= 1 << 25;
1000014c:	0489      	lsls	r1, r1, #18
    *(volatile uint32_t *) (IO_BANK0_BASE+0xcc) = 5;
1000014e:	601a      	str	r2, [r3, #0]
    *(volatile uint32_t *) (SIO_BASE+0x24) |= 1 << 25;
10000150:	4a30      	ldr	r2, [pc, #192]	@ (10000214 <main+0xf0>)
10000152:	6813      	ldr	r3, [r2, #0]
10000154:	430b      	orrs	r3, r1
10000156:	6013      	str	r3, [r2, #0]
    init_led_gpio();

    //Check if bss init loop works
    if (counter != 0)
10000158:	4b2f      	ldr	r3, [pc, #188]	@ (10000218 <main+0xf4>)
1000015a:	681d      	ldr	r5, [r3, #0]
1000015c:	4699      	mov	r9, r3
1000015e:	2d00      	cmp	r5, #0
10000160:	d145      	bne.n	100001ee <main+0xca>
    {
        failed();
    }

    //Check if data init loop works
    if (counter_compare_value != 100)
10000162:	4b2e      	ldr	r3, [pc, #184]	@ (1000021c <main+0xf8>)
10000164:	681c      	ldr	r4, [r3, #0]
10000166:	4698      	mov	r8, r3
10000168:	2c64      	cmp	r4, #100	@ 0x64
1000016a:	d140      	bne.n	100001ee <main+0xca>
1000016c:	4a2c      	ldr	r2, [pc, #176]	@ (10000220 <main+0xfc>)
1000016e:	4f2d      	ldr	r7, [pc, #180]	@ (10000224 <main+0x100>)
10000170:	6813      	ldr	r3, [r2, #0]
    if (counter >= counter_max)
10000172:	26fa      	movs	r6, #250	@ 0xfa
10000174:	9301      	str	r3, [sp, #4]
    *(volatile uint32_t *) (SIO_BASE+0x14) |= 1 << 25;
10000176:	4b2c      	ldr	r3, [pc, #176]	@ (10000228 <main+0x104>)
    if (counter >= counter_max)
10000178:	0076      	lsls	r6, r6, #1
    *(volatile uint32_t *) (SIO_BASE+0x14) |= 1 << 25;
1000017a:	469b      	mov	fp, r3
    *(volatile uint32_t *) (SIO_BASE+0x18) |= 1 << 25;
1000017c:	4b2b      	ldr	r3, [pc, #172]	@ (1000022c <main+0x108>)
1000017e:	469a      	mov	sl, r3
10000180:	003b      	movs	r3, r7
10000182:	4647      	mov	r7, r8
10000184:	4698      	mov	r8, r3
    

 
    while (true)
    {
        counter++;
10000186:	464b      	mov	r3, r9
10000188:	3501      	adds	r5, #1
1000018a:	601d      	str	r5, [r3, #0]
    if (counter >= counter_max)
1000018c:	42b5      	cmp	r5, r6
1000018e:	d30c      	bcc.n	100001aa <main+0x86>
        counter = 0;
10000190:	464b      	mov	r3, r9
10000192:	2200      	movs	r2, #0
10000194:	601a      	str	r2, [r3, #0]
    *(volatile uint32_t *) (SIO_BASE+0x14) |= 1 << 25;
10000196:	465b      	mov	r3, fp
10000198:	681a      	ldr	r2, [r3, #0]
1000019a:	2380      	movs	r3, #128	@ 0x80
1000019c:	049b      	lsls	r3, r3, #18
1000019e:	431a      	orrs	r2, r3
100001a0:	465b      	mov	r3, fp
100001a2:	601a      	str	r2, [r3, #0]
    if(counter >= counter_compare_value)
100001a4:	464b      	mov	r3, r9
100001a6:	683c      	ldr	r4, [r7, #0]
100001a8:	681d      	ldr	r5, [r3, #0]
100001aa:	42a5      	cmp	r5, r4
100001ac:	d308      	bcc.n	100001c0 <main+0x9c>
    *(volatile uint32_t *) (SIO_BASE+0x18) |= 1 << 25;
100001ae:	4653      	mov	r3, sl
100001b0:	681a      	ldr	r2, [r3, #0]
100001b2:	2380      	movs	r3, #128	@ 0x80
100001b4:	049b      	lsls	r3, r3, #18
100001b6:	431a      	orrs	r2, r3
100001b8:	4653      	mov	r3, sl
100001ba:	601a      	str	r2, [r3, #0]
    if(counter%100 == 0)
100001bc:	464b      	mov	r3, r9
100001be:	681d      	ldr	r5, [r3, #0]
        pwm_setpoint+=inc_step;
100001c0:	4643      	mov	r3, r8
100001c2:	2164      	movs	r1, #100	@ 0x64
100001c4:	0028      	movs	r0, r5
100001c6:	681c      	ldr	r4, [r3, #0]
100001c8:	f000 f88a 	bl	100002e0 <__aeabi_uidivmod>
    if(counter%100 == 0)
100001cc:	2900      	cmp	r1, #0
100001ce:	d104      	bne.n	100001da <main+0xb6>
        pwm_setpoint+=inc_step;
100001d0:	9b01      	ldr	r3, [sp, #4]
100001d2:	469c      	mov	ip, r3
100001d4:	4643      	mov	r3, r8
100001d6:	4464      	add	r4, ip
100001d8:	601c      	str	r4, [r3, #0]
    if(pwm_setpoint >= counter_max)
100001da:	42b4      	cmp	r4, r6
100001dc:	db09      	blt.n	100001f2 <main+0xce>
        inc_step=-1;
100001de:	2301      	movs	r3, #1
        counter++;
100001e0:	3501      	adds	r5, #1
        inc_step=-1;
100001e2:	425b      	negs	r3, r3
    counter_compare_value = setpoint;
100001e4:	603e      	str	r6, [r7, #0]
        inc_step=-1;
100001e6:	9301      	str	r3, [sp, #4]
    if (counter >= counter_max)
100001e8:	42b5      	cmp	r5, r6
100001ea:	d2d1      	bcs.n	10000190 <main+0x6c>
100001ec:	e7e8      	b.n	100001c0 <main+0x9c>
        failed();
100001ee:	f7ff ff8f 	bl	10000110 <failed>
    else if(pwm_setpoint <= 0)
100001f2:	2c00      	cmp	r4, #0
100001f4:	dc01      	bgt.n	100001fa <main+0xd6>
        inc_step=1;
100001f6:	2301      	movs	r3, #1
100001f8:	9301      	str	r3, [sp, #4]
    if(setpoint > counter_max)
100001fa:	42b4      	cmp	r4, r6
100001fc:	d901      	bls.n	10000202 <main+0xde>
100001fe:	24fa      	movs	r4, #250	@ 0xfa
10000200:	0064      	lsls	r4, r4, #1
    counter_compare_value = setpoint;
10000202:	603c      	str	r4, [r7, #0]
}
10000204:	e7bf      	b.n	10000186 <main+0x62>
10000206:	46c0      	nop			@ (mov r8, r8)
10000208:	4000c000 	.word	0x4000c000
1000020c:	4000c008 	.word	0x4000c008
10000210:	400140cc 	.word	0x400140cc
10000214:	d0000024 	.word	0xd0000024
10000218:	2000000c 	.word	0x2000000c
1000021c:	20000004 	.word	0x20000004
10000220:	20000000 	.word	0x20000000
10000224:	20000008 	.word	0x20000008
10000228:	d0000014 	.word	0xd0000014
1000022c:	d0000018 	.word	0xd0000018

10000230 <_reset_handler>:
	//__etext: symbol represent address of LMA of start of the section to copy from. Usually end of text
	//__data_start__: symbol containing address of VMA of start of the section to copy to.
	//__bss_start__: VMA of end of the section to copy to. Normally __data_end__ is used, but by using __bss_start__
	//                the user can add their own initialized data section before BSS section with the INSERT AFTER command.
	//				https://maskray.me/blog/2021-07-04-sections-and-overwrite-sections
	ldr r1, =__etext
10000230:	4909      	ldr	r1, [pc, #36]	@ (10000258 <fault+0x2>)
	ldr r2, =__data_start__
10000232:	4a0a      	ldr	r2, [pc, #40]	@ (1000025c <fault+0x6>)
	ldr r3, =__bss_start__
10000234:	4b0a      	ldr	r3, [pc, #40]	@ (10000260 <fault+0xa>)
	//r3 contains lenght of data to copy
	subs r3, r2
10000236:	1a9b      	subs	r3, r3, r2
	//If zero jump over the loop
    ble .data_init_loop_done
10000238:	dd03      	ble.n	10000242 <.data_init_loop_done>

1000023a <.data_init_loop>:
	

.data_init_loop:
	//decrease r3 by 4bytes because in single load store 4 bytes are copied
    subs r3, #4
1000023a:	3b04      	subs	r3, #4
    ldr r0, [r1,r3]
1000023c:	58c8      	ldr	r0, [r1, r3]
    str r0, [r2,r3]
1000023e:	50d0      	str	r0, [r2, r3]
	//branch until r3 is greater then zero
    bgt .data_init_loop
10000240:	dcfb      	bgt.n	1000023a <.data_init_loop>

10000242 <.data_init_loop_done>:

	//Initializing BSS
	//In C BSS represents statically allocated objects without an explicit initializer which are initialized to zero 
	//__bss_start__ represents start address of the bss section
	//__bss_end__ represents end address of the bss section
	ldr r1, =__bss_start__
10000242:	4907      	ldr	r1, [pc, #28]	@ (10000260 <fault+0xa>)
	ldr r2, =__bss_end__
10000244:	4a07      	ldr	r2, [pc, #28]	@ (10000264 <fault+0xe>)
	movs r0, 0
10000246:	2000      	movs	r0, #0
	subs r2, r1
10000248:	1a52      	subs	r2, r2, r1
	ble .bss_init_done
1000024a:	dd02      	ble.n	10000252 <.bss_init_done>

1000024c <.bss_init_loop>:
.bss_init_loop:
	//r2 is used as loop counter with 4bytes incrementation
	subs r2, #4
1000024c:	3a04      	subs	r2, #4
	str r0, [r1, r2]
1000024e:	5088      	str	r0, [r1, r2]
	bgt .bss_init_loop
10000250:	dcfc      	bgt.n	1000024c <.bss_init_loop>

10000252 <.bss_init_done>:
.bss_init_done:

	bl main
10000252:	f7ff ff67 	bl	10000124 <main>

10000256 <fault>:

.thumb_func
fault:
10000256:	e7fe      	b.n	10000256 <fault>
	ldr r1, =__etext
10000258:	100002f8 	.word	0x100002f8
	ldr r2, =__data_start__
1000025c:	20000000 	.word	0x20000000
	ldr r3, =__bss_start__
10000260:	20000008 	.word	0x20000008
	ldr r2, =__bss_end__
10000264:	20000010 	.word	0x20000010

10000268 <__udivsi3>:
10000268:	2900      	cmp	r1, #0
1000026a:	d034      	beq.n	100002d6 <.udivsi3_skip_div0_test+0x6a>

1000026c <.udivsi3_skip_div0_test>:
1000026c:	2301      	movs	r3, #1
1000026e:	2200      	movs	r2, #0
10000270:	b410      	push	{r4}
10000272:	4288      	cmp	r0, r1
10000274:	d32c      	bcc.n	100002d0 <.udivsi3_skip_div0_test+0x64>
10000276:	2401      	movs	r4, #1
10000278:	0724      	lsls	r4, r4, #28
1000027a:	42a1      	cmp	r1, r4
1000027c:	d204      	bcs.n	10000288 <.udivsi3_skip_div0_test+0x1c>
1000027e:	4281      	cmp	r1, r0
10000280:	d202      	bcs.n	10000288 <.udivsi3_skip_div0_test+0x1c>
10000282:	0109      	lsls	r1, r1, #4
10000284:	011b      	lsls	r3, r3, #4
10000286:	e7f8      	b.n	1000027a <.udivsi3_skip_div0_test+0xe>
10000288:	00e4      	lsls	r4, r4, #3
1000028a:	42a1      	cmp	r1, r4
1000028c:	d204      	bcs.n	10000298 <.udivsi3_skip_div0_test+0x2c>
1000028e:	4281      	cmp	r1, r0
10000290:	d202      	bcs.n	10000298 <.udivsi3_skip_div0_test+0x2c>
10000292:	0049      	lsls	r1, r1, #1
10000294:	005b      	lsls	r3, r3, #1
10000296:	e7f8      	b.n	1000028a <.udivsi3_skip_div0_test+0x1e>
10000298:	4288      	cmp	r0, r1
1000029a:	d301      	bcc.n	100002a0 <.udivsi3_skip_div0_test+0x34>
1000029c:	1a40      	subs	r0, r0, r1
1000029e:	431a      	orrs	r2, r3
100002a0:	084c      	lsrs	r4, r1, #1
100002a2:	42a0      	cmp	r0, r4
100002a4:	d302      	bcc.n	100002ac <.udivsi3_skip_div0_test+0x40>
100002a6:	1b00      	subs	r0, r0, r4
100002a8:	085c      	lsrs	r4, r3, #1
100002aa:	4322      	orrs	r2, r4
100002ac:	088c      	lsrs	r4, r1, #2
100002ae:	42a0      	cmp	r0, r4
100002b0:	d302      	bcc.n	100002b8 <.udivsi3_skip_div0_test+0x4c>
100002b2:	1b00      	subs	r0, r0, r4
100002b4:	089c      	lsrs	r4, r3, #2
100002b6:	4322      	orrs	r2, r4
100002b8:	08cc      	lsrs	r4, r1, #3
100002ba:	42a0      	cmp	r0, r4
100002bc:	d302      	bcc.n	100002c4 <.udivsi3_skip_div0_test+0x58>
100002be:	1b00      	subs	r0, r0, r4
100002c0:	08dc      	lsrs	r4, r3, #3
100002c2:	4322      	orrs	r2, r4
100002c4:	2800      	cmp	r0, #0
100002c6:	d003      	beq.n	100002d0 <.udivsi3_skip_div0_test+0x64>
100002c8:	091b      	lsrs	r3, r3, #4
100002ca:	d001      	beq.n	100002d0 <.udivsi3_skip_div0_test+0x64>
100002cc:	0909      	lsrs	r1, r1, #4
100002ce:	e7e3      	b.n	10000298 <.udivsi3_skip_div0_test+0x2c>
100002d0:	0010      	movs	r0, r2
100002d2:	bc10      	pop	{r4}
100002d4:	4770      	bx	lr
100002d6:	b501      	push	{r0, lr}
100002d8:	2000      	movs	r0, #0
100002da:	f000 f80b 	bl	100002f4 <__aeabi_idiv0>
100002de:	bd02      	pop	{r1, pc}

100002e0 <__aeabi_uidivmod>:
100002e0:	2900      	cmp	r1, #0
100002e2:	d0f8      	beq.n	100002d6 <.udivsi3_skip_div0_test+0x6a>
100002e4:	b503      	push	{r0, r1, lr}
100002e6:	f7ff ffc1 	bl	1000026c <.udivsi3_skip_div0_test>
100002ea:	bc0e      	pop	{r1, r2, r3}
100002ec:	4342      	muls	r2, r0
100002ee:	1a89      	subs	r1, r1, r2
100002f0:	4718      	bx	r3
100002f2:	46c0      	nop			@ (mov r8, r8)

100002f4 <__aeabi_idiv0>:
100002f4:	4770      	bx	lr
100002f6:	46c0      	nop			@ (mov r8, r8)
