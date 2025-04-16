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
    output wire [7:0] IR_out
    );
    reg [7:0] instruction_register;
    assign IR_out = instruction_register;

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            instruction_register <= 8'b0;
        end
        else begin
            if(C4) begin
                instruction_register <= MBR_in[15:8];
            end
            else begin
                instruction_register <= instruction_register;
            end
        end
    end
endmodule
