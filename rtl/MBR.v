`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/19 13:51:03
// Design Name: 
// Module Name: MBR
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


module MBR(
    input clk,
    input rst_n,
    input C3,
    input C11,
    input C12,
    input [15:0] ALU_out,
    input [15:0] MBR_in_memory,
    output [15:0] MBR_out,
    output reg [15:0] MBR_out_memory
    );

    reg [15:0] MBRr;
    assign MBR_out = MBRr;

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            MBRr <= 16'b0;
        end
        else begin
            if(C3) begin
                MBRr <= MBR_in_memory;
            end
            else if(C12) begin
                MBRr <= ALU_out;
            end
            else begin
                MBRr <= MBRr;
            end
            if(C11) begin
                MBR_out_memory <= MBRr;
            end
        end
    end
endmodule
