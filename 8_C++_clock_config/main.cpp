#include <cstdint>
#include "addressmap.h"
#include "systick_regs.h"
#include "xosc_regs.h"
#include "pll_regs.h"
#include "clocks_regs.h"

volatile uint32_t &GPIO_OUT_XOR = *reinterpret_cast<uint32_t *>(SIO_BASE+0x1c);
volatile uint32_t &GPIO_OUT_SET = *reinterpret_cast<uint32_t *>(SIO_BASE+0x14);
volatile uint32_t &GPIO_OUT_CLR = *reinterpret_cast<uint32_t *>(SIO_BASE+0x18);
volatile uint32_t &RESETS_BASE_REG = *reinterpret_cast<uint32_t *>(RESETS_BASE);
volatile uint32_t &RESET_DONE = *reinterpret_cast<uint32_t *>(RESETS_BASE+0x08);
volatile uint32_t &GPIO25_CTRL = *reinterpret_cast<uint32_t *>(IO_BANK0_BASE+0xcc);
volatile uint32_t &GPIO_OE_SET = *reinterpret_cast<uint32_t *>(SIO_BASE+0x24);

#define RESETS_RESET                (*(volatile uint32_t *) (RESETS_BASE + 0x000))
#define RESETS_RESET_DONE           (*(volatile uint32_t *) (RESETS_BASE + 0x008))

void external_crystal_osc_init()
{
    // Assumes 1-15 MHz input, checked above.
    xosc_hw->ctrl = XOSC_CTRL_FREQ_RANGE_VALUE_1_15MHZ;

    constexpr uint32_t STARTUP_DELAY = (((XOSC_HZ / 1000) + 128) / 256);
    // Set xosc startup delay
    xosc_hw->startup = STARTUP_DELAY;

    // Set the enable bit now that we have set freq range and startup delay
    hw_set_bits(&xosc_hw->ctrl, XOSC_CTRL_ENABLE_VALUE_ENABLE << XOSC_CTRL_ENABLE_LSB);

    // Wait for XOSC to be stable
    while((xosc_hw->status & XOSC_STATUS_STABLE_BITS) == 0) 
    {
    }
}

void pll_120MHz_init()
{
    // Initialize System PLL
    RESETS_RESET &= ~(1 << 12); // Bring System PLL out of reset state
    // Wait for PLL peripheral to respond
    while ((RESETS_RESET_DONE & (1 << 12)) == 0) {}

    // Set feedback clock div = 100, thus VCO clock = 12MHz * 100 = 1.2GHz
    pll_sys_hw->fbdiv_int = 100;
    // Turn on the main power and VCO
    uint32_t power = PLL_PWR_PD_BITS | // Main power
                     PLL_PWR_VCOPD_BITS; // VCO Power

    hw_clear_bits(&pll_sys_hw->pwr, power);

     // Wait for PLL to lock
    while ((pll_sys_hw->cs & PLL_CS_LOCK_BITS) == 0) {}
    
    // Set POSTDIV1 = 5 and POSTDIV2 = 2, thus 1.2GHz / 5 / 2 = 120MHz
    constexpr uint32_t post_div1 = 5;
    constexpr uint32_t post_div2 = 2;
    constexpr uint32_t pdiv = (post_div1 << PLL_PRIM_POSTDIV1_LSB) |
                    (post_div2 << PLL_PRIM_POSTDIV2_LSB);

     // Set up post dividers
    pll_sys_hw->prim = pdiv;

    // Turn on post divider
    hw_clear_bits(&pll_sys_hw->pwr, PLL_PWR_POSTDIVPD_BITS);
}

void clock_ref_init()
{
    //Switch glitchless to xosc(12MHz) as source for clk_ref
    //at startup it is switched to rosc_clksrc_ph
    clock_hw_t *clock_ref_hw = &clocks_hw->clk[clk_ref];
    hw_write_masked(&clock_ref_hw->ctrl,
            2 << CLOCKS_CLK_REF_CTRL_SRC_LSB,
            CLOCKS_CLK_REF_CTRL_SRC_BITS
        );
    //2.15.7. List of Registers in datasheet  CLK_REF_SELECTED
    //Wait for bit setting indicating that mux is switched
    //Bit position refers to value written to CTRL_SRC
    while ((clock_ref_hw->selected & (1u << 2)) == 0)
    {

    }
}

void clock_sysclk_init()
{
    // Switch clk_sys to clksrc_clk_sys_aux(where source for sys_aux is by default clksrc_pll_sys=120MHz)
    // by default switch selects clk_ref
    clock_hw_t *clock_sys_hw = &clocks_hw->clk[clk_sys];
    hw_write_masked(&clock_sys_hw->ctrl,
            CLOCKS_CLK_SYS_CTRL_SRC_VALUE_CLKSRC_CLK_SYS_AUX << CLOCKS_CLK_SYS_CTRL_SRC_LSB,
            CLOCKS_CLK_SYS_CTRL_SRC_BITS
        );

    //Wait for bit setting indicating that mux is switched
    //2.15.7. List of Registers in datasheet CLK_SYS_SELECTED
    //Bit position refers to value written to CTRL_SRC
    while ((clock_sys_hw->selected & (1u << CLOCKS_CLK_SYS_CTRL_SRC_VALUE_CLKSRC_CLK_SYS_AUX)) == 0)
    {

    }
}

void rosc_shutdown()
{
    hw_write_masked(&xosc_hw->ctrl, XOSC_CTRL_ENABLE_VALUE_DISABLE, XOSC_CTRL_ENABLE_BITS);
}

void clock_init_120MHz()
{
    external_crystal_osc_init();
    pll_120MHz_init();
    clock_ref_init();
    clock_sysclk_init();
    rosc_shutdown();
}

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

void systick_init()
{
    //To achieve interrupt every  1 second x counts is needed
    //Systick reload value register. It has only 24 bits, maximum value is 16777215(2^24-1)
    //With 120MHz clock led state changes in 1/10 of second = 100ms
    systick_hw->rvr = 120000000/10;
    //SysTick Control and Status Register
    systick_hw->csr =   M0PLUS_SYST_CSR_CLKSOURCE_BITS | 
                        M0PLUS_SYST_CSR_ENABLE_BITS |
                        M0PLUS_SYST_CSR_TICKINT_BITS;
}

int main()
{
    clock_init_120MHz();
    blue_led.off();
    systick_init();

    while (true)
    {
        __asm("  wfi");
    }
}