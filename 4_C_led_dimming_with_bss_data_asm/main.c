#include <stdint.h>
#include <stdbool.h>
#include "boot2/addressmap.h"

const int counter_max = 500;
uint32_t counter_compare_value = 100;
uint32_t counter = 0;

void delay(void)
{
    for (volatile uint32_t i = 0; i < 123456/8; ++i)
    {

    }
}

void failed(void)
{
    while (true)
    {
        delay();

        // SIO: GPIO_OUT_XOR Register
        // Offset: 0x01c
        // Description
        // GPIO output value XO
        // xor bit for GPIO 25 changing led state
        *(volatile uint32_t *) (SIO_BASE+0x1c) |= 1 << 25;
    }
}


void led_on(void)
{
    //2.3.1.7. List of Registers
    // SIO: GPIO_OUT_SET Register
    // Offset: 0x014
    // Description
    // GPIO output value set
    *(volatile uint32_t *) (SIO_BASE+0x14) |= 1 << 25;
}

void led_off(void)
{
    //2.3.1.7. List of Registers
    // SIO: GPIO_OUT_CLR Register
    // Offset: 0x018
    // Description
    // GPIO output value clear
    *(volatile uint32_t *) (SIO_BASE+0x18) |= 1 << 25;
}

void check_counter_overflow(void)
{
    if (counter >= counter_max)
    {
        counter = 0;
        led_on();
    }
}

void check_counter_compare(void)
{
    if(counter >= counter_compare_value)
    {
        led_off();
    }
}

void set_pwm_value(uint32_t setpoint)
{
    if(setpoint > counter_max)
    {
        setpoint = counter_max;
    }
    counter_compare_value = setpoint;
}

void process_led_dimming()
{
    static int32_t pwm_setpoint = 0;
    static int inc_step = 1;
    if(counter%100 == 0)
    {
        pwm_setpoint+=inc_step;
    }

    if(pwm_setpoint >= counter_max)
    {
        inc_step=-1;
    }
    else if(pwm_setpoint <= 0)
    {
        inc_step=1;
    }

    set_pwm_value(pwm_setpoint);
}

void init_led_gpio(void)
{
     //Activate IO_BANK0 ba setting bit 5 to 0
    //rp2040 datasheet 2.14.3. List of Registers
    *(volatile uint32_t *) (RESETS_BASE) &= ~(1 << 5);

    //RESETS: RESET_DONE Register
    //Offset: 0x8
    //Wait for IO_BANK0 to be ready bit 5 should be  set
    while (!( *(volatile uint32_t *) (RESETS_BASE+0x08) & (1 << 5)));


    //2.19.6. List of Registers
    //2.19.6.1. IO - User Bank
    //0x0cc GPIO25_CTRL GPIO control including function select and overrides
    // GPIO 25 BANK 0 CTRL
    *(volatile uint32_t *) (IO_BANK0_BASE+0xcc) = 5;

    //2.3.1.7. List of Registers
    //The SIO registers start at a base address of 0xd0000000 (defined as SIO_BASE in SDK)
    //SIO: GPIO_OE_SET Register
    //Offset: 0x024
    //Description
    //GPIO output enable set
    //GPIO 25 as Outputs using SIO
    *(volatile uint32_t *) (SIO_BASE+0x24) |= 1 << 25;
}

extern uint32_t __StackTop;

int main(void)
{
    init_led_gpio();

    //This is also impossible to get here without working stack
    //If stack will be set outside of SRAM hard fault will be generated
    //main at the beginning pushes 5 registers on stack
    //Check if stack top is correctly defined in linker script
    if(&__StackTop != (uint32_t*)0x20040000)
    {
        failed();
    }

    //Check if bss init loop works
    if (counter != 0)
    {
        failed();
    }

    //Check if data init loop works
    if (counter_compare_value != 100)
    {
        failed();
    }
    

 
    while (true)
    {
        counter++;
        check_counter_overflow();
        check_counter_compare();
        process_led_dimming();
    }
}