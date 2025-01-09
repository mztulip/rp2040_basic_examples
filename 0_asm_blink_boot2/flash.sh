#!/bin/bash
# Tested with:
# Open On-Chip Debugger 0.12.0+dev-01829-g250ab1008 (2025-01-06-18:09)

/opt/openocd/bin/openocd \
 -f interface/ftdi/jtag-lock-pick_tiny_2.cfg \
 -c "transport select swd" \
 -c "adapter speed 4000" \
 -f "target/rp2040.cfg" \
 -c "init" \
 -c "dap info" \
 -c "reset halt" \
 -c "program output/output.elf" \
 -c "reset" \
 -c "exit"

 # program file.elf verify
 # if verification used it always fail when SPI peripheral SSI
 # is configured in normal mode, beause it only supports XIP in such situation
 # Flash memory readings is working only in Quad mode.(perhaps dual also see rp2040  SSI doc)
