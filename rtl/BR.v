`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/19 13:51:03
// Design Name: 
// Module Name: BR
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


    module BR(
    input clk,
    input rst_n,
    input C7,
    input [15:0] MBR_out,
    output [15:0] BR_out
    );

    reg [15:0] BRr;
    assign BR_out = BRr;

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            BRr <= 16'b0;
        end
        else begin
            if(C7) begin
                BRr <= MBR_out; //取操作数
            end
            else begin
                BRr <= BRr;
            end
        end
    end
endmodule
