#include <cstdint>
#include <algorithm>

extern uint32_t __etext;   
extern uint32_t __data_start__;   
extern uint32_t __data_end__;   
extern uint32_t __bss_start__;    
extern uint32_t __bss_end__;     
extern uint32_t __StackTop;

//extern "C" makes a function-name in C++ have C linkage (compiler does not mangle the name)
extern "C" void Default_Handler(void)
{
     while(1)
    {
        
    }
}

int main();

void Reset_Handler()
{
  // Initialize the .data section (global variables with initial values)
  auto data_length = &__data_end__ - &__data_start__;
  auto data_source_end = &__etext + data_length;
  std::copy(&__etext,
            data_source_end,
            &__data_start__);

  
  // Clear the .bss section (global variables with no initial values)
  std::fill(&__bss_start__,
              &__bss_end__,
              0U);

  // https://refspecs.linuxfoundation.org/elf/gabi4+/ch4.sheader.html#special_sections
  // .preinit_array:
  //   This section holds an array of function pointers that contributes to
  //    a single pre-initialization array for the executable or shared object containing the section.

  // .init_array
  //   This section holds an array of function pointers that 
  //   contributes to a single initialization array for the executable 
  //   or shared object containing the section.

  // .fini_array

  //   This section holds an array of function pointers 
  //   that contributes to a single termination array for 
  //   the executable or shared object containing the section.

  main();
  for (;;);
}

#define WEAK __attribute__ ((weak, alias("Default_Handler")))

WEAK void NMI_Handler(void);
WEAK void HardFault_Handler(void);

#pragma GCC push_options
#pragma GCC optimize("O0")
__attribute__ ((section(".vectors")))
void (* const interrupt_vectors[])(void) = {
  (void (*)())&__StackTop,
  Reset_Handler,
  NMI_Handler,
  HardFault_Handler,
};
#pragma GCC pop_options