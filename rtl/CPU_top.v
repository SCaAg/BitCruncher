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
    input clk,
    input rst_n,
    input [15:0] MBR_in_memory,
    output [7:0] MAR_out_memory,
    output [15:0] MBR_out_memory
    );

    wire [31:0] Control_Signals;
    wire [15:0] MBR_out;
    wire [15:0] BR_out;
    wire [15:0] ALU_out;
    wire [7:0] IR_out;
    wire [7:0] PC_out;
    wire [3:0] ALUflags;

    MAR u_MAR(
    .clk     ( clk     ),
    .rst_n   ( rst_n   ),
    .C5      ( Control_Signals[5]      ),
    .C10     ( Control_Signals[10]     ),
    .MBR_out ( MBR_out ),
    .PC_out  ( PC_out  ),
    .MAR_out_memory  ( MAR_out_memory  )
    );

    MBR u_MBR(
    .clk           ( clk           ),
    .rst_n         ( rst_n         ),
    .C3            ( Control_Signals[3]   ),
    .C11           ( Control_Signals[11]           ),
    .C12           ( Control_Signals[12]           ),
    .ALU_out       ( ALU_out       ),
    .MBR_in_memory ( MBR_in_memory ),
    .MBR_out       ( MBR_out       ),
    .MBR_out_memory  ( MBR_out_memory  )
    );

    (* keep_hierarchy = "yes" *)
    ALU_ACC u_ALU_ACC(
    .clk     ( clk     ),
    .rst_n   ( rst_n   ),
    .C8      ( Control_Signals[8]      ),
    .C9      ( Control_Signals[9]      ),
    .C13     ( Control_Signals[13]     ),
    .C15     ( Control_Signals[15]     ),
    .C16     ( Control_Signals[16]     ),
    .C17     ( Control_Signals[17]     ),
    .C18     ( Control_Signals[18]     ),
    .C19     ( Control_Signals[19]     ),
    .C20     ( Control_Signals[20]     ),
    .C21     ( Control_Signals[21]     ),
    .BR_out  ( BR_out  ),
    .ALU_out ( ALU_out ),
    .ALUflags  ( ALUflags  )
    );


    PC u_PC(
    .clk     ( clk     ),
    .rst_n   ( rst_n   ),
    .C6      ( Control_Signals[6]      ),
    .C14     ( Control_Signals[14]     ),
    .MBR_out ( MBR_out ),
    .PC_out  ( PC_out  )
    );


    IR u_IR(
    .clk     ( clk     ),
    .rst_n   ( rst_n   ),
    .C4      ( Control_Signals[4]      ),
    .MBR_out ( MBR_out ),
    .IR_out  ( IR_out  )
    );

    (* keep_hierarchy = "yes" *)
    BR u_BR(
    .clk     ( clk     ),
    .rst_n   ( rst_n   ),
    .C7      ( Control_Signals[7]      ),
    .MBR_out ( MBR_out ),
    .BR_out  ( BR_out  )
    );

    CU u_CU(
    .clk      ( clk      ),
    .rst_n    ( rst_n    ),
    .IR_out   ( IR_out   ),
    .ALUflags ( ALUflags ),
    .Control_Signals  ( Control_Signals  )
    );


endmodule
