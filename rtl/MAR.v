`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/19 13:51:03
// Design Name: 
// Module Name: MAR
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


module MAR(
    input clk,
    input rst_n,
    input C5,
    input C10,
    input [15:0] MBR_out,
    input [7:0] PC_out,
    output [7:0] MAR_out_memory
    );

    reg [7:0] MARr;
    assign MAR_out_memory = MARr;

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            MARr <= 8'b0;
        end
        else begin
            if(C5) begin
                MARr <= MBR_out[7:0];
            end
            else if(C10) begin
                MARr <= PC_out;
            end
            else begin
                MARr <= MARr;
            end
        end
    end
endmodule
