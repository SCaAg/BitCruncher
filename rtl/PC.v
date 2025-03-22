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
    input clk,
    input rst_n,
    input C6,
    input C14,
    input [15:0] MBR_out,
    output [7:0] PC_out
    );

    reg [7:0] PCr;
    assign PC_out = PCr;

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            PCr <= 8'b0;
        end
        else begin
            if(C14) begin
                PCr <= MBR_out[15:8]; //取操作码
            end
            else if(C6) begin
                PCr <= PCr + 1'b1; //自增
            end
            else begin
                PCr <= PCr;
            end
        end
    end
endmodule
