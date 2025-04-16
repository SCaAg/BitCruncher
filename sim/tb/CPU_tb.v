`timescale 1ns / 1ps

module CPU_tb;
    // CPU interfaces
    reg clk;
    reg rst_n;
    reg [15:0] data_in;
    wire [7:0] address;
    wire [15:0] data_out;
    
    // Memory simulation
    reg [15:0] memory [0:255];
    
    // Program to calculate:
    // ((2+4+6+...+20) × (-12) SHL 1bit) AND (1+2+...+40)
    
    // Instantiate the CPU
    CPU_top uut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .address(address),
        .data_out(data_out)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Memory simulation
    always @(posedge clk) begin
        // Only process valid memory addresses
        if (address !== 8'bxxxxxxxx && address < 8'd255) begin
            // Memory read always happens
            data_in <= memory[address];
            
            // Memory write happens only when C11 is active
            if (uut.Control_Signals[11]) begin
                memory[address] <= data_out;
                // For debugging
                $display("Memory write at address %d: %h", address, data_out);
            end
        end
    end
    
    // Main test sequence
    initial begin
        // Initialize memory with test program
        init_memory();
        
        // Reset CPU
        rst_n = 0;
        #20;
        rst_n = 1;
        

        
        // End simulation
        #1000;
        $finish;
    end
    
    // Initialize memory with the test program
    task init_memory;
        integer i;
        begin
            // Clear memory
            for (i = 0; i < 256; i = i + 1) begin
                memory[i] = 16'h0000;
            end
            
            // Program based on instruction set in include/instruction_set.vh
            // LOAD = 8'b00000010, STORE = 8'b00000001, ADD = 8'b00000011, 
            // SUB = 8'b00000100, JMPGEZ = 8'b00000101, HALT = 8'b00000111,
            // MPY = 8'b00001000, SHIFTL = 8'b00001110, AND = 8'b00001010
            
            // Address 0: Initialize counter for 2,4,6,...,20 (start with 2)
            memory[0] = {8'b00000010, 8'd50};   // LOAD 50 - Load 2 into ACC
            memory[1] = {8'b00000001, 8'd60};   // STORE 60 - Store current even number
            memory[2] = {8'b00000001, 8'd61};   // ADD 51 - Add 2 to ACC
            memory[3] = {8'b00000100, 8'd52};   // SUB 52 - Subtract 2 from ACC
            memory[6] = {8'b00000111, 8'd55};   // HALT 55 - Halt
            
            // Address 41: Halt
            memory[41] = {8'h07, 8'd0};   // HALT
            
            // Data section (constants)
            memory[50] = 16'hFF;    // Initial even number
            memory[51] = 16'd0;    // Initial sum (0)
            memory[52] = 16'd1;    // Constant 1
            memory[53] = 16'd2;    // Constant 2
            memory[54] = 16'd22;   // Limit for even numbers
            memory[55] = 16'd41;   // Limit for all numbers
            memory[56] = 16'hFFF4; // -12 in two's complement
            
            // Results will be stored in memory locations 60-71
        end
    endtask
   

endmodule