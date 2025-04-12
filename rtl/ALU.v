`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/19 19:12:31 (Modified for Combinational Logic)
// Design Name: 
// Module Name: ALU_COMB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Combinational ALU based on the previous ALU_ACC design.
//              Performs operations based on control signals C*.
//              Outputs the result and status flags combinationally.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created (Sequential)
// Revision 1.00 - Converted to Combinational Logic
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ALU(
    // Control Inputs
    input C8,   // Clear ACC (ALU_out = 0)
    input C9,   // ADD: ACC + BR
    input C13,  // SUB: ACC - BR
    input C15,  // MUL: ACC * BR (lower 16 bits)
    input C16,  // DIV: ACC / BR
    input C17,  // SHL: ACC << BR[3:0]
    input C18,  // SHR: ACC >> BR[3:0] (Logical)
    input C19,  // AND: ACC & BR
    input C20,  // OR:  ACC | BR
    input C21,  // NOT: ~BR (result is NOT of BR, ACC_in ignored)

    // Data Inputs
    input [15:0] ACC_in, // Input representing the value that would be in the Accumulator
    input [15:0] BR_in, // Input from Bus Register

    // Data Outputs
    output reg [15:0] ALU_out,  // Result of the ALU operation
    output reg [3:0] ALUflags  // {ZF, CF, OF, SF} - Zero, Carry, Overflow, Sign
);

    // Internal variables for calculation
    reg ZF, CF, OF, SF;
    reg [16:0] temp_result_ext; // Intermediate result for ADD/SUB carry/borrow
    reg [15:0] result_val;      // Intermediate result for other operations

    // Combinational logic block
    always @(*) begin
        // Default values (important to avoid latches)
        // If no C* signal is active, pass ACC_in through? Or output 0?
        // Let's default to passing ACC_in through, calculating flags based on it.
        result_val = ACC_in; 
        ZF = (ACC_in == 16'b0);
        SF = ACC_in[15];
        CF = 1'b0;
        OF = 1'b0;

        // Operation selection based on control signals
        if (C8) begin // CLEAR
            result_val = 16'b0;
            ZF = 1'b1;
            SF = 1'b0;
            CF = 1'b0;
            OF = 1'b0;
        end
        else if (C9) begin // ADD: ACC_in + BR_in
            temp_result_ext = {1'b0, ACC_in} + {1'b0, BR_in};
            result_val = temp_result_ext[15:0];
            // Flags for ADD
            ZF = (result_val == 16'b0);
            SF = result_val[15];
            CF = temp_result_ext[16]; // Carry out
            // Overflow: occurs if sign of operands is the same, but sign of result is different
            OF = (ACC_in[15] == BR_in[15]) && (result_val[15] != ACC_in[15]);

        end
        else if (C13) begin // SUB: ACC_in - BR_in
            temp_result_ext = {1'b0, ACC_in} - {1'b0, BR_in};
            result_val = temp_result_ext[15:0];
            // Flags for SUB
            ZF = (result_val == 16'b0);
            SF = result_val[15];
            // Borrow is the carry-out of (A + ~B + 1). Here temp_result_ext[16] is borrow.
            // Standard CF for SUB is often defined as NOT(borrow). Let's keep it as borrow for consistency with original.
            CF = temp_result_ext[16]; // Borrow out
            // Overflow: occurs if sign of operands is different, but sign of result is different from minuend (ACC_in)
            OF = (ACC_in[15] != BR_in[15]) && (result_val[15] != ACC_in[15]);
        end
        else if (C15) begin // MUL: ACC_in * BR_in (lower 16 bits)
            // Note: Synthesis tool handles multiplication. Result width can be larger.
            // We only take lower 8 bits as implied by original sequential design.
            result_val = ACC_in[7:0] * BR_in[7:0]; 
            // Flags for MUL (simplified: only ZF, SF based on 16-bit result)
            ZF = (result_val == 16'b0);
            SF = result_val[15];
            CF = 1'b0; // Typically undefined or indicates upper bits non-zero
            OF = 1'b0; // Typically undefined or indicates upper bits non-zero
        end
        else if (C16) begin // DIV: ACC_in / BR_in
            if (BR_in != 16'b0) begin // Avoid division by zero
                result_val = ACC_in / BR_in; // Integer division
            end else begin
                result_val = 16'hFFFF; // Or 0, or ACC_in? Indicate error? Let's output FFFF.
                                      // Original didn't update ACC, here we must output *something*.
            end
             // Flags for DIV (simplified: only ZF, SF based on result)
            ZF = (result_val == 16'b0) && (BR_in != 16'b0); // ZF only if division valid and result is 0
            SF = result_val[15] && (BR_in != 16'b0);        // SF only if division valid
            CF = (BR_in == 16'b0); // Use CF to indicate division by zero? Or keep 0? Let's use it.
            OF = 1'b0; // Typically undefined
        end
        else if (C17) begin // SHL: ACC_in << BR_in[3:0] (Logical Shift Left)
            result_val = ACC_in << BR_in[3:0];
            // Flags for SHL (simplified: only ZF, SF)
            // CF could be the last bit shifted out, OF could indicate change in sign bit if not intended
            ZF = (result_val == 16'b0);
            SF = result_val[15];
            case (BR_in[3:0])
                4'd0:  CF = 1'b0;           // 不移位，CF 不定义/保持0
                4'd1:  CF = ACC_in[15];
                4'd2:  CF = ACC_in[14];
                4'd3:  CF = ACC_in[13];
                4'd4:  CF = ACC_in[12];
                4'd5:  CF = ACC_in[11];
                4'd6:  CF = ACC_in[10];
                4'd7:  CF = ACC_in[9];
                4'd8:  CF = ACC_in[8];
                4'd9:  CF = ACC_in[7];
                4'd10: CF = ACC_in[6];
                4'd11: CF = ACC_in[5];
                4'd12: CF = ACC_in[4];
                4'd13: CF = ACC_in[3];
                4'd14: CF = ACC_in[2];
                4'd15: CF = ACC_in[1];
                default: CF = 1'b0; // 超出范围默认0
            endcase

            OF = 1'b0; // Often unused for logical shifts
        end
        else if (C18) begin // SHR: ACC_in >> BR_in[3:0] (Logical Shift Right)
            result_val = ACC_in >> BR_in[3:0];
            // Flags for SHR (simplified: only ZF, SF)
            // CF could be the last bit shifted out
            ZF = (result_val == 16'b0);
            SF = result_val[15]; // Will always be 0 for logical right shift unless shift amount is 0
            case (BR_in[3:0])
                4'd0:  CF = 1'b0; // 没移，CF未定义或为0
                4'd1:  CF = ACC_in[0];
                4'd2:  CF = ACC_in[1];
                4'd3:  CF = ACC_in[2];
                4'd4:  CF = ACC_in[3];
                4'd5:  CF = ACC_in[4];
                4'd6:  CF = ACC_in[5];
                4'd7:  CF = ACC_in[6];
                4'd8:  CF = ACC_in[7];
                4'd9:  CF = ACC_in[8];
                4'd10: CF = ACC_in[9];
                4'd11: CF = ACC_in[10];
                4'd12: CF = ACC_in[11];
                4'd13: CF = ACC_in[12];
                4'd14: CF = ACC_in[13];
                4'd15: CF = ACC_in[14];
                default: CF = 1'b0;
            endcase

            OF = (BR_in[3:0] == 1) ? (result_val[15] ^ CF) : 1'b0;

        end
        else if (C19) begin // AND: ACC_in & BR_in
            result_val = ACC_in & BR_in;
            // Flags for AND (ZF, SF based on result, CF=0, OF=0)
            ZF = (result_val == 16'b0);
            SF = result_val[15];
            CF = 1'b0;
            OF = 1'b0;
        end
        else if (C20) begin // OR: ACC_in | BR_in
            result_val = ACC_in | BR_in;
            // Flags for OR (ZF, SF based on result, CF=0, OF=0)
            ZF = (result_val == 16'b0);
            SF = result_val[15];
            CF = 1'b0;
            OF = 1'b0;
        end
        else if (C21) begin // NOT: ~ACC_in (BR_in is ignored)
            result_val = ~ACC_in;
            // Flags for NOT (ZF, SF based on result, CF=0, OF=0)
            ZF = (result_val == 16'b0);
            SF = result_val[15];
            CF = 1'b0;
            OF = 1'b0;
        end
        // If none of the C* flags are active, the default values assigned 
        // at the beginning of the always block will be used (pass-through ACC_in).

        // Assign calculated values to outputs
        ALU_out = result_val;
        ALUflags = {ZF, CF, OF, SF};

    end // always @ (*)

endmodule