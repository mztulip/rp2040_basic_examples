
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

10000100 <_ZL17interrupt_vectors>:
10000100:	20040000 10000325 100002cd 100002cd     ... %...........

10000110 <_Z41__static_initialization_and_destruction_0v>:

    public:

    test()
    {
        x = 123;
10000110:	4b01      	ldr	r3, [pc, #4]	@ (10000118 <_Z41__static_initialization_and_destruction_0v+0x8>)
10000112:	227b      	movs	r2, #123	@ 0x7b
10000114:	601a      	str	r2, [r3, #0]
        counter++;
        check_counter_overflow();
        check_counter_compare();
        process_led_dimming();
    }
10000116:	4770      	bx	lr
10000118:	20000008 	.word	0x20000008

1000011c <_Z5delayv>:
{
1000011c:	b082      	sub	sp, #8
    for (volatile uint32_t i = 0; i < 123456/8; ++i)
1000011e:	2300      	movs	r3, #0
10000120:	9301      	str	r3, [sp, #4]
10000122:	e002      	b.n	1000012a <_Z5delayv+0xe>
10000124:	9b01      	ldr	r3, [sp, #4]
10000126:	3301      	adds	r3, #1
10000128:	9301      	str	r3, [sp, #4]
1000012a:	9a01      	ldr	r2, [sp, #4]
1000012c:	4b02      	ldr	r3, [pc, #8]	@ (10000138 <_Z5delayv+0x1c>)
1000012e:	429a      	cmp	r2, r3
10000130:	d9f8      	bls.n	10000124 <_Z5delayv+0x8>
}
10000132:	b002      	add	sp, #8
10000134:	4770      	bx	lr
10000136:	46c0      	nop			@ (mov r8, r8)
10000138:	00003c47 	.word	0x00003c47

1000013c <_Z6failedv>:
{
1000013c:	b510      	push	{r4, lr}
        delay();
1000013e:	f7ff ffed 	bl	1000011c <_Z5delayv>
        GPIO_OUT_XOR |= 1 << 25;
10000142:	4a03      	ldr	r2, [pc, #12]	@ (10000150 <_Z6failedv+0x14>)
10000144:	6811      	ldr	r1, [r2, #0]
10000146:	2380      	movs	r3, #128	@ 0x80
10000148:	049b      	lsls	r3, r3, #18
1000014a:	430b      	orrs	r3, r1
1000014c:	6013      	str	r3, [r2, #0]
    while (true)
1000014e:	e7f6      	b.n	1000013e <_Z6failedv+0x2>
10000150:	d000001c 	.word	0xd000001c

10000154 <_Z6led_onv>:
    GPIO_OUT_SET |= 1 << 25;
10000154:	4a03      	ldr	r2, [pc, #12]	@ (10000164 <_Z6led_onv+0x10>)
10000156:	6811      	ldr	r1, [r2, #0]
10000158:	2380      	movs	r3, #128	@ 0x80
1000015a:	049b      	lsls	r3, r3, #18
1000015c:	430b      	orrs	r3, r1
1000015e:	6013      	str	r3, [r2, #0]
}
10000160:	4770      	bx	lr
10000162:	46c0      	nop			@ (mov r8, r8)
10000164:	d0000014 	.word	0xd0000014

10000168 <_Z7led_offv>:
    GPIO_OUT_CLR |= 1 << 25;
10000168:	4a03      	ldr	r2, [pc, #12]	@ (10000178 <_Z7led_offv+0x10>)
1000016a:	6811      	ldr	r1, [r2, #0]
1000016c:	2380      	movs	r3, #128	@ 0x80
1000016e:	049b      	lsls	r3, r3, #18
10000170:	430b      	orrs	r3, r1
10000172:	6013      	str	r3, [r2, #0]
}
10000174:	4770      	bx	lr
10000176:	46c0      	nop			@ (mov r8, r8)
10000178:	d0000018 	.word	0xd0000018

1000017c <_Z22check_counter_overflowv>:
{
1000017c:	b510      	push	{r4, lr}
    if (counter >= counter_max)
1000017e:	4b06      	ldr	r3, [pc, #24]	@ (10000198 <_Z22check_counter_overflowv+0x1c>)
10000180:	681a      	ldr	r2, [r3, #0]
10000182:	23fa      	movs	r3, #250	@ 0xfa
10000184:	005b      	lsls	r3, r3, #1
10000186:	429a      	cmp	r2, r3
10000188:	d200      	bcs.n	1000018c <_Z22check_counter_overflowv+0x10>
}
1000018a:	bd10      	pop	{r4, pc}
        counter = 0;
1000018c:	4b02      	ldr	r3, [pc, #8]	@ (10000198 <_Z22check_counter_overflowv+0x1c>)
1000018e:	2200      	movs	r2, #0
10000190:	601a      	str	r2, [r3, #0]
        led_on();
10000192:	f7ff ffdf 	bl	10000154 <_Z6led_onv>
}
10000196:	e7f8      	b.n	1000018a <_Z22check_counter_overflowv+0xe>
10000198:	20000010 	.word	0x20000010

1000019c <_Z21check_counter_comparev>:
{
1000019c:	b510      	push	{r4, lr}
    if(counter >= counter_compare_value)
1000019e:	4b05      	ldr	r3, [pc, #20]	@ (100001b4 <_Z21check_counter_comparev+0x18>)
100001a0:	681a      	ldr	r2, [r3, #0]
100001a2:	4b05      	ldr	r3, [pc, #20]	@ (100001b8 <_Z21check_counter_comparev+0x1c>)
100001a4:	681b      	ldr	r3, [r3, #0]
100001a6:	429a      	cmp	r2, r3
100001a8:	d200      	bcs.n	100001ac <_Z21check_counter_comparev+0x10>
}
100001aa:	bd10      	pop	{r4, pc}
        led_off();
100001ac:	f7ff ffdc 	bl	10000168 <_Z7led_offv>
}
100001b0:	e7fb      	b.n	100001aa <_Z21check_counter_comparev+0xe>
100001b2:	46c0      	nop			@ (mov r8, r8)
100001b4:	20000010 	.word	0x20000010
100001b8:	20000004 	.word	0x20000004

100001bc <_Z13set_pwm_valuem>:
    if(setpoint > counter_max)
100001bc:	23fa      	movs	r3, #250	@ 0xfa
100001be:	005b      	lsls	r3, r3, #1
100001c0:	4298      	cmp	r0, r3
100001c2:	d900      	bls.n	100001c6 <_Z13set_pwm_valuem+0xa>
        setpoint = counter_max;
100001c4:	0018      	movs	r0, r3
    counter_compare_value = setpoint;
100001c6:	4b01      	ldr	r3, [pc, #4]	@ (100001cc <_Z13set_pwm_valuem+0x10>)
100001c8:	6018      	str	r0, [r3, #0]
}
100001ca:	4770      	bx	lr
100001cc:	20000004 	.word	0x20000004

100001d0 <_Z19process_led_dimmingv>:
{
100001d0:	b510      	push	{r4, lr}
    if(counter%100 == 0)
100001d2:	4b10      	ldr	r3, [pc, #64]	@ (10000214 <_Z19process_led_dimmingv+0x44>)
100001d4:	6818      	ldr	r0, [r3, #0]
100001d6:	2164      	movs	r1, #100	@ 0x64
100001d8:	f000 f90e 	bl	100003f8 <__aeabi_uidivmod>
100001dc:	2900      	cmp	r1, #0
100001de:	d105      	bne.n	100001ec <_Z19process_led_dimmingv+0x1c>
        pwm_setpoint+=inc_step;
100001e0:	4b0d      	ldr	r3, [pc, #52]	@ (10000218 <_Z19process_led_dimmingv+0x48>)
100001e2:	6819      	ldr	r1, [r3, #0]
100001e4:	4a0d      	ldr	r2, [pc, #52]	@ (1000021c <_Z19process_led_dimmingv+0x4c>)
100001e6:	6813      	ldr	r3, [r2, #0]
100001e8:	185b      	adds	r3, r3, r1
100001ea:	6013      	str	r3, [r2, #0]
    if(pwm_setpoint >= counter_max)
100001ec:	4b0b      	ldr	r3, [pc, #44]	@ (1000021c <_Z19process_led_dimmingv+0x4c>)
100001ee:	6818      	ldr	r0, [r3, #0]
100001f0:	23fa      	movs	r3, #250	@ 0xfa
100001f2:	005b      	lsls	r3, r3, #1
100001f4:	4298      	cmp	r0, r3
100001f6:	db06      	blt.n	10000206 <_Z19process_led_dimmingv+0x36>
        inc_step=-1;
100001f8:	4b07      	ldr	r3, [pc, #28]	@ (10000218 <_Z19process_led_dimmingv+0x48>)
100001fa:	2201      	movs	r2, #1
100001fc:	4252      	negs	r2, r2
100001fe:	601a      	str	r2, [r3, #0]
    set_pwm_value(pwm_setpoint);
10000200:	f7ff ffdc 	bl	100001bc <_Z13set_pwm_valuem>
}
10000204:	bd10      	pop	{r4, pc}
    else if(pwm_setpoint <= 0)
10000206:	2800      	cmp	r0, #0
10000208:	dcfa      	bgt.n	10000200 <_Z19process_led_dimmingv+0x30>
        inc_step=1;
1000020a:	4b03      	ldr	r3, [pc, #12]	@ (10000218 <_Z19process_led_dimmingv+0x48>)
1000020c:	2201      	movs	r2, #1
1000020e:	601a      	str	r2, [r3, #0]
10000210:	e7f6      	b.n	10000200 <_Z19process_led_dimmingv+0x30>
10000212:	46c0      	nop			@ (mov r8, r8)
10000214:	20000010 	.word	0x20000010
10000218:	20000000 	.word	0x20000000
1000021c:	2000000c 	.word	0x2000000c

10000220 <_Z13init_led_gpiov>:
    RESETS_BASE_REG &= ~(1 << 5);
10000220:	4a09      	ldr	r2, [pc, #36]	@ (10000248 <_Z13init_led_gpiov+0x28>)
10000222:	6813      	ldr	r3, [r2, #0]
10000224:	2120      	movs	r1, #32
10000226:	438b      	bics	r3, r1
10000228:	6013      	str	r3, [r2, #0]
    while (!( RESET_DONE & (1 << 5)));
1000022a:	4b08      	ldr	r3, [pc, #32]	@ (1000024c <_Z13init_led_gpiov+0x2c>)
1000022c:	681b      	ldr	r3, [r3, #0]
1000022e:	069b      	lsls	r3, r3, #26
10000230:	d5fb      	bpl.n	1000022a <_Z13init_led_gpiov+0xa>
    GPIO25_CTRL = 5;
10000232:	4b07      	ldr	r3, [pc, #28]	@ (10000250 <_Z13init_led_gpiov+0x30>)
10000234:	2205      	movs	r2, #5
10000236:	601a      	str	r2, [r3, #0]
    GPIO_OE_SET |= 1 << 25;
10000238:	4a06      	ldr	r2, [pc, #24]	@ (10000254 <_Z13init_led_gpiov+0x34>)
1000023a:	6811      	ldr	r1, [r2, #0]
1000023c:	2380      	movs	r3, #128	@ 0x80
1000023e:	049b      	lsls	r3, r3, #18
10000240:	430b      	orrs	r3, r1
10000242:	6013      	str	r3, [r2, #0]
}
10000244:	4770      	bx	lr
10000246:	46c0      	nop			@ (mov r8, r8)
10000248:	4000c000 	.word	0x4000c000
1000024c:	4000c008 	.word	0x4000c008
10000250:	400140cc 	.word	0x400140cc
10000254:	d0000024 	.word	0xd0000024

10000258 <_Z19check_startup_initsv>:
{
10000258:	b510      	push	{r4, lr}
    if(&__StackTop != (uint32_t*)0x20040000)
1000025a:	4b0c      	ldr	r3, [pc, #48]	@ (1000028c <_Z19check_startup_initsv+0x34>)
1000025c:	4a0c      	ldr	r2, [pc, #48]	@ (10000290 <_Z19check_startup_initsv+0x38>)
1000025e:	4293      	cmp	r3, r2
10000260:	d10d      	bne.n	1000027e <_Z19check_startup_initsv+0x26>
    if (counter != 0)
10000262:	4b0c      	ldr	r3, [pc, #48]	@ (10000294 <_Z19check_startup_initsv+0x3c>)
10000264:	681b      	ldr	r3, [r3, #0]
10000266:	2b00      	cmp	r3, #0
10000268:	d10b      	bne.n	10000282 <_Z19check_startup_initsv+0x2a>
    if (counter_compare_value != 100)
1000026a:	4b0b      	ldr	r3, [pc, #44]	@ (10000298 <_Z19check_startup_initsv+0x40>)
1000026c:	681b      	ldr	r3, [r3, #0]
1000026e:	2b64      	cmp	r3, #100	@ 0x64
10000270:	d109      	bne.n	10000286 <_Z19check_startup_initsv+0x2e>
        if(x == 123)
10000272:	4b0a      	ldr	r3, [pc, #40]	@ (1000029c <_Z19check_startup_initsv+0x44>)
10000274:	681b      	ldr	r3, [r3, #0]
10000276:	2b7b      	cmp	r3, #123	@ 0x7b
10000278:	d007      	beq.n	1000028a <_Z19check_startup_initsv+0x32>
        failed();
1000027a:	f7ff ff5f 	bl	1000013c <_Z6failedv>
        failed();
1000027e:	f7ff ff5d 	bl	1000013c <_Z6failedv>
        failed();
10000282:	f7ff ff5b 	bl	1000013c <_Z6failedv>
        failed();
10000286:	f7ff ff59 	bl	1000013c <_Z6failedv>
}
1000028a:	bd10      	pop	{r4, pc}
1000028c:	20040000 	.word	0x20040000
10000290:	20040000 	.word	0x20040000
10000294:	20000010 	.word	0x20000010
10000298:	20000004 	.word	0x20000004
1000029c:	20000008 	.word	0x20000008

100002a0 <main>:
{
100002a0:	b510      	push	{r4, lr}
    init_led_gpio();
100002a2:	f7ff ffbd 	bl	10000220 <_Z13init_led_gpiov>
    check_startup_inits();
100002a6:	f7ff ffd7 	bl	10000258 <_Z19check_startup_initsv>
        counter++;
100002aa:	4a05      	ldr	r2, [pc, #20]	@ (100002c0 <main+0x20>)
100002ac:	6813      	ldr	r3, [r2, #0]
100002ae:	3301      	adds	r3, #1
100002b0:	6013      	str	r3, [r2, #0]
        check_counter_overflow();
100002b2:	f7ff ff63 	bl	1000017c <_Z22check_counter_overflowv>
        check_counter_compare();
100002b6:	f7ff ff71 	bl	1000019c <_Z21check_counter_comparev>
        process_led_dimming();
100002ba:	f7ff ff89 	bl	100001d0 <_Z19process_led_dimmingv>
    while (true)
100002be:	e7f4      	b.n	100002aa <main+0xa>
100002c0:	20000010 	.word	0x20000010

100002c4 <_GLOBAL__sub_I_GPIO_OUT_XOR>:
100002c4:	b510      	push	{r4, lr}
100002c6:	f7ff ff23 	bl	10000110 <_Z41__static_initialization_and_destruction_0v>
100002ca:	bd10      	pop	{r4, pc}

100002cc <Default_Handler>:
extern "C" void(*__init_array_end [])(void);

//extern "C" makes a function-name in C++ have C linkage (compiler does not mangle the name)
extern "C" void Default_Handler(void)
{
     while(1)
100002cc:	e7fe      	b.n	100002cc <Default_Handler>

100002ce <_ZSt8for_eachIPPFvvEZ13Reset_HandlervEUlS1_E_ET0_T_S5_S4_>:
   *  If @p __f has a return value it is ignored.
  */
  template<typename _InputIterator, typename _Function>
    _GLIBCXX20_CONSTEXPR
    _Function
    for_each(_InputIterator __first, _InputIterator __last, _Function __f)
100002ce:	b570      	push	{r4, r5, r6, lr}
100002d0:	0004      	movs	r4, r0
100002d2:	000d      	movs	r5, r1
    {
      // concept requirements
      __glibcxx_function_requires(_InputIteratorConcept<_InputIterator>)
      __glibcxx_requires_valid_range(__first, __last);
      for (; __first != __last; ++__first)
100002d4:	e001      	b.n	100002da <_ZSt8for_eachIPPFvvEZ13Reset_HandlervEUlS1_E_ET0_T_S5_S4_+0xc>
	__f(*__first);
100002d6:	cc08      	ldmia	r4!, {r3}
  //    a single pre-initialization array for the executable or shared object containing the section.
  //I do not know where and when preinit is used.
  // Probably will be always empty
  std::for_each( __preinit_array_start,
                __preinit_array_end, 
                [](void (*f) (void)) {f();});
100002d8:	4798      	blx	r3
      for (; __first != __last; ++__first)
100002da:	42ac      	cmp	r4, r5
100002dc:	d1fb      	bne.n	100002d6 <_ZSt8for_eachIPPFvvEZ13Reset_HandlervEUlS1_E_ET0_T_S5_S4_+0x8>
      return __f; // N.B. [alg.foreach] says std::move(f) but it's redundant.
    }
100002de:	2000      	movs	r0, #0
100002e0:	bd70      	pop	{r4, r5, r6, pc}

100002e2 <_ZSt8for_eachIPPFvvEZ13Reset_HandlervEUlS1_E0_ET0_T_S5_S4_>:
    for_each(_InputIterator __first, _InputIterator __last, _Function __f)
100002e2:	b570      	push	{r4, r5, r6, lr}
100002e4:	0004      	movs	r4, r0
100002e6:	000d      	movs	r5, r1
      for (; __first != __last; ++__first)
100002e8:	e001      	b.n	100002ee <_ZSt8for_eachIPPFvvEZ13Reset_HandlervEUlS1_E0_ET0_T_S5_S4_+0xc>
	__f(*__first);
100002ea:	cc08      	ldmia	r4!, {r3}
  //   This section holds an array of function pointers that 
  //   contributes to a single initialization array for the executable 
  //   or shared object containing the section.
  std::for_each( __init_array_start,
                  __init_array_end, 
                  [](void (*f) (void)) {f();});
100002ec:	4798      	blx	r3
      for (; __first != __last; ++__first)
100002ee:	42ac      	cmp	r4, r5
100002f0:	d1fb      	bne.n	100002ea <_ZSt8for_eachIPPFvvEZ13Reset_HandlervEUlS1_E0_ET0_T_S5_S4_+0x8>
    }
100002f2:	2000      	movs	r0, #0
100002f4:	bd70      	pop	{r4, r5, r6, pc}

100002f6 <_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mImmEEPT0_PT_S6_S4_>:
    struct __copy_move<_IsMove, true, random_access_iterator_tag>
    {
      template<typename _Tp, typename _Up>
	_GLIBCXX20_CONSTEXPR
	static _Up*
	__copy_m(_Tp* __first, _Tp* __last, _Up* __result)
100002f6:	b570      	push	{r4, r5, r6, lr}
100002f8:	0014      	movs	r4, r2
	{
	  const ptrdiff_t _Num = __last - __first;
100002fa:	1a0d      	subs	r5, r1, r0
	  if (__builtin_expect(_Num > 1, true))
100002fc:	2301      	movs	r3, #1
100002fe:	2d04      	cmp	r5, #4
10000300:	dc00      	bgt.n	10000304 <_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mImmEEPT0_PT_S6_S4_+0xe>
10000302:	2300      	movs	r3, #0
10000304:	b2db      	uxtb	r3, r3
10000306:	2b00      	cmp	r3, #0
10000308:	d006      	beq.n	10000318 <_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mImmEEPT0_PT_S6_S4_+0x22>
	    __builtin_memmove(__result, __first, sizeof(_Tp) * _Num);
1000030a:	002a      	movs	r2, r5
1000030c:	0001      	movs	r1, r0
1000030e:	0020      	movs	r0, r4
10000310:	f000 f87e 	bl	10000410 <memmove>
	  else if (_Num == 1)
	    std::__copy_move<_IsMove, false, random_access_iterator_tag>::
	      __assign_one(__result, __first);
	  return __result + _Num;
10000314:	1960      	adds	r0, r4, r5
	}
10000316:	bd70      	pop	{r4, r5, r6, pc}
	  else if (_Num == 1)
10000318:	2d04      	cmp	r5, #4
1000031a:	d1fb      	bne.n	10000314 <_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mImmEEPT0_PT_S6_S4_+0x1e>
	{ *__to = *__from; }
1000031c:	6803      	ldr	r3, [r0, #0]
1000031e:	6023      	str	r3, [r4, #0]
10000320:	e7f8      	b.n	10000314 <_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mImmEEPT0_PT_S6_S4_+0x1e>
	...

10000324 <_Z13Reset_Handlerv>:
{
10000324:	b510      	push	{r4, lr}
  auto data_length = &__data_end__ - &__data_start__;
10000326:	4b0d      	ldr	r3, [pc, #52]	@ (1000035c <_Z13Reset_Handlerv+0x38>)
10000328:	4a0d      	ldr	r2, [pc, #52]	@ (10000360 <_Z13Reset_Handlerv+0x3c>)
1000032a:	1a99      	subs	r1, r3, r2
  auto data_source_end = &__start_data_at_flash + data_length;
1000032c:	480d      	ldr	r0, [pc, #52]	@ (10000364 <_Z13Reset_Handlerv+0x40>)
1000032e:	1809      	adds	r1, r1, r0
      if (std::is_constant_evaluated())
	return std::__copy_move<_IsMove, false, _Category>::
	  __copy_m(__first, __last, __result);
#endif
      return std::__copy_move<_IsMove, __memcpyable<_OI, _II>::__value,
			      _Category>::__copy_m(__first, __last, __result);
10000330:	f7ff ffe1 	bl	100002f6 <_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mImmEEPT0_PT_S6_S4_>
    __gnu_cxx::__enable_if<__is_scalar<_Tp>::__value, void>::__type
    __fill_a1(_ForwardIterator __first, _ForwardIterator __last,
	      const _Tp& __value)
    {
      const _Tp __tmp = __value;
      for (; __first != __last; ++__first)
10000334:	4b0c      	ldr	r3, [pc, #48]	@ (10000368 <_Z13Reset_Handlerv+0x44>)
10000336:	e001      	b.n	1000033c <_Z13Reset_Handlerv+0x18>
	*__first = __tmp;
10000338:	2200      	movs	r2, #0
1000033a:	c304      	stmia	r3!, {r2}
      for (; __first != __last; ++__first)
1000033c:	4a0b      	ldr	r2, [pc, #44]	@ (1000036c <_Z13Reset_Handlerv+0x48>)
1000033e:	4293      	cmp	r3, r2
10000340:	d1fa      	bne.n	10000338 <_Z13Reset_Handlerv+0x14>
  std::for_each( __preinit_array_start,
10000342:	490b      	ldr	r1, [pc, #44]	@ (10000370 <_Z13Reset_Handlerv+0x4c>)
10000344:	480b      	ldr	r0, [pc, #44]	@ (10000374 <_Z13Reset_Handlerv+0x50>)
10000346:	2200      	movs	r2, #0
10000348:	f7ff ffc1 	bl	100002ce <_ZSt8for_eachIPPFvvEZ13Reset_HandlervEUlS1_E_ET0_T_S5_S4_>
  std::for_each( __init_array_start,
1000034c:	490a      	ldr	r1, [pc, #40]	@ (10000378 <_Z13Reset_Handlerv+0x54>)
1000034e:	480b      	ldr	r0, [pc, #44]	@ (1000037c <_Z13Reset_Handlerv+0x58>)
10000350:	2200      	movs	r2, #0
10000352:	f7ff ffc6 	bl	100002e2 <_ZSt8for_eachIPPFvvEZ13Reset_HandlervEUlS1_E0_ET0_T_S5_S4_>

  main();
10000356:	f7ff ffa3 	bl	100002a0 <main>
  // .fini_array
  //   This section holds an array of function pointers 
  //   that contributes to a single termination array for 
  //   the executable or shared object containing the section.
  // Ececution of this part is not necessary because main should never return
  for (;;);
1000035a:	e7fe      	b.n	1000035a <_Z13Reset_Handlerv+0x36>
1000035c:	20000008 	.word	0x20000008
10000360:	20000000 	.word	0x20000000
10000364:	100004d8 	.word	0x100004d8
10000368:	20000008 	.word	0x20000008
1000036c:	20000014 	.word	0x20000014
10000370:	100004d4 	.word	0x100004d4
10000374:	100004d4 	.word	0x100004d4
10000378:	100004d8 	.word	0x100004d8
1000037c:	100004d4 	.word	0x100004d4

10000380 <__udivsi3>:
10000380:	2900      	cmp	r1, #0
10000382:	d034      	beq.n	100003ee <.udivsi3_skip_div0_test+0x6a>

10000384 <.udivsi3_skip_div0_test>:
10000384:	2301      	movs	r3, #1
10000386:	2200      	movs	r2, #0
10000388:	b410      	push	{r4}
1000038a:	4288      	cmp	r0, r1
1000038c:	d32c      	bcc.n	100003e8 <.udivsi3_skip_div0_test+0x64>
1000038e:	2401      	movs	r4, #1
10000390:	0724      	lsls	r4, r4, #28
10000392:	42a1      	cmp	r1, r4
10000394:	d204      	bcs.n	100003a0 <.udivsi3_skip_div0_test+0x1c>
10000396:	4281      	cmp	r1, r0
10000398:	d202      	bcs.n	100003a0 <.udivsi3_skip_div0_test+0x1c>
1000039a:	0109      	lsls	r1, r1, #4
1000039c:	011b      	lsls	r3, r3, #4
1000039e:	e7f8      	b.n	10000392 <.udivsi3_skip_div0_test+0xe>
100003a0:	00e4      	lsls	r4, r4, #3
100003a2:	42a1      	cmp	r1, r4
100003a4:	d204      	bcs.n	100003b0 <.udivsi3_skip_div0_test+0x2c>
100003a6:	4281      	cmp	r1, r0
100003a8:	d202      	bcs.n	100003b0 <.udivsi3_skip_div0_test+0x2c>
100003aa:	0049      	lsls	r1, r1, #1
100003ac:	005b      	lsls	r3, r3, #1
100003ae:	e7f8      	b.n	100003a2 <.udivsi3_skip_div0_test+0x1e>
100003b0:	4288      	cmp	r0, r1
100003b2:	d301      	bcc.n	100003b8 <.udivsi3_skip_div0_test+0x34>
100003b4:	1a40      	subs	r0, r0, r1
100003b6:	431a      	orrs	r2, r3
100003b8:	084c      	lsrs	r4, r1, #1
100003ba:	42a0      	cmp	r0, r4
100003bc:	d302      	bcc.n	100003c4 <.udivsi3_skip_div0_test+0x40>
100003be:	1b00      	subs	r0, r0, r4
100003c0:	085c      	lsrs	r4, r3, #1
100003c2:	4322      	orrs	r2, r4
100003c4:	088c      	lsrs	r4, r1, #2
100003c6:	42a0      	cmp	r0, r4
100003c8:	d302      	bcc.n	100003d0 <.udivsi3_skip_div0_test+0x4c>
100003ca:	1b00      	subs	r0, r0, r4
100003cc:	089c      	lsrs	r4, r3, #2
100003ce:	4322      	orrs	r2, r4
100003d0:	08cc      	lsrs	r4, r1, #3
100003d2:	42a0      	cmp	r0, r4
100003d4:	d302      	bcc.n	100003dc <.udivsi3_skip_div0_test+0x58>
100003d6:	1b00      	subs	r0, r0, r4
100003d8:	08dc      	lsrs	r4, r3, #3
100003da:	4322      	orrs	r2, r4
100003dc:	2800      	cmp	r0, #0
100003de:	d003      	beq.n	100003e8 <.udivsi3_skip_div0_test+0x64>
100003e0:	091b      	lsrs	r3, r3, #4
100003e2:	d001      	beq.n	100003e8 <.udivsi3_skip_div0_test+0x64>
100003e4:	0909      	lsrs	r1, r1, #4
100003e6:	e7e3      	b.n	100003b0 <.udivsi3_skip_div0_test+0x2c>
100003e8:	0010      	movs	r0, r2
100003ea:	bc10      	pop	{r4}
100003ec:	4770      	bx	lr
100003ee:	b501      	push	{r0, lr}
100003f0:	2000      	movs	r0, #0
100003f2:	f000 f80b 	bl	1000040c <__aeabi_idiv0>
100003f6:	bd02      	pop	{r1, pc}

100003f8 <__aeabi_uidivmod>:
100003f8:	2900      	cmp	r1, #0
100003fa:	d0f8      	beq.n	100003ee <.udivsi3_skip_div0_test+0x6a>
100003fc:	b503      	push	{r0, r1, lr}
100003fe:	f7ff ffc1 	bl	10000384 <.udivsi3_skip_div0_test>
10000402:	bc0e      	pop	{r1, r2, r3}
10000404:	4342      	muls	r2, r0
10000406:	1a89      	subs	r1, r1, r2
10000408:	4718      	bx	r3
1000040a:	46c0      	nop			@ (mov r8, r8)

1000040c <__aeabi_idiv0>:
1000040c:	4770      	bx	lr
1000040e:	46c0      	nop			@ (mov r8, r8)

10000410 <memmove>:
10000410:	b5f0      	push	{r4, r5, r6, r7, lr}
10000412:	46ce      	mov	lr, r9
10000414:	4647      	mov	r7, r8
10000416:	b580      	push	{r7, lr}
10000418:	4288      	cmp	r0, r1
1000041a:	d90d      	bls.n	10000438 <memmove+0x28>
1000041c:	188b      	adds	r3, r1, r2
1000041e:	4298      	cmp	r0, r3
10000420:	d20a      	bcs.n	10000438 <memmove+0x28>
10000422:	1e53      	subs	r3, r2, #1
10000424:	2a00      	cmp	r2, #0
10000426:	d003      	beq.n	10000430 <memmove+0x20>
10000428:	5cca      	ldrb	r2, [r1, r3]
1000042a:	54c2      	strb	r2, [r0, r3]
1000042c:	3b01      	subs	r3, #1
1000042e:	d2fb      	bcs.n	10000428 <memmove+0x18>
10000430:	bcc0      	pop	{r6, r7}
10000432:	46b9      	mov	r9, r7
10000434:	46b0      	mov	r8, r6
10000436:	bdf0      	pop	{r4, r5, r6, r7, pc}
10000438:	2a0f      	cmp	r2, #15
1000043a:	d80b      	bhi.n	10000454 <memmove+0x44>
1000043c:	0005      	movs	r5, r0
1000043e:	1e56      	subs	r6, r2, #1
10000440:	2a00      	cmp	r2, #0
10000442:	d0f5      	beq.n	10000430 <memmove+0x20>
10000444:	2300      	movs	r3, #0
10000446:	5ccc      	ldrb	r4, [r1, r3]
10000448:	001a      	movs	r2, r3
1000044a:	54ec      	strb	r4, [r5, r3]
1000044c:	3301      	adds	r3, #1
1000044e:	4296      	cmp	r6, r2
10000450:	d1f9      	bne.n	10000446 <memmove+0x36>
10000452:	e7ed      	b.n	10000430 <memmove+0x20>
10000454:	0003      	movs	r3, r0
10000456:	430b      	orrs	r3, r1
10000458:	4688      	mov	r8, r1
1000045a:	079b      	lsls	r3, r3, #30
1000045c:	d134      	bne.n	100004c8 <memmove+0xb8>
1000045e:	2610      	movs	r6, #16
10000460:	0017      	movs	r7, r2
10000462:	46b1      	mov	r9, r6
10000464:	000c      	movs	r4, r1
10000466:	0003      	movs	r3, r0
10000468:	3f10      	subs	r7, #16
1000046a:	093f      	lsrs	r7, r7, #4
1000046c:	013f      	lsls	r7, r7, #4
1000046e:	19c5      	adds	r5, r0, r7
10000470:	44a9      	add	r9, r5
10000472:	6826      	ldr	r6, [r4, #0]
10000474:	601e      	str	r6, [r3, #0]
10000476:	6866      	ldr	r6, [r4, #4]
10000478:	605e      	str	r6, [r3, #4]
1000047a:	68a6      	ldr	r6, [r4, #8]
1000047c:	609e      	str	r6, [r3, #8]
1000047e:	68e6      	ldr	r6, [r4, #12]
10000480:	3410      	adds	r4, #16
10000482:	60de      	str	r6, [r3, #12]
10000484:	001e      	movs	r6, r3
10000486:	3310      	adds	r3, #16
10000488:	42ae      	cmp	r6, r5
1000048a:	d1f2      	bne.n	10000472 <memmove+0x62>
1000048c:	19cf      	adds	r7, r1, r7
1000048e:	0039      	movs	r1, r7
10000490:	230f      	movs	r3, #15
10000492:	260c      	movs	r6, #12
10000494:	3110      	adds	r1, #16
10000496:	468c      	mov	ip, r1
10000498:	4013      	ands	r3, r2
1000049a:	4216      	tst	r6, r2
1000049c:	d017      	beq.n	100004ce <memmove+0xbe>
1000049e:	4644      	mov	r4, r8
100004a0:	3b04      	subs	r3, #4
100004a2:	089b      	lsrs	r3, r3, #2
100004a4:	009b      	lsls	r3, r3, #2
100004a6:	18ff      	adds	r7, r7, r3
100004a8:	3714      	adds	r7, #20
100004aa:	1b06      	subs	r6, r0, r4
100004ac:	680c      	ldr	r4, [r1, #0]
100004ae:	198d      	adds	r5, r1, r6
100004b0:	3104      	adds	r1, #4
100004b2:	602c      	str	r4, [r5, #0]
100004b4:	42b9      	cmp	r1, r7
100004b6:	d1f9      	bne.n	100004ac <memmove+0x9c>
100004b8:	4661      	mov	r1, ip
100004ba:	3304      	adds	r3, #4
100004bc:	1859      	adds	r1, r3, r1
100004be:	444b      	add	r3, r9
100004c0:	001d      	movs	r5, r3
100004c2:	2303      	movs	r3, #3
100004c4:	401a      	ands	r2, r3
100004c6:	e7ba      	b.n	1000043e <memmove+0x2e>
100004c8:	0005      	movs	r5, r0
100004ca:	1e56      	subs	r6, r2, #1
100004cc:	e7ba      	b.n	10000444 <memmove+0x34>
100004ce:	464d      	mov	r5, r9
100004d0:	001a      	movs	r2, r3
100004d2:	e7b4      	b.n	1000043e <memmove+0x2e>
