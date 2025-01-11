#/bin/bash

/opt/openocd/bin/openocd -f interface/cmsis-dap.cfg -f target/rp2040.cfg -c "adapter speed 5000" -c "program output/output.elf verify" -c "reset run" -c "exit"
