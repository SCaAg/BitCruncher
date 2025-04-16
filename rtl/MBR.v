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
    input  wire clk,
    input  wire rst_n,
    input  wire C3,          // MBR <- memory (Load from memory)
    input  wire C11,         // memory <- MBR (Store to memory)
    input  wire C12,         // MBR <- ACC (Copy ACC to MBR)
    input  wire [15:0] memory_in,
    output reg [15:0] memory_out,
    input  wire [15:0] ACC_in,
    output wire [15:0] MBR_out
    
    );

    reg [15:0] memory_buffer;
    assign MBR_out = memory_buffer;

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            memory_buffer <= 16'b0;
            memory_out <= 16'b0;
        end
        else begin
            if(C3) begin
                memory_buffer <= memory_in;
            end
            else if(C11) begin
                memory_out <= memory_buffer;
            end
            else if(C12) begin
                memory_buffer <= ACC_in;
            end
            else begin
                memory_buffer <= memory_buffer;
                memory_out <= memory_out;
            end
            
        end
    end
endmodule
