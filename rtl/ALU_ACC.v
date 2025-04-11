//timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/19 19:12:31
// Design Name: 
// Module Name: ALU_ACC
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


module ALU_ACC(
    input clk,
    input rst_n,
    input C8,
    input C9,
    input C13,
    input C15,
    input C16,
    input C17,
    input C18,
    input C19,
    input C20,
    input C21,
    input [15:0] BR_out,
    output [15:0] ALU_out,
    output reg [3:0] ALUflags // {ZF, CF, OF, SF} - Zero Flag, Carry Flag, Overflow Flag, Sign Flag
    );

    reg [15:0] ACC;
    assign ALU_out = ACC;
    
    // Temporary registers for flag calculations
    reg ZF, CF, OF, SF;
    reg [16:0] temp_result; // 17-bit for carry detection
    
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ACC <= 16'b0;
            ALUflags <= 4'b0;
        end
        else begin
            // Default flag values
            ZF = (ACC == 16'b0);
            SF = ACC[15];  // Sign bit
            CF = 1'b0;     // Default carry
            OF = 1'b0;     // Default overflow
            
            if(C8) begin
                ACC <= 16'b0;
                ZF = 1'b1;  // Reset ACC means ZF=1
                SF = 1'b0;  // Reset ACC means SF=0
            end
            else if(C9) begin 
                temp_result = {1'b0, ACC} + {1'b0, BR_out};
                ACC <= temp_result[15:0];
                CF = temp_result[16];  // Carry flag
                OF = (ACC[15] == BR_out[15]) && (ACC[15] != temp_result[15]);  // Overflow detection
                ZF = (temp_result[15:0] == 16'b0);
                SF = temp_result[15];
            end
            else if(C13) begin
                temp_result = {1'b0, ACC} - {1'b0, BR_out};
                ACC <= temp_result[15:0];
                CF = temp_result[16];  // Borrow (inverted carry)
                OF = (ACC[15] != BR_out[15]) && (ACC[15] != temp_result[15]);  // Overflow detection
                ZF = (temp_result[15:0] == 16'b0);
                SF = temp_result[15];
            end
            else if(C15) begin
                ACC <= ACC * BR_out;
                ZF = (ACC * BR_out == 16'b0);
                SF = (ACC * BR_out)[15];
            end
            else if(C16) begin
                if(BR_out != 16'b0) begin  // Avoid division by zero
                    ACC <= ACC / BR_out;
                    ZF = (ACC / BR_out == 16'b0);
                    SF = (ACC / BR_out)[15];
                end
            end
            else if(C17) begin
                ACC <= ACC << BR_out[3:0]; // Shift left logical by BR value
                ZF = (ACC << BR_out[3:0] == 16'b0);
                SF = (ACC << BR_out[3:0])[15];
            end
            else if(C18) begin
                ACC <= ACC >> BR_out[3:0]; // Shift right logical by BR value
                ZF = (ACC >> BR_out[3:0] == 16'b0);
                SF = (ACC >> BR_out[3:0])[15];
            end
            else if(C19) begin
                ACC <= ACC & BR_out;
                ZF = ((ACC & BR_out) == 16'b0);
                SF = (ACC & BR_out)[15];
            end
            else if(C20) begin
                ACC <= ACC | BR_out;
                ZF = ((ACC | BR_out) == 16'b0);
                SF = (ACC | BR_out)[15];
            end
            else if(C21) begin
                ACC <= ~BR_out;  // NOT operation on BR, not ACC
                ZF = (~BR_out == 16'b0);
                SF = (~BR_out)[15];
            end
            
            // Update ALUflags
            ALUflags <= {ZF, CF, OF, SF};
        end
    end
endmodule
