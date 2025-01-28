#include <cstdint>
#include <algorithm>

extern uint32_t __start_data_at_flash;   
extern uint32_t __data_start__;   
extern uint32_t __data_end__;   
extern uint32_t __bss_start__;    
extern uint32_t __bss_end__;     
extern uint32_t __StackTop;
extern "C" void(*__preinit_array_start [])(void);
extern "C" void(*__preinit_array_end [])(void);
extern "C" void(*__init_array_start [])(void);
extern "C" void(*__init_array_end [])(void);

//extern "C" makes a function-name in C++ have C linkage (compiler does not mangle the name)
extern "C" void Default_Handler(void)
{
     while(1)
    {
        
    }
}

int main();

extern "C" void Reset_Handler()
{
  // Initialize the .data section (global variables with initial values)
  auto data_length = &__data_end__ - &__data_start__;
  auto data_source_end = &__start_data_at_flash + data_length;
  std::copy(&__start_data_at_flash,
            data_source_end,
            &__data_start__);

  
  // Clear the .bss section (global variables with no initial values)
  std::fill(&__bss_start__,
              &__bss_end__,
              0U);

  //Good article about c++ startup:
  //https://embeddedartistry.com/blog/2019/04/17/exploring-startup-implementations-newlib-arm/


  /* TODO: Maybe init/__libc_init_array   also should be placed here when nanolib/newlib will be used 
  https://sourceware.org/git/gitweb.cgi?p=newlib-cygwin.git;a=blob_plain;f=newlib/libc/misc/init.c;hb=HEAD
  It seems to be in text section
  */

  // https://refspecs.linuxfoundation.org/elf/gabi4+/ch4.sheader.html#special_sections
  // .preinit_array:
  //   This section holds an array of function pointers that contributes to
  //    a single pre-initialization array for the executable or shared object containing the section.
  //I do not know where and when preinit is used.
  // Probably will be always empty
  std::for_each( __preinit_array_start,
                __preinit_array_end, 
                [](void (*f) (void)) {f();});

  // .init_array
  //   This section holds an array of function pointers that 
  //   contributes to a single initialization array for the executable 
  //   or shared object containing the section.
  std::for_each( __init_array_start,
                  __init_array_end, 
                  [](void (*f) (void)) {f();});

  main();

  // .fini_array
  //   This section holds an array of function pointers 
  //   that contributes to a single termination array for 
  //   the executable or shared object containing the section.
  // Ececution of this part is not necessary because main should never return
  for (;;);
}

#define WEAK __attribute__ ((weak, alias("Default_Handler")))

WEAK void NMI_Handler(void);
WEAK void HardFault_Handler(void);
WEAK void MemManage_Handler(void);
WEAK void BusFault_Handler(void);
WEAK void UsageFault_Handler(void);
WEAK void SVC_Handler(void);
WEAK void DebugMon_Handler(void);
WEAK void PendSV_Handler(void);
WEAK void SysTick_Handler(void);

#pragma GCC push_options
#pragma GCC optimize("O0")
__attribute__ ((section(".vectors")))
void (* const interrupt_vectors[])(void) = {
  (void (*)())&__StackTop,
  Reset_Handler,
  NMI_Handler,
  HardFault_Handler,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  SVC_Handler,
  0,
  0,
  PendSV_Handler,
  SysTick_Handler,
};
#pragma GCC pop_options