`timescale 1ns / 1ps
`include "../../rtl/include/instruction_set.vh"
module CPU_Top_tb;
    // CPU interfaces
    reg clk;
    reg rst_n;
    reg [15:0] data_in;
    wire [7:0] address;
    wire [15:0] data_out;
    wire wea;
    
    // Memory simulation
    reg [15:0] memory [0:255];
    
    // Instantiate the CPU
    CPU_top uut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .address(address),
        .data_out(data_out),
        .wea(wea)
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
            
            // Memory write happens only when write enable is active
            if (wea) begin
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
        
        // Run simulation for enough time to execute all instructions
        #20000;
        
        // Display final results
        $display("Test Complete. Memory state:");
        $display("Location 54: %d (Sum result), should be 5050", memory[54]);
        
        $finish;
    end
    
    // Initialize memory with the test program to calculate 1+2+...+100
    task init_memory;
        integer i;
        begin
            // Clear memory
            for (i = 0; i < 256; i = i + 1) begin
                memory[i] = 16'h0000;
            end
            
            // Constants for program
            memory[50] = 16'd0;    // sum
            memory[51] = 16'd1;    // counter
            memory[52] = 16'd1;    // increment/decrement
            memory[53] = 16'd99;  // loop limit
            memory[54] = 16'd101;  // result
            
            // Program to calculate 1+2+...+100
            // Initialize ACC with sum (0)
            memory[0] = {`OPCODE_LOAD, 8'd50};  // LOAD 50 - Load initial sum (0) into ACC
            memory[1] = {`OPCODE_ADD, 8'd51};  // ADD 51 - Add counter value to sum
            memory[2] = {`OPCODE_STORE, 8'd50};  // STORE 50 - Store updated sum
            memory[3] = {`OPCODE_LOAD, 8'd51};  // LOAD 51 - Load counter value
            memory[4] = {`OPCODE_ADD, 8'd52};  // ADD 52 - Add increment/decrement to counter
            memory[5] = {`OPCODE_STORE, 8'd51};  // STORE 51 - Store updated counter
            memory[6] = {`OPCODE_LOAD, 8'd53};  // LOAD 53 - Load loop limit
            memory[7] = {`OPCODE_SUB, 8'd52};  // SUB 52 - Subtract counter from loop limit
            memory[8] = {`OPCODE_STORE, 8'd53};  // STORE 53 - Store result
            memory[9] = {`OPCODE_JMPGEZ, 8'd0};  // JMPGEZ 0 - If counter >= loop limit, jump to beginning
            memory[10] = {`OPCODE_LOAD, 8'd50};  // LOAD 50 - Load sum
            memory[11] = {`OPCODE_STORE, 8'd54};  // STORE 54 - Store result
            memory[12] = {`OPCODE_HALT, 8'd0};  // HALT - End program
        end
    endtask

endmodule