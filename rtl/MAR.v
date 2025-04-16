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
    input [15:0] MBR_in,
    input [7:0] PC_in,
    output [7:0] MAR_out
    );

    reg [7:0] memory_address_register;
    assign MAR_out = memory_address_register;

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            memory_address_register <= 8'b0;
        end
        else begin
            if(C5) begin
                memory_address_register <= MBR_in[7:0];
            end
            else if(C10) begin
                memory_address_register <= PC_in;
            end
            else begin
                memory_address_register <= memory_address_register;
            end
        end
    end
endmodule
