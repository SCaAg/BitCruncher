`timescale 1ns / 1ps

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
            
            // Memory write happens only when C11 is active
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
        #6000;
        
        // Display final results
        $display("Test Complete. Memory state:");
        $display("Location 100: %d (LOAD result),should be 1", memory[100]);
        $display("Location 101: %d (ADD result),should be 3", memory[101]);
        $display("Location 102: %d (SUB result),should be 2", memory[102]);
        $display("Location 103: %d (MPY result),should be 6", memory[103]);
        $display("Location 104: %d (AND result),should be 0", memory[104]);
        $display("Location 105: %d (OR result),should be 3", memory[105]);
        $display("Location 106: %h (NOT result),should be FFFE", memory[106]);
        $display("Location 107: %d (SHIFTR result),should be 4", memory[107]);
        $display("Location 108: %d (SHIFTL result),should be 16", memory[108]);
        $display("Location 109: %d (JMPGEZ result),should be 0", memory[109]);
        $display("Location 110: %d (after JMPGEZ result),should be 8", memory[110]);
        $display("Location 111: %d (after no JMPGEZ result),should be 8", memory[111]);
        $display("Location 112: %h (after JMP result),should be F4", memory[112]);
        
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
            
            // Constants for testing
            memory[50] = 16'd1;    // Test value 1 (10101010)
            memory[51] = 16'd2;    // Test value 2 (01010101)
            memory[52] = 16'd3;    // Small value for multiply
            memory[53] = 16'hF4;    // Negative value for JMPGEZ test
            memory[54] = 16'd8;    // Value
            memory[55] = 16'hFFF0;   // Value
            
            // Test program - execute each instruction
            // Test 1: Start with LOAD instruction and store to 100
            memory[0] = {8'b00000010, 8'd50};   // LOAD 50 - Load test value 1 into ACC
            memory[1] = {8'b00000001, 8'd100};  // STORE 100 - Store ACC to verify LOAD worked
            
            // Test 2: Test ADD instruction
            memory[2] = {8'b00000011, 8'd51};   // ADD 51 - Add test value 2
            memory[3] = {8'b00000001, 8'd101};  // STORE 101 - Store result of ADD
            
            // Test 3: Test SUB instruction
            memory[4] = {8'b00000100, 8'd50};   // SUB 50
            memory[5] = {8'b00000001, 8'd102};  // STORE 102 - Store result of SUB
            
            // Test 4: Test MPY instruction
            memory[6] = {8'b00000010, 8'd51};   // LOAD 51 - Load test value 1
            memory[7] = {8'b00001000, 8'd52};   // MPY 52 - Multiply by small value
            memory[8] = {8'b00000001, 8'd103};  // STORE 103 - Store result of MPY
            
            // Test 5: Test AND instruction
            memory[9] = {8'b00000010, 8'd50};   // LOAD 50 - Load test value 1
            memory[10] = {8'b00001010, 8'd51};   // AND 51 - AND with test value 2
            memory[11] = {8'b00000001, 8'd104};  // STORE 104 - Store result of AND
            
            // Test 6: Test OR instruction
            memory[12] = {8'b00000010, 8'd50};   // LOAD 50 - Load test value 1
            memory[13] = {8'b00001011, 8'd51};   // OR 51 - OR with test value 2
            memory[14] = {8'b00000001, 8'd105};  // STORE 105 - Store result of OR
            
            // Test 7: Test NOT instruction
            memory[15] = {8'b00001100, 8'd50};   // NOT 50 - NOT of test value 1
            memory[16] = {8'b00000001, 8'd106};  // STORE 106 - Store result of NOT
            
            // Test 8: Test SHIFTR instruction
            memory[17] = {8'b00000010, 8'd54};   // LOAD 54 - Load test value 8
            memory[18] = {8'b00001101, 8'd1};    // SHIFTR - Shift right 1 bit
            memory[19] = {8'b00000001, 8'd107};  // STORE 107 - Store result of SHIFTR
            
            // Test 9: Test SHIFTL instruction
            memory[20] = {8'b00000010, 8'd54};   // LOAD 54 - Load test value 1
            memory[21] = {8'b00001110, 8'd1};    // SHIFTL - Shift left 1 bit
            memory[22] = {8'b00000001, 8'd108};  // STORE 108 - Store result of SHIFTL
            
            // Test 10: Test JMPGEZ instruction (with positive ACC)
            memory[23] = {8'b00000010, 8'd52};   // LOAD 52 - Load positive value
            memory[24] = {8'b00000100, 8'd50};  // SUB 50- ACC - 1
            memory[25] = {8'b00000101, 8'd24};   // JMPGEZ 24 - Should jump to 24
            memory[26] = {8'b00000001, 8'd109};  // STORE 109 - Should be skipped
            
            // Test 11: Continue after JMPGEZ test
            memory[26] = {8'b00000010, 8'd54};   // LOAD 54 - Load value 1
            memory[27] = {8'b00000001, 8'd110};  // STORE 110 - Store to indicate JMPGEZ worked
            
            // Test 12: Test JMPGEZ instruction (with negative ACC)
            memory[28] = {8'b00000010, 8'd55};   // LOAD 55 - Load negative value
            memory[29] = {8'b00000101, 8'd40};   // JMPGEZ 40 - Should NOT jump
            memory[30] = {8'b00000010, 8'd54};   // LOAD 54 - Load value 1 (should execute)
            memory[31] = {8'b00000001, 8'd111};  // STORE 111 - Store to indicate test worked
            
            // Test 13: Test JMP instruction
            memory[32] = {8'b00000110, 8'd40};   // JMP 40 - Jump to address 40
            memory[33] = {8'b00000010, 8'd53};   // LOAD 53 - Should be skipped
            
            // Test 14: Final halt
            memory[34] = {8'b00000111, 8'd0};    // HALT - End program
            memory[35] = {8'b00000111, 8'd0};   //  HALT - End program, prevent from executing again
            
            // Extra test area (if needed)
            memory[40] = {8'b00000010, 8'd53};   // LOAD 53 - This shouldn't execute if JMPGEZ works
            memory[41] = {8'b00000001, 8'd112};  // STORE 112 - This shouldn't execute if JMPGEZ works
            memory[42] = {8'b00000111, 8'd0};    // HALT
        end
    endtask

endmodule
