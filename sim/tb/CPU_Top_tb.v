`timescale 1ns / 1ps

module CPU_Top_tb;
    // CPU interfaces
    reg clk;
    reg rst_n;
    reg [15:0] data_in;
    wire [7:0] address;
    wire [15:0] data_out;
    
    // Memory simulation
    reg [15:0] memory [0:255];
    
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
        
        // Run simulation for enough time to execute all instructions
        #5000;
        
        // Display final results
        $display("Test Complete. Memory state:");
        $display("Location 100: %h (LOAD result)", memory[100]);
        $display("Location 101: %h (STORE result)", memory[101]);
        $display("Location 102: %h (ADD result)", memory[102]);
        $display("Location 103: %h (SUB result)", memory[103]);
        $display("Location 104: %h (MPY result)", memory[104]);
        $display("Location 105: %h (AND result)", memory[105]);
        $display("Location 106: %h (OR result)", memory[106]);
        $display("Location 107: %h (NOT result)", memory[107]);
        $display("Location 108: %h (SHIFTR result)", memory[108]);
        $display("Location 109: %h (SHIFTL result)", memory[109]);
        $display("Location 110: %h (JMPGEZ result)", memory[110]);
        $display("Location 111: %h (JMP result)", memory[111]);
        
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
            memory[50] = 16'h00AA;    // Test value 1 (10101010)
            memory[51] = 16'h0055;    // Test value 2 (01010101)
            memory[52] = 16'h0003;    // Small value for multiply
            memory[53] = 16'h8000;    // Negative value for JMPGEZ test
            memory[54] = 16'h0001;    // Value 1 for increments
            
            // Test program - execute each instruction
            // Address 0: Start with LOAD instruction
            memory[0] = {8'b00000010, 8'd50};   // LOAD 50 - Load test value 1 into ACC
            memory[1] = {8'b00000001, 8'd100};  // STORE 100 - Store ACC to verify LOAD worked
            
            // Address 2: Test STORE instruction
            memory[2] = {8'b00000010, 8'd51};   // LOAD 51 - Load test value 2
            memory[3] = {8'b00000001, 8'd101};  // STORE 101 - Store to test location
            
            // Address 4: Test ADD instruction
            memory[4] = {8'b00000010, 8'd50};   // LOAD 50 - Load test value 1
            memory[5] = {8'b00000011, 8'd51};   // ADD 51 - Add test value 2
            memory[6] = {8'b00000001, 8'd102};  // STORE 102 - Store result of ADD
            
            // Address 7: Test SUB instruction
            memory[7] = {8'b00000010, 8'd50};   // LOAD 50 - Load test value 1
            memory[8] = {8'b00000100, 8'd51};   // SUB 51 - Subtract test value 2
            memory[9] = {8'b00000001, 8'd103};  // STORE 103 - Store result of SUB
            
            // Address 10: Test MPY instruction
            memory[10] = {8'b00000010, 8'd50};   // LOAD 50 - Load test value 1
            memory[11] = {8'b00001000, 8'd52};   // MPY 52 - Multiply by small value
            memory[12] = {8'b00000001, 8'd104};  // STORE 104 - Store result of MPY
            
            // Address 13: Test AND instruction
            memory[13] = {8'b00000010, 8'd50};   // LOAD 50 - Load test value 1
            memory[14] = {8'b00001010, 8'd51};   // AND 51 - AND with test value 2
            memory[15] = {8'b00000001, 8'd105};  // STORE 105 - Store result of AND
            
            // Address 16: Test OR instruction
            memory[16] = {8'b00000010, 8'd50};   // LOAD 50 - Load test value 1
            memory[17] = {8'b00001011, 8'd51};   // OR 51 - OR with test value 2
            memory[18] = {8'b00000001, 8'd106};  // STORE 106 - Store result of OR
            
            // Address 19: Test NOT instruction
            memory[19] = {8'b00001100, 8'd50};   // NOT 50 - NOT of test value 1
            memory[20] = {8'b00000001, 8'd107};  // STORE 107 - Store result of NOT
            
            // Address 21: Test SHIFTR instruction
            memory[21] = {8'b00000010, 8'd50};   // LOAD 50 - Load test value 1
            memory[22] = {8'b00001101, 8'd0};    // SHIFTR - Shift right 1 bit
            memory[23] = {8'b00000001, 8'd108};  // STORE 108 - Store result of SHIFTR
            
            // Address 24: Test SHIFTL instruction
            memory[24] = {8'b00000010, 8'd50};   // LOAD 50 - Load test value 1
            memory[25] = {8'b00001110, 8'd0};    // SHIFTL - Shift left 1 bit
            memory[26] = {8'b00000001, 8'd109};  // STORE 109 - Store result of SHIFTL
            
            // Address 27: Test JMPGEZ instruction (with positive ACC)
            memory[27] = {8'b00000010, 8'd54};   // LOAD 54 - Load positive value
            memory[28] = {8'b00000101, 8'd30};   // JMPGEZ 30 - Should jump to 30
            memory[29] = {8'b00000001, 8'd110};  // STORE 110 - Should be skipped
            
            // Address 30: Continue after JMPGEZ test
            memory[30] = {8'b00000010, 8'd54};   // LOAD 54 - Load value 1
            memory[31] = {8'b00000001, 8'd110};  // STORE 110 - Store to indicate JMPGEZ worked
            
            // Address 32: Test JMPGEZ with negative value (should not jump)
            memory[32] = {8'b00000010, 8'd53};   // LOAD 53 - Load negative value
            memory[33] = {8'b00000101, 8'd40};   // JMPGEZ 40 - Should NOT jump
            memory[34] = {8'b00000010, 8'd54};   // LOAD 54 - Load value 1 (should execute)
            memory[35] = {8'b00000001, 8'd111};  // STORE 111 - Store to indicate test worked
            
            // Address 36: Test JMP instruction
            memory[36] = {8'b00000110, 8'd38};   // JMP 38 - Jump to address 38
            memory[37] = {8'b00000010, 8'd53};   // LOAD 53 - Should be skipped
            
            // Address 38: Final halt
            memory[38] = {8'b00000111, 8'd0};    // HALT - End program
            
            // Extra test area (if needed)
            memory[40] = {8'b00000010, 8'd53};   // LOAD 53 - This shouldn't execute if JMPGEZ works
            memory[41] = {8'b00000001, 8'd111};  // STORE 111 - This shouldn't execute if JMPGEZ works
            memory[42] = {8'b00000111, 8'd0};    // HALT
        end
    endtask

endmodule
