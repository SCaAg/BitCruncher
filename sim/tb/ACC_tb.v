`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: ACC_tb
// Project Name: BitCruncher
// Description: Testbench for the Accumulator (ACC) module
//////////////////////////////////////////////////////////////////////////////////

module ACC_tb;
    // Parameters
    parameter CLK_PERIOD = 10; // 10ns clock period (100MHz)
    
    // Inputs
    reg clk;
    reg rst_n;
    reg C8, C9, C13, C15, C16, C17, C18, C19, C20, C21;
    reg [15:0] BR_in;
    
    // Outputs
    wire [15:0] ACC_out;
    wire [3:0] ALUflags;
    
    // Instantiate the Unit Under Test (UUT)
    ALU_ACC uut (
        .clk(clk),
        .rst_n(rst_n),
        .C8(C8),
        .C9(C9),
        .C13(C13),
        .C15(C15),
        .C16(C16),
        .C17(C17),
        .C18(C18),
        .C19(C19),
        .C20(C20),
        .C21(C21),
        .BR_in(BR_in),
        .ACC_out(ACC_out),
        .ALUflags(ALUflags)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Extract individual flags for easier debugging
    wire ZF, CF, OF, SF;
    assign {ZF, CF, OF, SF} = ALUflags;
    
    // Test sequence
    initial begin
        // Initialize inputs
        rst_n = 0;
        C8 = 0; C9 = 0; C13 = 0; C15 = 0; C16 = 0; 
        C17 = 0; C18 = 0; C19 = 0; C20 = 0; C21 = 0;
        BR_in = 16'h0000;
        
        // Apply reset
        #(CLK_PERIOD*2);
        rst_n = 1;
        #(CLK_PERIOD);
        #(CLK_PERIOD/2);
        
        // Test 1: Clear ACC (C8)
        $display("Test 1: Clear ACC");
        C8 = 1;
        #(CLK_PERIOD);
        C8 = 0;
        #(CLK_PERIOD); // Wait for one cycle to complete the operation
        $display("ACC_out = %h, Flags = ZF:%b CF:%b OF:%b SF:%b", ACC_out, ZF, CF, OF, SF);
        
        // Test 2: Add operation (C9) - ACC + BR
        $display("Test 2: Add operation");
        BR_in = 16'h1234;
        C9 = 1;
        #(CLK_PERIOD);
        C9 = 0;
        #(CLK_PERIOD); // Wait for one cycle to complete the operation
        $display("ACC_out = %h, Flags = ZF:%b CF:%b OF:%b SF:%b", ACC_out, ZF, CF, OF, SF);
        
        // Test 3: Subtract operation (C13) - ACC - BR
        $display("Test 3: Subtract operation");
        BR_in = 16'h0033;
        C13 = 1;
        #(CLK_PERIOD);
        C13 = 0;
        #(CLK_PERIOD); // Wait for one cycle to complete the operation
        $display("ACC_out = %h, Flags = ZF:%b CF:%b OF:%b SF:%b", ACC_out, ZF, CF, OF, SF);
        
        // Test 4: Multiplication (C15) - ACC * BR
        $display("Test 4: Multiplication");
        BR_in = 16'h0003;
        C15 = 1;
        #(CLK_PERIOD);
        C15 = 0;
        #(CLK_PERIOD); // Wait for one cycle to complete the operation
        $display("ACC_out = %h, Flags = ZF:%b CF:%b OF:%b SF:%b", ACC_out, ZF, CF, OF, SF);
        
        // Test 5: Division (C16) - ACC / BR
        $display("Test 5: Division");
        BR_in = 16'h0002;
        C16 = 1;
        #(CLK_PERIOD);
        C16 = 0;
        #(CLK_PERIOD); // Wait for one cycle to complete the operation
        $display("ACC_out = %h, Flags = ZF:%b CF:%b OF:%b SF:%b", ACC_out, ZF, CF, OF, SF);
        
        // Test 6: Shift Left (C17) - ACC << BR[3:0]
        $display("Test 6: Shift Left");
        BR_in = 16'h0002; // Shift left by 2
        C17 = 1;
        #(CLK_PERIOD);
        C17 = 0;
        #(CLK_PERIOD); // Wait for one cycle to complete the operation
        $display("ACC_out = %h, Flags = ZF:%b CF:%b OF:%b SF:%b", ACC_out, ZF, CF, OF, SF);
        
        // Test 7: Shift Right (C18) - ACC >> BR[3:0]
        $display("Test 7: Shift Right");
        BR_in = 16'h0001; // Shift right by 1
        C18 = 1;
        #(CLK_PERIOD);
        C18 = 0;
        #(CLK_PERIOD); // Wait for one cycle to complete the operation
        $display("ACC_out = %h, Flags = ZF:%b CF:%b OF:%b SF:%b", ACC_out, ZF, CF, OF, SF);
        
        // Test 8: AND operation (C19) - ACC & BR
        $display("Test 8: AND operation");
        BR_in = 16'hFF00;
        C19 = 1;
        #(CLK_PERIOD);
        C19 = 0;
        #(CLK_PERIOD); // Wait for one cycle to complete the operation
        $display("ACC_out = %h, Flags = ZF:%b CF:%b OF:%b SF:%b", ACC_out, ZF, CF, OF, SF);
        
        // Test 9: OR operation (C20) - ACC | BR
        $display("Test 9: OR operation");
        BR_in = 16'h00FF;
        C20 = 1;
        #(CLK_PERIOD);
        C20 = 0;
        #(CLK_PERIOD); // Wait for one cycle to complete the operation
        $display("ACC_out = %h, Flags = ZF:%b CF:%b OF:%b SF:%b", ACC_out, ZF, CF, OF, SF);
        
        // Test 10: NOT operation (C21) - ~BR
        $display("Test 10: NOT operation");
        BR_in = 16'hAAAA;
        C21 = 1;
        #(CLK_PERIOD);
        C21 = 0;
        #(CLK_PERIOD); // Wait for one cycle to complete the operation
        $display("ACC_out = %h, Flags = ZF:%b CF:%b OF:%b SF:%b", ACC_out, ZF, CF, OF, SF);
        
        // Test 11: Overflow condition in addition
        $display("Test 11: Addition with Overflow");
        C8 = 1; // Clear ACC first
        #(CLK_PERIOD);
        C8 = 0;
        #(CLK_PERIOD); // Wait for one cycle to complete the operation
        BR_in = 16'h7FFF; // Max positive value
        C9 = 1; // Add BR to ACC
        #(CLK_PERIOD);
        C9 = 0;
        #(CLK_PERIOD); // Wait for one cycle to complete the operation
        BR_in = 16'h0001; // Add 1 more to cause overflow
        C9 = 1;
        #(CLK_PERIOD);
        C9 = 0;
        #(CLK_PERIOD); // Wait for one cycle to complete the operation
        $display("ACC_out = %h, Flags = ZF:%b CF:%b OF:%b SF:%b", ACC_out, ZF, CF, OF, SF);
        
        // Test 12: Division by zero
        $display("Test 12: Division by Zero");
        C8 = 1; // Clear ACC first
        #(CLK_PERIOD);
        C8 = 0;
        #(CLK_PERIOD); // Wait for one cycle to complete the operation
        BR_in = 16'h0005; // Set ACC to some value
        C9 = 1;
        #(CLK_PERIOD);
        C9 = 0;
        #(CLK_PERIOD); // Wait for one cycle to complete the operation
        BR_in = 16'h0000; // Try to divide by zero
        C16 = 1;
        #(CLK_PERIOD);
        C16 = 0;
        #(CLK_PERIOD); // Wait for one cycle to complete the operation
        $display("ACC_out = %h, Flags = ZF:%b CF:%b OF:%b SF:%b", ACC_out, ZF, CF, OF, SF);
        
        // Finish simulation
        #(CLK_PERIOD*5);
        $display("Testbench completed");
        $finish;
    end
    
    // Optional: Monitor changes for debugging
    //initial begin
    //    $monitor("Time=%t, ACC=%h, BR=%h, Flags={Z:%b,C:%b,O:%b,S:%b}", 
    //             $time, ACC_out, BR_in, ZF, CF, OF, SF);
    //end
    
endmodule 