#include <stdint.h>

extern uint32_t __etext;   
extern uint32_t __data_start__;   
extern uint32_t __data_end__;   
extern uint32_t __bss_start__;    
extern uint32_t __bss_end__;     
extern uint32_t __StackTop;

void Default_Handler(void)
{
     while(1)
    {
        
    }
}

int main(void);

void Reset_Handler(void)
{
  uint32_t *src, *dst;

  for (dst = &__data_start__, src = &__etext; dst < &__data_end__; ++dst, ++src)
    *dst = *src;
 
  for (dst = &__bss_start__; dst < &__bss_end__; ++dst)
    *dst = 0;
  main();
  for (;;);
}

#define WEAK __attribute__ ((weak, alias("Default_Handler")))

WEAK void NMI_Handler(void);
WEAK void HardFault_Handler(void);

__attribute__ ((section(".vectors")))
void (* const interrupt_vectors[])(void) = {
  (void*)&__StackTop,
  Reset_Handler,
  NMI_Handler,
  HardFault_Handler,
};