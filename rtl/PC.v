`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/19 13:51:03
// Design Name: 
// Module Name: PC
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


module PC(
    input wire clk,
    input wire rst_n,
    input wire C6,          // PC <- PC+1 (Increment PC)
    input wire C14,         // PC <- MBR[7:0] (Jump)
    input wire [15:0] IR_in,
    output reg [7:0] PC_out
    );



    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            PC_out <= 8'b0;
        end
        else begin
            if(C14) begin
                // Jump instruction - load address from MBR lower 8 bits
                PC_out <= IR_in[7:0]; 
            end
            else if(C6) begin
                // Increment PC
                PC_out <= PC_out + 1'b1;
            end
            // If neither C14 nor C6 is active, PC remains unchanged
            else begin
                PC_out <= PC_out;
            end
        end
    end
endmodule
