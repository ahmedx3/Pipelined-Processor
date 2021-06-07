exec python ./Assembler/Assembler.py ./Assembler/Branch.asm
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
force -freeze sim:/main/INPUT_PORT 16#30 0
run 100
force -freeze sim:/main/INPUT_PORT 16#50 0
run 100
force -freeze sim:/main/INPUT_PORT 16#100 0
run 100
force -freeze sim:/main/INPUT_PORT 16#300 0
run 100
force -freeze sim:/main/INPUT_PORT 16#200 0
run 500