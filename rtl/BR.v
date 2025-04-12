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
input wire clk,
input wire rst_n,
input wire C7,
input wire [15:0] MBR_in,
output reg [15:0] BR_out
);

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            BR_out <= 16'b0;
        end
        else begin
            if(C7) begin
                BR_out <= MBR_in; //取操作数
            end
            else begin
                BR_out <= BR_out;
            end
        end
    end
endmodule
