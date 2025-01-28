
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
	...
1000012c:	100002cd 00000000 00000000 100002cd     ................
1000013c:	1000027d                                }...

10000140 <_Z25external_crystal_osc_initv>:
#define RESETS_RESET_DONE           (*(volatile uint32_t *) (RESETS_BASE + 0x008))

void external_crystal_osc_init()
{
    // Assumes 1-15 MHz input, checked above.
    xosc_hw->ctrl = XOSC_CTRL_FREQ_RANGE_VALUE_1_15MHZ;
10000140:	4b06      	ldr	r3, [pc, #24]	@ (1000015c <_Z25external_crystal_osc_initv+0x1c>)
10000142:	22aa      	movs	r2, #170	@ 0xaa
10000144:	0112      	lsls	r2, r2, #4
10000146:	601a      	str	r2, [r3, #0]

    constexpr uint32_t STARTUP_DELAY = (((XOSC_HZ / 1000) + 128) / 256);
    // Set xosc startup delay
    xosc_hw->startup = STARTUP_DELAY;
10000148:	222f      	movs	r2, #47	@ 0x2f
1000014a:	60da      	str	r2, [r3, #12]
 *
 * \param addr Address of writable register
 * \param mask Bit-mask specifying bits to set
 */
__force_inline static void hw_set_bits(io_rw_32 *addr, uint32_t mask) {
    *(io_rw_32 *) hw_set_alias_untyped((volatile void *) addr) = mask;
1000014c:	4b04      	ldr	r3, [pc, #16]	@ (10000160 <_Z25external_crystal_osc_initv+0x20>)
1000014e:	4a05      	ldr	r2, [pc, #20]	@ (10000164 <_Z25external_crystal_osc_initv+0x24>)
10000150:	601a      	str	r2, [r3, #0]

    // Set the enable bit now that we have set freq range and startup delay
    hw_set_bits(&xosc_hw->ctrl, XOSC_CTRL_ENABLE_VALUE_ENABLE << XOSC_CTRL_ENABLE_LSB);

    // Wait for XOSC to be stable
    while((xosc_hw->status & XOSC_STATUS_STABLE_BITS) == 0) 
10000152:	4b02      	ldr	r3, [pc, #8]	@ (1000015c <_Z25external_crystal_osc_initv+0x1c>)
10000154:	685b      	ldr	r3, [r3, #4]
10000156:	2b00      	cmp	r3, #0
10000158:	dafb      	bge.n	10000152 <_Z25external_crystal_osc_initv+0x12>
    {
    }
}
1000015a:	4770      	bx	lr
1000015c:	40024000 	.word	0x40024000
10000160:	40026000 	.word	0x40026000
10000164:	00fab000 	.word	0x00fab000

10000168 <_Z15pll_120MHz_initv>:

void pll_120MHz_init()
{
    // Initialize System PLL
    RESETS_RESET &= ~(1 << 12); // Bring System PLL out of reset state
10000168:	4a0d      	ldr	r2, [pc, #52]	@ (100001a0 <_Z15pll_120MHz_initv+0x38>)
1000016a:	6813      	ldr	r3, [r2, #0]
1000016c:	490d      	ldr	r1, [pc, #52]	@ (100001a4 <_Z15pll_120MHz_initv+0x3c>)
1000016e:	400b      	ands	r3, r1
10000170:	6013      	str	r3, [r2, #0]
    // Wait for PLL peripheral to respond
    while ((RESETS_RESET_DONE & (1 << 12)) == 0) {}
10000172:	4b0d      	ldr	r3, [pc, #52]	@ (100001a8 <_Z15pll_120MHz_initv+0x40>)
10000174:	681b      	ldr	r3, [r3, #0]
10000176:	04db      	lsls	r3, r3, #19
10000178:	d5fb      	bpl.n	10000172 <_Z15pll_120MHz_initv+0xa>

    // Set feedback clock div = 100, thus VCO clock = 12MHz * 100 = 1.2GHz
    pll_sys_hw->fbdiv_int = 100;
1000017a:	4b0c      	ldr	r3, [pc, #48]	@ (100001ac <_Z15pll_120MHz_initv+0x44>)
1000017c:	2264      	movs	r2, #100	@ 0x64
1000017e:	609a      	str	r2, [r3, #8]
 *
 * \param addr Address of writable register
 * \param mask Bit-mask specifying bits to clear
 */
__force_inline static void hw_clear_bits(io_rw_32 *addr, uint32_t mask) {
    *(io_rw_32 *) hw_clear_alias_untyped((volatile void *) addr) = mask;
10000180:	4b0b      	ldr	r3, [pc, #44]	@ (100001b0 <_Z15pll_120MHz_initv+0x48>)
10000182:	3a43      	subs	r2, #67	@ 0x43
10000184:	601a      	str	r2, [r3, #0]
                     PLL_PWR_VCOPD_BITS; // VCO Power

    hw_clear_bits(&pll_sys_hw->pwr, power);

     // Wait for PLL to lock
    while ((pll_sys_hw->cs & PLL_CS_LOCK_BITS) == 0) {}
10000186:	4b09      	ldr	r3, [pc, #36]	@ (100001ac <_Z15pll_120MHz_initv+0x44>)
10000188:	681b      	ldr	r3, [r3, #0]
1000018a:	2b00      	cmp	r3, #0
1000018c:	dafb      	bge.n	10000186 <_Z15pll_120MHz_initv+0x1e>
    constexpr uint32_t post_div2 = 2;
    constexpr uint32_t pdiv = (post_div1 << PLL_PRIM_POSTDIV1_LSB) |
                    (post_div2 << PLL_PRIM_POSTDIV2_LSB);

     // Set up post dividers
    pll_sys_hw->prim = pdiv;
1000018e:	4b07      	ldr	r3, [pc, #28]	@ (100001ac <_Z15pll_120MHz_initv+0x44>)
10000190:	22a4      	movs	r2, #164	@ 0xa4
10000192:	02d2      	lsls	r2, r2, #11
10000194:	60da      	str	r2, [r3, #12]
10000196:	4b06      	ldr	r3, [pc, #24]	@ (100001b0 <_Z15pll_120MHz_initv+0x48>)
10000198:	2208      	movs	r2, #8
1000019a:	601a      	str	r2, [r3, #0]

    // Turn on post divider
    hw_clear_bits(&pll_sys_hw->pwr, PLL_PWR_POSTDIVPD_BITS);
}
1000019c:	4770      	bx	lr
1000019e:	46c0      	nop			@ (mov r8, r8)
100001a0:	4000c000 	.word	0x4000c000
100001a4:	ffffefff 	.word	0xffffefff
100001a8:	4000c008 	.word	0x4000c008
100001ac:	40028000 	.word	0x40028000
100001b0:	4002b004 	.word	0x4002b004

100001b4 <_Z14clock_ref_initv>:
 * \param addr Address of writable register
 * \param values Bits values
 * \param write_mask Mask of bits to change
 */
__force_inline static void hw_write_masked(io_rw_32 *addr, uint32_t values, uint32_t write_mask) {
    hw_xor_bits(addr, (*addr ^ values) & write_mask);
100001b4:	4b06      	ldr	r3, [pc, #24]	@ (100001d0 <_Z14clock_ref_initv+0x1c>)
100001b6:	681a      	ldr	r2, [r3, #0]
100001b8:	2302      	movs	r3, #2
100001ba:	405a      	eors	r2, r3
100001bc:	3301      	adds	r3, #1
100001be:	4013      	ands	r3, r2
    *(io_rw_32 *) hw_xor_alias_untyped((volatile void *) addr) = mask;
100001c0:	4a04      	ldr	r2, [pc, #16]	@ (100001d4 <_Z14clock_ref_initv+0x20>)
100001c2:	6013      	str	r3, [r2, #0]
            CLOCKS_CLK_REF_CTRL_SRC_BITS
        );
    //2.15.7. List of Registers in datasheet  CLK_REF_SELECTED
    //Wait for bit setting indicating that mux is switched
    //Bit position refers to value written to CTRL_SRC
    while ((clock_ref_hw->selected & (1u << 2)) == 0)
100001c4:	4b02      	ldr	r3, [pc, #8]	@ (100001d0 <_Z14clock_ref_initv+0x1c>)
100001c6:	689b      	ldr	r3, [r3, #8]
100001c8:	075b      	lsls	r3, r3, #29
100001ca:	d5fb      	bpl.n	100001c4 <_Z14clock_ref_initv+0x10>
    {

    }
}
100001cc:	4770      	bx	lr
100001ce:	46c0      	nop			@ (mov r8, r8)
100001d0:	40008030 	.word	0x40008030
100001d4:	40009030 	.word	0x40009030

100001d8 <_Z17clock_sysclk_initv>:
    hw_xor_bits(addr, (*addr ^ values) & write_mask);
100001d8:	4b05      	ldr	r3, [pc, #20]	@ (100001f0 <_Z17clock_sysclk_initv+0x18>)
100001da:	681a      	ldr	r2, [r3, #0]
100001dc:	2301      	movs	r3, #1
100001de:	4393      	bics	r3, r2
    *(io_rw_32 *) hw_xor_alias_untyped((volatile void *) addr) = mask;
100001e0:	4a04      	ldr	r2, [pc, #16]	@ (100001f4 <_Z17clock_sysclk_initv+0x1c>)
100001e2:	6013      	str	r3, [r2, #0]
        );

    //Wait for bit setting indicating that mux is switched
    //2.15.7. List of Registers in datasheet CLK_SYS_SELECTED
    //Bit position refers to value written to CTRL_SRC
    while ((clock_sys_hw->selected & (1u << CLOCKS_CLK_SYS_CTRL_SRC_VALUE_CLKSRC_CLK_SYS_AUX)) == 0)
100001e4:	4b02      	ldr	r3, [pc, #8]	@ (100001f0 <_Z17clock_sysclk_initv+0x18>)
100001e6:	689b      	ldr	r3, [r3, #8]
100001e8:	079b      	lsls	r3, r3, #30
100001ea:	d5fb      	bpl.n	100001e4 <_Z17clock_sysclk_initv+0xc>
    {

    }
}
100001ec:	4770      	bx	lr
100001ee:	46c0      	nop			@ (mov r8, r8)
100001f0:	4000803c 	.word	0x4000803c
100001f4:	4000903c 	.word	0x4000903c

100001f8 <_Z13rosc_shutdownv>:
    hw_xor_bits(addr, (*addr ^ values) & write_mask);
100001f8:	4b04      	ldr	r3, [pc, #16]	@ (1000020c <_Z13rosc_shutdownv+0x14>)
100001fa:	681a      	ldr	r2, [r3, #0]
100001fc:	4b04      	ldr	r3, [pc, #16]	@ (10000210 <_Z13rosc_shutdownv+0x18>)
100001fe:	4053      	eors	r3, r2
10000200:	4a04      	ldr	r2, [pc, #16]	@ (10000214 <_Z13rosc_shutdownv+0x1c>)
10000202:	4013      	ands	r3, r2
    *(io_rw_32 *) hw_xor_alias_untyped((volatile void *) addr) = mask;
10000204:	4a04      	ldr	r2, [pc, #16]	@ (10000218 <_Z13rosc_shutdownv+0x20>)
10000206:	6013      	str	r3, [r2, #0]

void rosc_shutdown()
{
    hw_write_masked(&xosc_hw->ctrl, XOSC_CTRL_ENABLE_VALUE_DISABLE, XOSC_CTRL_ENABLE_BITS);
}
10000208:	4770      	bx	lr
1000020a:	46c0      	nop			@ (mov r8, r8)
1000020c:	40024000 	.word	0x40024000
10000210:	00000d1e 	.word	0x00000d1e
10000214:	00fff000 	.word	0x00fff000
10000218:	40025000 	.word	0x40025000

1000021c <_Z17clock_init_120MHzv>:

void clock_init_120MHz()
{
1000021c:	b510      	push	{r4, lr}
    external_crystal_osc_init();
1000021e:	f7ff ff8f 	bl	10000140 <_Z25external_crystal_osc_initv>
    pll_120MHz_init();
10000222:	f7ff ffa1 	bl	10000168 <_Z15pll_120MHz_initv>
    clock_ref_init();
10000226:	f7ff ffc5 	bl	100001b4 <_Z14clock_ref_initv>
    clock_sysclk_init();
1000022a:	f7ff ffd5 	bl	100001d8 <_Z17clock_sysclk_initv>
    rosc_shutdown();
1000022e:	f7ff ffe3 	bl	100001f8 <_Z13rosc_shutdownv>
}
10000232:	bd10      	pop	{r4, pc}

10000234 <_ZN3ledC1Ev>:
public:
    led()
    {
        //Activate IO_BANK0 ba setting bit 5 to 0
        //rp2040 datasheet 2.14.3. List of Registers
        RESETS_BASE_REG &= ~(1 << 5);
10000234:	4a09      	ldr	r2, [pc, #36]	@ (1000025c <_ZN3ledC1Ev+0x28>)
10000236:	6813      	ldr	r3, [r2, #0]
10000238:	2120      	movs	r1, #32
1000023a:	438b      	bics	r3, r1
1000023c:	6013      	str	r3, [r2, #0]

        //RESETS: RESET_DONE Register
        //Offset: 0x8
        //Wait for IO_BANK0 to be ready bit 5 should be  set
        while (!( RESET_DONE & (1 << 5)));
1000023e:	4b08      	ldr	r3, [pc, #32]	@ (10000260 <_ZN3ledC1Ev+0x2c>)
10000240:	681b      	ldr	r3, [r3, #0]
10000242:	069b      	lsls	r3, r3, #26
10000244:	d5fb      	bpl.n	1000023e <_ZN3ledC1Ev+0xa>

        //2.19.6. List of Registers
        //2.19.6.1. IO - User Bank
        //0x0cc GPIO25_CTRL GPIO control including function select and overrides
        // GPIO 25 BANK 0 CTRL
        GPIO25_CTRL = 5;
10000246:	4b07      	ldr	r3, [pc, #28]	@ (10000264 <_ZN3ledC1Ev+0x30>)
10000248:	2205      	movs	r2, #5
1000024a:	601a      	str	r2, [r3, #0]
        //SIO: GPIO_OE_SET Register
        //Offset: 0x024
        //Description
        //GPIO output enable set
        //GPIO 25 as Outputs using SIO
        GPIO_OE_SET |= 1 << 25;
1000024c:	4a06      	ldr	r2, [pc, #24]	@ (10000268 <_ZN3ledC1Ev+0x34>)
1000024e:	6811      	ldr	r1, [r2, #0]
10000250:	2380      	movs	r3, #128	@ 0x80
10000252:	049b      	lsls	r3, r3, #18
10000254:	430b      	orrs	r3, r1
10000256:	6013      	str	r3, [r2, #0]
    }
10000258:	4770      	bx	lr
1000025a:	46c0      	nop			@ (mov r8, r8)
1000025c:	4000c000 	.word	0x4000c000
10000260:	4000c008 	.word	0x4000c008
10000264:	400140cc 	.word	0x400140cc
10000268:	d0000024 	.word	0xd0000024

1000026c <_Z41__static_initialization_and_destruction_0v>:

    while (true)
    {
        __asm("  wfi");
    }
1000026c:	b510      	push	{r4, lr}
led blue_led;
1000026e:	4802      	ldr	r0, [pc, #8]	@ (10000278 <_Z41__static_initialization_and_destruction_0v+0xc>)
10000270:	f7ff ffe0 	bl	10000234 <_ZN3ledC1Ev>
10000274:	bd10      	pop	{r4, pc}
10000276:	46c0      	nop			@ (mov r8, r8)
10000278:	20000000 	.word	0x20000000

1000027c <_Z15SysTick_Handlerv>:
        GPIO_OUT_XOR |= 1 << 25;
1000027c:	4a03      	ldr	r2, [pc, #12]	@ (1000028c <_Z15SysTick_Handlerv+0x10>)
1000027e:	6811      	ldr	r1, [r2, #0]
10000280:	2380      	movs	r3, #128	@ 0x80
10000282:	049b      	lsls	r3, r3, #18
10000284:	430b      	orrs	r3, r1
10000286:	6013      	str	r3, [r2, #0]
}
10000288:	4770      	bx	lr
1000028a:	46c0      	nop			@ (mov r8, r8)
1000028c:	d000001c 	.word	0xd000001c

10000290 <_Z12systick_initv>:
    systick_hw->rvr = 120000000/10;
10000290:	4b02      	ldr	r3, [pc, #8]	@ (1000029c <_Z12systick_initv+0xc>)
10000292:	4a03      	ldr	r2, [pc, #12]	@ (100002a0 <_Z12systick_initv+0x10>)
10000294:	605a      	str	r2, [r3, #4]
    systick_hw->csr =   M0PLUS_SYST_CSR_CLKSOURCE_BITS | 
10000296:	2207      	movs	r2, #7
10000298:	601a      	str	r2, [r3, #0]
}
1000029a:	4770      	bx	lr
1000029c:	e000e010 	.word	0xe000e010
100002a0:	00b71b00 	.word	0x00b71b00

100002a4 <main>:
{
100002a4:	b510      	push	{r4, lr}
    clock_init_120MHz();
100002a6:	f7ff ffb9 	bl	1000021c <_Z17clock_init_120MHzv>
        GPIO_OUT_CLR |= 1 << 25;
100002aa:	4a05      	ldr	r2, [pc, #20]	@ (100002c0 <main+0x1c>)
100002ac:	6811      	ldr	r1, [r2, #0]
100002ae:	2380      	movs	r3, #128	@ 0x80
100002b0:	049b      	lsls	r3, r3, #18
100002b2:	430b      	orrs	r3, r1
100002b4:	6013      	str	r3, [r2, #0]
    systick_init();
100002b6:	f7ff ffeb 	bl	10000290 <_Z12systick_initv>
        __asm("  wfi");
100002ba:	bf30      	wfi
    while (true)
100002bc:	e7fd      	b.n	100002ba <main+0x16>
100002be:	46c0      	nop			@ (mov r8, r8)
100002c0:	d0000018 	.word	0xd0000018

100002c4 <_GLOBAL__sub_I_GPIO_OUT_XOR>:
100002c4:	b510      	push	{r4, lr}
100002c6:	f7ff ffd1 	bl	1000026c <_Z41__static_initialization_and_destruction_0v>
100002ca:	bd10      	pop	{r4, pc}

100002cc <Default_Handler>:
extern "C" void(*__init_array_end [])(void);

//extern "C" makes a function-name in C++ have C linkage (compiler does not mangle the name)
extern "C" void Default_Handler(void)
{
     while(1)
100002cc:	e7fe      	b.n	100002cc <Default_Handler>

100002ce <_ZSt8for_eachIPPFvvEZ13Reset_HandlerEUlS1_E_ET0_T_S5_S4_>:
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
100002d4:	e001      	b.n	100002da <_ZSt8for_eachIPPFvvEZ13Reset_HandlerEUlS1_E_ET0_T_S5_S4_+0xc>
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
100002dc:	d1fb      	bne.n	100002d6 <_ZSt8for_eachIPPFvvEZ13Reset_HandlerEUlS1_E_ET0_T_S5_S4_+0x8>
      return __f; // N.B. [alg.foreach] says std::move(f) but it's redundant.
    }
100002de:	2000      	movs	r0, #0
100002e0:	bd70      	pop	{r4, r5, r6, pc}

100002e2 <_ZSt8for_eachIPPFvvEZ13Reset_HandlerEUlS1_E0_ET0_T_S5_S4_>:
    for_each(_InputIterator __first, _InputIterator __last, _Function __f)
100002e2:	b570      	push	{r4, r5, r6, lr}
100002e4:	0004      	movs	r4, r0
100002e6:	000d      	movs	r5, r1
      for (; __first != __last; ++__first)
100002e8:	e001      	b.n	100002ee <_ZSt8for_eachIPPFvvEZ13Reset_HandlerEUlS1_E0_ET0_T_S5_S4_+0xc>
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
100002f0:	d1fb      	bne.n	100002ea <_ZSt8for_eachIPPFvvEZ13Reset_HandlerEUlS1_E0_ET0_T_S5_S4_+0x8>
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
10000310:	f000 f836 	bl	10000380 <memmove>
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

10000324 <Reset_Handler>:
{
10000324:	b510      	push	{r4, lr}
  auto data_length = &__data_end__ - &__data_start__;
10000326:	4b0d      	ldr	r3, [pc, #52]	@ (1000035c <Reset_Handler+0x38>)
10000328:	4a0d      	ldr	r2, [pc, #52]	@ (10000360 <Reset_Handler+0x3c>)
1000032a:	1a99      	subs	r1, r3, r2
  auto data_source_end = &__start_data_at_flash + data_length;
1000032c:	480d      	ldr	r0, [pc, #52]	@ (10000364 <Reset_Handler+0x40>)
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
10000334:	4b0c      	ldr	r3, [pc, #48]	@ (10000368 <Reset_Handler+0x44>)
10000336:	e001      	b.n	1000033c <Reset_Handler+0x18>
	*__first = __tmp;
10000338:	2200      	movs	r2, #0
1000033a:	c304      	stmia	r3!, {r2}
      for (; __first != __last; ++__first)
1000033c:	4a0b      	ldr	r2, [pc, #44]	@ (1000036c <Reset_Handler+0x48>)
1000033e:	4293      	cmp	r3, r2
10000340:	d1fa      	bne.n	10000338 <Reset_Handler+0x14>
  std::for_each( __preinit_array_start,
10000342:	490b      	ldr	r1, [pc, #44]	@ (10000370 <Reset_Handler+0x4c>)
10000344:	480b      	ldr	r0, [pc, #44]	@ (10000374 <Reset_Handler+0x50>)
10000346:	2200      	movs	r2, #0
10000348:	f7ff ffc1 	bl	100002ce <_ZSt8for_eachIPPFvvEZ13Reset_HandlerEUlS1_E_ET0_T_S5_S4_>
  std::for_each( __init_array_start,
1000034c:	490a      	ldr	r1, [pc, #40]	@ (10000378 <Reset_Handler+0x54>)
1000034e:	480b      	ldr	r0, [pc, #44]	@ (1000037c <Reset_Handler+0x58>)
10000350:	2200      	movs	r2, #0
10000352:	f7ff ffc6 	bl	100002e2 <_ZSt8for_eachIPPFvvEZ13Reset_HandlerEUlS1_E0_ET0_T_S5_S4_>

  main();
10000356:	f7ff ffa5 	bl	100002a4 <main>
  // .fini_array
  //   This section holds an array of function pointers 
  //   that contributes to a single termination array for 
  //   the executable or shared object containing the section.
  // Ececution of this part is not necessary because main should never return
  for (;;);
1000035a:	e7fe      	b.n	1000035a <Reset_Handler+0x36>
1000035c:	20000000 	.word	0x20000000
10000360:	20000000 	.word	0x20000000
10000364:	10000448 	.word	0x10000448
10000368:	20000000 	.word	0x20000000
1000036c:	20000004 	.word	0x20000004
10000370:	10000444 	.word	0x10000444
10000374:	10000444 	.word	0x10000444
10000378:	10000448 	.word	0x10000448
1000037c:	10000444 	.word	0x10000444

10000380 <memmove>:
10000380:	b5f0      	push	{r4, r5, r6, r7, lr}
10000382:	46ce      	mov	lr, r9
10000384:	4647      	mov	r7, r8
10000386:	b580      	push	{r7, lr}
10000388:	4288      	cmp	r0, r1
1000038a:	d90d      	bls.n	100003a8 <memmove+0x28>
1000038c:	188b      	adds	r3, r1, r2
1000038e:	4298      	cmp	r0, r3
10000390:	d20a      	bcs.n	100003a8 <memmove+0x28>
10000392:	1e53      	subs	r3, r2, #1
10000394:	2a00      	cmp	r2, #0
10000396:	d003      	beq.n	100003a0 <memmove+0x20>
10000398:	5cca      	ldrb	r2, [r1, r3]
1000039a:	54c2      	strb	r2, [r0, r3]
1000039c:	3b01      	subs	r3, #1
1000039e:	d2fb      	bcs.n	10000398 <memmove+0x18>
100003a0:	bcc0      	pop	{r6, r7}
100003a2:	46b9      	mov	r9, r7
100003a4:	46b0      	mov	r8, r6
100003a6:	bdf0      	pop	{r4, r5, r6, r7, pc}
100003a8:	2a0f      	cmp	r2, #15
100003aa:	d80b      	bhi.n	100003c4 <memmove+0x44>
100003ac:	0005      	movs	r5, r0
100003ae:	1e56      	subs	r6, r2, #1
100003b0:	2a00      	cmp	r2, #0
100003b2:	d0f5      	beq.n	100003a0 <memmove+0x20>
100003b4:	2300      	movs	r3, #0
100003b6:	5ccc      	ldrb	r4, [r1, r3]
100003b8:	001a      	movs	r2, r3
100003ba:	54ec      	strb	r4, [r5, r3]
100003bc:	3301      	adds	r3, #1
100003be:	4296      	cmp	r6, r2
100003c0:	d1f9      	bne.n	100003b6 <memmove+0x36>
100003c2:	e7ed      	b.n	100003a0 <memmove+0x20>
100003c4:	0003      	movs	r3, r0
100003c6:	430b      	orrs	r3, r1
100003c8:	4688      	mov	r8, r1
100003ca:	079b      	lsls	r3, r3, #30
100003cc:	d134      	bne.n	10000438 <memmove+0xb8>
100003ce:	2610      	movs	r6, #16
100003d0:	0017      	movs	r7, r2
100003d2:	46b1      	mov	r9, r6
100003d4:	000c      	movs	r4, r1
100003d6:	0003      	movs	r3, r0
100003d8:	3f10      	subs	r7, #16
100003da:	093f      	lsrs	r7, r7, #4
100003dc:	013f      	lsls	r7, r7, #4
100003de:	19c5      	adds	r5, r0, r7
100003e0:	44a9      	add	r9, r5
100003e2:	6826      	ldr	r6, [r4, #0]
100003e4:	601e      	str	r6, [r3, #0]
100003e6:	6866      	ldr	r6, [r4, #4]
100003e8:	605e      	str	r6, [r3, #4]
100003ea:	68a6      	ldr	r6, [r4, #8]
100003ec:	609e      	str	r6, [r3, #8]
100003ee:	68e6      	ldr	r6, [r4, #12]
100003f0:	3410      	adds	r4, #16
100003f2:	60de      	str	r6, [r3, #12]
100003f4:	001e      	movs	r6, r3
100003f6:	3310      	adds	r3, #16
100003f8:	42ae      	cmp	r6, r5
100003fa:	d1f2      	bne.n	100003e2 <memmove+0x62>
100003fc:	19cf      	adds	r7, r1, r7
100003fe:	0039      	movs	r1, r7
10000400:	230f      	movs	r3, #15
10000402:	260c      	movs	r6, #12
10000404:	3110      	adds	r1, #16
10000406:	468c      	mov	ip, r1
10000408:	4013      	ands	r3, r2
1000040a:	4216      	tst	r6, r2
1000040c:	d017      	beq.n	1000043e <memmove+0xbe>
1000040e:	4644      	mov	r4, r8
10000410:	3b04      	subs	r3, #4
10000412:	089b      	lsrs	r3, r3, #2
10000414:	009b      	lsls	r3, r3, #2
10000416:	18ff      	adds	r7, r7, r3
10000418:	3714      	adds	r7, #20
1000041a:	1b06      	subs	r6, r0, r4
1000041c:	680c      	ldr	r4, [r1, #0]
1000041e:	198d      	adds	r5, r1, r6
10000420:	3104      	adds	r1, #4
10000422:	602c      	str	r4, [r5, #0]
10000424:	42b9      	cmp	r1, r7
10000426:	d1f9      	bne.n	1000041c <memmove+0x9c>
10000428:	4661      	mov	r1, ip
1000042a:	3304      	adds	r3, #4
1000042c:	1859      	adds	r1, r3, r1
1000042e:	444b      	add	r3, r9
10000430:	001d      	movs	r5, r3
10000432:	2303      	movs	r3, #3
10000434:	401a      	ands	r2, r3
10000436:	e7ba      	b.n	100003ae <memmove+0x2e>
10000438:	0005      	movs	r5, r0
1000043a:	1e56      	subs	r6, r2, #1
1000043c:	e7ba      	b.n	100003b4 <memmove+0x34>
1000043e:	464d      	mov	r5, r9
10000440:	001a      	movs	r2, r3
10000442:	e7b4      	b.n	100003ae <memmove+0x2e>
