// Test program - execute each instruction
// Based on new_tb.sv

// Test 1: LOAD & STORE
load_test:
    LOAD    50      // Load test value 1 (from memory[50]) into ACC
    STORE   100     // Store ACC to memory[100]

// Test 2: ADD
add_test:
    ADD     51      // Add value from memory[51]
    STORE   101     // Store result to memory[101]

// Test 3: SUB
sub_test:
    SUB     50      // Subtract value from memory[50]
    STORE   102     // Store result to memory[102]

// Test 4: MPY
mpy_test:
    LOAD    51      // Load test value 2 (from memory[51])
    MPY     52      // Multiply by value from memory[52]
    STORE   103     // Store result (ACC part) to memory[103]

// Test 5: AND
and_test:
    LOAD    50      // Load test value 1 (from memory[50])
    AND     51      // AND with value from memory[51]
    STORE   104     // Store result to memory[104]

// Test 6: OR
or_test:
    LOAD    50      // Load test value 1 (from memory[50])
    OR      51      // OR with value from memory[51]
    STORE   105     // Store result to memory[105]

// Test 7: NOT
not_test:
    NOT     50      // NOT of value from memory[50] (Note: Operates on [X], result to ACC)
    STORE   106     // Store result to memory[106]

// Test 8: SHIFTR
// The .vh comment says SHIFT [X] to Right 1bit.
// Let's assume X is the address of the value to shift, result to ACC.
shiftr_test:
    LOAD    54      // Load value 8 (needed in ACC for potential storing)
    SHIFTR  54      // Shift value AT address 54 right, result into ACC
    STORE   107     // Store result to memory[107]

// Test 9: SHIFTL
shiftl_test:
    LOAD    54      // Load value 8
    SHIFTL  54      // Shift value AT address 54 left, result into ACC
    STORE   108     // Store result to memory[108]

// Test 10: JMPGEZ (Positive ACC -> Jump Taken)
// The Verilog loads 52 (val 3), subs 50 (val 1), leaving ACC=2 (positive)
// Then jumps to addr 24 (0x18) if ACC >= 0
jmpgez_pos_test:    // Address 0x16 (22)
    LOAD    52      // Address 0x16 Load value 3 (from memory[52])
    SUB     50      // Address 0x17 ACC = ACC - memory[50] (3 - 1 = 2)
jmpgez_pos_target: // Address 0x18 (24)
    JMPGEZ  jmpgez_pos_target // Address 0x18 Jump back to self if ACC >= 0
    STORE   109     // Address 0x19 This should be skipped in the original test logic due to the JMP

// Test 11: Continue after JMPGEZ test (Original Verilog overwrites skip target)
// The SV code at address 26 loads 54. Let's place it here. Address 0x1A (26)
continue_after_jmpgez:
    LOAD    54      // Address 0x1A Load value from memory[54]
    STORE   110     // Address 0x1B Store to memory[110]

// Test 12: JMPGEZ (Negative ACC -> No Jump)
// Verilog loads 55 (0xFFF0 treated as neg), JMPGEZ 40 (0x28) -> should not jump
jmpgez_neg_test: // Address 0x1C (28)
    LOAD    55      // Address 0x1C Load value from memory[55] (interpreted as negative)
    JMPGEZ  jump_target // Address 0x1D Jump to 'jump_target' (address 40 / 0x28) if ACC >= 0 (should not jump)
    LOAD    54      // Address 0x1E Should execute (from memory[54])
    STORE   111     // Address 0x1F Store to memory[111]

// Test 13: JMP
jmp_test:           // Address 0x20 (32)
    JMP     jump_target // Address 0x20 Jump to 'jump_target' (address 40 / 0x28)
    LOAD    53      // Address 0x21 Should be skipped

// Test 14: Final halt (Original Verilog HALT is at address 34 / 0x22)
halt_program:       // Address 0x22 (34)
    HALT            // Address 0x22 Halt execution
    HALT            // Address 0x23 Extra halt from Verilog (addr 35)

// --- Jump Target Area ---
// Skipped instructions between address 0x23 and 0x28 in this assembly.
// We need to ensure 'jump_target' resolves to the correct address (40 / 0x28).
// We can use an ORG pseudo-directive if the assembler supported it, or pad with HALTs/NOPs.
// Let's pad with HALT instructions to reach the target address 0x28 (40).
// Current address is 0x24 (36). Need 40 - 36 = 4 padding instructions.
HALT      // Address 0x24
HALT      // Address 0x25
HALT      // Address 0x26
HALT      // Address 0x27

// Extra test area target from JMPs
jump_target:        // Address 0x28 (40)
    LOAD    53      // Address 0x28 Load value from memory[53]
    STORE   112     // Address 0x29 Store to memory[112]
    HALT            // Address 0x2A Halt 