vsim -gui work.fetchstage
add wave -position insertpoint  \
sim:/fetchstage/CLK \
sim:/fetchstage/PC_IN \
sim:/fetchstage/SP_IN \
sim:/fetchstage/PC_OUT \
sim:/fetchstage/SP_OUT \
sim:/fetchstage/INSTRUCTION \
sim:/fetchstage/IMMEDIATE_VALUE
force -freeze sim:/fetchstage/CLK 1 0, 0 {50 ps} -r 100
force -freeze sim:/fetchstage/PC_IN 00000000000000000000000000000000 0
force -freeze sim:/fetchstage/SP_IN 00000000000000000000000000000001 0
run
run
run
run