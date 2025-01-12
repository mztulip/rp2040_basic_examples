
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
10000100:	20040000 100002cd 1000029d 1000029d     ... ............

10000110 <_Z5delayv>:
const int counter_max = 500;
uint32_t counter_compare_value = 100;
uint32_t counter = 0;

void delay(void)
{
10000110:	b082      	sub	sp, #8
    for (volatile uint32_t i = 0; i < 123456/8; ++i)
10000112:	2300      	movs	r3, #0
10000114:	9301      	str	r3, [sp, #4]
10000116:	e002      	b.n	1000011e <_Z5delayv+0xe>
10000118:	9b01      	ldr	r3, [sp, #4]
1000011a:	3301      	adds	r3, #1
1000011c:	9301      	str	r3, [sp, #4]
1000011e:	9a01      	ldr	r2, [sp, #4]
10000120:	4b02      	ldr	r3, [pc, #8]	@ (1000012c <_Z5delayv+0x1c>)
10000122:	429a      	cmp	r2, r3
10000124:	d9f8      	bls.n	10000118 <_Z5delayv+0x8>
    {

    }
}
10000126:	b002      	add	sp, #8
10000128:	4770      	bx	lr
1000012a:	46c0      	nop			@ (mov r8, r8)
1000012c:	00003c47 	.word	0x00003c47

10000130 <_Z6failedv>:

void failed(void)
{
10000130:	b510      	push	{r4, lr}
    while (true)
    {
        delay();
10000132:	f7ff ffed 	bl	10000110 <_Z5delayv>
        // SIO: GPIO_OUT_XOR Register
        // Offset: 0x01c
        // Description
        // GPIO output value XO
        // xor bit for GPIO 25 changing led state
        *(volatile uint32_t *) (SIO_BASE+0x1c) |= 1 << 25;
10000136:	4a03      	ldr	r2, [pc, #12]	@ (10000144 <_Z6failedv+0x14>)
10000138:	6811      	ldr	r1, [r2, #0]
1000013a:	2380      	movs	r3, #128	@ 0x80
1000013c:	049b      	lsls	r3, r3, #18
1000013e:	430b      	orrs	r3, r1
10000140:	6013      	str	r3, [r2, #0]
    while (true)
10000142:	e7f6      	b.n	10000132 <_Z6failedv+0x2>
10000144:	d000001c 	.word	0xd000001c

10000148 <_Z6led_onv>:
    //2.3.1.7. List of Registers
    // SIO: GPIO_OUT_SET Register
    // Offset: 0x014
    // Description
    // GPIO output value set
    *(volatile uint32_t *) (SIO_BASE+0x14) |= 1 << 25;
10000148:	4a03      	ldr	r2, [pc, #12]	@ (10000158 <_Z6led_onv+0x10>)
1000014a:	6811      	ldr	r1, [r2, #0]
1000014c:	2380      	movs	r3, #128	@ 0x80
1000014e:	049b      	lsls	r3, r3, #18
10000150:	430b      	orrs	r3, r1
10000152:	6013      	str	r3, [r2, #0]
}
10000154:	4770      	bx	lr
10000156:	46c0      	nop			@ (mov r8, r8)
10000158:	d0000014 	.word	0xd0000014

1000015c <_Z7led_offv>:
    //2.3.1.7. List of Registers
    // SIO: GPIO_OUT_CLR Register
    // Offset: 0x018
    // Description
    // GPIO output value clear
    *(volatile uint32_t *) (SIO_BASE+0x18) |= 1 << 25;
1000015c:	4a03      	ldr	r2, [pc, #12]	@ (1000016c <_Z7led_offv+0x10>)
1000015e:	6811      	ldr	r1, [r2, #0]
10000160:	2380      	movs	r3, #128	@ 0x80
10000162:	049b      	lsls	r3, r3, #18
10000164:	430b      	orrs	r3, r1
10000166:	6013      	str	r3, [r2, #0]
}
10000168:	4770      	bx	lr
1000016a:	46c0      	nop			@ (mov r8, r8)
1000016c:	d0000018 	.word	0xd0000018

10000170 <_Z22check_counter_overflowv>:

void check_counter_overflow(void)
{
10000170:	b510      	push	{r4, lr}
    if (counter >= counter_max)
10000172:	4b06      	ldr	r3, [pc, #24]	@ (1000018c <_Z22check_counter_overflowv+0x1c>)
10000174:	681a      	ldr	r2, [r3, #0]
10000176:	23fa      	movs	r3, #250	@ 0xfa
10000178:	005b      	lsls	r3, r3, #1
1000017a:	429a      	cmp	r2, r3
1000017c:	d200      	bcs.n	10000180 <_Z22check_counter_overflowv+0x10>
    {
        counter = 0;
        led_on();
    }
}
1000017e:	bd10      	pop	{r4, pc}
        counter = 0;
10000180:	4b02      	ldr	r3, [pc, #8]	@ (1000018c <_Z22check_counter_overflowv+0x1c>)
10000182:	2200      	movs	r2, #0
10000184:	601a      	str	r2, [r3, #0]
        led_on();
10000186:	f7ff ffdf 	bl	10000148 <_Z6led_onv>
}
1000018a:	e7f8      	b.n	1000017e <_Z22check_counter_overflowv+0xe>
1000018c:	2000000c 	.word	0x2000000c

10000190 <_Z21check_counter_comparev>:

void check_counter_compare(void)
{
10000190:	b510      	push	{r4, lr}
    if(counter >= counter_compare_value)
10000192:	4b05      	ldr	r3, [pc, #20]	@ (100001a8 <_Z21check_counter_comparev+0x18>)
10000194:	681a      	ldr	r2, [r3, #0]
10000196:	4b05      	ldr	r3, [pc, #20]	@ (100001ac <_Z21check_counter_comparev+0x1c>)
10000198:	681b      	ldr	r3, [r3, #0]
1000019a:	429a      	cmp	r2, r3
1000019c:	d200      	bcs.n	100001a0 <_Z21check_counter_comparev+0x10>
    {
        led_off();
    }
}
1000019e:	bd10      	pop	{r4, pc}
        led_off();
100001a0:	f7ff ffdc 	bl	1000015c <_Z7led_offv>
}
100001a4:	e7fb      	b.n	1000019e <_Z21check_counter_comparev+0xe>
100001a6:	46c0      	nop			@ (mov r8, r8)
100001a8:	2000000c 	.word	0x2000000c
100001ac:	20000004 	.word	0x20000004

100001b0 <_Z13set_pwm_valuem>:

void set_pwm_value(uint32_t setpoint)
{
    if(setpoint > counter_max)
100001b0:	23fa      	movs	r3, #250	@ 0xfa
100001b2:	005b      	lsls	r3, r3, #1
100001b4:	4298      	cmp	r0, r3
100001b6:	d900      	bls.n	100001ba <_Z13set_pwm_valuem+0xa>
    {
        setpoint = counter_max;
100001b8:	0018      	movs	r0, r3
    }
    counter_compare_value = setpoint;
100001ba:	4b01      	ldr	r3, [pc, #4]	@ (100001c0 <_Z13set_pwm_valuem+0x10>)
100001bc:	6018      	str	r0, [r3, #0]
}
100001be:	4770      	bx	lr
100001c0:	20000004 	.word	0x20000004

100001c4 <_Z19process_led_dimmingv>:

void process_led_dimming()
{
100001c4:	b510      	push	{r4, lr}
    static int32_t pwm_setpoint = 0;
    static int inc_step = 1;
    if(counter%100 == 0)
100001c6:	4b10      	ldr	r3, [pc, #64]	@ (10000208 <_Z19process_led_dimmingv+0x44>)
100001c8:	6818      	ldr	r0, [r3, #0]
100001ca:	2164      	movs	r1, #100	@ 0x64
100001cc:	f000 f8d6 	bl	1000037c <__aeabi_uidivmod>
100001d0:	2900      	cmp	r1, #0
100001d2:	d105      	bne.n	100001e0 <_Z19process_led_dimmingv+0x1c>
    {
        pwm_setpoint+=inc_step;
100001d4:	4b0d      	ldr	r3, [pc, #52]	@ (1000020c <_Z19process_led_dimmingv+0x48>)
100001d6:	6819      	ldr	r1, [r3, #0]
100001d8:	4a0d      	ldr	r2, [pc, #52]	@ (10000210 <_Z19process_led_dimmingv+0x4c>)
100001da:	6813      	ldr	r3, [r2, #0]
100001dc:	185b      	adds	r3, r3, r1
100001de:	6013      	str	r3, [r2, #0]
    }

    if(pwm_setpoint >= counter_max)
100001e0:	4b0b      	ldr	r3, [pc, #44]	@ (10000210 <_Z19process_led_dimmingv+0x4c>)
100001e2:	6818      	ldr	r0, [r3, #0]
100001e4:	23fa      	movs	r3, #250	@ 0xfa
100001e6:	005b      	lsls	r3, r3, #1
100001e8:	4298      	cmp	r0, r3
100001ea:	db06      	blt.n	100001fa <_Z19process_led_dimmingv+0x36>
    {
        inc_step=-1;
100001ec:	4b07      	ldr	r3, [pc, #28]	@ (1000020c <_Z19process_led_dimmingv+0x48>)
100001ee:	2201      	movs	r2, #1
100001f0:	4252      	negs	r2, r2
100001f2:	601a      	str	r2, [r3, #0]
    else if(pwm_setpoint <= 0)
    {
        inc_step=1;
    }

    set_pwm_value(pwm_setpoint);
100001f4:	f7ff ffdc 	bl	100001b0 <_Z13set_pwm_valuem>
}
100001f8:	bd10      	pop	{r4, pc}
    else if(pwm_setpoint <= 0)
100001fa:	2800      	cmp	r0, #0
100001fc:	dcfa      	bgt.n	100001f4 <_Z19process_led_dimmingv+0x30>
        inc_step=1;
100001fe:	4b03      	ldr	r3, [pc, #12]	@ (1000020c <_Z19process_led_dimmingv+0x48>)
10000200:	2201      	movs	r2, #1
10000202:	601a      	str	r2, [r3, #0]
10000204:	e7f6      	b.n	100001f4 <_Z19process_led_dimmingv+0x30>
10000206:	46c0      	nop			@ (mov r8, r8)
10000208:	2000000c 	.word	0x2000000c
1000020c:	20000000 	.word	0x20000000
10000210:	20000008 	.word	0x20000008

10000214 <_Z13init_led_gpiov>:

void init_led_gpio(void)
{
     //Activate IO_BANK0 ba setting bit 5 to 0
    //rp2040 datasheet 2.14.3. List of Registers
    *(volatile uint32_t *) (RESETS_BASE) &= ~(1 << 5);
10000214:	4a09      	ldr	r2, [pc, #36]	@ (1000023c <_Z13init_led_gpiov+0x28>)
10000216:	6813      	ldr	r3, [r2, #0]
10000218:	2120      	movs	r1, #32
1000021a:	438b      	bics	r3, r1
1000021c:	6013      	str	r3, [r2, #0]

    //RESETS: RESET_DONE Register
    //Offset: 0x8
    //Wait for IO_BANK0 to be ready bit 5 should be  set
    while (!( *(volatile uint32_t *) (RESETS_BASE+0x08) & (1 << 5)));
1000021e:	4b08      	ldr	r3, [pc, #32]	@ (10000240 <_Z13init_led_gpiov+0x2c>)
10000220:	681b      	ldr	r3, [r3, #0]
10000222:	069b      	lsls	r3, r3, #26
10000224:	d5fb      	bpl.n	1000021e <_Z13init_led_gpiov+0xa>

    //2.19.6. List of Registers
    //2.19.6.1. IO - User Bank
    //0x0cc GPIO25_CTRL GPIO control including function select and overrides
    // GPIO 25 BANK 0 CTRL
    *(volatile uint32_t *) (IO_BANK0_BASE+0xcc) = 5;
10000226:	4b07      	ldr	r3, [pc, #28]	@ (10000244 <_Z13init_led_gpiov+0x30>)
10000228:	2205      	movs	r2, #5
1000022a:	601a      	str	r2, [r3, #0]
    //SIO: GPIO_OE_SET Register
    //Offset: 0x024
    //Description
    //GPIO output enable set
    //GPIO 25 as Outputs using SIO
    *(volatile uint32_t *) (SIO_BASE+0x24) |= 1 << 25;
1000022c:	4a06      	ldr	r2, [pc, #24]	@ (10000248 <_Z13init_led_gpiov+0x34>)
1000022e:	6811      	ldr	r1, [r2, #0]
10000230:	2380      	movs	r3, #128	@ 0x80
10000232:	049b      	lsls	r3, r3, #18
10000234:	430b      	orrs	r3, r1
10000236:	6013      	str	r3, [r2, #0]
}
10000238:	4770      	bx	lr
1000023a:	46c0      	nop			@ (mov r8, r8)
1000023c:	4000c000 	.word	0x4000c000
10000240:	4000c008 	.word	0x4000c008
10000244:	400140cc 	.word	0x400140cc
10000248:	d0000024 	.word	0xd0000024

1000024c <main>:

extern uint32_t __StackTop;

int main(void)
{
1000024c:	b510      	push	{r4, lr}
    init_led_gpio();
1000024e:	f7ff ffe1 	bl	10000214 <_Z13init_led_gpiov>

    //This is also impossible to get here without working stack
    //If stack will be set outside of SRAM hard fault will be generated
    //main at the beginning pushes 5 registers on stack
    //Check if stack top is correctly defined in linker script
    if(&__StackTop != (uint32_t*)0x20040000)
10000252:	4b0e      	ldr	r3, [pc, #56]	@ (1000028c <main+0x40>)
10000254:	4a0e      	ldr	r2, [pc, #56]	@ (10000290 <main+0x44>)
10000256:	4293      	cmp	r3, r2
10000258:	d001      	beq.n	1000025e <main+0x12>
    {
        failed();
1000025a:	f7ff ff69 	bl	10000130 <_Z6failedv>
    }

    //Check if bss init loop works
    if (counter != 0)
1000025e:	4b0d      	ldr	r3, [pc, #52]	@ (10000294 <main+0x48>)
10000260:	681b      	ldr	r3, [r3, #0]
10000262:	2b00      	cmp	r3, #0
10000264:	d10e      	bne.n	10000284 <main+0x38>
    {
        failed();
    }

    //Check if data init loop works
    if (counter_compare_value != 100)
10000266:	4b0c      	ldr	r3, [pc, #48]	@ (10000298 <main+0x4c>)
10000268:	681b      	ldr	r3, [r3, #0]
1000026a:	2b64      	cmp	r3, #100	@ 0x64
1000026c:	d10c      	bne.n	10000288 <main+0x3c>
    

 
    while (true)
    {
        counter++;
1000026e:	4a09      	ldr	r2, [pc, #36]	@ (10000294 <main+0x48>)
10000270:	6813      	ldr	r3, [r2, #0]
10000272:	3301      	adds	r3, #1
10000274:	6013      	str	r3, [r2, #0]
        check_counter_overflow();
10000276:	f7ff ff7b 	bl	10000170 <_Z22check_counter_overflowv>
        check_counter_compare();
1000027a:	f7ff ff89 	bl	10000190 <_Z21check_counter_comparev>
        process_led_dimming();
1000027e:	f7ff ffa1 	bl	100001c4 <_Z19process_led_dimmingv>
    while (true)
10000282:	e7f4      	b.n	1000026e <main+0x22>
        failed();
10000284:	f7ff ff54 	bl	10000130 <_Z6failedv>
        failed();
10000288:	f7ff ff52 	bl	10000130 <_Z6failedv>
1000028c:	20040000 	.word	0x20040000
10000290:	20040000 	.word	0x20040000
10000294:	2000000c 	.word	0x2000000c
10000298:	20000004 	.word	0x20000004

1000029c <Default_Handler>:
extern uint32_t __StackTop;

//extern "C" makes a function-name in C++ have C linkage (compiler does not mangle the name)
extern "C" void Default_Handler(void)
{
     while(1)
1000029c:	e7fe      	b.n	1000029c <Default_Handler>

1000029e <_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mImmEEPT0_PT_S6_S4_>:
    struct __copy_move<_IsMove, true, random_access_iterator_tag>
    {
      template<typename _Tp, typename _Up>
	_GLIBCXX20_CONSTEXPR
	static _Up*
	__copy_m(_Tp* __first, _Tp* __last, _Up* __result)
1000029e:	b570      	push	{r4, r5, r6, lr}
100002a0:	0014      	movs	r4, r2
	{
	  const ptrdiff_t _Num = __last - __first;
100002a2:	1a0d      	subs	r5, r1, r0
	  if (__builtin_expect(_Num > 1, true))
100002a4:	2301      	movs	r3, #1
100002a6:	2d04      	cmp	r5, #4
100002a8:	dc00      	bgt.n	100002ac <_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mImmEEPT0_PT_S6_S4_+0xe>
100002aa:	2300      	movs	r3, #0
100002ac:	b2db      	uxtb	r3, r3
100002ae:	2b00      	cmp	r3, #0
100002b0:	d006      	beq.n	100002c0 <_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mImmEEPT0_PT_S6_S4_+0x22>
	    __builtin_memmove(__result, __first, sizeof(_Tp) * _Num);
100002b2:	002a      	movs	r2, r5
100002b4:	0001      	movs	r1, r0
100002b6:	0020      	movs	r0, r4
100002b8:	f000 f86c 	bl	10000394 <memmove>
	  else if (_Num == 1)
	    std::__copy_move<_IsMove, false, random_access_iterator_tag>::
	      __assign_one(__result, __first);
	  return __result + _Num;
100002bc:	1960      	adds	r0, r4, r5
	}
100002be:	bd70      	pop	{r4, r5, r6, pc}
	  else if (_Num == 1)
100002c0:	2d04      	cmp	r5, #4
100002c2:	d1fb      	bne.n	100002bc <_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mImmEEPT0_PT_S6_S4_+0x1e>
	{ *__to = *__from; }
100002c4:	6803      	ldr	r3, [r0, #0]
100002c6:	6023      	str	r3, [r4, #0]
100002c8:	e7f8      	b.n	100002bc <_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mImmEEPT0_PT_S6_S4_+0x1e>
	...

100002cc <_Z13Reset_Handlerv>:
}

int main(void);

void Reset_Handler()
{
100002cc:	b510      	push	{r4, lr}
  // Initialize the .data section (global variables with initial values)
  auto data_length = &__data_end__ - &__data_start__;
100002ce:	4b08      	ldr	r3, [pc, #32]	@ (100002f0 <_Z13Reset_Handlerv+0x24>)
100002d0:	4a08      	ldr	r2, [pc, #32]	@ (100002f4 <_Z13Reset_Handlerv+0x28>)
100002d2:	1a99      	subs	r1, r3, r2
  auto data_source_end = &__etext + data_length;
100002d4:	4808      	ldr	r0, [pc, #32]	@ (100002f8 <_Z13Reset_Handlerv+0x2c>)
100002d6:	1809      	adds	r1, r1, r0
      if (std::is_constant_evaluated())
	return std::__copy_move<_IsMove, false, _Category>::
	  __copy_m(__first, __last, __result);
#endif
      return std::__copy_move<_IsMove, __memcpyable<_OI, _II>::__value,
			      _Category>::__copy_m(__first, __last, __result);
100002d8:	f7ff ffe1 	bl	1000029e <_ZNSt11__copy_moveILb0ELb1ESt26random_access_iterator_tagE8__copy_mImmEEPT0_PT_S6_S4_>
    __gnu_cxx::__enable_if<__is_scalar<_Tp>::__value, void>::__type
    __fill_a1(_ForwardIterator __first, _ForwardIterator __last,
	      const _Tp& __value)
    {
      const _Tp __tmp = __value;
      for (; __first != __last; ++__first)
100002dc:	4b07      	ldr	r3, [pc, #28]	@ (100002fc <_Z13Reset_Handlerv+0x30>)
100002de:	e001      	b.n	100002e4 <_Z13Reset_Handlerv+0x18>
	*__first = __tmp;
100002e0:	2200      	movs	r2, #0
100002e2:	c304      	stmia	r3!, {r2}
      for (; __first != __last; ++__first)
100002e4:	4a06      	ldr	r2, [pc, #24]	@ (10000300 <_Z13Reset_Handlerv+0x34>)
100002e6:	4293      	cmp	r3, r2
100002e8:	d1fa      	bne.n	100002e0 <_Z13Reset_Handlerv+0x14>
  //   that contributes to a single termination array for 
  //   the executable or shared object containing the section.



  main();
100002ea:	f7ff ffaf 	bl	1000024c <main>
  for (;;);
100002ee:	e7fe      	b.n	100002ee <_Z13Reset_Handlerv+0x22>
100002f0:	20000008 	.word	0x20000008
100002f4:	20000000 	.word	0x20000000
100002f8:	10000458 	.word	0x10000458
100002fc:	20000008 	.word	0x20000008
10000300:	20000010 	.word	0x20000010

10000304 <__udivsi3>:
10000304:	2900      	cmp	r1, #0
10000306:	d034      	beq.n	10000372 <.udivsi3_skip_div0_test+0x6a>

10000308 <.udivsi3_skip_div0_test>:
10000308:	2301      	movs	r3, #1
1000030a:	2200      	movs	r2, #0
1000030c:	b410      	push	{r4}
1000030e:	4288      	cmp	r0, r1
10000310:	d32c      	bcc.n	1000036c <.udivsi3_skip_div0_test+0x64>
10000312:	2401      	movs	r4, #1
10000314:	0724      	lsls	r4, r4, #28
10000316:	42a1      	cmp	r1, r4
10000318:	d204      	bcs.n	10000324 <.udivsi3_skip_div0_test+0x1c>
1000031a:	4281      	cmp	r1, r0
1000031c:	d202      	bcs.n	10000324 <.udivsi3_skip_div0_test+0x1c>
1000031e:	0109      	lsls	r1, r1, #4
10000320:	011b      	lsls	r3, r3, #4
10000322:	e7f8      	b.n	10000316 <.udivsi3_skip_div0_test+0xe>
10000324:	00e4      	lsls	r4, r4, #3
10000326:	42a1      	cmp	r1, r4
10000328:	d204      	bcs.n	10000334 <.udivsi3_skip_div0_test+0x2c>
1000032a:	4281      	cmp	r1, r0
1000032c:	d202      	bcs.n	10000334 <.udivsi3_skip_div0_test+0x2c>
1000032e:	0049      	lsls	r1, r1, #1
10000330:	005b      	lsls	r3, r3, #1
10000332:	e7f8      	b.n	10000326 <.udivsi3_skip_div0_test+0x1e>
10000334:	4288      	cmp	r0, r1
10000336:	d301      	bcc.n	1000033c <.udivsi3_skip_div0_test+0x34>
10000338:	1a40      	subs	r0, r0, r1
1000033a:	431a      	orrs	r2, r3
1000033c:	084c      	lsrs	r4, r1, #1
1000033e:	42a0      	cmp	r0, r4
10000340:	d302      	bcc.n	10000348 <.udivsi3_skip_div0_test+0x40>
10000342:	1b00      	subs	r0, r0, r4
10000344:	085c      	lsrs	r4, r3, #1
10000346:	4322      	orrs	r2, r4
10000348:	088c      	lsrs	r4, r1, #2
1000034a:	42a0      	cmp	r0, r4
1000034c:	d302      	bcc.n	10000354 <.udivsi3_skip_div0_test+0x4c>
1000034e:	1b00      	subs	r0, r0, r4
10000350:	089c      	lsrs	r4, r3, #2
10000352:	4322      	orrs	r2, r4
10000354:	08cc      	lsrs	r4, r1, #3
10000356:	42a0      	cmp	r0, r4
10000358:	d302      	bcc.n	10000360 <.udivsi3_skip_div0_test+0x58>
1000035a:	1b00      	subs	r0, r0, r4
1000035c:	08dc      	lsrs	r4, r3, #3
1000035e:	4322      	orrs	r2, r4
10000360:	2800      	cmp	r0, #0
10000362:	d003      	beq.n	1000036c <.udivsi3_skip_div0_test+0x64>
10000364:	091b      	lsrs	r3, r3, #4
10000366:	d001      	beq.n	1000036c <.udivsi3_skip_div0_test+0x64>
10000368:	0909      	lsrs	r1, r1, #4
1000036a:	e7e3      	b.n	10000334 <.udivsi3_skip_div0_test+0x2c>
1000036c:	0010      	movs	r0, r2
1000036e:	bc10      	pop	{r4}
10000370:	4770      	bx	lr
10000372:	b501      	push	{r0, lr}
10000374:	2000      	movs	r0, #0
10000376:	f000 f80b 	bl	10000390 <__aeabi_idiv0>
1000037a:	bd02      	pop	{r1, pc}

1000037c <__aeabi_uidivmod>:
1000037c:	2900      	cmp	r1, #0
1000037e:	d0f8      	beq.n	10000372 <.udivsi3_skip_div0_test+0x6a>
10000380:	b503      	push	{r0, r1, lr}
10000382:	f7ff ffc1 	bl	10000308 <.udivsi3_skip_div0_test>
10000386:	bc0e      	pop	{r1, r2, r3}
10000388:	4342      	muls	r2, r0
1000038a:	1a89      	subs	r1, r1, r2
1000038c:	4718      	bx	r3
1000038e:	46c0      	nop			@ (mov r8, r8)

10000390 <__aeabi_idiv0>:
10000390:	4770      	bx	lr
10000392:	46c0      	nop			@ (mov r8, r8)

10000394 <memmove>:
10000394:	b5f0      	push	{r4, r5, r6, r7, lr}
10000396:	46ce      	mov	lr, r9
10000398:	4647      	mov	r7, r8
1000039a:	b580      	push	{r7, lr}
1000039c:	4288      	cmp	r0, r1
1000039e:	d90d      	bls.n	100003bc <memmove+0x28>
100003a0:	188b      	adds	r3, r1, r2
100003a2:	4298      	cmp	r0, r3
100003a4:	d20a      	bcs.n	100003bc <memmove+0x28>
100003a6:	1e53      	subs	r3, r2, #1
100003a8:	2a00      	cmp	r2, #0
100003aa:	d003      	beq.n	100003b4 <memmove+0x20>
100003ac:	5cca      	ldrb	r2, [r1, r3]
100003ae:	54c2      	strb	r2, [r0, r3]
100003b0:	3b01      	subs	r3, #1
100003b2:	d2fb      	bcs.n	100003ac <memmove+0x18>
100003b4:	bcc0      	pop	{r6, r7}
100003b6:	46b9      	mov	r9, r7
100003b8:	46b0      	mov	r8, r6
100003ba:	bdf0      	pop	{r4, r5, r6, r7, pc}
100003bc:	2a0f      	cmp	r2, #15
100003be:	d80b      	bhi.n	100003d8 <memmove+0x44>
100003c0:	0005      	movs	r5, r0
100003c2:	1e56      	subs	r6, r2, #1
100003c4:	2a00      	cmp	r2, #0
100003c6:	d0f5      	beq.n	100003b4 <memmove+0x20>
100003c8:	2300      	movs	r3, #0
100003ca:	5ccc      	ldrb	r4, [r1, r3]
100003cc:	001a      	movs	r2, r3
100003ce:	54ec      	strb	r4, [r5, r3]
100003d0:	3301      	adds	r3, #1
100003d2:	4296      	cmp	r6, r2
100003d4:	d1f9      	bne.n	100003ca <memmove+0x36>
100003d6:	e7ed      	b.n	100003b4 <memmove+0x20>
100003d8:	0003      	movs	r3, r0
100003da:	430b      	orrs	r3, r1
100003dc:	4688      	mov	r8, r1
100003de:	079b      	lsls	r3, r3, #30
100003e0:	d134      	bne.n	1000044c <memmove+0xb8>
100003e2:	2610      	movs	r6, #16
100003e4:	0017      	movs	r7, r2
100003e6:	46b1      	mov	r9, r6
100003e8:	000c      	movs	r4, r1
100003ea:	0003      	movs	r3, r0
100003ec:	3f10      	subs	r7, #16
100003ee:	093f      	lsrs	r7, r7, #4
100003f0:	013f      	lsls	r7, r7, #4
100003f2:	19c5      	adds	r5, r0, r7
100003f4:	44a9      	add	r9, r5
100003f6:	6826      	ldr	r6, [r4, #0]
100003f8:	601e      	str	r6, [r3, #0]
100003fa:	6866      	ldr	r6, [r4, #4]
100003fc:	605e      	str	r6, [r3, #4]
100003fe:	68a6      	ldr	r6, [r4, #8]
10000400:	609e      	str	r6, [r3, #8]
10000402:	68e6      	ldr	r6, [r4, #12]
10000404:	3410      	adds	r4, #16
10000406:	60de      	str	r6, [r3, #12]
10000408:	001e      	movs	r6, r3
1000040a:	3310      	adds	r3, #16
1000040c:	42ae      	cmp	r6, r5
1000040e:	d1f2      	bne.n	100003f6 <memmove+0x62>
10000410:	19cf      	adds	r7, r1, r7
10000412:	0039      	movs	r1, r7
10000414:	230f      	movs	r3, #15
10000416:	260c      	movs	r6, #12
10000418:	3110      	adds	r1, #16
1000041a:	468c      	mov	ip, r1
1000041c:	4013      	ands	r3, r2
1000041e:	4216      	tst	r6, r2
10000420:	d017      	beq.n	10000452 <memmove+0xbe>
10000422:	4644      	mov	r4, r8
10000424:	3b04      	subs	r3, #4
10000426:	089b      	lsrs	r3, r3, #2
10000428:	009b      	lsls	r3, r3, #2
1000042a:	18ff      	adds	r7, r7, r3
1000042c:	3714      	adds	r7, #20
1000042e:	1b06      	subs	r6, r0, r4
10000430:	680c      	ldr	r4, [r1, #0]
10000432:	198d      	adds	r5, r1, r6
10000434:	3104      	adds	r1, #4
10000436:	602c      	str	r4, [r5, #0]
10000438:	42b9      	cmp	r1, r7
1000043a:	d1f9      	bne.n	10000430 <memmove+0x9c>
1000043c:	4661      	mov	r1, ip
1000043e:	3304      	adds	r3, #4
10000440:	1859      	adds	r1, r3, r1
10000442:	444b      	add	r3, r9
10000444:	001d      	movs	r5, r3
10000446:	2303      	movs	r3, #3
10000448:	401a      	ands	r2, r3
1000044a:	e7ba      	b.n	100003c2 <memmove+0x2e>
1000044c:	0005      	movs	r5, r0
1000044e:	1e56      	subs	r6, r2, #1
10000450:	e7ba      	b.n	100003c8 <memmove+0x34>
10000452:	464d      	mov	r5, r9
10000454:	001a      	movs	r2, r3
10000456:	e7b4      	b.n	100003c2 <memmove+0x2e>
