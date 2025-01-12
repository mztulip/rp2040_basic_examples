#include <cstdint>
#include "addressmap.h"
#include "systick.h"

volatile uint32_t &GPIO_OUT_XOR = *reinterpret_cast<uint32_t *>(SIO_BASE+0x1c);
volatile uint32_t &GPIO_OUT_SET = *reinterpret_cast<uint32_t *>(SIO_BASE+0x14);
volatile uint32_t &GPIO_OUT_CLR = *reinterpret_cast<uint32_t *>(SIO_BASE+0x18);
volatile uint32_t &RESETS_BASE_REG = *reinterpret_cast<uint32_t *>(RESETS_BASE);
volatile uint32_t &RESET_DONE = *reinterpret_cast<uint32_t *>(RESETS_BASE+0x08);
volatile uint32_t &GPIO25_CTRL = *reinterpret_cast<uint32_t *>(IO_BANK0_BASE+0xcc);
volatile uint32_t &GPIO_OE_SET = *reinterpret_cast<uint32_t *>(SIO_BASE+0x24);

class led
{


public:
    led()
    {
        //Activate IO_BANK0 ba setting bit 5 to 0
        //rp2040 datasheet 2.14.3. List of Registers
        RESETS_BASE_REG &= ~(1 << 5);

        //RESETS: RESET_DONE Register
        //Offset: 0x8
        //Wait for IO_BANK0 to be ready bit 5 should be  set
        while (!( RESET_DONE & (1 << 5)));


        //2.19.6. List of Registers
        //2.19.6.1. IO - User Bank
        //0x0cc GPIO25_CTRL GPIO control including function select and overrides
        // GPIO 25 BANK 0 CTRL
        GPIO25_CTRL = 5;

        //2.3.1.7. List of Registers
        //The SIO registers start at a base address of 0xd0000000 (defined as SIO_BASE in SDK)
        //SIO: GPIO_OE_SET Register
        //Offset: 0x024
        //Description
        //GPIO output enable set
        //GPIO 25 as Outputs using SIO
        GPIO_OE_SET |= 1 << 25;
    }

    void on()
    {
        //2.3.1.7. List of Registers
        // SIO: GPIO_OUT_SET Register
        // Offset: 0x014
        // Description
        // GPIO output value set
        GPIO_OUT_SET |= 1 << 25;
    }

    void off()
    {
        //2.3.1.7. List of Registers
        // SIO: GPIO_OUT_CLR Register
        // Offset: 0x018
        // Description
        // GPIO output value clear
        GPIO_OUT_CLR |= 1 << 25;
    }

    void toogle()
    {
        // SIO: GPIO_OUT_XOR Register
        // Offset: 0x01c
        // Description
        // GPIO output value XO
        // xor bit for GPIO 25 changing led state
        GPIO_OUT_XOR |= 1 << 25;
    }
};

led blue_led;

void SysTick_Handler(void)
{
    blue_led.toogle();
}

int main()
{
    
    blue_led.off();
    //To achieve interrupt every  1 second 6500000 counts is needed(cpu work by default with 6.5MHz ring oscillator)
    //Systick reload value register
    systick_hw->rvr = 6500000;
    //SysTick Control and Status Register
    systick_hw->csr =   M0PLUS_SYST_CSR_CLKSOURCE_BITS | 
                        M0PLUS_SYST_CSR_ENABLE_BITS |
                        M0PLUS_SYST_CSR_TICKINT_BITS;

    while (true)
    {
        __asm("  wfi");
    }
}