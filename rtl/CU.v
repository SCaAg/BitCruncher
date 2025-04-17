`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/21 15:10:25
// Design Name: 
// Module Name: CU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
// Instruction Opcodes (8-bit)
`include "include/instruction_set.vh"

module CU(
    input wire clk,
    input wire rst_n,
    input wire [15:0] IR_in,  // Changed from IR_in to IR_in for consistency
    input wire [3:0] ALUflags,  // {ZF, CF, OF, SF}
    output reg [31:0] Control_Signals
);

    // Control signals mapping (from 0 to 31)
    // C0: CAR <- CAR+1 (Control Address Register increment)
    // C1: CAR <- *** (Control Address Redirection)
    // C2: CAR <- 0 (Reset Control Address)
    // C3: MBR <- memory (Load memory to MBR)
    // C4: IR <- MBR[15:8] (Load OPCODE to IR)
    // C5: MAR <- MBR[7:0] (Load address part to MAR)
    // C6: PC <- PC+1 (Increment PC)
    // C7: BR <- MBR (Load MBR to BR for ALU)
    // C8: ACC <- 0 (Reset ACC)
    // C9: ACC <- ACC+BR (Add BR to ACC)
    // C10: MAR <- PC (Copy PC to MAR for next fetch)
    // C11: Mem[MAR] <- MBR (Store MBR to memory)
    // C12: MBR <- ACC (Copy ACC to MBR)
    // C13: ACC <- ACC-BR (Subtract BR from ACC)
    // C14: PC <- MBR (Jump instruction, load MBR to PC)
    // C15: ACC <- ACC*BR (Multiply)
    // C16: ACC <- ACC/BR (Divide)
    // C17: ACC <- ACC << BR (Shift left)
    // C18: ACC <- ACC >> BR (Shift right)
    // C19: ACC <- ACC & BR (AND)
    // C20: ACC <- ACC | BR (OR)
    // C21: ACC <- ~BR (NOT)
    
    // Control signals for ALU operations
    // C22-C31: Reserved for future use
    
    // Microcode memory - 64 addresses, each storing 32-bit control signals
    reg [31:0] microcode_memory [0:71];
    
    // Control Address Register (CAR) - points to current microinstruction
    reg [7:0] CAR;
    
    // Initialize microcode memory
    initial begin

        
        // Common beginning for all instructions (fetch)
        // Step 1: MBR <- Mem[MAR] (C3)
        microcode_memory[0] = 32'b00000000000000000000000000001001; // C0|C3
        
        // Step 2: IR <- MBR (C4)
        microcode_memory[1] = 32'b00000000000000000000000000010001; // C0|C4
        
        // Step 3: MAR <- MBR[7:0], PC <- PC+1
        microcode_memory[2] = 32'b00000000000000000000000001100001; // C0|C5|C6

        // Step 3: Decode - Branch based on opcode (C1)
        microcode_memory[3] = 32'b00000000000000000000000000000010; // C1
        microcode_memory[4] = 32'b00000000000000000000000000000000; // No operation
        
        // Instruction-specific microcodes
        // LOAD instruction (opcode 00000010)
        microcode_memory[5] = 32'b00000000000000000000000000001001; // C0|C3 - MBR <- Mem[MAR]
        microcode_memory[6] = 32'b00000000000000000000000110000001; // C0|C7|C8 - BR <- MBR, ACC <- 0
        microcode_memory[7] = 32'b00000000000000000000001000000001; // C0|C9 - ACC <- ACC+BR
        microcode_memory[8] = 32'b00000000000000000000000000000010; // C1 - Jump to end
        microcode_memory[9] = 32'b00000000000000000000000000000000; // No operation

        // STORE instruction (opcode 00000001)
        microcode_memory[10] = 32'b00000000000000000001000000000001; // C0|C12 - MBR <- ACC
        microcode_memory[11] = 32'b00000000000000000000100000000001; // C0|C11 - Mem[MAR] <- MBR
        microcode_memory[12] = 32'b00000000000000000000000000000010; // C1 - Jump to end
        microcode_memory[13] = 32'b00000000100000000000000000000000; // C23 - Write Enable
        
        // ADD instruction (opcode 00000011)
        microcode_memory[14] = 32'b00000000000000000000000000001001; // C0|C3 - MBR <- Mem[MAR]
        microcode_memory[15] = 32'b00000000000000000000000010000001; // C0|C7 - BR <- MBR
        microcode_memory[16] = 32'b00000000000000000000001000000001; // C0|C9 - ACC <- ACC+BR
        microcode_memory[17] = 32'b00000000000000000000000000000010; // C1 - Jump to end
        microcode_memory[18] = 32'b00000000000000000000000000000000; // No operation
        
        // SUB instruction (opcode 00000100)
        microcode_memory[19] = 32'b00000000000000000000000000001001; // C0|C3 - MBR <- Mem[MAR]
        microcode_memory[20] = 32'b00000000000000000000000010000001; // C0|C7 - BR <- MBR
        microcode_memory[21] = 32'b00000000000000000010000000000001; // C0|C13 - ACC <- ACC-BR
        microcode_memory[22] = 32'b00000000000000000000000000000010; // C1 - Jump to end
        microcode_memory[23] = 32'b00000000000000000000000000000000; // No operation
        
        // JMPGEZ instruction (opcode 00000101) - Jump if ACC >= 0
        microcode_memory[24] = 32'b00000000000000000000000000001001; // C0|C3 - MBR <- Mem[MAR]
        // Branch based on condition
        microcode_memory[25] = 32'b00000000000000000000000000000010; // C1 - Condition check (will be redirected based on flags)
        microcode_memory[26] = 32'b00000000000000000000000000000000; // No operation
        // Path for when condition is true (ACC >= 0)
        microcode_memory[27] = 32'b00000000000000000100000000000001; // C0|C14 - PC <- MBR (Jump)
        microcode_memory[28] = 32'b00000000000000000000000000000010; // C1 - Jump to end
        microcode_memory[29] = 32'b00000000000000000000000000000000; // No operation
        // Path for when condition is false (ACC < 0)
        microcode_memory[30] = 32'b00000000000000000000000000000001; // C0 - Just increment CAR (No jump)
        microcode_memory[31] = 32'b00000000000000000000000000000010; // C1 - Jump to end
        microcode_memory[32] = 32'b00000000000000000000000000000000; // No operation
        
        // JMP instruction (opcode 00000110)
        microcode_memory[33] = 32'b00000000000000000000000000001001; // C0|C3 - MBR <- Mem[MAR]
        microcode_memory[34] = 32'b00000000000000000100000000000001; // C0|C14 - PC <- MBR
        microcode_memory[35] = 32'b00000000000000000000000000000001; // C0 - Increment CAR
        microcode_memory[36] = 32'b00000000000000000000000000000010; // C1 - Jump to end
        microcode_memory[37] = 32'b00000000000000000000000000000000; // No operation
        
        // HALT instruction (opcode 00000111)
        microcode_memory[38] = 32'b00000000000000000000000000000000; // No operation (halt)
        microcode_memory[39] = 32'b00000000000000000000000000000000; // No operation (halt)
        microcode_memory[40] = 32'b00000000000000000000000000000000; // No operation (halt forever)
        
        // MPY instruction (opcode 00001000)
        microcode_memory[41] = 32'b00000000000000000000000000001001; // C0|C3 - MBR <- Mem[MAR]
        microcode_memory[42] = 32'b00000000000000000000000010000001; // C0|C7 - BR <- MBR
        microcode_memory[43] = 32'b00000000000000001000000000000001; // C0|C15 - ACC <- ACC*BR
        microcode_memory[44] = 32'b00000000000000000000000000000010; // C1 - Jump to end
        microcode_memory[45] = 32'b00000000000000000000000000000000; // No operation
        
        // AND instruction (opcode 00001010)
        microcode_memory[46] = 32'b00000000000000000000000000001001; // C0|C3 - MBR <- Mem[MAR]
        microcode_memory[47] = 32'b00000000000000000000000010000001; // C0|C7 - BR <- MBR
        microcode_memory[48] = 32'b00000000000010000000000000000001; // C0|C19 - ACC <- ACC&BR
        microcode_memory[49] = 32'b00000000000000000000000000000010; // C1 - Jump to end
        microcode_memory[50] = 32'b00000000000000000000000000000000; // No operation
        
        // OR instruction (opcode 00001011)
        microcode_memory[51] = 32'b00000000000000000000000000001001; // C0|C3 - MBR <- Mem[MAR]
        microcode_memory[52] = 32'b00000000000000000000000010000001; // C0|C7 - BR <- MBR
        microcode_memory[53] = 32'b00000000000100000000000000000001; // C0|C20 - ACC <- ACC|BR
        microcode_memory[54] = 32'b00000000000000000000000000000010; // C1 - Jump to end
        microcode_memory[55] = 32'b00000000000000000000000000000000; // No operation
        
        // NOT instruction (opcode 00001100)
        microcode_memory[56] = 32'b00000000000000000000000000001001; // C0|C3 - MBR <- Mem[MAR]
        microcode_memory[57] = 32'b00000000000000000000000010000001; // C0|C7 - BR <- MBR
        microcode_memory[58] = 32'b00000000001000000000000000000001; // C0|C21 - ACC <- ~BR
        microcode_memory[59] = 32'b00000000000000000000000000000010; // C1 - Jump to end
        microcode_memory[60] = 32'b00000000000000000000000000000000; // No operation
        
        // SHIFTR instruction (opcode 00001101)
        microcode_memory[61] = 32'b00000000000000000000000000001001; // C0|C3 - MBR <- Mem[MAR]
        microcode_memory[62] = 32'b00000000000000000000000010000001; // C0|C7 - BR <- MBR
        microcode_memory[63] = 32'b00000000000001000000000000000001; // C0|C18 - ACC <- ACC>>BR
        microcode_memory[64] = 32'b00000000000000000000000000000010; // C1 - Jump to end
        microcode_memory[65] = 32'b00000000000000000000000000000000; // No operation
        
        // SHIFTL instruction (opcode 00001110)
        microcode_memory[66] = 32'b00000000000000000000000000001001; // C0|C3 - MBR <- Mem[MAR]
        microcode_memory[67] = 32'b00000000000000000000000010000001; // C0|C7 - BR <- MBR
        microcode_memory[68] = 32'b00000000000000100000000000000001; // C0|C17 - ACC <- ACC<<BR
        microcode_memory[69] = 32'b00000000000000000000000000000010; // C1 - Jump to end
        microcode_memory[70] = 32'b00000000000000000000000000000000; // No operation
        
        // Common ending for all instructions - return to fetch cycle
        // MAR <- PC, CAR <- 0
        microcode_memory[71] = 32'b00000000000000000000010000000100; // C2|C10 - Reset CAR to 0 and MAR <- PC
    end
    
    // Handle Control Signals updates
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            Control_Signals <= 32'd0;
        end else begin
            // Output current control signals
            Control_Signals <= microcode_memory[CAR];
        end
    end
    
    // Handle Control Address Register updates
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            CAR <= 6'd0;  // Reset to start of fetch cycle
        end else begin
            // Update CAR based on current microcode
            if (Control_Signals[0]) begin  // C0: Increment CAR
                CAR <= CAR + 1;
            end else if (Control_Signals[1]) begin  // C1: Redirection based on opcode or condition
                if (CAR == 7'd3 + 1'b1) begin
                    // Map opcode to microcode entry points
                    case (IR_in[15:8])
                        `OPCODE_LOAD:   CAR <= 7'd5;
                        `OPCODE_STORE:  CAR <= 7'd10;
                        `OPCODE_ADD:    CAR <= 7'd14;
                        `OPCODE_SUB:    CAR <= 7'd19;
                        `OPCODE_JMPGEZ: CAR <= 7'd24;
                        `OPCODE_JMP:    CAR <= 7'd33;
                        `OPCODE_HALT:   CAR <= 7'd38;
                        `OPCODE_MPY:    CAR <= 7'd41;
                        `OPCODE_AND:    CAR <= 7'd46;
                        `OPCODE_OR:     CAR <= 7'd51;
                        `OPCODE_NOT:    CAR <= 7'd56;
                        `OPCODE_SHIFTR: CAR <= 7'd61;
                        `OPCODE_SHIFTL: CAR <= 7'd66;
                        default:        CAR <= 7'd71;  // Go to end on unknown opcode
                    endcase
                end else if (CAR == 7'd25 + 1'b1) begin//TODO: Check if this is correct
                    // For JMPGEZ conditional branch in microcode
                    // Note: In our implementation, ALUflags[3]=ZF, ALUflags[0]=SF
                    if (ALUflags[0] == 1'b0 || ALUflags[3] == 1'b1) begin
                        // If ACC >= 0, branch to the jump path
                        CAR <= 7'd27;
                    end else begin
                        // If ACC < 0, branch to the no-jump path
                        CAR <= 7'd30;
                    end
                end else begin
                    CAR <= 7'd71;
                end
            end else if (Control_Signals[2]) begin  // C2: Reset CAR
                CAR <= 7'd0;
            end
        end
    end
    
endmodule
