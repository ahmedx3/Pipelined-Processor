vsim -gui work.alu
add wave -position end  sim:/alu/RST
add wave -position end  sim:/alu/SEL
add wave -position end -radix decimal sim:/alu/A
add wave -position end -radix decimal sim:/alu/B
add wave -position end  sim:/alu/FLAG_EN
add wave -position end  sim:/alu/SHIFT
add wave -position end -radix decimal sim:/alu/C
add wave -position end  sim:/alu/FLAG
add wave -position end -radix decimal sim:/alu/FIRST
add wave -position end -radix decimal sim:/alu/SECOND
add wave -position end -radix decimal sim:/alu/ADDER_OUT
add wave -position end -radix decimal sim:/alu/ALU_OUT
add wave -position end  sim:/alu/CARRY_IN
add wave -position end  sim:/alu/CARRY_OUT
add wave -position end  sim:/alu/SH

force -freeze sim:/alu/RST 1 0
run
force -freeze sim:/alu/RST 0 0
force -freeze sim:/alu/A 10#30 0
force -freeze sim:/alu/B 10#20 0
force -freeze sim:/alu/SHIFT 00000 0
force -freeze sim:/alu/FLAG_EN 1 0

force -freeze sim:/alu/SEL 0000 0
run
force -freeze sim:/alu/SEL 0001 0
run
force -freeze sim:/alu/SEL 0010 0
run
force -freeze sim:/alu/SEL 0011 0
run
force -freeze sim:/alu/SEL 0100 0
run
force -freeze sim:/alu/SEL 0101 0
run
force -freeze sim:/alu/SEL 0110 0
run
force -freeze sim:/alu/SEL 0111 0
run
force -freeze sim:/alu/SEL 1000 0
run
force -freeze sim:/alu/SEL 1001 0
run
force -freeze sim:/alu/SEL 1010 0
run
force -freeze sim:/alu/SEL 1011 0
run
force -freeze sim:/alu/SEL 1100 0
run
force -freeze sim:/alu/SEL 1101 0
run
force -freeze sim:/alu/SHIFT 00010 0
force -freeze sim:/alu/SEL 1110 0
run
force -freeze sim:/alu/SHIFT 00011 0
force -freeze sim:/alu/SEL 1111 0
run