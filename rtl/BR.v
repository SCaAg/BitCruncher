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
output wire [15:0] BR_out
);
    reg [15:0] buffer_register;
    assign BR_out = buffer_register;
    
    
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            buffer_register <= 16'b0;
        end
        else begin
            if(C7) begin
                buffer_register <= MBR_in; //取操作数
            end
            else begin
                buffer_register <= buffer_register;
            end
        end
    end
endmodule
