`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Simple testbench for Control Unit - Minimal version
// This version simply applies test vectors and lets you examine the waveform
//////////////////////////////////////////////////////////////////////////////////

`include "../../rtl/include/instruction_set.vh"

// Define Control Signal Macros for better readability
`define C_CAR_INC      32'b00000000000000000000000000000001 // C0: CAR <- CAR+1
`define C_CAR_REDIR    32'b00000000000000000000000000000010 // C1: CAR <- ***
`define C_CAR_RESET    32'b00000000000000000000000000000100 // C2: CAR <- 0
`define C_MBR_MEM      32'b00000000000000000000000000001000 // C3: MBR <- memory
`define C_IR_MBR       32'b00000000000000000000000000010000 // C4: IR <- MBR
`define C_MAR_MBR      32'b00000000000000000000000000100000 // C5: MAR <- MBR[7:0]
`define C_PC_INC       32'b00000000000000000000000001000000 // C6: PC <- PC+1
`define C_BR_MBR       32'b00000000000000000000000010000000 // C7: BR <- MBR
`define C_ACC_RESET    32'b00000000000000000000000100000000 // C8: ACC <- 0
`define C_ACC_ADD_BR   32'b00000000000000000000001000000000 // C9: ACC <- ACC+BR
`define C_MAR_PC       32'b00000000000000000000010000000000 // C10: MAR <- PC
`define C_MEM_MBR      32'b00000000000000000000100000000000 // C11: Mem[MAR] <- MBR
`define C_MBR_ACC      32'b00000000000000000001000000000000 // C12: MBR <- ACC
`define C_ACC_SUB_BR   32'b00000000000000000010000000000000 // C13: ACC <- ACC-BR
`define C_PC_MBR       32'b00000000000000000100000000000000 // C14: PC <- MBR
`define C_ACC_MUL_BR   32'b00000000000000001000000000000000 // C15: ACC <- ACC*BR
`define C_ACC_DIV_BR   32'b00000000000000010000000000000000 // C16: ACC <- ACC/BR
`define C_ACC_SHL_BR   32'b00000000000000100000000000000000 // C17: ACC <- ACC << BR
`define C_ACC_SHR_BR   32'b00000000000001000000000000000000 // C18: ACC <- ACC >> BR
`define C_ACC_AND_BR   32'b00000000000010000000000000000000 // C19: ACC <- ACC & BR
`define C_ACC_OR_BR    32'b00000000000100000000000000000000 // C20: ACC <- ACC | BR
`define C_ACC_NOT_BR   32'b00000000001000000000000000000000 // C21: ACC <- ~BR

module CU_tb;

    // Parameters
    parameter CLK_PERIOD = 10; // 10ns -> 100MHz
    parameter TEST_CYCLES = 20; // Number of cycles to run each instruction test
    
    // Inputs
    reg clk;
    reg rst_n;
    reg [7:0] IR_out;
    reg [3:0] ALUflags; // {ZF, CF, OF, SF}
    
    // Outputs
    wire [31:0] Control_Signals;
    
    // Instantiate the DUT (Device Under Test)
    CU dut (
        .clk(clk),
        .rst_n(rst_n),
        .IR_out(IR_out),
        .ALUflags(ALUflags),
        .Control_Signals(Control_Signals)
    );
    
    // Generate clock
    always #(CLK_PERIOD/2) clk = ~clk;
    
    // Task to test an instruction for a fixed number of cycles
    task test_instruction;
        input [7:0] opcode;
        input [63:0] instr_name;
        input [3:0] flags;
        begin
            $display("\n=== Testing %s instruction ===", instr_name);
            IR_out = opcode;
            ALUflags = flags;
            
            // Apply reset to ensure CAR is at 0
            rst_n = 0;
            #(CLK_PERIOD*2);
            rst_n = 1;
            
            // Run for fixed number of cycles
            #(CLK_PERIOD*TEST_CYCLES);
        end
    endtask
    
    // Main test sequence
    initial begin
        // Initialize inputs
        clk = 0;
        rst_n = 0;
        IR_out = 0;
        ALUflags = 0;
        
        // Initial reset
        #20 rst_n = 1;
        #10;
        
        // Test each instruction
        test_instruction(`OPCODE_LOAD, "LOAD", 4'b0000);
        test_instruction(`OPCODE_STORE, "STORE", 4'b0000);  
        test_instruction(`OPCODE_ADD, "ADD", 4'b0000);
        test_instruction(`OPCODE_SUB, "SUB", 4'b0000);
        
        // Test JMPGEZ with different ALU flags
        test_instruction(`OPCODE_JMPGEZ, "JMPGEZ (ACC >= 0)", 4'b1000); // ZF=1, SF=0 (ACC=0)
        test_instruction(`OPCODE_JMPGEZ, "JMPGEZ (ACC < 0)", 4'b0001);  // SF=1 (ACC<0)
        
        test_instruction(`OPCODE_JMP, "JMP", 4'b0000);
        test_instruction(`OPCODE_HALT, "HALT", 4'b0000);
        test_instruction(`OPCODE_MPY, "MPY", 4'b0000);
        test_instruction(`OPCODE_AND, "AND", 4'b0000);
        test_instruction(`OPCODE_OR, "OR", 4'b0000);
        test_instruction(`OPCODE_NOT, "NOT", 4'b0000);
        test_instruction(`OPCODE_SHIFTR, "SHIFTR", 4'b0000);
        test_instruction(`OPCODE_SHIFTL, "SHIFTL", 4'b0000);
        
        // End simulation
        $display("\n=== Test completed ===");
        #100 $finish;
    end
    
    // Display progress - critical signals to watch
    initial begin
        $monitor("Time: %0t | Reset: %b | IR: %b | ALUflags: %b | Control: %b",
                 $time, rst_n, IR_out, ALUflags, Control_Signals);
    end

endmodule
