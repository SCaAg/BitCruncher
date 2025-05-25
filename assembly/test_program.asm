// Test program - execute each instruction
// Based on new_tb.sv

CODE SEGMENT
// Test 1: LOAD & STORE
load_test:
    LOAD    val_1      // Load test value 1 into ACC
    STORE   result_0   // Store ACC to memory[result_0]

// Test 2: ADD
add_test:
    ADD     val_2      // Add value from memory[val_2]
    STORE   result_1   // Store result to memory[result_1]

// Test 3: SUB
sub_test:
    SUB     val_1      // Subtract value from memory[val_1]
    STORE   result_2   // Store result to memory[result_2]

// Test 4: MPY
mpy_test:
    LOAD    val_2      // Load test value 2
    MPY     val_3      // Multiply by value from memory[val_3]
    STORE   result_3   // Store result (ACC part) to memory[result_3]

// Test 5: AND
and_test:
    LOAD    val_1      // Load test value 1
    AND     val_2      // AND with value from memory[val_2]
    STORE   result_4   // Store result to memory[result_4]

// Test 6: OR
or_test:
    LOAD    val_1      // Load test value 1
    OR      val_2      // OR with value from memory[val_2]
    STORE   result_5   // Store result to memory[result_5]

// Test 7: NOT
not_test:
    NOT     val_1      // NOT of value from memory[val_1] (Note: Operates on [X], result to ACC)
    STORE   result_6   // Store result to memory[result_6]

// Test 8: SHIFTR
// The .vh comment says SHIFT [X] to Right 1bit.
// Let's assume X is the address of the value to shift, result to ACC.
shiftr_test:
    LOAD    val_5      // Load value 8 (needed in ACC for potential storing)
    SHIFTR  val_5      // Shift value AT address val_5 right, result into ACC
    STORE   result_7   // Store result to memory[result_7]

// Test 9: SHIFTL
shiftl_test:
    LOAD    val_5      // Load value 8
    SHIFTL  val_5      // Shift value AT address val_5 left, result into ACC
    STORE   result_8   // Store result to memory[result_8]

// Test 10: JMPGEZ (Positive ACC -> Jump Taken)
// The Verilog loads val_3 (val 3), subs val_1 (val 1), leaving ACC=2 (positive)
// Then jumps to addr 24 (0x18) if ACC >= 0
jmpgez_pos_test:    // Address 0x16 (22)
    LOAD    val_3      // Load value 3
    SUB     val_1      // ACC = ACC - memory[val_1] (3 - 1 = 2)
jmpgez_pos_target: // Address 0x18 (24)
    JMPGEZ  jmpgez_pos_target // Jump back to self if ACC >= 0
    STORE   result_9     // This should be skipped in the original test logic due to the JMP

// Test 11: Continue after JMPGEZ test (Original Verilog overwrites skip target)
continue_after_jmpgez:
    LOAD    val_5      // Load value from memory[val_5]
    STORE   result_10  // Store to memory[result_10]

// Test 12: JMPGEZ (Negative ACC -> No Jump)
// Verilog loads neg value, JMPGEZ to jump_target -> should not jump
jmpgez_neg_test:
    LOAD    val_6      // Load value from memory[val_6] (interpreted as negative)
    JMPGEZ  jump_target // Jump to 'jump_target' if ACC >= 0 (should not jump)
    LOAD    val_5      // Should execute
    STORE   result_11  // Store to memory[result_11]

// Test 13: JMP
jmp_test:
    JMP     jump_target // Jump to 'jump_target'
    LOAD    val_4      // Should be skipped

// Test 14: Final halt
halt_program:
    HALT            // Halt execution
    HALT            // Extra halt from Verilog

// --- Jump Target Area ---
// Pad with HALT instructions to reach the target address
HALT
HALT
HALT
HALT

// Extra test area target from JMPs
jump_target:
    LOAD    val_4      // Load value from memory[val_4]
    STORE   result_12  // Store to memory[result_12]
    HALT
END SEGMENT

DATA SEGMENT
// Test values
val_1:      DATA 1       // Value for tests (corresponds to memory[50])
val_2:      DATA 2       // Value for tests (corresponds to memory[51])
val_3:      DATA 3       // Value for tests (corresponds to memory[52])
val_4:      DATA 4       // Value for tests (corresponds to memory[53])
val_5:      DATA 8       // Value for tests (corresponds to memory[54])
val_6:      DATA 0xFFF0  // Negative value for tests (corresponds to memory[55])

// Result storage
result_0:   DATA 0       // Storage for test results (corresponds to memory[100])
result_1:   DATA 0       // Storage for test results (corresponds to memory[101])
result_2:   DATA 0       // Storage for test results (corresponds to memory[102])
result_3:   DATA 0       // Storage for test results (corresponds to memory[103])
result_4:   DATA 0       // Storage for test results (corresponds to memory[104])
result_5:   DATA 0       // Storage for test results (corresponds to memory[105])
result_6:   DATA 0       // Storage for test results (corresponds to memory[106])
result_7:   DATA 0       // Storage for test results (corresponds to memory[107])
result_8:   DATA 0       // Storage for test results (corresponds to memory[108])
result_9:   DATA 0       // Storage for test results (corresponds to memory[109])
result_10:  DATA 0       // Storage for test results (corresponds to memory[110])
result_11:  DATA 0       // Storage for test results (corresponds to memory[111])
result_12:  DATA 0       // Storage for test results (corresponds to memory[112])
END SEGMENT 