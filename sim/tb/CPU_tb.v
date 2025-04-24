`timescale 1ns / 1ps

module CPU_tb;
    // CPU interfaces
    reg clk;
    reg rst_n;
    reg [15:0] data_in;
    wire [7:0] address;
    wire [15:0] data_out;
    wire wea;
    
    // Test interface signals
    reg [7:0] cpu_test_addr;
    reg [15:0] cpu_test_out;
    reg cpu_test_wr;
    wire [15:0] cpu_test_in;
    
    // Memory simulation
    reg [15:0] memory [0:255];
    
    // Set BRAM base address
    localparam BRAM_BASE_ADDR = 32'hC000_0000;
    
    // Instantiate the CPU
    CPU_top uut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .address(address),
        .data_out(data_out),
        .wea(wea)
    );
    
    // Clock generation: 100MHz clock, period 10ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Memory simulation
    always @(posedge clk) begin
        // Only process valid memory addresses
        if (address !== 8'bxxxxxxxx) begin
            // Memory read always happens
            data_in <= memory[address];
            
            // Memory write happens only when wea is active
            if (wea) begin
                memory[address] <= data_out;
                $display("CPU write to memory at address %d: %h", address, data_out);
            end
        end
    end
    
    // Test interface memory access
    always @(posedge clk) begin
        // Test write to memory
        if (cpu_test_wr) begin
            memory[cpu_test_addr] <= cpu_test_out;
            $display("Test interface write to memory at address %d: %h", cpu_test_addr, cpu_test_out);
        end
    end
    
    // Test interface read
    assign cpu_test_in = memory[cpu_test_addr];
    
    // Main test sequence
    initial begin
        // Initialize signals
        rst_n = 0;
        cpu_test_addr = 8'h00;
        cpu_test_out = 16'h0000;
        cpu_test_wr = 0;
        
        // Clear memory
        init_memory();
        
        // Release reset after some time
        #20;
        rst_n = 1;
        
        // Load test program
        load_test_program();
        
        // Run simulation for enough time to execute all instructions
        #6000;
        
        // Display final results
        $display("Test Complete. Memory state:");
        show_result(100, 1, "LOAD result");
        show_result(101, 3, "ADD result");
        show_result(102, 2, "SUB result");
        show_result(103, 6, "MPY result");
        show_result(104, 0, "AND result");
        show_result(105, 3, "OR result");
        show_result(106, 16'hFFFE, "NOT result");
        show_result(107, 4, "SHIFTR result");
        show_result(108, 16, "SHIFTL result");
        show_result(109, 0, "JMPGEZ result");
        show_result(110, 8, "after JMPGEZ result");
        show_result(111, 8, "after no JMPGEZ result");
        show_result(112, 16'hF4, "after JMP result");
        
        $finish;
    end
    
    // Task to read a memory location and display result
    task show_result;
        input [7:0] addr;
        input [15:0] expected;
        input [8*32-1:0] description;
        begin
            $display("Location %d: %h (%s), should be %h", 
                     addr, memory[addr], description, expected);
        end
    endtask
    
    // Initialize memory with zeros
    task init_memory;
        integer i;
        begin
            // Clear memory
            for (i = 0; i < 256; i = i + 1) begin
                memory[i] = 16'h0000;
            end
        end
    endtask
    
    // Task to perform a memory write through the test interface
    task memory_write;
        input [7:0] addr;
        input [15:0] data;
        begin
            cpu_test_addr = addr;
            cpu_test_out = data;
            cpu_test_wr = 1;
            #10;
            cpu_test_wr = 0;
            #10;
        end
    endtask
    
    // Load the test program into memory
    task load_test_program;
        begin
            // Constants for testing
            memory_write(50, 16'd1);     // Test value 1
            memory_write(51, 16'd2);     // Test value 2
            memory_write(52, 16'd3);     // Small value for multiply
            memory_write(53, 16'hF4);    // Negative value for JMPGEZ test
            memory_write(54, 16'd8);     // Value
            memory_write(55, 16'hFFF0);  // Value
            
            // Test program - execute each instruction
            // Test 1: Start with LOAD instruction and store to 100
            memory_write(0, {8'b00000010, 8'd50});   // LOAD 50 - Load test value 1 into ACC
            memory_write(1, {8'b00000001, 8'd100});  // STORE 100 - Store ACC to verify LOAD worked
            
            // Test 2: Test ADD instruction
            memory_write(2, {8'b00000011, 8'd51});   // ADD 51 - Add test value 2
            memory_write(3, {8'b00000001, 8'd101});  // STORE 101 - Store result of ADD
            
            // Test 3: Test SUB instruction
            memory_write(4, {8'b00000100, 8'd50});   // SUB 50
            memory_write(5, {8'b00000001, 8'd102});  // STORE 102 - Store result of SUB
            
            // Test 4: Test MPY instruction
            memory_write(6, {8'b00000010, 8'd51});   // LOAD 51 - Load test value 1
            memory_write(7, {8'b00001000, 8'd52});   // MPY 52 - Multiply by small value
            memory_write(8, {8'b00000001, 8'd103});  // STORE 103 - Store result of MPY
            
            // Test 5: Test AND instruction
            memory_write(9, {8'b00000010, 8'd50});   // LOAD 50 - Load test value 1
            memory_write(10, {8'b00001010, 8'd51});  // AND 51 - AND with test value 2
            memory_write(11, {8'b00000001, 8'd104}); // STORE 104 - Store result of AND
            
            // Test 6: Test OR instruction
            memory_write(12, {8'b00000010, 8'd50});  // LOAD 50 - Load test value 1
            memory_write(13, {8'b00001011, 8'd51});  // OR 51 - OR with test value 2
            memory_write(14, {8'b00000001, 8'd105}); // STORE 105 - Store result of OR
            
            // Test 7: Test NOT instruction
            memory_write(15, {8'b00001100, 8'd50});  // NOT 50 - NOT of test value 1
            memory_write(16, {8'b00000001, 8'd106}); // STORE 106 - Store result of NOT
            
            // Test 8: Test SHIFTR instruction
            memory_write(17, {8'b00000010, 8'd54});  // LOAD 54 - Load test value 8
            memory_write(18, {8'b00001101, 8'd1});   // SHIFTR - Shift right 1 bit
            memory_write(19, {8'b00000001, 8'd107}); // STORE 107 - Store result of SHIFTR
            
            // Test 9: Test SHIFTL instruction
            memory_write(20, {8'b00000010, 8'd54});  // LOAD 54 - Load test value 1
            memory_write(21, {8'b00001110, 8'd1});   // SHIFTL - Shift left 1 bit
            memory_write(22, {8'b00000001, 8'd108}); // STORE 108 - Store result of SHIFTL
            
            // Test 10: Test JMPGEZ instruction (with positive ACC)
            memory_write(23, {8'b00000010, 8'd52});  // LOAD 52 - Load positive value
            memory_write(24, {8'b00000100, 8'd50});  // SUB 50- ACC - 1
            memory_write(25, {8'b00000101, 8'd24});  // JMPGEZ 24 - Should jump to 24
            memory_write(26, {8'b00000001, 8'd109}); // STORE 109 - Should be skipped
            
            // Test 11: Continue after JMPGEZ test
            memory_write(26, {8'b00000010, 8'd54});  // LOAD 54 - Load value 1
            memory_write(27, {8'b00000001, 8'd110}); // STORE 110 - Store to indicate JMPGEZ worked
            
            // Test 12: Test JMPGEZ instruction (with negative ACC)
            memory_write(28, {8'b00000010, 8'd55});  // LOAD 55 - Load negative value
            memory_write(29, {8'b00000101, 8'd40});  // JMPGEZ 40 - Should NOT jump
            memory_write(30, {8'b00000010, 8'd54});  // LOAD 54 - Load value 1 (should execute)
            memory_write(31, {8'b00000001, 8'd111}); // STORE 111 - Store to indicate test worked
            
            // Test 13: Test JMP instruction
            memory_write(32, {8'b00000110, 8'd40});  // JMP 40 - Jump to address 40
            memory_write(33, {8'b00000010, 8'd53});  // LOAD 53 - Should be skipped
            
            // Test 14: Final halt
            memory_write(34, {8'b00000111, 8'd0});   // HALT - End program
            memory_write(35, {8'b00000111, 8'd0});   // HALT - End program, prevent from executing again
            
            // Extra test area (if needed)
            memory_write(40, {8'b00000010, 8'd53});  // LOAD 53 - Load F4
            memory_write(41, {8'b00000001, 8'd112}); // STORE 112 - Store F4
            memory_write(42, {8'b00000111, 8'd0});   // HALT
        end
    endtask

endmodule
