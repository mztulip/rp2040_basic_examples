
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

10000100 <interrupt_vectors>:
10000100:	20040000 10000309 10000301 10000301     ... ............

10000110 <delay>:
const int counter_max = 500;
uint32_t counter_compare_value = 100;
uint32_t counter = 0;

void delay(void)
{
10000110:	b580      	push	{r7, lr}
10000112:	b082      	sub	sp, #8
10000114:	af00      	add	r7, sp, #0
    for (volatile uint32_t i = 0; i < 123456/8; ++i)
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
10000134:	00003c47 	.word	0x00003c47

10000138 <failed>:

void failed(void)
{
10000138:	b580      	push	{r7, lr}
1000013a:	af00      	add	r7, sp, #0
    while (true)
    {
        delay();
1000013c:	f7ff ffe8 	bl	10000110 <delay>
        // SIO: GPIO_OUT_XOR Register
        // Offset: 0x01c
        // Description
        // GPIO output value XO
        // xor bit for GPIO 25 changing led state
        *(volatile uint32_t *) (SIO_BASE+0x1c) |= 1 << 25;
10000140:	4b03      	ldr	r3, [pc, #12]	@ (10000150 <failed+0x18>)
10000142:	681a      	ldr	r2, [r3, #0]
10000144:	4b02      	ldr	r3, [pc, #8]	@ (10000150 <failed+0x18>)
10000146:	2180      	movs	r1, #128	@ 0x80
10000148:	0489      	lsls	r1, r1, #18
1000014a:	430a      	orrs	r2, r1
1000014c:	601a      	str	r2, [r3, #0]
        delay();
1000014e:	e7f5      	b.n	1000013c <failed+0x4>
10000150:	d000001c 	.word	0xd000001c

10000154 <led_on>:
    }
}


void led_on(void)
{
10000154:	b580      	push	{r7, lr}
10000156:	af00      	add	r7, sp, #0
    //2.3.1.7. List of Registers
    // SIO: GPIO_OUT_SET Register
    // Offset: 0x014
    // Description
    // GPIO output value set
    *(volatile uint32_t *) (SIO_BASE+0x14) |= 1 << 25;
10000158:	4b04      	ldr	r3, [pc, #16]	@ (1000016c <led_on+0x18>)
1000015a:	681a      	ldr	r2, [r3, #0]
1000015c:	4b03      	ldr	r3, [pc, #12]	@ (1000016c <led_on+0x18>)
1000015e:	2180      	movs	r1, #128	@ 0x80
10000160:	0489      	lsls	r1, r1, #18
10000162:	430a      	orrs	r2, r1
10000164:	601a      	str	r2, [r3, #0]
}
10000166:	46c0      	nop			@ (mov r8, r8)
10000168:	46bd      	mov	sp, r7
1000016a:	bd80      	pop	{r7, pc}
1000016c:	d0000014 	.word	0xd0000014

10000170 <led_off>:

void led_off(void)
{
10000170:	b580      	push	{r7, lr}
10000172:	af00      	add	r7, sp, #0
    //2.3.1.7. List of Registers
    // SIO: GPIO_OUT_CLR Register
    // Offset: 0x018
    // Description
    // GPIO output value clear
    *(volatile uint32_t *) (SIO_BASE+0x18) |= 1 << 25;
10000174:	4b04      	ldr	r3, [pc, #16]	@ (10000188 <led_off+0x18>)
10000176:	681a      	ldr	r2, [r3, #0]
10000178:	4b03      	ldr	r3, [pc, #12]	@ (10000188 <led_off+0x18>)
1000017a:	2180      	movs	r1, #128	@ 0x80
1000017c:	0489      	lsls	r1, r1, #18
1000017e:	430a      	orrs	r2, r1
10000180:	601a      	str	r2, [r3, #0]
}
10000182:	46c0      	nop			@ (mov r8, r8)
10000184:	46bd      	mov	sp, r7
10000186:	bd80      	pop	{r7, pc}
10000188:	d0000018 	.word	0xd0000018

1000018c <check_counter_overflow>:

void check_counter_overflow(void)
{
1000018c:	b580      	push	{r7, lr}
1000018e:	af00      	add	r7, sp, #0
    if (counter >= counter_max)
10000190:	4b06      	ldr	r3, [pc, #24]	@ (100001ac <check_counter_overflow+0x20>)
10000192:	681b      	ldr	r3, [r3, #0]
10000194:	22fa      	movs	r2, #250	@ 0xfa
10000196:	0052      	lsls	r2, r2, #1
10000198:	4293      	cmp	r3, r2
1000019a:	d304      	bcc.n	100001a6 <check_counter_overflow+0x1a>
    {
        counter = 0;
1000019c:	4b03      	ldr	r3, [pc, #12]	@ (100001ac <check_counter_overflow+0x20>)
1000019e:	2200      	movs	r2, #0
100001a0:	601a      	str	r2, [r3, #0]
        led_on();
100001a2:	f7ff ffd7 	bl	10000154 <led_on>
    }
}
100001a6:	46c0      	nop			@ (mov r8, r8)
100001a8:	46bd      	mov	sp, r7
100001aa:	bd80      	pop	{r7, pc}
100001ac:	20000008 	.word	0x20000008

100001b0 <check_counter_compare>:

void check_counter_compare(void)
{
100001b0:	b580      	push	{r7, lr}
100001b2:	af00      	add	r7, sp, #0
    if(counter >= counter_compare_value)
100001b4:	4b05      	ldr	r3, [pc, #20]	@ (100001cc <check_counter_compare+0x1c>)
100001b6:	681a      	ldr	r2, [r3, #0]
100001b8:	4b05      	ldr	r3, [pc, #20]	@ (100001d0 <check_counter_compare+0x20>)
100001ba:	681b      	ldr	r3, [r3, #0]
100001bc:	429a      	cmp	r2, r3
100001be:	d301      	bcc.n	100001c4 <check_counter_compare+0x14>
    {
        led_off();
100001c0:	f7ff ffd6 	bl	10000170 <led_off>
    }
}
100001c4:	46c0      	nop			@ (mov r8, r8)
100001c6:	46bd      	mov	sp, r7
100001c8:	bd80      	pop	{r7, pc}
100001ca:	46c0      	nop			@ (mov r8, r8)
100001cc:	20000008 	.word	0x20000008
100001d0:	20000000 	.word	0x20000000

100001d4 <set_pwm_value>:

void set_pwm_value(uint32_t setpoint)
{
100001d4:	b580      	push	{r7, lr}
100001d6:	b082      	sub	sp, #8
100001d8:	af00      	add	r7, sp, #0
100001da:	6078      	str	r0, [r7, #4]
    if(setpoint > counter_max)
100001dc:	23fa      	movs	r3, #250	@ 0xfa
100001de:	005b      	lsls	r3, r3, #1
100001e0:	001a      	movs	r2, r3
100001e2:	687b      	ldr	r3, [r7, #4]
100001e4:	4293      	cmp	r3, r2
100001e6:	d902      	bls.n	100001ee <set_pwm_value+0x1a>
    {
        setpoint = counter_max;
100001e8:	23fa      	movs	r3, #250	@ 0xfa
100001ea:	005b      	lsls	r3, r3, #1
100001ec:	607b      	str	r3, [r7, #4]
    }
    counter_compare_value = setpoint;
100001ee:	4b03      	ldr	r3, [pc, #12]	@ (100001fc <set_pwm_value+0x28>)
100001f0:	687a      	ldr	r2, [r7, #4]
100001f2:	601a      	str	r2, [r3, #0]
}
100001f4:	46c0      	nop			@ (mov r8, r8)
100001f6:	46bd      	mov	sp, r7
100001f8:	b002      	add	sp, #8
100001fa:	bd80      	pop	{r7, pc}
100001fc:	20000000 	.word	0x20000000

10000200 <process_led_dimming>:

void process_led_dimming()
{
10000200:	b580      	push	{r7, lr}
10000202:	af00      	add	r7, sp, #0
    static int32_t pwm_setpoint = 0;
    static int inc_step = 1;
    if(counter%100 == 0)
10000204:	4b14      	ldr	r3, [pc, #80]	@ (10000258 <process_led_dimming+0x58>)
10000206:	681b      	ldr	r3, [r3, #0]
10000208:	2164      	movs	r1, #100	@ 0x64
1000020a:	0018      	movs	r0, r3
1000020c:	f000 f8e8 	bl	100003e0 <__aeabi_uidivmod>
10000210:	1e0b      	subs	r3, r1, #0
10000212:	d106      	bne.n	10000222 <process_led_dimming+0x22>
    {
        pwm_setpoint+=inc_step;
10000214:	4b11      	ldr	r3, [pc, #68]	@ (1000025c <process_led_dimming+0x5c>)
10000216:	681a      	ldr	r2, [r3, #0]
10000218:	4b11      	ldr	r3, [pc, #68]	@ (10000260 <process_led_dimming+0x60>)
1000021a:	681b      	ldr	r3, [r3, #0]
1000021c:	18d2      	adds	r2, r2, r3
1000021e:	4b0f      	ldr	r3, [pc, #60]	@ (1000025c <process_led_dimming+0x5c>)
10000220:	601a      	str	r2, [r3, #0]
    }

    if(pwm_setpoint >= counter_max)
10000222:	4b0e      	ldr	r3, [pc, #56]	@ (1000025c <process_led_dimming+0x5c>)
10000224:	681a      	ldr	r2, [r3, #0]
10000226:	23fa      	movs	r3, #250	@ 0xfa
10000228:	005b      	lsls	r3, r3, #1
1000022a:	429a      	cmp	r2, r3
1000022c:	db04      	blt.n	10000238 <process_led_dimming+0x38>
    {
        inc_step=-1;
1000022e:	4b0c      	ldr	r3, [pc, #48]	@ (10000260 <process_led_dimming+0x60>)
10000230:	2201      	movs	r2, #1
10000232:	4252      	negs	r2, r2
10000234:	601a      	str	r2, [r3, #0]
10000236:	e006      	b.n	10000246 <process_led_dimming+0x46>
    }
    else if(pwm_setpoint <= 0)
10000238:	4b08      	ldr	r3, [pc, #32]	@ (1000025c <process_led_dimming+0x5c>)
1000023a:	681b      	ldr	r3, [r3, #0]
1000023c:	2b00      	cmp	r3, #0
1000023e:	dc02      	bgt.n	10000246 <process_led_dimming+0x46>
    {
        inc_step=1;
10000240:	4b07      	ldr	r3, [pc, #28]	@ (10000260 <process_led_dimming+0x60>)
10000242:	2201      	movs	r2, #1
10000244:	601a      	str	r2, [r3, #0]
    }

    set_pwm_value(pwm_setpoint);
10000246:	4b05      	ldr	r3, [pc, #20]	@ (1000025c <process_led_dimming+0x5c>)
10000248:	681b      	ldr	r3, [r3, #0]
1000024a:	0018      	movs	r0, r3
1000024c:	f7ff ffc2 	bl	100001d4 <set_pwm_value>
}
10000250:	46c0      	nop			@ (mov r8, r8)
10000252:	46bd      	mov	sp, r7
10000254:	bd80      	pop	{r7, pc}
10000256:	46c0      	nop			@ (mov r8, r8)
10000258:	20000008 	.word	0x20000008
1000025c:	2000000c 	.word	0x2000000c
10000260:	20000004 	.word	0x20000004

10000264 <init_led_gpio>:

void init_led_gpio(void)
{
10000264:	b580      	push	{r7, lr}
10000266:	af00      	add	r7, sp, #0
     //Activate IO_BANK0 ba setting bit 5 to 0
    //rp2040 datasheet 2.14.3. List of Registers
    *(volatile uint32_t *) (RESETS_BASE) &= ~(1 << 5);
10000268:	4b0c      	ldr	r3, [pc, #48]	@ (1000029c <init_led_gpio+0x38>)
1000026a:	681a      	ldr	r2, [r3, #0]
1000026c:	4b0b      	ldr	r3, [pc, #44]	@ (1000029c <init_led_gpio+0x38>)
1000026e:	2120      	movs	r1, #32
10000270:	438a      	bics	r2, r1
10000272:	601a      	str	r2, [r3, #0]

    //RESETS: RESET_DONE Register
    //Offset: 0x8
    //Wait for IO_BANK0 to be ready bit 5 should be  set
    while (!( *(volatile uint32_t *) (RESETS_BASE+0x08) & (1 << 5)));
10000274:	46c0      	nop			@ (mov r8, r8)
10000276:	4b0a      	ldr	r3, [pc, #40]	@ (100002a0 <init_led_gpio+0x3c>)
10000278:	681b      	ldr	r3, [r3, #0]
1000027a:	2220      	movs	r2, #32
1000027c:	4013      	ands	r3, r2
1000027e:	d0fa      	beq.n	10000276 <init_led_gpio+0x12>

    //2.19.6. List of Registers
    //2.19.6.1. IO - User Bank
    //0x0cc GPIO25_CTRL GPIO control including function select and overrides
    // GPIO 25 BANK 0 CTRL
    *(volatile uint32_t *) (IO_BANK0_BASE+0xcc) = 5;
10000280:	4b08      	ldr	r3, [pc, #32]	@ (100002a4 <init_led_gpio+0x40>)
10000282:	2205      	movs	r2, #5
10000284:	601a      	str	r2, [r3, #0]
    //SIO: GPIO_OE_SET Register
    //Offset: 0x024
    //Description
    //GPIO output enable set
    //GPIO 25 as Outputs using SIO
    *(volatile uint32_t *) (SIO_BASE+0x24) |= 1 << 25;
10000286:	4b08      	ldr	r3, [pc, #32]	@ (100002a8 <init_led_gpio+0x44>)
10000288:	681a      	ldr	r2, [r3, #0]
1000028a:	4b07      	ldr	r3, [pc, #28]	@ (100002a8 <init_led_gpio+0x44>)
1000028c:	2180      	movs	r1, #128	@ 0x80
1000028e:	0489      	lsls	r1, r1, #18
10000290:	430a      	orrs	r2, r1
10000292:	601a      	str	r2, [r3, #0]
}
10000294:	46c0      	nop			@ (mov r8, r8)
10000296:	46bd      	mov	sp, r7
10000298:	bd80      	pop	{r7, pc}
1000029a:	46c0      	nop			@ (mov r8, r8)
1000029c:	4000c000 	.word	0x4000c000
100002a0:	4000c008 	.word	0x4000c008
100002a4:	400140cc 	.word	0x400140cc
100002a8:	d0000024 	.word	0xd0000024

100002ac <main>:

extern uint32_t __StackTop;

int main(void)
{
100002ac:	b580      	push	{r7, lr}
100002ae:	af00      	add	r7, sp, #0
    init_led_gpio();
100002b0:	f7ff ffd8 	bl	10000264 <init_led_gpio>

    //This is also impossible to get here without working stack
    //If stack will be set outside of SRAM hard fault will be generated
    //main at the beginning pushes 5 registers on stack
    //Check if stack top is correctly defined in linker script
    if(&__StackTop != (uint32_t*)0x20040000)
100002b4:	4b0e      	ldr	r3, [pc, #56]	@ (100002f0 <main+0x44>)
100002b6:	4a0f      	ldr	r2, [pc, #60]	@ (100002f4 <main+0x48>)
100002b8:	4293      	cmp	r3, r2
100002ba:	d001      	beq.n	100002c0 <main+0x14>
    {
        failed();
100002bc:	f7ff ff3c 	bl	10000138 <failed>
    }

    //Check if bss init loop works
    if (counter != 0)
100002c0:	4b0d      	ldr	r3, [pc, #52]	@ (100002f8 <main+0x4c>)
100002c2:	681b      	ldr	r3, [r3, #0]
100002c4:	2b00      	cmp	r3, #0
100002c6:	d001      	beq.n	100002cc <main+0x20>
    {
        failed();
100002c8:	f7ff ff36 	bl	10000138 <failed>
    }

    //Check if data init loop works
    if (counter_compare_value != 100)
100002cc:	4b0b      	ldr	r3, [pc, #44]	@ (100002fc <main+0x50>)
100002ce:	681b      	ldr	r3, [r3, #0]
100002d0:	2b64      	cmp	r3, #100	@ 0x64
100002d2:	d001      	beq.n	100002d8 <main+0x2c>
    {
        failed();
100002d4:	f7ff ff30 	bl	10000138 <failed>
    

 
    while (true)
    {
        counter++;
100002d8:	4b07      	ldr	r3, [pc, #28]	@ (100002f8 <main+0x4c>)
100002da:	681b      	ldr	r3, [r3, #0]
100002dc:	1c5a      	adds	r2, r3, #1
100002de:	4b06      	ldr	r3, [pc, #24]	@ (100002f8 <main+0x4c>)
100002e0:	601a      	str	r2, [r3, #0]
        check_counter_overflow();
100002e2:	f7ff ff53 	bl	1000018c <check_counter_overflow>
        check_counter_compare();
100002e6:	f7ff ff63 	bl	100001b0 <check_counter_compare>
        process_led_dimming();
100002ea:	f7ff ff89 	bl	10000200 <process_led_dimming>
        counter++;
100002ee:	e7f3      	b.n	100002d8 <main+0x2c>
100002f0:	20040000 	.word	0x20040000
100002f4:	20040000 	.word	0x20040000
100002f8:	20000008 	.word	0x20000008
100002fc:	20000000 	.word	0x20000000

10000300 <Default_Handler>:
extern uint32_t __bss_start__;    
extern uint32_t __bss_end__;     
extern uint32_t __StackTop;

void Default_Handler(void)
{
10000300:	b580      	push	{r7, lr}
10000302:	af00      	add	r7, sp, #0
     while(1)
10000304:	e7fe      	b.n	10000304 <Default_Handler+0x4>
	...

10000308 <Reset_Handler>:
}

int main(void);

void Reset_Handler(void)
{
10000308:	b580      	push	{r7, lr}
1000030a:	b082      	sub	sp, #8
1000030c:	af00      	add	r7, sp, #0
  uint32_t *src, *dst;

  for (dst = &__data_start__, src = &__etext; dst < &__data_end__; ++dst, ++src)
1000030e:	4b11      	ldr	r3, [pc, #68]	@ (10000354 <Reset_Handler+0x4c>)
10000310:	603b      	str	r3, [r7, #0]
10000312:	4b11      	ldr	r3, [pc, #68]	@ (10000358 <Reset_Handler+0x50>)
10000314:	607b      	str	r3, [r7, #4]
10000316:	e009      	b.n	1000032c <Reset_Handler+0x24>
    *dst = *src;
10000318:	687b      	ldr	r3, [r7, #4]
1000031a:	681a      	ldr	r2, [r3, #0]
1000031c:	683b      	ldr	r3, [r7, #0]
1000031e:	601a      	str	r2, [r3, #0]
  for (dst = &__data_start__, src = &__etext; dst < &__data_end__; ++dst, ++src)
10000320:	683b      	ldr	r3, [r7, #0]
10000322:	3304      	adds	r3, #4
10000324:	603b      	str	r3, [r7, #0]
10000326:	687b      	ldr	r3, [r7, #4]
10000328:	3304      	adds	r3, #4
1000032a:	607b      	str	r3, [r7, #4]
1000032c:	683a      	ldr	r2, [r7, #0]
1000032e:	4b0b      	ldr	r3, [pc, #44]	@ (1000035c <Reset_Handler+0x54>)
10000330:	429a      	cmp	r2, r3
10000332:	d3f1      	bcc.n	10000318 <Reset_Handler+0x10>
 
  for (dst = &__bss_start__; dst < &__bss_end__; ++dst)
10000334:	4b0a      	ldr	r3, [pc, #40]	@ (10000360 <Reset_Handler+0x58>)
10000336:	603b      	str	r3, [r7, #0]
10000338:	e005      	b.n	10000346 <Reset_Handler+0x3e>
    *dst = 0;
1000033a:	683b      	ldr	r3, [r7, #0]
1000033c:	2200      	movs	r2, #0
1000033e:	601a      	str	r2, [r3, #0]
  for (dst = &__bss_start__; dst < &__bss_end__; ++dst)
10000340:	683b      	ldr	r3, [r7, #0]
10000342:	3304      	adds	r3, #4
10000344:	603b      	str	r3, [r7, #0]
10000346:	683a      	ldr	r2, [r7, #0]
10000348:	4b06      	ldr	r3, [pc, #24]	@ (10000364 <Reset_Handler+0x5c>)
1000034a:	429a      	cmp	r2, r3
1000034c:	d3f5      	bcc.n	1000033a <Reset_Handler+0x32>
  main();
1000034e:	f7ff ffad 	bl	100002ac <main>
  for (;;);
10000352:	e7fe      	b.n	10000352 <Reset_Handler+0x4a>
10000354:	20000000 	.word	0x20000000
10000358:	100003f8 	.word	0x100003f8
1000035c:	20000008 	.word	0x20000008
10000360:	20000008 	.word	0x20000008
10000364:	20000010 	.word	0x20000010

10000368 <__udivsi3>:
10000368:	2900      	cmp	r1, #0
1000036a:	d034      	beq.n	100003d6 <.udivsi3_skip_div0_test+0x6a>

1000036c <.udivsi3_skip_div0_test>:
1000036c:	2301      	movs	r3, #1
1000036e:	2200      	movs	r2, #0
10000370:	b410      	push	{r4}
10000372:	4288      	cmp	r0, r1
10000374:	d32c      	bcc.n	100003d0 <.udivsi3_skip_div0_test+0x64>
10000376:	2401      	movs	r4, #1
10000378:	0724      	lsls	r4, r4, #28
1000037a:	42a1      	cmp	r1, r4
1000037c:	d204      	bcs.n	10000388 <.udivsi3_skip_div0_test+0x1c>
1000037e:	4281      	cmp	r1, r0
10000380:	d202      	bcs.n	10000388 <.udivsi3_skip_div0_test+0x1c>
10000382:	0109      	lsls	r1, r1, #4
10000384:	011b      	lsls	r3, r3, #4
10000386:	e7f8      	b.n	1000037a <.udivsi3_skip_div0_test+0xe>
10000388:	00e4      	lsls	r4, r4, #3
1000038a:	42a1      	cmp	r1, r4
1000038c:	d204      	bcs.n	10000398 <.udivsi3_skip_div0_test+0x2c>
1000038e:	4281      	cmp	r1, r0
10000390:	d202      	bcs.n	10000398 <.udivsi3_skip_div0_test+0x2c>
10000392:	0049      	lsls	r1, r1, #1
10000394:	005b      	lsls	r3, r3, #1
10000396:	e7f8      	b.n	1000038a <.udivsi3_skip_div0_test+0x1e>
10000398:	4288      	cmp	r0, r1
1000039a:	d301      	bcc.n	100003a0 <.udivsi3_skip_div0_test+0x34>
1000039c:	1a40      	subs	r0, r0, r1
1000039e:	431a      	orrs	r2, r3
100003a0:	084c      	lsrs	r4, r1, #1
100003a2:	42a0      	cmp	r0, r4
100003a4:	d302      	bcc.n	100003ac <.udivsi3_skip_div0_test+0x40>
100003a6:	1b00      	subs	r0, r0, r4
100003a8:	085c      	lsrs	r4, r3, #1
100003aa:	4322      	orrs	r2, r4
100003ac:	088c      	lsrs	r4, r1, #2
100003ae:	42a0      	cmp	r0, r4
100003b0:	d302      	bcc.n	100003b8 <.udivsi3_skip_div0_test+0x4c>
100003b2:	1b00      	subs	r0, r0, r4
100003b4:	089c      	lsrs	r4, r3, #2
100003b6:	4322      	orrs	r2, r4
100003b8:	08cc      	lsrs	r4, r1, #3
100003ba:	42a0      	cmp	r0, r4
100003bc:	d302      	bcc.n	100003c4 <.udivsi3_skip_div0_test+0x58>
100003be:	1b00      	subs	r0, r0, r4
100003c0:	08dc      	lsrs	r4, r3, #3
100003c2:	4322      	orrs	r2, r4
100003c4:	2800      	cmp	r0, #0
100003c6:	d003      	beq.n	100003d0 <.udivsi3_skip_div0_test+0x64>
100003c8:	091b      	lsrs	r3, r3, #4
100003ca:	d001      	beq.n	100003d0 <.udivsi3_skip_div0_test+0x64>
100003cc:	0909      	lsrs	r1, r1, #4
100003ce:	e7e3      	b.n	10000398 <.udivsi3_skip_div0_test+0x2c>
100003d0:	0010      	movs	r0, r2
100003d2:	bc10      	pop	{r4}
100003d4:	4770      	bx	lr
100003d6:	b501      	push	{r0, lr}
100003d8:	2000      	movs	r0, #0
100003da:	f000 f80b 	bl	100003f4 <__aeabi_idiv0>
100003de:	bd02      	pop	{r1, pc}

100003e0 <__aeabi_uidivmod>:
100003e0:	2900      	cmp	r1, #0
100003e2:	d0f8      	beq.n	100003d6 <.udivsi3_skip_div0_test+0x6a>
100003e4:	b503      	push	{r0, r1, lr}
100003e6:	f7ff ffc1 	bl	1000036c <.udivsi3_skip_div0_test>
100003ea:	bc0e      	pop	{r1, r2, r3}
100003ec:	4342      	muls	r2, r0
100003ee:	1a89      	subs	r1, r1, r2
100003f0:	4718      	bx	r3
100003f2:	46c0      	nop			@ (mov r8, r8)

100003f4 <__aeabi_idiv0>:
100003f4:	4770      	bx	lr
100003f6:	46c0      	nop			@ (mov r8, r8)
