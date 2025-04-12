`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/19 13:51:37
// Design Name: 
// Module Name: CPU_top
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


module CPU_top(
    input clk,              // System clock
    input rst_n,            // Active-low reset
    input [15:0] MBR_in_memory,   // Data from memory to MBR
    output [7:0] MAR_out_memory,  // Address from MAR to memory
    output [15:0] MBR_out_memory  // Data from MBR to memory
    );

    // Internal signals
    wire [31:0] Control_Signals;  // Control signals from CU
    wire [15:0] MBR_out;          // Output from MBR register
    wire [15:0] BR_out;           // Output from BR register
    wire [15:0] ACC_out;          // Output from ALU
    wire [7:0] IR_out;            // Output from IR register
    wire [7:0] PC_out;            // Output from PC register
    wire [3:0] ALUflags;          // ALU flags {ZF, CF, OF, SF}

    // Memory Address Register (MAR)
    MAR u_MAR(
        .clk              (clk),
        .rst_n            (rst_n),
        .C5               (Control_Signals[5]),     // MAR <- MBR[7:0]
        .C10              (Control_Signals[10]),    // MAR <- PC
        .MBR_out          (MBR_out),
        .PC_out           (PC_out),
        .MAR_out_memory   (MAR_out_memory)
    );

    // Memory Buffer Register (MBR)
    MBR u_MBR(
        .clk              (clk),
        .rst_n            (rst_n),
        .C3               (Control_Signals[3]),     // MBR <- memory
        .C11              (Control_Signals[11]),    // memory <- MBR
        .C12              (Control_Signals[12]),    // MBR <- ACC
        .ACC_in           (ACC_out),
        .memory_in        (MBR_in_memory),
        .MBR_out          (MBR_out),
        .memory_out       (MBR_out_memory)
    );

    // Arithmetic Logic Unit and Accumulator
    ALU_ACC u_ALU_ACC(
        .clk              (clk),
        .rst_n            (rst_n),
        .C8               (Control_Signals[8]),     // ACC <- 0
        .C9               (Control_Signals[9]),     // ACC <- ACC+BR
        .C13              (Control_Signals[13]),    // ACC <- ACC-BR
        .C15              (Control_Signals[15]),    // ACC <- ACC*BR
        .C16              (Control_Signals[16]),    // ACC <- ACC/BR
        .C17              (Control_Signals[17]),    // ACC <- ACC<<BR
        .C18              (Control_Signals[18]),    // ACC <- ACC>>BR
        .C19              (Control_Signals[19]),    // ACC <- ACC&BR
        .C20              (Control_Signals[20]),    // ACC <- ACC|BR
        .C21              (Control_Signals[21]),    // ACC <- ~BR
        .BR_in           (BR_out),
        .ACC_out          (ACC_out),
        .ALUflags         (ALUflags)                // {ZF, CF, OF, SF}
    );

    // Program Counter (PC)
    PC u_PC(
        .clk              (clk),
        .rst_n            (rst_n),
        .C6               (Control_Signals[6]),     // PC <- PC+1
        .C14              (Control_Signals[14]),    // PC <- MBR[7:0]
        .MBR_in           (MBR_out),
        .PC_out           (PC_out)
    );

    // Instruction Register (IR)
    IR u_IR(
        .clk              (clk),
        .rst_n            (rst_n),
        .C4               (Control_Signals[4]),     // IR <- MBR[15:8]
        .MBR_in           (MBR_out),
        .IR_out           (IR_out)
    );

    // Buffer Register (BR)
    BR u_BR(
        .clk              (clk),
        .rst_n            (rst_n),
        .C7               (Control_Signals[7]),     // BR <- MBR
        .MBR_in           (MBR_out),
        .BR_out           (BR_out)
    );

    // Control Unit (CU)
    CU u_CU(
        .clk              (clk),
        .rst_n            (rst_n),
        .IR_out           (IR_out),
        .ALUflags         (ALUflags),
        .Control_Signals  (Control_Signals)
    );

endmodule
