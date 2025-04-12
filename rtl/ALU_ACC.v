`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/20 11:00:00
// Design Name: Accumulator Register
// Module Name: ACC
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 16-bit Accumulator register with integrated ALU control.
//              Loads result from ALU based on C22 enable signal.
//              Feeds its current value back to the ALU.
// 
// Dependencies: ALU.v
// 
// Revision:
// Revision 1.00 - File Created
// Additional Comments: Based on ALU.v and doc/寄组II预定义.md
// 
//////////////////////////////////////////////////////////////////////////////////

module ALU_ACC (
    // Clock and Reset
    input wire clk,
    input wire rst_n, // Active high reset

    // Control Inputs
    input wire C8, C9, C13, C15, C16, C17, C18, C19, C20, C21, // ALU Op Controls

    // Data Input
    input wire [15:0] BR_in, // Data input from Bus Register (for ALU)

    // Data Outputs
    output reg [15:0] ACC_out, // Current Accumulator Value
    output reg [3:0] ALUflags // Flags from ALU {ZF, CF, OF, SF}
);

    // Internal wires for ALU outputs
    wire [15:0] ALU_out_wire;
    wire [3:0] ALUflags_wire;
    
    // Instantiate the Arithmetic Logic Unit (ALU)
    ALU alu_inst (
        // Control Inputs (Pass through)
        .C8(C8), 
        .C9(C9), 
        .C13(C13), 
        .C15(C15), 
        .C16(C16), 
        .C17(C17), 
        .C18(C18), // Note: Markdown C17/C18 seem swapped vs ALU.v C17/C18 (SHL/SHR)
        .C19(C19), 
        .C20(C20), 
        .C21(C21), // Note: Markdown C21 is NOT ACC, ALU.v C21 is NOT BR. Using ALU.v behavior.

        // Data Inputs
        .ACC_in(ACC_out), // Feed current ACC value to ALU
        .BR_in(BR_in),    // Feed BR input to ALU

        // Data Outputs
        .ALU_out(ALU_out_wire),   // Get ALU result
        .ALUflags(ALUflags_wire)  // Get ALU flags
    );

    // Synchronous logic for the accumulator register and flags
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset accumulator and flags to zero
            ACC_out <= 16'b0;
            ALUflags <= 4'b0;
        end else begin
            // Update accumulator and flags in a single cycle
            ACC_out <= ALU_out_wire;
            ALUflags <= ALUflags_wire;
        end
    end

endmodule
