#exec python ./Assembler/Assembler.py ./Assembler/test1.asm
exec python ./Assembler/Assembler.py ./Assembler/OneOperand.asm
vsim -gui work.main
mem load -i {./memory.mem} /main/FetchStage_PORTMAP/INSTRUCTION_RAM/RAM
add wave  \
sim:/main/CLK \
sim:/main/RST \
-radix hexadecimal sim:/main/PC \
sim:/main/DecodeStage_PORTMAP/CONTROL_UNIT/controlSignals \
sim:/main/DecodeStage_PORTMAP/CONTROL_UNIT/instruction \
sim:/main/DecodeStage_PORTMAP/CONTROL_UNIT/temp \
sim:/main/ExecutionStage_PORTMAP/FLAG \
sim:/main/ALU_OUT_EX \
sim:/main/ALU_OUT_EX_MEM \
sim:/main/ALU_OUT_MEM_WB \
sim:/main/BUFFER_WRITE_ENABLE \
sim:/main/IF_ID_MAP/WRITE_ENABLE \
sim:/main/IF_ID_MAP/INSTRUCTION_IN \
sim:/main/IF_ID_MAP/INSTRUCTION_OUT \
sim:/main/CTRL_SIG_ID \
sim:/main/CTRL_SIG_OUT_ID_EX \
sim:/main/CTRL_SIG_OUT_EX_MEM \
sim:/main/CTRL_SIG_OUT_MEM_WB \
sim:/main/ENABLE_WB \
sim:/main/IMMEDIATE_IF_ID \
sim:/main/IMMEDIATE_OUT_ID_EX \
sim:/main/IMMEDIATE_VALUE_IF \
sim:/main/INPUT_PORT \
sim:/main/INSTRUCTION_IF \
sim:/main/INSTRUCTION_IF_ID \
sim:/main/InputBus_WB \
sim:/main/MEM_OUT_MEM \
sim:/main/MEM_OUT_MEM_WB \
sim:/main/OUTPUT_PORT \
sim:/main/PC_EX_MEM \
sim:/main/PC_ID_EX \
sim:/main/PC_IF \
sim:/main/PC_IF_ID \
sim:/main/PC_MEM_WB \
sim:/main/PORT_WRITE_ENABLE \
sim:/main/RDST_INDEX_OUT_EX_MEM \
sim:/main/RDST_INDEX_OUT_ID \
sim:/main/RDST_INDEX_OUT_ID_EX \
sim:/main/RDST_INDEX_OUT_MEM_WB \
sim:/main/RDST_VALUE_OUT_ID \
sim:/main/RDST_VAL_OUT_EX_MEM \
sim:/main/RDST_VAL_OUT_ID_EX \
sim:/main/RSRC_INDEX_OUT_EX_MEM \
sim:/main/RSRC_INDEX_OUT_ID \
sim:/main/RSRC_INDEX_OUT_ID_EX \
sim:/main/RSRC_VALUE_OUT_ID \
sim:/main/RSRC_VAL_OUT_EX_MEM \
sim:/main/RSRC_VAL_OUT_ID_EX \
sim:/main/writeIndex_WB

force -freeze sim:/main/CLK 1 0, 0 {50 ps} -r 100
force -freeze sim:/main/RST 1 0
run
force -freeze sim:/main/RST 0 0
run 700
force -freeze sim:/main/INPUT_PORT 16#5 0
run 100
force -freeze sim:/main/INPUT_PORT 16#10 0
run 100
