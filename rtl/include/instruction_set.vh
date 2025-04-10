// instruction_set.vh
// Custom CPU Instruction Set Definition
// Based on the provided instruction set architecture

`ifndef _INSTRUCTION_SET_VH_
`define _INSTRUCTION_SET_VH_

// Instruction Opcodes (8-bit)
`define OPCODE_STORE   8'b00000001  // ACC → [X]
`define OPCODE_LOAD    8'b00000010  // [X] → ACC
`define OPCODE_ADD     8'b00000011  // ACC + [X] → ACC
`define OPCODE_SUB     8'b00000100  // ACC - [X] → ACC
`define OPCODE_JMPGEZ  8'b00000101  // IF ACC ≥ 0 then X → PC else PC+1 → PC
`define OPCODE_JMP     8'b00000110  // X → PC
`define OPCODE_HALT    8'b00000111  // Halt a program
`define OPCODE_MPY     8'b00001000  // ACC ×[X] → MR, ACC
`define OPCODE_AND     8'b00001010  // ACC and [X] → ACC
`define OPCODE_OR      8'b00001011  // ACC or [X] → ACC
`define OPCODE_NOT     8'b00001100  // NOT [X] → ACC
`define OPCODE_SHIFTR  8'b00001101  // SHIFT [X] to Right 1bit, Logic Shift
`define OPCODE_SHIFTL  8'b00001110  // SHIFT [X] to Left 1bit, Logic Shift

// Instruction width parameters
`define OPCODE_WIDTH   8
`define ADDR_WIDTH     8  // Assuming 8-bit address field, adjust as needed
`define INSTR_WIDTH    (`OPCODE_WIDTH + `ADDR_WIDTH)

// Register definitions
`define REG_ACC        8'h00  // Accumulator
`define REG_PC         8'h01  // Program Counter
`define REG_MR         8'h02  // Multiplication Result

`endif // _INSTRUCTION_SET_VH_