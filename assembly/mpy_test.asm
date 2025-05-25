// Test program for the MPY instruction
// MPY: ACC * [X] -> MR (high 8 bits), ACC (low 8 bits)

CODE SEGMENT
// --- Code Section ---
start:
    // Test 1: 10 * 20 = 200 (0xC8)
    // Result fits in 8 bits. Expected: ACC=200 (0xC8), MR=0
    LOAD    operand_a   // Load 10 into ACC
    MPY     operand_b   // Multiply ACC by value at operand_b (20)
    STORE   result1_acc // Store ACC (lower 8 bits of result)

    // Test 2: 20 * 30 = 600 (0x0258)
    // Result requires 16 bits. Expected: ACC=88 (0x58), MR=2 (0x02)
    LOAD    operand_b   // Load 20 into ACC
    MPY     operand_c   // Multiply ACC by value at operand_c (30)
    STORE   result2_acc // Store ACC (lower 8 bits of result)

    // We cannot directly verify MR with current instructions.

    HALT
END SEGMENT

DATA SEGMENT
// --- Data Section ---
operand_a:   DATA 10     // Value 10 (0x000A) - MPY uses lower 8 bits (0x0A)
operand_b:   DATA 20     // Value 20 (0x0014) - MPY uses lower 8 bits (0x14)
operand_c:   DATA 30     // Value 30 (0x001E) - MPY uses lower 8 bits (0x1E)

result1_acc: DATA 0      // Placeholder for result of 10*20 (ACC). Expect 200 (0x00C8)
result2_acc: DATA 0      // Placeholder for result of 20*30 (ACC). Expect 88 (0x0058) 
END SEGMENT 