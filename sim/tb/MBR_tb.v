`timescale 1ns / 1ps

module MBR_tb;
    // Inputs
    reg clk;
    reg rst_n;
    reg C3;
    reg C11;
    reg C12;
    reg [15:0] ACC_in;
    reg [15:0] MBR_in_memory;
    
    // Outputs
    wire [15:0] MBR_out;
    wire [15:0] MBR_out_memory;
    
    // Declare a reg to monitor the CU output directly
    reg [31:0] Control_Signals_CU;
    
    // Instantiate the MBR module
    MBR uut (
        .clk(clk),
        .rst_n(rst_n),
        .C3(C3),
        .C11(C11),
        .C12(C12),
        .ACC_in(ACC_in),
        .MBR_in_memory(MBR_in_memory),
        .MBR_out(MBR_out),
        .MBR_out_memory(MBR_out_memory)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test sequence
    initial begin
        // Initialize inputs
        rst_n = 0;
        C3 = 0;
        C11 = 0;
        C12 = 0;
        ACC_in = 16'h1234;
        MBR_in_memory = 16'h5678;
        Control_Signals_CU = 32'h0;
        
        // Reset
        #20 rst_n = 1;
        
        // -------------------------
        // Test 1: MBR <- memory (C3) - Direct signal version
        #10;
        $display("\nTest 1: MBR <- memory (C3) - Direct signal");
        $display("Before: MBR_out=%h, MBR_in_memory=%h", MBR_out, MBR_in_memory);
        C3 = 1;
        #10;
        $display("After: MBR_out=%h", MBR_out);
        C3 = 0;
        
        // -------------------------
        // Test 2: MBR <- ACC (C12) - Direct signal version
        #10;
        $display("\nTest 2: MBR <- ACC (C12) - Direct signal");
        $display("Before: MBR_out=%h, ACC_in=%h", MBR_out, ACC_in);
        C12 = 1;
        #10;
        $display("After: MBR_out=%h", MBR_out);
        C12 = 0;
        
        // -------------------------
        // Test 3: memory <- MBR (C11) - Direct signal version
        #10;
        $display("\nTest 3: memory <- MBR (C11) - Direct signal");
        $display("Before: MBR_out=%h, MBR_out_memory=%h", MBR_out, MBR_out_memory);
        C11 = 1;
        #10;
        $display("After: MBR_out_memory=%h", MBR_out_memory);
        C11 = 0;
        
        // -------------------------
        // Test 4: MBR <- memory (C3) AND memory <- MBR (C11) - Same cycle
        #10;
        $display("\nTest 4: MBR <- memory AND memory <- MBR - Same cycle");
        MBR_in_memory = 16'h9ABC;
        $display("Before: MBR_out=%h, MBR_in_memory=%h, MBR_out_memory=%h", 
                 MBR_out, MBR_in_memory, MBR_out_memory);
        C3 = 1;
        C11 = 1;
        #10;
        $display("After: MBR_out=%h, MBR_out_memory=%h", MBR_out, MBR_out_memory);
        C3 = 0;
        C11 = 0;
        
        // -------------------------
        // Now simulate through Control_Signals direct indexing
        $display("\n--- Testing through Control_Signals indexing ---");
        
        // Test 5: MBR <- memory (Control_Signals[3])
        #10;
        $display("\nTest 5: MBR <- memory (Control_Signals[3])");
        MBR_in_memory = 16'hDEF0;
        $display("Before: MBR_out=%h, MBR_in_memory=%h", MBR_out, MBR_in_memory);
        Control_Signals_CU = 32'h0000_0008; // Bit 3 set
        C3 = Control_Signals_CU[3];
        #10;
        $display("After: MBR_out=%h, Control_Signals_CU=%b, C3=%b", 
                 MBR_out, Control_Signals_CU, C3);
        Control_Signals_CU = 32'h0;
        C3 = 0;
        
        // Test 6: memory <- MBR (Control_Signals[11])
        #10;
        $display("\nTest 6: memory <- MBR (Control_Signals[11])");
        $display("Before: MBR_out=%h, MBR_out_memory=%h", MBR_out, MBR_out_memory);
        Control_Signals_CU = 32'h0000_0800; // Bit 11 set
        C11 = Control_Signals_CU[11];
        #10;
        $display("After: MBR_out_memory=%h, Control_Signals_CU=%b, C11=%b", 
                 MBR_out_memory, Control_Signals_CU, C11);
        Control_Signals_CU = 32'h0;
        C11 = 0;
        
        // Test 7: MBR <- memory AND memory <- MBR - Same cycle with Control_Signals
        #10;
        $display("\nTest 7: MBR <- memory AND memory <- MBR - Control_Signals same cycle");
        MBR_in_memory = 16'h1111;
        $display("Before: MBR_out=%h, MBR_in_memory=%h, MBR_out_memory=%h", 
                 MBR_out, MBR_in_memory, MBR_out_memory);
        Control_Signals_CU = 32'h0000_0808; // Bits 3 and 11 set
        C3 = Control_Signals_CU[3];
        C11 = Control_Signals_CU[11];
        #10;
        $display("After: MBR_out=%h, MBR_out_memory=%h", MBR_out, MBR_out_memory);
        $display("Control_Signals_CU=%b, C3=%b, C11=%b", Control_Signals_CU, C3, C11);
        Control_Signals_CU = 32'h0;
        C3 = 0;
        C11 = 0;
        
        // End simulation
        #20;
        $finish;
    end
    
    // Monitor changes
    initial begin
        $monitor("Time=%t, C3=%b, C11=%b, C12=%b, MBR_out=%h, MBR_out_memory=%h", 
                 $time, C3, C11, C12, MBR_out, MBR_out_memory);
    end
    
endmodule 