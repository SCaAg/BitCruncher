`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/19 19:12:31
// Design Name: 
// Module Name: ALU_ACC
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


module ALU_ACC(
    input         clk,
    input         rst_n,
    input         C8,    // 清零：ACC<=0
    input         C9,    // 加法：ACC<=ACC+BR_out
    input         C13,   // 减法：ACC<=ACC-BR_out
    input         C15,   // 乘法
    input         C16,   // 除法
    input         C17,   // 右移
    input         C18,   // 左移
    input         C19,   // 按位与
    input         C20,   // 按位或
    input         C21,   // 按位取反
    input  [15:0] BR_out,
    output [15:0] ALU_out,
    output reg [3:0] ALUflags // {ZF, CF, OF, SF}，高电平有效
    );

    reg [15:0] ACC;
    assign ALU_out = ACC;
    reg signed [15:0] sACC, sBR;
    reg signed [31:0] prod;
    // 用于加/减时的中间变量
    reg [16:0] tmp;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ACC      <= 16'b0;
            ALUflags <= 4'b0;
        end
        else begin
            if (C8) begin
                ACC      <= 16'b0;
                // 结果为0：ZF=1，其余均为0
                ALUflags <= {1'b1, 3'b0};
            end
            else if (C9) begin
                // 加法：扩展一位计算进位
                tmp = {1'b0, ACC} + {1'b0, BR_out};
                ACC <= tmp[15:0];
                // ZF：结果是否为0
                ALUflags[3] <= (tmp[15:0] == 16'b0) ? 1'b1 : 1'b0;
                // CF：进位标志（tmp最高位）
                ALUflags[2] <= tmp[16];
                // OF：若两个操作数符号相同，而结果符号与操作数不同，则溢出
                ALUflags[1] <= ((ACC[15] == BR_out[15]) && (tmp[15] != ACC[15])) ? 1'b1 : 1'b0;
                // SF：结果最高位
                ALUflags[0] <= tmp[15];
            end
            else if (C13) begin
                // 减法
                tmp = {1'b0, ACC} - {1'b0, BR_out};
                ACC <= tmp[15:0];
                ALUflags[3] <= (tmp[15:0] == 16'b0) ? 1'b1 : 1'b0;
                // 对于减法，通常将借位当作CF：当ACC<BR_out时置1
                ALUflags[2] <= (ACC < BR_out) ? 1'b1 : 1'b0;
                // OF：若两个操作数符号不同，且结果符号与被减数不同，则溢出
                ALUflags[1] <= ((ACC[15] != BR_out[15]) && (tmp[15] != ACC[15])) ? 1'b1 : 1'b0;
                ALUflags[0] <= tmp[15];
            end
            else if (C15) begin
                // 使用有符号数进行乘法运算
                sACC = ACC;
                sBR  = BR_out;
                prod = sACC * sBR;  // 32位乘积
                // 更新ACC取低16位
                ACC = prod[15:0];
                // ZF：结果是否为0
                ALUflags[3] <= (prod[15:0] == 16'b0) ? 1'b1 : 1'b0;
                // CF暂时不用：置0
                ALUflags[2] <= 1'b0;
                // OF：检测乘法溢出，若高16位不为符号扩展，则溢出
                ALUflags[1] <= (prod[31:16] != {16{prod[15]}}) ? 1'b1 : 1'b0;
                // SF：取结果的最高位
                ALUflags[0] <= prod[15];
            end
            else if (C16) begin
                // 除法：注意除0问题未处理
                ACC = ACC / BR_out;
                ALUflags[3] <= (ACC == 16'b0) ? 1'b1 : 1'b0;
                ALUflags[2] <= 1'b0;
                ALUflags[1] <= 1'b0;
                ALUflags[0] <= ACC[15];
            end
            else if (C17) begin
                ACC = ACC >> 1;
                ALUflags[3] <= (ACC == 16'b0) ? 1'b1 : 1'b0;
                ALUflags[2] <= 1'b0;
                ALUflags[1] <= 1'b0;
                ALUflags[0] <= ACC[15];
            end
            else if (C18) begin
                ACC = ACC << 1;
                ALUflags[3] <= (ACC == 16'b0) ? 1'b1 : 1'b0;
                ALUflags[2] <= 1'b0;
                ALUflags[1] <= 1'b0;
                ALUflags[0] <= ACC[15];
            end
            else if (C19) begin
                ACC = ACC & BR_out;
                ALUflags[3] <= (ACC == 16'b0) ? 1'b1 : 1'b0;
                ALUflags[2] <= 1'b0;
                ALUflags[1] <= 1'b0;
                ALUflags[0] <= ACC[15];
            end
            else if (C20) begin
                ACC = ACC | BR_out;
                ALUflags[3] <= (ACC == 16'b0) ? 1'b1 : 1'b0;
                ALUflags[2] <= 1'b0;
                ALUflags[1] <= 1'b0;
                ALUflags[0] <= ACC[15];
            end
            else if (C21) begin
                ACC = ~ACC;
                ALUflags[3] <= (ACC == 16'b0) ? 1'b1 : 1'b0;
                ALUflags[2] <= 1'b0;
                ALUflags[1] <= 1'b0;
                ALUflags[0] <= ACC[15];
            end
            else begin
                ACC <= ACC;
                ALUflags <= ALUflags;
            end
        end
    end
endmodule
