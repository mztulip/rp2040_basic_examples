# rp2040_basic_examples
Idea of this repository is to create simple code examples which are bare metal.  For example LED blinking without makefile cmake. It uses gcc with bash script as build tool.

Compiling

Change directory to example and execute ./make.sh

If compiler is not in envs modify path to compiler in make.sh.

Code is tested with:
arm-none-eabi-gcc (Arch Repository) 14.2.0

I want to give a lot of thanks for vxj9800 for describing rp2040 booting process with examples.
https://github.com/vxj9800/bareMetalRP2040

External code

https://github.com/d-bahr/CRCpp

It uses CRCpp header library to compute CRC fot second bootloader.

https://github.com/microsoft/uf2

It uses uf2 python script to generate uf2 file from elf output file.