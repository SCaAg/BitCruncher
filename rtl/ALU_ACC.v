`timescale 1ns / 1ps
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
    output reg [3:0] ALUflags
    );

    reg [15:0] ACC;
    assign ALU_out = ACC;

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ACC <= 16'b0;
        end
        else begin
            if(C8) ACC <= 16'b0;
            else if(C9) ACC <= ACC + BR_out;
            else if(C13) ACC <= ACC - BR_out;
            else if(C15) ACC <= ACC * BR_out;
            else if(C16) ACC <= ACC / BR_out;
            else if(C17) ACC <= ACC >> 1;
            else if(C18) ACC <= ACC << 1;
            else if(C19) ACC <= ACC & BR_out;
            else if(C20) ACC <= ACC | BR_out;
            else if(C21) ACC <= ~ACC;
            else ACC <= ACC;
        end
    end
endmodule
