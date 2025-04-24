// Assembly program to calculate sum 1+...+100

// --- Code Section ---
loop_start:
    LOAD    sum_var     // Load current sum into ACC
    ADD     counter_var // Add current counter value to ACC (sum = sum + counter)
    STORE   sum_var     // Store the updated sum back

    LOAD    counter_var // Load current counter value into ACC
    ADD     one_const   // Increment the counter (ACC = counter + 1)
    STORE   counter_var // Store the updated counter back

    LOAD    limit_var   // Load the loop limit counter into ACC
    SUB     one_const   // Decrement the loop limit counter (ACC = limit - 1)
    STORE   limit_var   // Store the updated loop limit counter back

    JMPGEZ  loop_start  // If ACC (the decremented limit) is >= 0, jump back to loop_start

// Loop has finished (limit went below 0)
exit_loop:
    LOAD    sum_var     // Load the final calculated sum into ACC
    STORE   result_addr // Store the final sum into the result address
    HALT                // Halt the program

// --- Data Section ---
// Variables used by the program
sum_var:     DATA 0     // Initial sum = 0
counter_var: DATA 1     // Initial counter = 1
limit_var:   DATA 99    // Initial loop limit counter = 99 (loops 100 times, 99 down to 0)
one_const:   DATA 1     // Constant value 1 for increment/decrement
result_addr: DATA 0     // Placeholder for the result (will be overwritten)
                    // The address of this label itself could be used if needed
                    // Or store to a known fixed address like 54 if required by testbench
