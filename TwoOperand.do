exec python ./Assembler/Assembler.py ./Assembler/TwoOperand.asm
#exec python ./Assembler/Assembler.py ./Assembler/OneOperand.asm
vsim -gui work.main
mem load -i {./memory.mem} /main/FetchStage_PORTMAP/INSTRUCTION_RAM/RAM
add wave  \
sim:/main/CLK \
sim:/main/RST \
-radix hexadecimal sim:/main/PC \
sim:/main/MemoryStage_PORTMAP/SP \
sim:/main/INPUT_PORT \
sim:/main/OUTPUT_PORT \
sim:/main/RegisterFile_PORTMAP/REGISTERS \
-radix binary sim:/main/ExecutionStage_PORTMAP/FLAG \


force -freeze sim:/main/INPUT_PORT 16#0 0
force -freeze sim:/main/CLK 1 0, 0 {50 ps} -r 100
force -freeze sim:/main/RST 1 0
run
force -freeze sim:/main/RST 0 0
run 200
force -freeze sim:/main/INPUT_PORT 16#5 0
run 100
force -freeze sim:/main/INPUT_PORT 16#19 0
run 100
force -freeze sim:/main/INPUT_PORT 16#FFFFFFFF 0
run 100
force -freeze sim:/main/INPUT_PORT 16#FFFFF320 0
run 100
