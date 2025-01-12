
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
10000100:	20040000 10000319 100002c1 100002c1     ... ............

10000110 <_Z41__static_initialization_and_destruction_0v>:

    public:

    test()
    {
        x = 123;
10000110:	4b01      	ldr	r3, [pc, #4]	@ (10000118 <_Z41__static_initialization_and_destruction_0v+0x8>)
10000112:	227b      	movs	r2, #123	@ 0x7b
10000114:	601a      	str	r2, [r3, #0]
        counter++;
        check_counter_overflow(blue_led);
        check_counter_compare(blue_led);
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

10000154 <_Z13set_pwm_valuem>:
    if(setpoint > counter_max)
10000154:	23fa      	movs	r3, #250	@ 0xfa
10000156:	005b      	lsls	r3, r3, #1
10000158:	4298      	cmp	r0, r3
1000015a:	d900      	bls.n	1000015e <_Z13set_pwm_valuem+0xa>
        setpoint = counter_max;
1000015c:	0018      	movs	r0, r3
    counter_compare_value = setpoint;
1000015e:	4b01      	ldr	r3, [pc, #4]	@ (10000164 <_Z13set_pwm_valuem+0x10>)
10000160:	6018      	str	r0, [r3, #0]
}
10000162:	4770      	bx	lr
10000164:	20000004 	.word	0x20000004

10000168 <_Z19process_led_dimmingv>:
{
10000168:	b510      	push	{r4, lr}
    if(counter%100 == 0)
1000016a:	4b10      	ldr	r3, [pc, #64]	@ (100001ac <_Z19process_led_dimmingv+0x44>)
1000016c:	6818      	ldr	r0, [r3, #0]
1000016e:	2164      	movs	r1, #100	@ 0x64
10000170:	f000 f93c 	bl	100003ec <__aeabi_uidivmod>
10000174:	2900      	cmp	r1, #0
10000176:	d105      	bne.n	10000184 <_Z19process_led_dimmingv+0x1c>
        pwm_setpoint+=inc_step;
10000178:	4b0d      	ldr	r3, [pc, #52]	@ (100001b0 <_Z19process_led_dimmingv+0x48>)
1000017a:	6819      	ldr	r1, [r3, #0]
1000017c:	4a0d      	ldr	r2, [pc, #52]	@ (100001b4 <_Z19process_led_dimmingv+0x4c>)
1000017e:	6813      	ldr	r3, [r2, #0]
10000180:	185b      	adds	r3, r3, r1
10000182:	6013      	str	r3, [r2, #0]
    if(pwm_setpoint >= counter_max)
10000184:	4b0b      	ldr	r3, [pc, #44]	@ (100001b4 <_Z19process_led_dimmingv+0x4c>)
10000186:	6818      	ldr	r0, [r3, #0]
10000188:	23fa      	movs	r3, #250	@ 0xfa
1000018a:	005b      	lsls	r3, r3, #1
1000018c:	4298      	cmp	r0, r3
1000018e:	db06      	blt.n	1000019e <_Z19process_led_dimmingv+0x36>
        inc_step=-1;
10000190:	4b07      	ldr	r3, [pc, #28]	@ (100001b0 <_Z19process_led_dimmingv+0x48>)
10000192:	2201      	movs	r2, #1
10000194:	4252      	negs	r2, r2
10000196:	601a      	str	r2, [r3, #0]
    set_pwm_value(pwm_setpoint);
10000198:	f7ff ffdc 	bl	10000154 <_Z13set_pwm_valuem>
}
1000019c:	bd10      	pop	{r4, pc}
    else if(pwm_setpoint <= 0)
1000019e:	2800      	cmp	r0, #0
100001a0:	dcfa      	bgt.n	10000198 <_Z19process_led_dimmingv+0x30>
        inc_step=1;
100001a2:	4b03      	ldr	r3, [pc, #12]	@ (100001b0 <_Z19process_led_dimmingv+0x48>)
100001a4:	2201      	movs	r2, #1
100001a6:	601a      	str	r2, [r3, #0]
100001a8:	e7f6      	b.n	10000198 <_Z19process_led_dimmingv+0x30>
100001aa:	46c0      	nop			@ (mov r8, r8)
100001ac:	20000010 	.word	0x20000010
100001b0:	20000000 	.word	0x20000000
100001b4:	2000000c 	.word	0x2000000c

100001b8 <_Z13init_led_gpiov>:
    RESETS_BASE_REG &= ~(1 << 5);
100001b8:	4a09      	ldr	r2, [pc, #36]	@ (100001e0 <_Z13init_led_gpiov+0x28>)
100001ba:	6813      	ldr	r3, [r2, #0]
100001bc:	2120      	movs	r1, #32
100001be:	438b      	bics	r3, r1
100001c0:	6013      	str	r3, [r2, #0]
    while (!( RESET_DONE & (1 << 5)));
100001c2:	4b08      	ldr	r3, [pc, #32]	@ (100001e4 <_Z13init_led_gpiov+0x2c>)
100001c4:	681b      	ldr	r3, [r3, #0]
100001c6:	069b      	lsls	r3, r3, #26
100001c8:	d5fb      	bpl.n	100001c2 <_Z13init_led_gpiov+0xa>
    GPIO25_CTRL = 5;
100001ca:	4b07      	ldr	r3, [pc, #28]	@ (100001e8 <_Z13init_led_gpiov+0x30>)
100001cc:	2205      	movs	r2, #5
100001ce:	601a      	str	r2, [r3, #0]
    GPIO_OE_SET |= 1 << 25;
100001d0:	4a06      	ldr	r2, [pc, #24]	@ (100001ec <_Z13init_led_gpiov+0x34>)
100001d2:	6811      	ldr	r1, [r2, #0]
100001d4:	2380      	movs	r3, #128	@ 0x80
100001d6:	049b      	lsls	r3, r3, #18
100001d8:	430b      	orrs	r3, r1
100001da:	6013      	str	r3, [r2, #0]
}
100001dc:	4770      	bx	lr
100001de:	46c0      	nop			@ (mov r8, r8)
100001e0:	4000c000 	.word	0x4000c000
100001e4:	4000c008 	.word	0x4000c008
100001e8:	400140cc 	.word	0x400140cc
100001ec:	d0000024 	.word	0xd0000024

100001f0 <_Z22check_counter_overflowR3led>:
    if (counter >= counter_max)
100001f0:	4b07      	ldr	r3, [pc, #28]	@ (10000210 <_Z22check_counter_overflowR3led+0x20>)
100001f2:	681a      	ldr	r2, [r3, #0]
100001f4:	23fa      	movs	r3, #250	@ 0xfa
100001f6:	005b      	lsls	r3, r3, #1
100001f8:	429a      	cmp	r2, r3
100001fa:	d308      	bcc.n	1000020e <_Z22check_counter_overflowR3led+0x1e>
        counter = 0;
100001fc:	4b04      	ldr	r3, [pc, #16]	@ (10000210 <_Z22check_counter_overflowR3led+0x20>)
100001fe:	2200      	movs	r2, #0
10000200:	601a      	str	r2, [r3, #0]
        GPIO_OUT_SET |= 1 << 25;
10000202:	4a04      	ldr	r2, [pc, #16]	@ (10000214 <_Z22check_counter_overflowR3led+0x24>)
10000204:	6811      	ldr	r1, [r2, #0]
10000206:	2380      	movs	r3, #128	@ 0x80
10000208:	049b      	lsls	r3, r3, #18
1000020a:	430b      	orrs	r3, r1
1000020c:	6013      	str	r3, [r2, #0]
}
1000020e:	4770      	bx	lr
10000210:	20000010 	.word	0x20000010
10000214:	d0000014 	.word	0xd0000014

10000218 <_Z21check_counter_compareR3led>:
    if(counter >= counter_compare_value)
10000218:	4b06      	ldr	r3, [pc, #24]	@ (10000234 <_Z21check_counter_compareR3led+0x1c>)
1000021a:	681a      	ldr	r2, [r3, #0]
1000021c:	4b06      	ldr	r3, [pc, #24]	@ (10000238 <_Z21check_counter_compareR3led+0x20>)
1000021e:	681b      	ldr	r3, [r3, #0]
10000220:	429a      	cmp	r2, r3
10000222:	d305      	bcc.n	10000230 <_Z21check_counter_compareR3led+0x18>
        GPIO_OUT_CLR |= 1 << 25;
10000224:	4a05      	ldr	r2, [pc, #20]	@ (1000023c <_Z21check_counter_compareR3led+0x24>)
10000226:	6811      	ldr	r1, [r2, #0]
10000228:	2380      	movs	r3, #128	@ 0x80
1000022a:	049b      	lsls	r3, r3, #18
1000022c:	430b      	orrs	r3, r1
1000022e:	6013      	str	r3, [r2, #0]
}
10000230:	4770      	bx	lr
10000232:	46c0      	nop			@ (mov r8, r8)
10000234:	20000010 	.word	0x20000010
10000238:	20000004 	.word	0x20000004
1000023c:	d0000018 	.word	0xd0000018

10000240 <_Z19check_startup_initsv>:
{
10000240:	b510      	push	{r4, lr}
    if(&__StackTop != (uint32_t*)0x20040000)
10000242:	4b0c      	ldr	r3, [pc, #48]	@ (10000274 <_Z19check_startup_initsv+0x34>)
10000244:	4a0c      	ldr	r2, [pc, #48]	@ (10000278 <_Z19check_startup_initsv+0x38>)
10000246:	4293      	cmp	r3, r2
10000248:	d10d      	bne.n	10000266 <_Z19check_startup_initsv+0x26>
    if (counter != 0)
1000024a:	4b0c      	ldr	r3, [pc, #48]	@ (1000027c <_Z19check_startup_initsv+0x3c>)
1000024c:	681b      	ldr	r3, [r3, #0]
1000024e:	2b00      	cmp	r3, #0
10000250:	d10b      	bne.n	1000026a <_Z19check_startup_initsv+0x2a>
    if (counter_compare_value != 100)
10000252:	4b0b      	ldr	r3, [pc, #44]	@ (10000280 <_Z19check_startup_initsv+0x40>)
10000254:	681b      	ldr	r3, [r3, #0]
10000256:	2b64      	cmp	r3, #100	@ 0x64
10000258:	d109      	bne.n	1000026e <_Z19check_startup_initsv+0x2e>
        if(x == 123)
1000025a:	4b0a      	ldr	r3, [pc, #40]	@ (10000284 <_Z19check_startup_initsv+0x44>)
1000025c:	681b      	ldr	r3, [r3, #0]
1000025e:	2b7b      	cmp	r3, #123	@ 0x7b
10000260:	d007      	beq.n	10000272 <_Z19check_startup_initsv+0x32>
        failed();
10000262:	f7ff ff6b 	bl	1000013c <_Z6failedv>
        failed();
10000266:	f7ff ff69 	bl	1000013c <_Z6failedv>
        failed();
1000026a:	f7ff ff67 	bl	1000013c <_Z6failedv>
        failed();
1000026e:	f7ff ff65 	bl	1000013c <_Z6failedv>
}
10000272:	bd10      	pop	{r4, pc}
10000274:	20040000 	.word	0x20040000
10000278:	20040000 	.word	0x20040000
1000027c:	20000010 	.word	0x20000010
10000280:	20000004 	.word	0x20000004
10000284:	20000008 	.word	0x20000008

10000288 <main>:
{
10000288:	b510      	push	{r4, lr}
1000028a:	b082      	sub	sp, #8
    init_led_gpio();
1000028c:	f7ff ff94 	bl	100001b8 <_Z13init_led_gpiov>
    check_startup_inits();
10000290:	f7ff ffd6 	bl	10000240 <_Z19check_startup_initsv>
        init_led_gpio();
10000294:	f7ff ff90 	bl	100001b8 <_Z13init_led_gpiov>
        counter++;
10000298:	4a06      	ldr	r2, [pc, #24]	@ (100002b4 <main+0x2c>)
1000029a:	6813      	ldr	r3, [r2, #0]
1000029c:	3301      	adds	r3, #1
1000029e:	6013      	str	r3, [r2, #0]
        check_counter_overflow(blue_led);
100002a0:	ac01      	add	r4, sp, #4
100002a2:	0020      	movs	r0, r4
100002a4:	f7ff ffa4 	bl	100001f0 <_Z22check_counter_overflowR3led>
        check_counter_compare(blue_led);
100002a8:	0020      	movs	r0, r4
100002aa:	f7ff ffb5 	bl	10000218 <_Z21check_counter_compareR3led>
        process_led_dimming();
100002ae:	f7ff ff5b 	bl	10000168 <_Z19process_led_dimmingv>
    while (true)
100002b2:	e7f1      	b.n	10000298 <main+0x10>
100002b4:	20000010 	.word	0x20000010

100002b8 <_GLOBAL__sub_I_GPIO_OUT_XOR>:
100002b8:	b510      	push	{r4, lr}
100002ba:	f7ff ff29 	bl	10000110 <_Z41__static_initialization_and_destruction_0v>
100002be:	bd10      	pop	{r4, pc}

100002c0 <Default_Handler>:
extern "C" void(*__init_array_end [])(void);

//extern "C" makes a function-name in C++ have C linkage (compiler does not mangle the name)
extern "C" void Default_Handler(void)
{
     while(1)
100002c0:	e7fe      	b.n	100002c0 <Default_Handler>

100002c2 <_ZSt8for_eachIPPFvvEZ13Reset_HandlervEUlS1_E_ET0_T_S5_S4_>:
   *  If @p __f has a return value it is ignored.
  */
  template<typename _InputIterator, typename _Function>
    _GLIBCXX20_CONSTEXPR
    _Function
    for_each(_InputIterator __first, _InputIterator __last, _Function __f)
100002c2:	b570      	push	{r4, r5, r6, lr}
100002c4:	0004      	movs	r4, r0
100002c6:	000d      	movs	r5, r1
    {
      // concept requirements
      __glibcxx_function_requires(_InputIteratorConcept<_InputIterator>)
      __glibcxx_requires_valid_range(__first, __last);
      for (; __first != __last; ++__first)
100002c8:	e001      	b.n	100002ce <_ZSt8for_eachIPPFvvEZ13Reset_HandlervEUlS1_E_ET0_T_S5_S4_+0xc>
	__f(*__first);
100002ca:	cc08      	ldmia	r4!, {r3}
  //    a single pre-initialization array for the executable or shared object containing the section.
  //I do not know where and when preinit is used.
  // Probably will be always empty
  std::for_each( __preinit_array_start,
                __preinit_array_end, 
                [](void (*f) (void)) {f();});
100002cc:	4798      	blx	r3
      for (; __first != __last; ++__first)
100002ce:	42ac      	cmp	r4, r5
100002d0:	d1fb      	bne.n	100002ca <_ZSt8for_eachIPPFvvEZ13Reset_HandlervEUlS1_E_ET0_T_S5_S4_+0x8>
      return __f; // N.B. [alg.foreach] says std::move(f) but it's redundant.
    }
100002d2:	2000      	movs	r0, #0
100002d4:	bd70      	pop	{r4, r5, r6, pc}

100002d6 <_ZSt8for_eachIPPFvvEZ13Reset_HandlervEUlS1_E0_ET0_T_S5_S4_>:
    for_each(_InputIterator __first, _InputIterator __last, _Function __f)
100002d6:	b570      	push	{r4, r5, r6, lr}
100002d8:	0004      	movs	r4, r0
100002da:	000d      	movs	r5, r1
      for (; __first != __last; ++__first)
100002dc:	e001      	b.n	100002e2 <_ZSt8for_eachIPPFvvEZ13Reset_HandlervEUlS1_E0_ET0_T_S5_S4_+0xc>
	__f(*__first);
100002de:	cc08      	ldmia	r4!, {r3}
  //   This section holds an array of function pointers that 
  //   contributes to a single initialization array for the executable 
  //   or shared object containing the section.
  std::for_each( __init_array_start,
                  __init_array_end, 
                  [](void (*f) (void)) {f();});
100002e0:	4798      	blx	r3
      for (; __first != __last; ++__first)
100002e2:	42ac      	cmp	r4, r5
100002e4:	d1fb      	bne.n	100002de <_ZSt8for_eachIPPFvvEZ13Reset_HandlervEUlS1_E0_ET0_T_S5_S4_+0x8>
    }
100002e6:	2000      	movs	r0, #0
100002e8:	bd70      	pop	{r4, r5, r6, pc}

100002ea <_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mImmEEPT0_PT_S6_S4_>:
    struct __copy_move<_IsMove, true, random_access_iterator_tag>
    {
      template<typename _Tp, typename _Up>
	_GLIBCXX20_CONSTEXPR
	static _Up*
	__copy_m(_Tp* __first, _Tp* __last, _Up* __result)
100002ea:	b570      	push	{r4, r5, r6, lr}
100002ec:	0014      	movs	r4, r2
	{
	  const ptrdiff_t _Num = __last - __first;
100002ee:	1a0d      	subs	r5, r1, r0
	  if (__builtin_expect(_Num > 1, true))
100002f0:	2301      	movs	r3, #1
100002f2:	2d04      	cmp	r5, #4
100002f4:	dc00      	bgt.n	100002f8 <_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mImmEEPT0_PT_S6_S4_+0xe>
100002f6:	2300      	movs	r3, #0
100002f8:	b2db      	uxtb	r3, r3
100002fa:	2b00      	cmp	r3, #0
100002fc:	d006      	beq.n	1000030c <_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mImmEEPT0_PT_S6_S4_+0x22>
	    __builtin_memmove(__result, __first, sizeof(_Tp) * _Num);
100002fe:	002a      	movs	r2, r5
10000300:	0001      	movs	r1, r0
10000302:	0020      	movs	r0, r4
10000304:	f000 f87e 	bl	10000404 <memmove>
	  else if (_Num == 1)
	    std::__copy_move<_IsMove, false, random_access_iterator_tag>::
	      __assign_one(__result, __first);
	  return __result + _Num;
10000308:	1960      	adds	r0, r4, r5
	}
1000030a:	bd70      	pop	{r4, r5, r6, pc}
	  else if (_Num == 1)
1000030c:	2d04      	cmp	r5, #4
1000030e:	d1fb      	bne.n	10000308 <_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mImmEEPT0_PT_S6_S4_+0x1e>
	{ *__to = *__from; }
10000310:	6803      	ldr	r3, [r0, #0]
10000312:	6023      	str	r3, [r4, #0]
10000314:	e7f8      	b.n	10000308 <_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mImmEEPT0_PT_S6_S4_+0x1e>
	...

10000318 <_Z13Reset_Handlerv>:
{
10000318:	b510      	push	{r4, lr}
  auto data_length = &__data_end__ - &__data_start__;
1000031a:	4b0d      	ldr	r3, [pc, #52]	@ (10000350 <_Z13Reset_Handlerv+0x38>)
1000031c:	4a0d      	ldr	r2, [pc, #52]	@ (10000354 <_Z13Reset_Handlerv+0x3c>)
1000031e:	1a99      	subs	r1, r3, r2
  auto data_source_end = &__start_data_at_flash + data_length;
10000320:	480d      	ldr	r0, [pc, #52]	@ (10000358 <_Z13Reset_Handlerv+0x40>)
10000322:	1809      	adds	r1, r1, r0
      if (std::is_constant_evaluated())
	return std::__copy_move<_IsMove, false, _Category>::
	  __copy_m(__first, __last, __result);
#endif
      return std::__copy_move<_IsMove, __memcpyable<_OI, _II>::__value,
			      _Category>::__copy_m(__first, __last, __result);
10000324:	f7ff ffe1 	bl	100002ea <_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mImmEEPT0_PT_S6_S4_>
    __gnu_cxx::__enable_if<__is_scalar<_Tp>::__value, void>::__type
    __fill_a1(_ForwardIterator __first, _ForwardIterator __last,
	      const _Tp& __value)
    {
      const _Tp __tmp = __value;
      for (; __first != __last; ++__first)
10000328:	4b0c      	ldr	r3, [pc, #48]	@ (1000035c <_Z13Reset_Handlerv+0x44>)
1000032a:	e001      	b.n	10000330 <_Z13Reset_Handlerv+0x18>
	*__first = __tmp;
1000032c:	2200      	movs	r2, #0
1000032e:	c304      	stmia	r3!, {r2}
      for (; __first != __last; ++__first)
10000330:	4a0b      	ldr	r2, [pc, #44]	@ (10000360 <_Z13Reset_Handlerv+0x48>)
10000332:	4293      	cmp	r3, r2
10000334:	d1fa      	bne.n	1000032c <_Z13Reset_Handlerv+0x14>
  std::for_each( __preinit_array_start,
10000336:	490b      	ldr	r1, [pc, #44]	@ (10000364 <_Z13Reset_Handlerv+0x4c>)
10000338:	480b      	ldr	r0, [pc, #44]	@ (10000368 <_Z13Reset_Handlerv+0x50>)
1000033a:	2200      	movs	r2, #0
1000033c:	f7ff ffc1 	bl	100002c2 <_ZSt8for_eachIPPFvvEZ13Reset_HandlervEUlS1_E_ET0_T_S5_S4_>
  std::for_each( __init_array_start,
10000340:	490a      	ldr	r1, [pc, #40]	@ (1000036c <_Z13Reset_Handlerv+0x54>)
10000342:	480b      	ldr	r0, [pc, #44]	@ (10000370 <_Z13Reset_Handlerv+0x58>)
10000344:	2200      	movs	r2, #0
10000346:	f7ff ffc6 	bl	100002d6 <_ZSt8for_eachIPPFvvEZ13Reset_HandlervEUlS1_E0_ET0_T_S5_S4_>

  main();
1000034a:	f7ff ff9d 	bl	10000288 <main>
  // .fini_array
  //   This section holds an array of function pointers 
  //   that contributes to a single termination array for 
  //   the executable or shared object containing the section.
  // Ececution of this part is not necessary because main should never return
  for (;;);
1000034e:	e7fe      	b.n	1000034e <_Z13Reset_Handlerv+0x36>
10000350:	20000008 	.word	0x20000008
10000354:	20000000 	.word	0x20000000
10000358:	100004cc 	.word	0x100004cc
1000035c:	20000008 	.word	0x20000008
10000360:	20000014 	.word	0x20000014
10000364:	100004c8 	.word	0x100004c8
10000368:	100004c8 	.word	0x100004c8
1000036c:	100004cc 	.word	0x100004cc
10000370:	100004c8 	.word	0x100004c8

10000374 <__udivsi3>:
10000374:	2900      	cmp	r1, #0
10000376:	d034      	beq.n	100003e2 <.udivsi3_skip_div0_test+0x6a>

10000378 <.udivsi3_skip_div0_test>:
10000378:	2301      	movs	r3, #1
1000037a:	2200      	movs	r2, #0
1000037c:	b410      	push	{r4}
1000037e:	4288      	cmp	r0, r1
10000380:	d32c      	bcc.n	100003dc <.udivsi3_skip_div0_test+0x64>
10000382:	2401      	movs	r4, #1
10000384:	0724      	lsls	r4, r4, #28
10000386:	42a1      	cmp	r1, r4
10000388:	d204      	bcs.n	10000394 <.udivsi3_skip_div0_test+0x1c>
1000038a:	4281      	cmp	r1, r0
1000038c:	d202      	bcs.n	10000394 <.udivsi3_skip_div0_test+0x1c>
1000038e:	0109      	lsls	r1, r1, #4
10000390:	011b      	lsls	r3, r3, #4
10000392:	e7f8      	b.n	10000386 <.udivsi3_skip_div0_test+0xe>
10000394:	00e4      	lsls	r4, r4, #3
10000396:	42a1      	cmp	r1, r4
10000398:	d204      	bcs.n	100003a4 <.udivsi3_skip_div0_test+0x2c>
1000039a:	4281      	cmp	r1, r0
1000039c:	d202      	bcs.n	100003a4 <.udivsi3_skip_div0_test+0x2c>
1000039e:	0049      	lsls	r1, r1, #1
100003a0:	005b      	lsls	r3, r3, #1
100003a2:	e7f8      	b.n	10000396 <.udivsi3_skip_div0_test+0x1e>
100003a4:	4288      	cmp	r0, r1
100003a6:	d301      	bcc.n	100003ac <.udivsi3_skip_div0_test+0x34>
100003a8:	1a40      	subs	r0, r0, r1
100003aa:	431a      	orrs	r2, r3
100003ac:	084c      	lsrs	r4, r1, #1
100003ae:	42a0      	cmp	r0, r4
100003b0:	d302      	bcc.n	100003b8 <.udivsi3_skip_div0_test+0x40>
100003b2:	1b00      	subs	r0, r0, r4
100003b4:	085c      	lsrs	r4, r3, #1
100003b6:	4322      	orrs	r2, r4
100003b8:	088c      	lsrs	r4, r1, #2
100003ba:	42a0      	cmp	r0, r4
100003bc:	d302      	bcc.n	100003c4 <.udivsi3_skip_div0_test+0x4c>
100003be:	1b00      	subs	r0, r0, r4
100003c0:	089c      	lsrs	r4, r3, #2
100003c2:	4322      	orrs	r2, r4
100003c4:	08cc      	lsrs	r4, r1, #3
100003c6:	42a0      	cmp	r0, r4
100003c8:	d302      	bcc.n	100003d0 <.udivsi3_skip_div0_test+0x58>
100003ca:	1b00      	subs	r0, r0, r4
100003cc:	08dc      	lsrs	r4, r3, #3
100003ce:	4322      	orrs	r2, r4
100003d0:	2800      	cmp	r0, #0
100003d2:	d003      	beq.n	100003dc <.udivsi3_skip_div0_test+0x64>
100003d4:	091b      	lsrs	r3, r3, #4
100003d6:	d001      	beq.n	100003dc <.udivsi3_skip_div0_test+0x64>
100003d8:	0909      	lsrs	r1, r1, #4
100003da:	e7e3      	b.n	100003a4 <.udivsi3_skip_div0_test+0x2c>
100003dc:	0010      	movs	r0, r2
100003de:	bc10      	pop	{r4}
100003e0:	4770      	bx	lr
100003e2:	b501      	push	{r0, lr}
100003e4:	2000      	movs	r0, #0
100003e6:	f000 f80b 	bl	10000400 <__aeabi_idiv0>
100003ea:	bd02      	pop	{r1, pc}

100003ec <__aeabi_uidivmod>:
100003ec:	2900      	cmp	r1, #0
100003ee:	d0f8      	beq.n	100003e2 <.udivsi3_skip_div0_test+0x6a>
100003f0:	b503      	push	{r0, r1, lr}
100003f2:	f7ff ffc1 	bl	10000378 <.udivsi3_skip_div0_test>
100003f6:	bc0e      	pop	{r1, r2, r3}
100003f8:	4342      	muls	r2, r0
100003fa:	1a89      	subs	r1, r1, r2
100003fc:	4718      	bx	r3
100003fe:	46c0      	nop			@ (mov r8, r8)

10000400 <__aeabi_idiv0>:
10000400:	4770      	bx	lr
10000402:	46c0      	nop			@ (mov r8, r8)

10000404 <memmove>:
10000404:	b5f0      	push	{r4, r5, r6, r7, lr}
10000406:	46ce      	mov	lr, r9
10000408:	4647      	mov	r7, r8
1000040a:	b580      	push	{r7, lr}
1000040c:	4288      	cmp	r0, r1
1000040e:	d90d      	bls.n	1000042c <memmove+0x28>
10000410:	188b      	adds	r3, r1, r2
10000412:	4298      	cmp	r0, r3
10000414:	d20a      	bcs.n	1000042c <memmove+0x28>
10000416:	1e53      	subs	r3, r2, #1
10000418:	2a00      	cmp	r2, #0
1000041a:	d003      	beq.n	10000424 <memmove+0x20>
1000041c:	5cca      	ldrb	r2, [r1, r3]
1000041e:	54c2      	strb	r2, [r0, r3]
10000420:	3b01      	subs	r3, #1
10000422:	d2fb      	bcs.n	1000041c <memmove+0x18>
10000424:	bcc0      	pop	{r6, r7}
10000426:	46b9      	mov	r9, r7
10000428:	46b0      	mov	r8, r6
1000042a:	bdf0      	pop	{r4, r5, r6, r7, pc}
1000042c:	2a0f      	cmp	r2, #15
1000042e:	d80b      	bhi.n	10000448 <memmove+0x44>
10000430:	0005      	movs	r5, r0
10000432:	1e56      	subs	r6, r2, #1
10000434:	2a00      	cmp	r2, #0
10000436:	d0f5      	beq.n	10000424 <memmove+0x20>
10000438:	2300      	movs	r3, #0
1000043a:	5ccc      	ldrb	r4, [r1, r3]
1000043c:	001a      	movs	r2, r3
1000043e:	54ec      	strb	r4, [r5, r3]
10000440:	3301      	adds	r3, #1
10000442:	4296      	cmp	r6, r2
10000444:	d1f9      	bne.n	1000043a <memmove+0x36>
10000446:	e7ed      	b.n	10000424 <memmove+0x20>
10000448:	0003      	movs	r3, r0
1000044a:	430b      	orrs	r3, r1
1000044c:	4688      	mov	r8, r1
1000044e:	079b      	lsls	r3, r3, #30
10000450:	d134      	bne.n	100004bc <memmove+0xb8>
10000452:	2610      	movs	r6, #16
10000454:	0017      	movs	r7, r2
10000456:	46b1      	mov	r9, r6
10000458:	000c      	movs	r4, r1
1000045a:	0003      	movs	r3, r0
1000045c:	3f10      	subs	r7, #16
1000045e:	093f      	lsrs	r7, r7, #4
10000460:	013f      	lsls	r7, r7, #4
10000462:	19c5      	adds	r5, r0, r7
10000464:	44a9      	add	r9, r5
10000466:	6826      	ldr	r6, [r4, #0]
10000468:	601e      	str	r6, [r3, #0]
1000046a:	6866      	ldr	r6, [r4, #4]
1000046c:	605e      	str	r6, [r3, #4]
1000046e:	68a6      	ldr	r6, [r4, #8]
10000470:	609e      	str	r6, [r3, #8]
10000472:	68e6      	ldr	r6, [r4, #12]
10000474:	3410      	adds	r4, #16
10000476:	60de      	str	r6, [r3, #12]
10000478:	001e      	movs	r6, r3
1000047a:	3310      	adds	r3, #16
1000047c:	42ae      	cmp	r6, r5
1000047e:	d1f2      	bne.n	10000466 <memmove+0x62>
10000480:	19cf      	adds	r7, r1, r7
10000482:	0039      	movs	r1, r7
10000484:	230f      	movs	r3, #15
10000486:	260c      	movs	r6, #12
10000488:	3110      	adds	r1, #16
1000048a:	468c      	mov	ip, r1
1000048c:	4013      	ands	r3, r2
1000048e:	4216      	tst	r6, r2
10000490:	d017      	beq.n	100004c2 <memmove+0xbe>
10000492:	4644      	mov	r4, r8
10000494:	3b04      	subs	r3, #4
10000496:	089b      	lsrs	r3, r3, #2
10000498:	009b      	lsls	r3, r3, #2
1000049a:	18ff      	adds	r7, r7, r3
1000049c:	3714      	adds	r7, #20
1000049e:	1b06      	subs	r6, r0, r4
100004a0:	680c      	ldr	r4, [r1, #0]
100004a2:	198d      	adds	r5, r1, r6
100004a4:	3104      	adds	r1, #4
100004a6:	602c      	str	r4, [r5, #0]
100004a8:	42b9      	cmp	r1, r7
100004aa:	d1f9      	bne.n	100004a0 <memmove+0x9c>
100004ac:	4661      	mov	r1, ip
100004ae:	3304      	adds	r3, #4
100004b0:	1859      	adds	r1, r3, r1
100004b2:	444b      	add	r3, r9
100004b4:	001d      	movs	r5, r3
100004b6:	2303      	movs	r3, #3
100004b8:	401a      	ands	r2, r3
100004ba:	e7ba      	b.n	10000432 <memmove+0x2e>
100004bc:	0005      	movs	r5, r0
100004be:	1e56      	subs	r6, r2, #1
100004c0:	e7ba      	b.n	10000438 <memmove+0x34>
100004c2:	464d      	mov	r5, r9
100004c4:	001a      	movs	r2, r3
100004c6:	e7b4      	b.n	10000432 <memmove+0x2e>
