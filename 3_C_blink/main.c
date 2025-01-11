#include <stdint.h>
#include <stdbool.h>
#include "boot2/addressmap.h"

void delay(void)
{
    for (uint32_t i = 0; i < 123456; ++i)
    {

    }
}

int main(void)
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