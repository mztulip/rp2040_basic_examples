
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
10000100:	20040000 10000225 100001cd 100001cd     ... %...........
	...
1000012c:	100001cd 00000000 00000000 100001cd     ................
1000013c:	10000189                                ....

10000140 <_ZN3ledC1Ev>:
public:
    led()
    {
        //Activate IO_BANK0 ba setting bit 5 to 0
        //rp2040 datasheet 2.14.3. List of Registers
        RESETS_BASE_REG &= ~(1 << 5);
10000140:	4a09      	ldr	r2, [pc, #36]	@ (10000168 <_ZN3ledC1Ev+0x28>)
10000142:	6813      	ldr	r3, [r2, #0]
10000144:	2120      	movs	r1, #32
10000146:	438b      	bics	r3, r1
10000148:	6013      	str	r3, [r2, #0]

        //RESETS: RESET_DONE Register
        //Offset: 0x8
        //Wait for IO_BANK0 to be ready bit 5 should be  set
        while (!( RESET_DONE & (1 << 5)));
1000014a:	4b08      	ldr	r3, [pc, #32]	@ (1000016c <_ZN3ledC1Ev+0x2c>)
1000014c:	681b      	ldr	r3, [r3, #0]
1000014e:	069b      	lsls	r3, r3, #26
10000150:	d5fb      	bpl.n	1000014a <_ZN3ledC1Ev+0xa>

        //2.19.6. List of Registers
        //2.19.6.1. IO - User Bank
        //0x0cc GPIO25_CTRL GPIO control including function select and overrides
        // GPIO 25 BANK 0 CTRL
        GPIO25_CTRL = 5;
10000152:	4b07      	ldr	r3, [pc, #28]	@ (10000170 <_ZN3ledC1Ev+0x30>)
10000154:	2205      	movs	r2, #5
10000156:	601a      	str	r2, [r3, #0]
        //SIO: GPIO_OE_SET Register
        //Offset: 0x024
        //Description
        //GPIO output enable set
        //GPIO 25 as Outputs using SIO
        GPIO_OE_SET |= 1 << 25;
10000158:	4a06      	ldr	r2, [pc, #24]	@ (10000174 <_ZN3ledC1Ev+0x34>)
1000015a:	6811      	ldr	r1, [r2, #0]
1000015c:	2380      	movs	r3, #128	@ 0x80
1000015e:	049b      	lsls	r3, r3, #18
10000160:	430b      	orrs	r3, r1
10000162:	6013      	str	r3, [r2, #0]
    }
10000164:	4770      	bx	lr
10000166:	46c0      	nop			@ (mov r8, r8)
10000168:	4000c000 	.word	0x4000c000
1000016c:	4000c008 	.word	0x4000c008
10000170:	400140cc 	.word	0x400140cc
10000174:	d0000024 	.word	0xd0000024

10000178 <_Z41__static_initialization_and_destruction_0v>:

    while (true)
    {
        __asm("  wfi");
    }
10000178:	b510      	push	{r4, lr}
led blue_led;
1000017a:	4802      	ldr	r0, [pc, #8]	@ (10000184 <_Z41__static_initialization_and_destruction_0v+0xc>)
1000017c:	f7ff ffe0 	bl	10000140 <_ZN3ledC1Ev>
10000180:	bd10      	pop	{r4, pc}
10000182:	46c0      	nop			@ (mov r8, r8)
10000184:	20000000 	.word	0x20000000

10000188 <_Z15SysTick_Handlerv>:
        GPIO_OUT_XOR |= 1 << 25;
10000188:	4a03      	ldr	r2, [pc, #12]	@ (10000198 <_Z15SysTick_Handlerv+0x10>)
1000018a:	6811      	ldr	r1, [r2, #0]
1000018c:	2380      	movs	r3, #128	@ 0x80
1000018e:	049b      	lsls	r3, r3, #18
10000190:	430b      	orrs	r3, r1
10000192:	6013      	str	r3, [r2, #0]
}
10000194:	4770      	bx	lr
10000196:	46c0      	nop			@ (mov r8, r8)
10000198:	d000001c 	.word	0xd000001c

1000019c <main>:
        GPIO_OUT_CLR |= 1 << 25;
1000019c:	4a06      	ldr	r2, [pc, #24]	@ (100001b8 <main+0x1c>)
1000019e:	6811      	ldr	r1, [r2, #0]
100001a0:	2380      	movs	r3, #128	@ 0x80
100001a2:	049b      	lsls	r3, r3, #18
100001a4:	430b      	orrs	r3, r1
100001a6:	6013      	str	r3, [r2, #0]
    systick_hw->rvr = 6500000;
100001a8:	4b04      	ldr	r3, [pc, #16]	@ (100001bc <main+0x20>)
100001aa:	4a05      	ldr	r2, [pc, #20]	@ (100001c0 <main+0x24>)
100001ac:	605a      	str	r2, [r3, #4]
    systick_hw->csr =   M0PLUS_SYST_CSR_CLKSOURCE_BITS | 
100001ae:	2207      	movs	r2, #7
100001b0:	601a      	str	r2, [r3, #0]
        __asm("  wfi");
100001b2:	bf30      	wfi
    while (true)
100001b4:	e7fd      	b.n	100001b2 <main+0x16>
100001b6:	46c0      	nop			@ (mov r8, r8)
100001b8:	d0000018 	.word	0xd0000018
100001bc:	e000e010 	.word	0xe000e010
100001c0:	00632ea0 	.word	0x00632ea0

100001c4 <_GLOBAL__sub_I_GPIO_OUT_XOR>:
100001c4:	b510      	push	{r4, lr}
100001c6:	f7ff ffd7 	bl	10000178 <_Z41__static_initialization_and_destruction_0v>
100001ca:	bd10      	pop	{r4, pc}

100001cc <Default_Handler>:
extern "C" void(*__init_array_end [])(void);

//extern "C" makes a function-name in C++ have C linkage (compiler does not mangle the name)
extern "C" void Default_Handler(void)
{
     while(1)
100001cc:	e7fe      	b.n	100001cc <Default_Handler>

100001ce <_ZSt8for_eachIPPFvvEZ13Reset_HandlervEUlS1_E_ET0_T_S5_S4_>:
   *  If @p __f has a return value it is ignored.
  */
  template<typename _InputIterator, typename _Function>
    _GLIBCXX20_CONSTEXPR
    _Function
    for_each(_InputIterator __first, _InputIterator __last, _Function __f)
100001ce:	b570      	push	{r4, r5, r6, lr}
100001d0:	0004      	movs	r4, r0
100001d2:	000d      	movs	r5, r1
    {
      // concept requirements
      __glibcxx_function_requires(_InputIteratorConcept<_InputIterator>)
      __glibcxx_requires_valid_range(__first, __last);
      for (; __first != __last; ++__first)
100001d4:	e001      	b.n	100001da <_ZSt8for_eachIPPFvvEZ13Reset_HandlervEUlS1_E_ET0_T_S5_S4_+0xc>
	__f(*__first);
100001d6:	cc08      	ldmia	r4!, {r3}
  //    a single pre-initialization array for the executable or shared object containing the section.
  //I do not know where and when preinit is used.
  // Probably will be always empty
  std::for_each( __preinit_array_start,
                __preinit_array_end, 
                [](void (*f) (void)) {f();});
100001d8:	4798      	blx	r3
      for (; __first != __last; ++__first)
100001da:	42ac      	cmp	r4, r5
100001dc:	d1fb      	bne.n	100001d6 <_ZSt8for_eachIPPFvvEZ13Reset_HandlervEUlS1_E_ET0_T_S5_S4_+0x8>
      return __f; // N.B. [alg.foreach] says std::move(f) but it's redundant.
    }
100001de:	2000      	movs	r0, #0
100001e0:	bd70      	pop	{r4, r5, r6, pc}

100001e2 <_ZSt8for_eachIPPFvvEZ13Reset_HandlervEUlS1_E0_ET0_T_S5_S4_>:
    for_each(_InputIterator __first, _InputIterator __last, _Function __f)
100001e2:	b570      	push	{r4, r5, r6, lr}
100001e4:	0004      	movs	r4, r0
100001e6:	000d      	movs	r5, r1
      for (; __first != __last; ++__first)
100001e8:	e001      	b.n	100001ee <_ZSt8for_eachIPPFvvEZ13Reset_HandlervEUlS1_E0_ET0_T_S5_S4_+0xc>
	__f(*__first);
100001ea:	cc08      	ldmia	r4!, {r3}
  //   This section holds an array of function pointers that 
  //   contributes to a single initialization array for the executable 
  //   or shared object containing the section.
  std::for_each( __init_array_start,
                  __init_array_end, 
                  [](void (*f) (void)) {f();});
100001ec:	4798      	blx	r3
      for (; __first != __last; ++__first)
100001ee:	42ac      	cmp	r4, r5
100001f0:	d1fb      	bne.n	100001ea <_ZSt8for_eachIPPFvvEZ13Reset_HandlervEUlS1_E0_ET0_T_S5_S4_+0x8>
    }
100001f2:	2000      	movs	r0, #0
100001f4:	bd70      	pop	{r4, r5, r6, pc}

100001f6 <_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mImmEEPT0_PT_S6_S4_>:
    struct __copy_move<_IsMove, true, random_access_iterator_tag>
    {
      template<typename _Tp, typename _Up>
	_GLIBCXX20_CONSTEXPR
	static _Up*
	__copy_m(_Tp* __first, _Tp* __last, _Up* __result)
100001f6:	b570      	push	{r4, r5, r6, lr}
100001f8:	0014      	movs	r4, r2
	{
	  const ptrdiff_t _Num = __last - __first;
100001fa:	1a0d      	subs	r5, r1, r0
	  if (__builtin_expect(_Num > 1, true))
100001fc:	2301      	movs	r3, #1
100001fe:	2d04      	cmp	r5, #4
10000200:	dc00      	bgt.n	10000204 <_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mImmEEPT0_PT_S6_S4_+0xe>
10000202:	2300      	movs	r3, #0
10000204:	b2db      	uxtb	r3, r3
10000206:	2b00      	cmp	r3, #0
10000208:	d006      	beq.n	10000218 <_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mImmEEPT0_PT_S6_S4_+0x22>
	    __builtin_memmove(__result, __first, sizeof(_Tp) * _Num);
1000020a:	002a      	movs	r2, r5
1000020c:	0001      	movs	r1, r0
1000020e:	0020      	movs	r0, r4
10000210:	f000 f836 	bl	10000280 <memmove>
	  else if (_Num == 1)
	    std::__copy_move<_IsMove, false, random_access_iterator_tag>::
	      __assign_one(__result, __first);
	  return __result + _Num;
10000214:	1960      	adds	r0, r4, r5
	}
10000216:	bd70      	pop	{r4, r5, r6, pc}
	  else if (_Num == 1)
10000218:	2d04      	cmp	r5, #4
1000021a:	d1fb      	bne.n	10000214 <_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mImmEEPT0_PT_S6_S4_+0x1e>
	{ *__to = *__from; }
1000021c:	6803      	ldr	r3, [r0, #0]
1000021e:	6023      	str	r3, [r4, #0]
10000220:	e7f8      	b.n	10000214 <_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mImmEEPT0_PT_S6_S4_+0x1e>
	...

10000224 <_Z13Reset_Handlerv>:
{
10000224:	b510      	push	{r4, lr}
  auto data_length = &__data_end__ - &__data_start__;
10000226:	4b0d      	ldr	r3, [pc, #52]	@ (1000025c <_Z13Reset_Handlerv+0x38>)
10000228:	4a0d      	ldr	r2, [pc, #52]	@ (10000260 <_Z13Reset_Handlerv+0x3c>)
1000022a:	1a99      	subs	r1, r3, r2
  auto data_source_end = &__start_data_at_flash + data_length;
1000022c:	480d      	ldr	r0, [pc, #52]	@ (10000264 <_Z13Reset_Handlerv+0x40>)
1000022e:	1809      	adds	r1, r1, r0
      if (std::is_constant_evaluated())
	return std::__copy_move<_IsMove, false, _Category>::
	  __copy_m(__first, __last, __result);
#endif
      return std::__copy_move<_IsMove, __memcpyable<_OI, _II>::__value,
			      _Category>::__copy_m(__first, __last, __result);
10000230:	f7ff ffe1 	bl	100001f6 <_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mImmEEPT0_PT_S6_S4_>
    __gnu_cxx::__enable_if<__is_scalar<_Tp>::__value, void>::__type
    __fill_a1(_ForwardIterator __first, _ForwardIterator __last,
	      const _Tp& __value)
    {
      const _Tp __tmp = __value;
      for (; __first != __last; ++__first)
10000234:	4b0c      	ldr	r3, [pc, #48]	@ (10000268 <_Z13Reset_Handlerv+0x44>)
10000236:	e001      	b.n	1000023c <_Z13Reset_Handlerv+0x18>
	*__first = __tmp;
10000238:	2200      	movs	r2, #0
1000023a:	c304      	stmia	r3!, {r2}
      for (; __first != __last; ++__first)
1000023c:	4a0b      	ldr	r2, [pc, #44]	@ (1000026c <_Z13Reset_Handlerv+0x48>)
1000023e:	4293      	cmp	r3, r2
10000240:	d1fa      	bne.n	10000238 <_Z13Reset_Handlerv+0x14>
  std::for_each( __preinit_array_start,
10000242:	490b      	ldr	r1, [pc, #44]	@ (10000270 <_Z13Reset_Handlerv+0x4c>)
10000244:	480b      	ldr	r0, [pc, #44]	@ (10000274 <_Z13Reset_Handlerv+0x50>)
10000246:	2200      	movs	r2, #0
10000248:	f7ff ffc1 	bl	100001ce <_ZSt8for_eachIPPFvvEZ13Reset_HandlervEUlS1_E_ET0_T_S5_S4_>
  std::for_each( __init_array_start,
1000024c:	490a      	ldr	r1, [pc, #40]	@ (10000278 <_Z13Reset_Handlerv+0x54>)
1000024e:	480b      	ldr	r0, [pc, #44]	@ (1000027c <_Z13Reset_Handlerv+0x58>)
10000250:	2200      	movs	r2, #0
10000252:	f7ff ffc6 	bl	100001e2 <_ZSt8for_eachIPPFvvEZ13Reset_HandlervEUlS1_E0_ET0_T_S5_S4_>

  main();
10000256:	f7ff ffa1 	bl	1000019c <main>
  // .fini_array
  //   This section holds an array of function pointers 
  //   that contributes to a single termination array for 
  //   the executable or shared object containing the section.
  // Ececution of this part is not necessary because main should never return
  for (;;);
1000025a:	e7fe      	b.n	1000025a <_Z13Reset_Handlerv+0x36>
1000025c:	20000000 	.word	0x20000000
10000260:	20000000 	.word	0x20000000
10000264:	10000348 	.word	0x10000348
10000268:	20000000 	.word	0x20000000
1000026c:	20000004 	.word	0x20000004
10000270:	10000344 	.word	0x10000344
10000274:	10000344 	.word	0x10000344
10000278:	10000348 	.word	0x10000348
1000027c:	10000344 	.word	0x10000344

10000280 <memmove>:
10000280:	b5f0      	push	{r4, r5, r6, r7, lr}
10000282:	46ce      	mov	lr, r9
10000284:	4647      	mov	r7, r8
10000286:	b580      	push	{r7, lr}
10000288:	4288      	cmp	r0, r1
1000028a:	d90d      	bls.n	100002a8 <memmove+0x28>
1000028c:	188b      	adds	r3, r1, r2
1000028e:	4298      	cmp	r0, r3
10000290:	d20a      	bcs.n	100002a8 <memmove+0x28>
10000292:	1e53      	subs	r3, r2, #1
10000294:	2a00      	cmp	r2, #0
10000296:	d003      	beq.n	100002a0 <memmove+0x20>
10000298:	5cca      	ldrb	r2, [r1, r3]
1000029a:	54c2      	strb	r2, [r0, r3]
1000029c:	3b01      	subs	r3, #1
1000029e:	d2fb      	bcs.n	10000298 <memmove+0x18>
100002a0:	bcc0      	pop	{r6, r7}
100002a2:	46b9      	mov	r9, r7
100002a4:	46b0      	mov	r8, r6
100002a6:	bdf0      	pop	{r4, r5, r6, r7, pc}
100002a8:	2a0f      	cmp	r2, #15
100002aa:	d80b      	bhi.n	100002c4 <memmove+0x44>
100002ac:	0005      	movs	r5, r0
100002ae:	1e56      	subs	r6, r2, #1
100002b0:	2a00      	cmp	r2, #0
100002b2:	d0f5      	beq.n	100002a0 <memmove+0x20>
100002b4:	2300      	movs	r3, #0
100002b6:	5ccc      	ldrb	r4, [r1, r3]
100002b8:	001a      	movs	r2, r3
100002ba:	54ec      	strb	r4, [r5, r3]
100002bc:	3301      	adds	r3, #1
100002be:	4296      	cmp	r6, r2
100002c0:	d1f9      	bne.n	100002b6 <memmove+0x36>
100002c2:	e7ed      	b.n	100002a0 <memmove+0x20>
100002c4:	0003      	movs	r3, r0
100002c6:	430b      	orrs	r3, r1
100002c8:	4688      	mov	r8, r1
100002ca:	079b      	lsls	r3, r3, #30
100002cc:	d134      	bne.n	10000338 <memmove+0xb8>
100002ce:	2610      	movs	r6, #16
100002d0:	0017      	movs	r7, r2
100002d2:	46b1      	mov	r9, r6
100002d4:	000c      	movs	r4, r1
100002d6:	0003      	movs	r3, r0
100002d8:	3f10      	subs	r7, #16
100002da:	093f      	lsrs	r7, r7, #4
100002dc:	013f      	lsls	r7, r7, #4
100002de:	19c5      	adds	r5, r0, r7
100002e0:	44a9      	add	r9, r5
100002e2:	6826      	ldr	r6, [r4, #0]
100002e4:	601e      	str	r6, [r3, #0]
100002e6:	6866      	ldr	r6, [r4, #4]
100002e8:	605e      	str	r6, [r3, #4]
100002ea:	68a6      	ldr	r6, [r4, #8]
100002ec:	609e      	str	r6, [r3, #8]
100002ee:	68e6      	ldr	r6, [r4, #12]
100002f0:	3410      	adds	r4, #16
100002f2:	60de      	str	r6, [r3, #12]
100002f4:	001e      	movs	r6, r3
100002f6:	3310      	adds	r3, #16
100002f8:	42ae      	cmp	r6, r5
100002fa:	d1f2      	bne.n	100002e2 <memmove+0x62>
100002fc:	19cf      	adds	r7, r1, r7
100002fe:	0039      	movs	r1, r7
10000300:	230f      	movs	r3, #15
10000302:	260c      	movs	r6, #12
10000304:	3110      	adds	r1, #16
10000306:	468c      	mov	ip, r1
10000308:	4013      	ands	r3, r2
1000030a:	4216      	tst	r6, r2
1000030c:	d017      	beq.n	1000033e <memmove+0xbe>
1000030e:	4644      	mov	r4, r8
10000310:	3b04      	subs	r3, #4
10000312:	089b      	lsrs	r3, r3, #2
10000314:	009b      	lsls	r3, r3, #2
10000316:	18ff      	adds	r7, r7, r3
10000318:	3714      	adds	r7, #20
1000031a:	1b06      	subs	r6, r0, r4
1000031c:	680c      	ldr	r4, [r1, #0]
1000031e:	198d      	adds	r5, r1, r6
10000320:	3104      	adds	r1, #4
10000322:	602c      	str	r4, [r5, #0]
10000324:	42b9      	cmp	r1, r7
10000326:	d1f9      	bne.n	1000031c <memmove+0x9c>
10000328:	4661      	mov	r1, ip
1000032a:	3304      	adds	r3, #4
1000032c:	1859      	adds	r1, r3, r1
1000032e:	444b      	add	r3, r9
10000330:	001d      	movs	r5, r3
10000332:	2303      	movs	r3, #3
10000334:	401a      	ands	r2, r3
10000336:	e7ba      	b.n	100002ae <memmove+0x2e>
10000338:	0005      	movs	r5, r0
1000033a:	1e56      	subs	r6, r2, #1
1000033c:	e7ba      	b.n	100002b4 <memmove+0x34>
1000033e:	464d      	mov	r5, r9
10000340:	001a      	movs	r2, r3
10000342:	e7b4      	b.n	100002ae <memmove+0x2e>
