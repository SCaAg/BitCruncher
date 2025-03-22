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
    input clk,
    input rst_n,
    input C4,
    input [15:0] MBR_out,
    output [7:0] IR_out
    );

    reg [7:0] IRr;
    assign IR_out = IRr;

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            IRr <= 8'b0;
        end
        else begin
            if(C4) begin
                IRr <= MBR_out[15:8];
            end
            else begin
                IRr <= IRr;
            end
        end
    end
endmodule
