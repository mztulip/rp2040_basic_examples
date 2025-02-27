/*
 * Copyright (c) 2020 Raspberry Pi (Trading) Ltd.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#ifndef _HARDWARE_ADDRESS_MAPPED_H
#define _HARDWARE_ADDRESS_MAPPED_H

// #include "pico.h"
// #include "hardware/regs/addressmap.h"
#include "addressmap.h"

/** \file address_mapped.h
 *  \defgroup hardware_base hardware_base
 *
 *  \brief Low-level types and (atomic) accessors for memory-mapped hardware registers
 *
 *  `hardware_base` defines the low level types and access functions for memory mapped hardware registers. It is included
 *  by default by all other hardware libraries.
 *
 *  The following register access typedefs codify the access type (read/write) and the bus size (8/16/32) of the hardware register.
 *  The register type names are formed by concatenating one from each of the 3 parts A, B, C

 *   A    | B | C | Meaning
 *  ------|---|---|--------
 *  io_   |   |   | A Memory mapped IO register
 *  &nbsp;|ro_|   | read-only access
 *  &nbsp;|rw_|   | read-write access
 *  &nbsp;|wo_|   | write-only access (can't actually be enforced via C API)
 *  &nbsp;|   |  8| 8-bit wide access
 *  &nbsp;|   | 16| 16-bit wide access
 *  &nbsp;|   | 32| 32-bit wide access
 *
 *  When dealing with these types, you will always use a pointer, i.e. `io_rw_32 *some_reg` is a pointer to a read/write
 *  32 bit register that you can write with `*some_reg = value`, or read with `value = *some_reg`.
 *
 *  RP-series hardware is also aliased to provide atomic setting, clear or flipping of a subset of the bits within
 *  a hardware register so that concurrent access by two cores is always consistent with one atomic operation
 *  being performed first, followed by the second.
 *
 *  See hw_set_bits(), hw_clear_bits() and hw_xor_bits() provide for atomic access via a pointer to a 32 bit register
 *
 *  Additionally given a pointer to a structure representing a piece of hardware (e.g. `dma_hw_t *dma_hw` for the DMA controller), you can
 *  get an alias to the entire structure such that writing any member (register) within the structure is equivalent
 *  to an atomic operation via hw_set_alias(), hw_clear_alias() or hw_xor_alias()...
 *
 *  For example `hw_set_alias(dma_hw)->inte1 = 0x80;` will set bit 7 of the INTE1 register of the DMA controller,
 *  leaving the other bits unchanged.
 */

#ifdef __cplusplus
extern "C" {
#endif

#define check_hw_layout(type, member, offset) static_assert(offsetof(type, member) == (offset), "hw offset mismatch")
#define check_hw_size(type, size) static_assert(sizeof(type) == (size), "hw size mismatch")

// PICO_CONFIG: PARAM_ASSERTIONS_ENABLED_ADDRESS_ALIAS, Enable/disable assertions in memory address aliasing macros, type=bool, default=0, group=hardware_base
#ifndef PARAM_ASSERTIONS_ENABLED_ADDRESS_ALIAS
#define PARAM_ASSERTIONS_ENABLED_ADDRESS_ALIAS 0
#endif

typedef volatile uint64_t io_rw_64;
typedef const volatile uint64_t io_ro_64;
typedef volatile uint64_t io_wo_64;
typedef volatile uint32_t io_rw_32;
typedef const volatile uint32_t io_ro_32;
typedef volatile uint32_t io_wo_32;
typedef volatile uint16_t io_rw_16;
typedef const volatile uint16_t io_ro_16;
typedef volatile uint16_t io_wo_16;
typedef volatile uint8_t io_rw_8;
typedef const volatile uint8_t io_ro_8;
typedef volatile uint8_t io_wo_8;

typedef volatile uint8_t *const ioptr;
typedef ioptr const const_ioptr;

// A non-functional (empty) helper macro to help IDEs follow links from the autogenerated
// hardware struct headers in hardware/structs/xxx.h to the raw register definitions
// in hardware/regs/xxx.h. A preprocessor define such as TIMER_TIMEHW_OFFSET (a timer register offset)
// is not generally clickable (in an IDE) if placed in a C comment, so _REG_(TIMER_TIMEHW_OFFSET) is
// included outside of a comment instead
#define _REG_(x)

// Helper method used by hw_alias macros to optionally check input validity
#define hw_alias_check_addr(addr) ((uintptr_t)(addr))


// Untyped conversion alias pointer generation macros
#define hw_set_alias_untyped(addr) ((void *)(REG_ALIAS_SET_BITS + hw_alias_check_addr(addr)))
#define hw_clear_alias_untyped(addr) ((void *)(REG_ALIAS_CLR_BITS + hw_alias_check_addr(addr)))
#define hw_xor_alias_untyped(addr) ((void *)(REG_ALIAS_XOR_BITS + hw_alias_check_addr(addr)))

#if PICO_RP2040
#define xip_noalloc_alias_untyped(addr) ((void *)(XIP_NOALLOC_BASE | xip_alias_check_addr(addr)))
#define xip_nocache_alias_untyped(addr) ((void *)(XIP_NOCACHE_BASE | xip_alias_check_addr(addr)))
#define xip_nocache_noalloc_alias_untyped(addr) ((void *)(XIP_NOCACHE_NOALLOC_BASE | xip_alias_check_addr(addr)))
#endif

// Typed conversion alias pointer generation macros
#define hw_set_alias(p) ((typeof(p))hw_set_alias_untyped(p))
#define hw_clear_alias(p) ((typeof(p))hw_clear_alias_untyped(p))
#define hw_xor_alias(p) ((typeof(p))hw_xor_alias_untyped(p))
#define xip_noalloc_alias(p) ((typeof(p))xip_noalloc_alias_untyped(p))
#define xip_nocache_alias(p) ((typeof(p))xip_nocache_alias_untyped(p))
#define xip_nocache_noalloc_alias(p) ((typeof(p))xip_nocache_noalloc_alias_untyped(p))

#ifdef __cplusplus
}
#endif

#endif
