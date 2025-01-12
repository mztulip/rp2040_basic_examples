#/bin/bash
set -e

LINKER_SCRIPT="link.ld"

# Tested with
# arm-none-eabi-gcc --version
# arm-none-eabi-gcc (Arch Repository) 14.2.0
TOOLCHAIN="arm-none-eabi-"
TOOLCHAIN_GCC=$TOOLCHAIN"gcc"
TOOLCHAIN_GPP=$TOOLCHAIN"g++"
TOOLCHAIN_SIZE=$TOOLCHAIN"size"
TOOLCHAIN_OBJDUMP=$TOOLCHAIN"objdump"
TOOLCHAIN_OBJCOPY=$TOOLCHAIN"objcopy"
echo $TOOLCHAIN_GCC
# https://gcc.gnu.org/onlinedocs/gcc/Option-Index.html
# -c => Compile or assemble the source files, but do not link. 
# -fdata-sections
#-ffunction-sections => Place each function or data item into its own section in the output file if the target supports arbitrary sections. The name of the function or the name of the data item determines the section’s name in the output file. 
# -mthumb => Select between generating code that executes in ARM and Thumb states
# -g Produce debugging information in the operating system’s native format (stabs, COFF, XCOFF, or DWARF). GDB can work with this debugging information. 
# https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html
# -Wall this enables all the warnings about constructions that some users consider questionable
# -Wextra This enables some extra warning flags that are not enabled by -Wall
# https://gcc.gnu.org/onlinedocs/gcc/C_002b_002b-Dialect-Options.html
# -fno-threadsafe-statics Do not emit the extra code to use the routines specified in the C++ ABI for thread-safe initialization of local statics. You can use this option to reduce code size slightly in code that doesn’t need to be thread-safe.
# -fno-use-cxa-get-exception-ptr Don’t use the __cxa_get_exception_ptr runtime routine. This causes std::uncaught_exception to be incorrect, but is necessary if the runtime routine is not available.
#  -fno-rtti Disable generation of information about every class with virtual functions for use by the C++ run-time type identification features (dynamic_cast and typeid). If you don’t use those parts of the language, you can save some space by using this flag.
# -fmessage-length=n Try to format error messages so that they fit on lines of about n characters. If n is zero, then no line-wrapping is done;
# -fsigned-char Let the type char be signed, like signed char. 
# -ffreestanding Assert that compilation targets a freestanding environment. This implies -fno-builtin. A freestanding environment is one in which the standard library may not exist, and program startup may not necessarily be at main
GCC_FLAGS="-c -ffunction-sections -fdata-sections -mthumb -mcpu=cortex-m0plus -g -mfloat-abi=soft -Og"
GPP_FLAGS="$GCC_FLAGS -std=c++17 -fno-exceptions -fno-threadsafe-statics -fno-use-cxa-atexit -fno-rtti -fmessage-length=0 -fsigned-char -Wall -Wextra -ffreestanding -fno-builtin -frecord-gcc-switches"
INCLUDES_BASIC=""
INLCUDES="$INCLUDES_BASIC"

set -x #echo on

mkdir -p build
rm build/* -f

filename=vectors_startup
file="$TOOLCHAIN_GPP ./$filename.cpp $INLCUDES -o build/$filename.o $GPP_FLAGS"
$file

filename=main
file="$TOOLCHAIN_GPP ./$filename.cpp $INLCUDES -o build/$filename.o $GPP_FLAGS"
$file

filename=boot2_generic_03h
file="$TOOLCHAIN_GCC ./boot2/$filename.S $INLCUDES -o build/boot2.o $GCC_FLAGS"
$file

# generate bin file for boot2 code to calculate CRC
# objcopy will not copy out sections that are flagged neither loaded ("load") nor allocated ("alloc").
$TOOLCHAIN_OBJCOPY -O binary build/boot2.o build/boot2.bin
# Compile app to generate CRC
g++ -I ../utils boot2/compCrc32.cpp -o build/compCrc32
echo -e "\033[0;32mGenerating crc.c file\033[0m"
build/compCrc32 build/boot2.bin

file="$TOOLCHAIN_GCC build/crc.c $INLCUDES -o build/crc.o $GCC_FLAGS"
$file

mkdir -p output

# --gc-sections - remove not referenced code
LINKER_FLAGS="-nostartfiles -Wl,--gc-sections -mcpu=cortex-m0plus -mthumb"
linker="$TOOLCHAIN_GPP build/*.o -T$LINKER_SCRIPT -o output/output.elf  -Xlinker -Map=output/output.map $LINKER_FLAGS"
echo -e "\033[0;32mLinking\033[0m"
$linker

$TOOLCHAIN_OBJDUMP -S -d -mcortex-m0plus output/output.elf > output/output.asm
$TOOLCHAIN_OBJCOPY -O ihex output/output.elf output/output.hex
$TOOLCHAIN_OBJCOPY -O binary output/output.elf output/output.bin
$TOOLCHAIN_SIZE "output/output.elf"
echo -e "\033[0;32mGenerating uf2 file\033[0m"
python3 ../utils/uf2conv.py -b 0x10000000 -f 0xe48bff56 -c output/output.bin -o output/output.uf2
