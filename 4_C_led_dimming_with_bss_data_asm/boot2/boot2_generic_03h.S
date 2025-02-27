// ----------------------------------------------------------------------------
// Second stage boot code
// Copyright (c) 2019-2021 Raspberry Pi (Trading) Ltd.
// SPDX-License-Identifier: BSD-3-Clause
// modified by mztulip
//
// Device:      Anything which responds to 03h serial read command
//
// Details:     * Configure SSI to translate each APB read into a 03h command
//              * 8 command clocks, 24 address clocks and 32 data clocks
//              * This enables you to boot from almost anything: you can pretty
//                much solder a potato to your PCB, or a piece of cheese
//              * The tradeoff is performance around 3x worse than QSPI XIP
//
// Building:    * This code must be position-independent, and use stack only
//              * The code will be padded to a size of 256 bytes, including a
//                4-byte checksum. Therefore code size cannot exceed 252 bytes.
// ----------------------------------------------------------------------------

.macro pico_default_asm_setup
.syntax unified
.cpu cortex-m0plus
.thumb
.endm

// do not put align in here as it is used mid function sometimes
.macro regular_func x
.global \x
.type \x,%function
.thumb_func
\x:
.endm


#include "addressmap.h"
#include "ssi.h"

pico_default_asm_setup

// ----------------------------------------------------------------------------
// Config section
// ----------------------------------------------------------------------------
// It should be possible to support most flash devices by modifying this section

// The serial flash interface will run at clk_sys/PICO_FLASH_SPI_CLKDIV.
// This must be a positive, even integer.
// The bootrom is very conservative with SPI frequency, but here we should be
// as aggressive as possible.
#ifndef PICO_FLASH_SPI_CLKDIV
#define PICO_FLASH_SPI_CLKDIV 4
#endif

#define CMD_READ 0x03

// Value is number of address bits divided by 4
#define ADDR_L 6

#define CTRLR0_XIP \
    (SSI_CTRLR0_SPI_FRF_VALUE_STD << SSI_CTRLR0_SPI_FRF_LSB) |  /* Standard 1-bit SPI serial frames */ \
    (31 << SSI_CTRLR0_DFS_32_LSB)  |                            /* 32 clocks per data frame */ \
    (SSI_CTRLR0_TMOD_VALUE_EEPROM_READ  << SSI_CTRLR0_TMOD_LSB) /* Send instr + addr, receive data */

#define SPI_CTRLR0_XIP \
    (CMD_READ << SSI_SPI_CTRLR0_XIP_CMD_LSB) |        /* Value of instruction prefix */ \
    (ADDR_L << SSI_SPI_CTRLR0_ADDR_L_LSB) |           /* Total number of address + mode bits */ \
    (2 << SSI_SPI_CTRLR0_INST_L_LSB) |                /* 8 bit command prefix (field value is bits divided by 4) */ \
    (SSI_SPI_CTRLR0_TRANS_TYPE_VALUE_1C1A << SSI_SPI_CTRLR0_TRANS_TYPE_LSB) /* command and address both in serial format */

// ----------------------------------------------------------------------------
// Start of 2nd Stage Boot Code
// ----------------------------------------------------------------------------

.section .text

// lr will be zero on entry if entered from the bootrom, and the boot_stage2 is expected
// to continue into the binary via the vector table at 0x10000100.
//
// lr will be non-zero on entry if this code has been copied into RAM by user code and called
// from there, and the boot_stage2 should just return normally.
//
// r3 holds SSI base, r0...2 used as temporaries. Other GPRs not used.
regular_func _stage2_boot
    push {lr}

    ldr r3, =XIP_SSI_BASE                // Use as base address where possible

    // Disable SSI to allow further config
    movs r1, #0
    str r1, [r3, #SSI_SSIENR_OFFSET]

    // Set baud rate
    movs r1, #PICO_FLASH_SPI_CLKDIV
    str r1, [r3, #SSI_BAUDR_OFFSET]

    ldr r1, =(CTRLR0_XIP)
    str r1, [r3, #SSI_CTRLR0_OFFSET]

    ldr r1, =(SPI_CTRLR0_XIP)
    ldr r0, =(XIP_SSI_BASE + SSI_SPI_CTRLR0_OFFSET)
    str r1, [r0]

    // NDF=0 (single 32b read)
    movs r1, #0x0
    str r1, [r3, #SSI_CTRLR1_OFFSET]

    // Re-enable SSI
    movs r1, #1
    str r1, [r3, #SSI_SSIENR_OFFSET]

// We are now in XIP mode. Any bus accesses to the XIP address window will be
// translated by the SSI into 03h read commands to the external flash (if cache is missed),
// and the data will be returned to the bus.

// Pull in standard exit routine

#include "m0plus.h"

    // If entered from the bootrom, lr (which we earlier pushed) will be 0,
    // and we vector through the table at the start of the main flash image.
    // Any regular function call will have a nonzero value for lr.
    check_return:
        pop {r0}
        cmp r0, #0
        beq vector_into_flash
        bx r0
    vector_into_flash:
// it assumes that at 0x10000100 is placed 4 bytes
// value of STACK pointer, end next 4 bytes repsesent of Reset handler/ code starting point
        ldr r0, =(XIP_BASE + 0x100)
        ldr r1, =(PPB_BASE + M0PLUS_VTOR_OFFSET)
        str r0, [r1]
        //Load two 32 bit values to r0 and r1 where first is pointed by r0
        ldmia r0, {r0, r1}
        //Load sp=r0
        msr msp, r0
        //branch to address at r1, it must containt address 
        //increased +1 to branch in thumb code
        bx r1

.global literals
literals:
.ltorg

.end
