`timescale 1ns / 1ps

module CU_tb;

    // Testbench signals
    reg clk;
    reg rst_n;
    reg [7:0] IR_in;
    reg [3:0] ALUflags;
    wire [31:0] Control_Signals;
    
    // Instantiate the Unit Under Test (UUT)
    CU uut (
        .clk(clk),
        .rst_n(rst_n),
        .IR_in(IR_in),
        .ALUflags(ALUflags),
        .Control_Signals(Control_Signals)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end
    
    // Convenience functions to extract control signals
    function automatic string decode_control_signals;
        input [31:0] signals;
        begin
            decode_control_signals = "";
            if (signals[0]) decode_control_signals = {decode_control_signals, " C0(CAR+1)"};
            if (signals[1]) decode_control_signals = {decode_control_signals, " C1(Redirect)"};
            if (signals[2]) decode_control_signals = {decode_control_signals, " C2(CAR=0)"};
            if (signals[3]) decode_control_signals = {decode_control_signals, " C3(MBR<=Mem)"};
            if (signals[4]) decode_control_signals = {decode_control_signals, " C4(IR<=MBR)"};
            if (signals[5]) decode_control_signals = {decode_control_signals, " C5(MAR<=MBR)"};
            if (signals[6]) decode_control_signals = {decode_control_signals, " C6(PC+1)"};
            if (signals[7]) decode_control_signals = {decode_control_signals, " C7(BR<=MBR)"};
            if (signals[8]) decode_control_signals = {decode_control_signals, " C8(ACC=0)"};
            if (signals[9]) decode_control_signals = {decode_control_signals, " C9(ACC+=BR)"};
            if (signals[10]) decode_control_signals = {decode_control_signals, " C10(MAR<=PC)"};
            if (signals[11]) decode_control_signals = {decode_control_signals, " C11(Mem<=MBR)"};
            if (signals[12]) decode_control_signals = {decode_control_signals, " C12(MBR<=ACC)"};
            if (signals[13]) decode_control_signals = {decode_control_signals, " C13(ACC-=BR)"};
            if (signals[14]) decode_control_signals = {decode_control_signals, " C14(PC<=MBR)"};
            if (signals[15]) decode_control_signals = {decode_control_signals, " C15(ACC*=BR)"};
            if (signals[16]) decode_control_signals = {decode_control_signals, " C16(ACC/=BR)"};
            if (signals[17]) decode_control_signals = {decode_control_signals, " C17(ACC<<=BR)"};
            if (signals[18]) decode_control_signals = {decode_control_signals, " C18(ACC>>=BR)"};
            if (signals[19]) decode_control_signals = {decode_control_signals, " C19(ACC&=BR)"};
            if (signals[20]) decode_control_signals = {decode_control_signals, " C20(ACC|=BR)"};
            if (signals[21]) decode_control_signals = {decode_control_signals, " C21(ACC=~BR)"};
        end
    endfunction
    
    // Test sequence
    initial begin
        // Initialize inputs
        rst_n = 0;
        IR_in = 8'h00;
        ALUflags = 4'b0000; // ZF=0, CF=0, OF=0, SF=0
        
        // Reset the CU
        #20;
        rst_n = 1;
        #10;
        
        // Test LOAD instruction
        $display("Testing LOAD instruction (opcode: 00000010)");
        IR_in = 8'b00000010; // LOAD opcode
        
        // Wait for 10 clock cycles to observe all microinstructions for LOAD
        repeat(10) begin
            #10;
            $display("Time %t: Control_Signals = %b - %s", $time, Control_Signals, decode_control_signals(Control_Signals));
        end
        
        // Reset CU to start fresh
        rst_n = 0;
        #20;
        rst_n = 1;
        #10;
        
        // Test ADD instruction
        $display("\nTesting ADD instruction (opcode: 00000011)");
        IR_in = 8'b00000011; // ADD opcode
        
        // Wait for 10 clock cycles
        repeat(10) begin
            #10;
            $display("Time %t: Control_Signals = %b - %s", $time, Control_Signals, decode_control_signals(Control_Signals));
        end
        
        // Reset CU to start fresh
        rst_n = 0;
        #20;
        rst_n = 1;
        #10;
        
        // Test JMPGEZ instruction with ACC >= 0 (SF=0)
        $display("\nTesting JMPGEZ instruction with ACC >= 0 (opcode: 00000101)");
        IR_in = 8'b00000101; // JMPGEZ opcode
        ALUflags = 4'b0000; // SF=0, ACC >= 0
        
        // Wait for 10 clock cycles
        repeat(10) begin
            #10;
            $display("Time %t: Control_Signals = %b - %s", $time, Control_Signals, decode_control_signals(Control_Signals));
        end
        
        // Reset CU to start fresh
        rst_n = 0;
        #20;
        rst_n = 1;
        #10;
        
        // Test JMPGEZ instruction with ACC < 0 (SF=1)
        $display("\nTesting JMPGEZ instruction with ACC < 0 (opcode: 00000101)");
        IR_in = 8'b00000101; // JMPGEZ opcode
        ALUflags = 4'b0001; // SF=1, ACC < 0
        
        // Wait for 10 clock cycles
        repeat(10) begin
            #10;
            $display("Time %t: Control_Signals = %b - %s", $time, Control_Signals, decode_control_signals(Control_Signals));
        end
        
        // Reset CU to start fresh
        rst_n = 0;
        #20;
        rst_n = 1;
        #10;
        
        // Test AND instruction
        $display("\nTesting AND instruction (opcode: 00001010)");
        IR_in = 8'b00001010; // AND opcode
        
        // Wait for 10 clock cycles
        repeat(10) begin
            #10;
            $display("Time %t: Control_Signals = %b - %s", $time, Control_Signals, decode_control_signals(Control_Signals));
        end
        
        // Reset CU to start fresh
        rst_n = 0;
        #20;
        rst_n = 1;
        #10;
        
        // Test OR instruction
        $display("\nTesting OR instruction (opcode: 00001011)");
        IR_in = 8'b00001011; // OR opcode
        
        // Wait for 10 clock cycles
        repeat(10) begin
            #10;
            $display("Time %t: Control_Signals = %b - %s", $time, Control_Signals, decode_control_signals(Control_Signals));
        end
        
        // Reset CU to start fresh
        rst_n = 0;
        #20;
        rst_n = 1;
        #10;
        
        // Test SHIFTR instruction
        $display("\nTesting SHIFTR instruction (opcode: 00001101)");
        IR_in = 8'b00001101; // SHIFTR opcode
        
        // Wait for 10 clock cycles
        repeat(10) begin
            #10;
            $display("Time %t: Control_Signals = %b - %s", $time, Control_Signals, decode_control_signals(Control_Signals));
        end
        
        // Reset CU to start fresh
        rst_n = 0;
        #20;
        rst_n = 1;
        #10;
        
        // Test SHIFTL instruction
        $display("\nTesting SHIFTL instruction (opcode: 00001110)");
        IR_in = 8'b00001110; // SHIFTL opcode
        
        // Wait for 10 clock cycles
        repeat(10) begin
            #10;
            $display("Time %t: Control_Signals = %b - %s", $time, Control_Signals, decode_control_signals(Control_Signals));
        end
        
        // Reset CU to start fresh
        rst_n = 0;
        #20;
        rst_n = 1;
        #10;
        
        // Test HALT instruction
        $display("\nTesting HALT instruction (opcode: 00000111)");
        IR_in = 8'b00000111; // HALT opcode
        
        // Wait for 10 clock cycles
        repeat(10) begin
            #10;
            $display("Time %t: Control_Signals = %b - %s", $time, Control_Signals, decode_control_signals(Control_Signals));
        end
        
        // Finish simulation
        #20;
        $display("\nTestbench completed successfully");
        $finish;
    end
      
endmodule 