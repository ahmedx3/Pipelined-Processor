import sys
import re
import numpy as np

###############################################################
########################## Read File ##########################
###############################################################

if(len(sys.argv) > 1):
    fileName = sys.argv[1]
else:
    fileName = input("Enter file name: ")

file = open(fileName, 'r')
instructionsRead = file.readlines()

#############################################################################
########################## Dictionaries And Arrays ##########################
#############################################################################

memory = ['0000000000000000'] * 2048

noOperand = [ "NOP" , "SETC" , "CLRC" , "RET" , "RTI" ]
oneOperand = ["CLR","NOT","","INC","DEC","NEG","OUT","IN","RLC","RRC","PUSH","POP","JZ","JN","JC","JMP","CALL"]
twoOperand = ["MOV","ADD","SUB","AND","OR","IADD" ,"SHL","SHR","LDM","LDD","STD"]

twoWordInstructions = ["IADD" , "LDM" , "LDD" , "STD"]
shiftInstructions = ["SHL","SHR"]

instructionsDict = {
    "NOP" : "000000",
    "SETC": "000001",
    "CLRC": "000010",
    "RET" : "000011",
    "RTI" : "000100",
    "CLR" :	"000101",
    "NOT" :	"000110",
    "INC" :	"000111",
    "DEC" :	"001000",
    "NEG" :	"001001",
    "OUT" :	"001010",
    "IN"  : "001011",
    "RLC" :	"001100",
    "RRC" :	"001101",
    "PUSH": "001110",
    "POP" :	"001111",
    "JZ"  : "010000",
    "JN"  : "010001",
    "JC"  : "010010",
    "JMP" :	"010011",
    "CALL": "010100",
    "MOV" :	"010101",
    "ADD" :	"010110",
    "SUB" :	"010111",
    "AND" :	"011000",
    "OR"  :	"011001",
    "IADD":	"011010",
    "SHL" : "011011",
    "SHR" : "011100",
    "LDM" : "011101",
    "LDD" : "011110",
    "STD" : "011111"
}

registersDict = {
   "R0" : "00000",
   "R1" : "00001",
   "R2" : "00010",
   "R3" : "00011",
   "R4" : "00100",
   "R5" : "00101",
   "R6" : "00110",
   "R7" : "00111"
}

##########################################################################
########################## Calculate the adress ##########################
##########################################################################

addressArr = [] # address of each instruction in decimal
instructionsProcessed = [] # instructions after processing them (removing spaces , comments , etc..)

tempAdress= -1
for i, instruction in enumerate(instructionsRead):
    instruction = instruction.upper().replace("\n","").replace("\t","").replace(",", " ").replace("(", " ").replace(")", "")
    instructionArr = instruction.split("#")[0].split(" ")
    instructionArr = list(filter(lambda x: x != "", instructionArr))
    
    if(instructionArr):
        
        if(instructionArr[0] == ".ORG"):
            hexNum = "0x" + instructionArr[1]
            decimalAdress = int(hexNum, 16)
            tempAdress = decimalAdress - 1
            continue
        
        tempAdress += 1

        # Handle 2 words instructions by adding one word location after the instr
        if(instructionArr[0] in twoWordInstructions):
            # print(instructionArr)
            instructionsProcessed.append(instructionArr)
            addressArr.append(tempAdress)
            tempAdress += 1
        else:
            # print(instructionArr)
            instructionsProcessed.append(instructionArr)
            addressArr.append(tempAdress)

#########################################################################
########################## Replace with opCode ##########################
#########################################################################

for i, instruction in enumerate(instructionsProcessed):
    code = ""
    if(instruction[0] in noOperand):
        code += instructionsDict[instruction[0]]
        code += "0000000000"
        memory[addressArr[i]] = code
    elif(instruction[0] in oneOperand):
        if (instruction[0] == 'OUT' or instruction[0] == 'PUSH'):
            code += instructionsDict[instruction[0]]
            code += registersDict[instruction[1]]
            code += "00000"
        else:
            code += instructionsDict[instruction[0]]
            code += "00000"
            code += registersDict[instruction[1]]
        memory[addressArr[i]] = code
    elif(instruction[0] in twoOperand):
        if(instruction[0] in twoWordInstructions):
            if(instruction[0] == "LDD"):
                code += instructionsDict[instruction[0]]
                code += registersDict[instruction[3]]
                code += registersDict[instruction[1]]
                memory[addressArr[i]] = code
                immediateValue = format(int(instruction[2], 16),'0>16b')
                memory[addressArr[i]+1] = immediateValue
            elif(instruction[0] == "STD"):
                code += instructionsDict[instruction[0]]
                code += registersDict[instruction[1]]
                code += registersDict[instruction[3]]
                memory[addressArr[i]] = code
                immediateValue = format(int(instruction[2], 16),'0>16b')
                memory[addressArr[i]+1] = immediateValue
            else:
                # for IADD and LDM
                code += instructionsDict[instruction[0]]
                code += "00000"
                code += registersDict[instruction[1]]
                memory[addressArr[i]] = code
                immediateValue = format(int(instruction[2], 16),'0>16b')
                memory[addressArr[i]+1] = immediateValue
        elif(instruction[0] in shiftInstructions):
            code += instructionsDict[instruction[0]]
            code += format(int(instruction[2], 16),'0>5b')
            code += registersDict[instruction[1]]
            memory[addressArr[i]] = code
        else:
            code += instructionsDict[instruction[0]]
            code += registersDict[instruction[1]]
            code += registersDict[instruction[2]]
            memory[addressArr[i]] = code
    else:
        # To handle reset and interrupt address
        code += format(int(instruction[0], 16),'0>16b')
        memory[addressArr[i]] = code

#########################################################################
########################## Save to memory file ##########################
#########################################################################

f = open('memory.mem', "w")
f.write("// instance=/ram/ram\n")
f.write("// format=mti addressradix=d dataradix=b version=1.0 wordsperline=1\n")
for index, element in enumerate(memory):
    f.write(str(index) + ": "+ element + "\n")
f.close()

