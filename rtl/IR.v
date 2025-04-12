`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/19 13:51:03
// Design Name: 
// Module Name: IR
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


module IR(
    input wire clk,
    input wire rst_n,
    input wire C4,
    input wire [15:0] MBR_in,
    output reg [7:0] IR_out
    );


    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            IR_out <= 8'b0;
        end
        else begin
            if(C4) begin
                IR_out <= MBR_in[15:8];
            end
            else begin
                IR_out <= IR_out;
            end
        end
    end
endmodule
