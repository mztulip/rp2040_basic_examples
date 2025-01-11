#/bin/bash
# tested with Open On-Chip Debugger 0.12.0+dev-gebec950 (2025-01-11-12:30)
# from https://github.com/raspberrypi/openocd branch rp2040
/opt/openocd/bin/openocd -f interface/cmsis-dap.cfg -f target/rp2040.cfg -c "adapter speed 5000" -c "program output/output.elf verify" -c "reset run" -c "exit"
