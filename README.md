# Multi-Cycle-RISC-V
Implementation of a multi cycle RISC-V processor in Verilog, for FPGA.

Designed for 4 types of opcodes:
1. R-format(arithemetic) : 51
2. LOAD type : 3
3. STORE type : 35
4. BEQ type : 99

##########################################################################################################################################################################################################

ALU operations:
1. ADD
2. SUBTRACT
3. AND
4. OR

###########################################################################################################################################################################################################

Instruction format
1. R-format : {funct7[6:0] , register_1[4:0] , register_2[4:0] , funct3[2:0] , register_write[4:0] , opcode[6:0]}
2. LOAD : {offset[11:0] , register[4:0] , funct3[2:0] , register_write[4:0] , opcode[6:0]}
3. STORE : {offset[11:5] , register_2[4:0] ,  register_1[4:0] , funct3[2:0] , offset[4:0] , opcode[6:0]}
4. BEQ : {offset[11] , offset[9:4] , register_1[4:0] , register_2[4:0] , funct3[2:0] , offset[3:0] , offset[10] , opcode[6:0]}
