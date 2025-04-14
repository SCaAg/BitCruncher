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
    wire C5, C10;
    assign C5 = Control_Signals[5];
    assign C10 = Control_Signals[10];
    // Memory Address Register (MAR)
    MAR u_MAR(
        .clk              (clk),
        .rst_n            (rst_n),
        .C5               (C5),     // MAR <- MBR[7:0]
        .C10              (C10),    // MAR <- PC
        .MBR_out          (MBR_out),
        .PC_out           (PC_out),
        .MAR_out_memory   (MAR_out_memory)
    );

    // Memory Buffer Register (MBR)
    wire C3, C11, C12;
    assign C3 = Control_Signals[3];
    assign C11 = Control_Signals[11];
    assign C12 = Control_Signals[12];
    MBR u_MBR(
        .clk              (clk),
        .rst_n            (rst_n),
        .C3               (C3),     // MBR <- memory
        .C11              (C11),    // memory <- MBR
        .C12              (C12),    // MBR <- ACC
        .ACC_in           (ACC_out),
        .memory_in        (MBR_in_memory),
        .MBR_out          (MBR_out),
        .memory_out       (MBR_out_memory)
    );

    // Arithmetic Logic Unit and Accumulator
    wire C8, C9, C13, C15, C16, C17, C18, C19, C20, C21;
    assign C8 = Control_Signals[8];
    assign C9 = Control_Signals[9];
    assign C13 = Control_Signals[13];
    assign C15 = Control_Signals[15];
    assign C16 = Control_Signals[16];   
    assign C17 = Control_Signals[17];
    assign C18 = Control_Signals[18];
    assign C19 = Control_Signals[19];
    assign C20 = Control_Signals[20];
    assign C21 = Control_Signals[21];
    

    ALU_ACC u_ALU_ACC(
        .clk              (clk),
        .rst_n            (rst_n),
        .C8               (C8),     // ACC <- 0
        .C9               (C9),     // ACC <- ACC+BR
        .C13              (C13),    // ACC <- ACC-BR
        .C15              (C15),    // ACC <- ACC*BR
        .C16              (C16),    // ACC <- ACC/BR
        .C17              (C17),    // ACC <- ACC<<BR
        .C18              (C18),    // ACC <- ACC>>BR
        .C19              (C19),    // ACC <- ACC&BR
        .C20              (C20),    // ACC <- ACC|BR
        .C21              (C21),    // ACC <- ~BR
        .BR_in           (BR_out),
        .ACC_out          (ACC_out),
        .ALUflags         (ALUflags)                // {ZF, CF, OF, SF}
    );

    // Program Counter (PC)
    wire C6, C14;
    assign C6 = Control_Signals[6];
    assign C14 = Control_Signals[14];
    PC u_PC(
        .clk              (clk),
        .rst_n            (rst_n),
        .C6               (C6),     // PC <- PC+1
        .C14              (C14),    // PC <- MBR[7:0]
        .MBR_in           (MBR_out),
        .PC_out           (PC_out)
    );

    // Instruction Register (IR)
    wire C4;
    assign C4 = Control_Signals[4];
    IR u_IR(
        .clk              (clk),
        .rst_n            (rst_n),
        .C4               (C4),     // IR <- MBR[15:8]
        .MBR_in           (MBR_out),
        .IR_out           (IR_out)
    );

    // Buffer Register (BR)
    wire C7;
    assign C7 = Control_Signals[7];
    BR u_BR(
        .clk              (clk),
        .rst_n            (rst_n),
        .C7               (C7),     // BR <- MBR
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
