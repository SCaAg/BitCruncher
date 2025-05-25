# BitCruncher CPU Microcode Definitions

This document defines the microcode sequences and control signals for the BitCruncher CPU implementation.

## Control Signal Mapping

The control unit generates 32 control signals (C0-C31) with the following assignments:

### Core Control Signals (C0-C2)
- **C0**: CAR ← CAR+1 (Control Address Register increment)
- **C1**: CAR ← *** (Control Address Redirection, depends on microinstruction)
- **C2**: CAR ← 0 (Reset Control Address to zero position)

### Memory and Register Operations (C3-C14)
- **C3**: MBR ← memory (Memory Content to MBR)
- **C4**: IR ← MBR[15:8] (Copy MBR[15:8] to IR for OPCODE)
- **C5**: MAR ← MBR[7:0] (Copy MBR[7:0] to MAR for address)
- **C6**: PC ← PC+1 (Increment PC for indicating position)
- **C7**: BR ← MBR (Copy MBR data to BR for buffer to ALU)
- **C8**: ACC ← 0 (Reset ACC register to zero)
- **C9**: ACC ← ACC+BR (Add BR to ACC)
- **C10**: MAR ← PC (Copy PC value to MAR for next address)
- **C11**: Mem[MAR] ← MBR (Store MBR to memory)
- **C12**: MBR ← ACC (Copy ACC to MBR)
- **C13**: ACC ← ACC-BR (Subtract BR from ACC)
- **C14**: PC ← MBR[7:0] (Jump instruction, load MBR to PC)

### ALU Operations (C15-C21)
- **C15**: ACC ← ACC*BR (Multiply)
- **C16**: ACC ← ACC/BR (Divide) - Reserved
- **C17**: ACC ← ACC << BR (Shift left)
- **C18**: ACC ← ACC >> BR (Shift right)
- **C19**: ACC ← ACC & BR (AND)
- **C20**: ACC ← ACC | BR (OR)
- **C21**: ACC ← ~BR (NOT)

### Reserved Signals (C22-C31)
- **C22-C31**: Reserved for future use

## Microcode Memory Layout

The microcode memory contains 72 microinstructions (addresses 0-71), organized as follows:

### Common Fetch Cycle (Addresses 0-4)
All instructions begin with the same fetch sequence:

```
Address 0: C0|C3     - MBR ← Mem[MAR], CAR++
Address 1: C0|C4     - IR ← MBR[15:8], CAR++
Address 2: C0|C5|C6  - MAR ← MBR[7:0], PC ← PC+1, CAR++
Address 3: C1        - Branch based on opcode (decode)
Address 4: NOP       - No operation
```

### Instruction-Specific Microcode

#### LOAD Instruction (Opcode 00000010)
**Microcode Addresses: 5-9**
```
Address 5: C0|C3     - MBR ← Mem[MAR], CAR++
Address 6: C0|C7|C8  - BR ← MBR, ACC ← 0, CAR++
Address 7: C0|C9     - ACC ← ACC+BR, CAR++
Address 8: C1        - Jump to end
Address 9: NOP       - No operation
```

#### STORE Instruction (Opcode 00000001)
**Microcode Addresses: 10-13**
```
Address 10: C0|C12   - MBR ← ACC, CAR++
Address 11: C0|C11   - Mem[MAR] ← MBR, CAR++
Address 12: C1       - Jump to end
Address 13: C23      - Write Enable (for memory interface)
```

#### ADD Instruction (Opcode 00000011)
**Microcode Addresses: 14-18**
```
Address 14: C0|C3    - MBR ← Mem[MAR], CAR++
Address 15: C0|C7    - BR ← MBR, CAR++
Address 16: C0|C9    - ACC ← ACC+BR, CAR++
Address 17: C1       - Jump to end
Address 18: NOP      - No operation
```

#### SUB Instruction (Opcode 00000100)
**Microcode Addresses: 19-23**
```
Address 19: C0|C3    - MBR ← Mem[MAR], CAR++
Address 20: C0|C7    - BR ← MBR, CAR++
Address 21: C0|C13   - ACC ← ACC-BR, CAR++
Address 22: C1       - Jump to end
Address 23: NOP      - No operation
```

#### JMPGEZ Instruction (Opcode 00000101)
**Microcode Addresses: 24-32**
```
Address 24: C0|C3    - MBR ← Mem[MAR], CAR++
Address 25: C1       - Condition check (redirected based on flags)
Address 26: NOP      - No operation
Address 27: C0|C14   - PC ← MBR (Jump taken), CAR++
Address 28: C1       - Jump to end
Address 29: NOP      - No operation
Address 30: C0       - Just increment CAR (Jump not taken)
Address 31: C1       - Jump to end
Address 32: NOP      - No operation
```

#### JMP Instruction (Opcode 00000110)
**Microcode Addresses: 33-37**
```
Address 33: C0|C3    - MBR ← Mem[MAR], CAR++
Address 34: C0|C14   - PC ← MBR, CAR++
Address 35: C0       - Increment CAR
Address 36: C1       - Jump to end
Address 37: NOP      - No operation
```

#### HALT Instruction (Opcode 00000111)
**Microcode Addresses: 38-40**
```
Address 38: NOP      - No operation (halt)
Address 39: NOP      - No operation (halt)
Address 40: NOP      - No operation (halt forever)
```

#### MPY Instruction (Opcode 00001000)
**Microcode Addresses: 41-45**
```
Address 41: C0|C3    - MBR ← Mem[MAR], CAR++
Address 42: C0|C7    - BR ← MBR, CAR++
Address 43: C0|C15   - ACC ← ACC*BR, CAR++
Address 44: C1       - Jump to end
Address 45: NOP      - No operation
```

#### AND Instruction (Opcode 00001010)
**Microcode Addresses: 46-50**
```
Address 46: C0|C3    - MBR ← Mem[MAR], CAR++
Address 47: C0|C7    - BR ← MBR, CAR++
Address 48: C0|C19   - ACC ← ACC&BR, CAR++
Address 49: C1       - Jump to end
Address 50: NOP      - No operation
```

#### OR Instruction (Opcode 00001011)
**Microcode Addresses: 51-55**
```
Address 51: C0|C3    - MBR ← Mem[MAR], CAR++
Address 52: C0|C7    - BR ← MBR, CAR++
Address 53: C0|C20   - ACC ← ACC|BR, CAR++
Address 54: C1       - Jump to end
Address 55: NOP      - No operation
```

#### NOT Instruction (Opcode 00001100)
**Microcode Addresses: 56-60**
```
Address 56: C0|C3    - MBR ← Mem[MAR], CAR++
Address 57: C0|C7    - BR ← MBR, CAR++
Address 58: C0|C21   - ACC ← ~BR, CAR++
Address 59: C1       - Jump to end
Address 60: NOP      - No operation
```

#### SHIFTR Instruction (Opcode 00001101)
**Microcode Addresses: 61-65**
```
Address 61: C0|C3    - MBR ← Mem[MAR], CAR++
Address 62: C0|C7    - BR ← MBR, CAR++
Address 63: C0|C18   - ACC ← ACC>>BR, CAR++
Address 64: C1       - Jump to end
Address 65: NOP      - No operation
```

#### SHIFTL Instruction (Opcode 00001110)
**Microcode Addresses: 66-70**
```
Address 66: C0|C3    - MBR ← Mem[MAR], CAR++
Address 67: C0|C7    - BR ← MBR, CAR++
Address 68: C0|C17   - ACC ← ACC<<BR, CAR++
Address 69: C1       - Jump to end
Address 70: NOP      - No operation
```

### Common End Sequence (Address 71)
All instructions end by returning to the fetch cycle:
```
Address 71: C2|C10   - Reset CAR to 0 and MAR ← PC
```

## Microcode Execution Flow

### Standard Instruction Flow
1. **Fetch Phase** (Addresses 0-3):
   - Load instruction from memory
   - Extract opcode and address
   - Increment PC
   - Branch to instruction-specific microcode

2. **Execute Phase** (Instruction-specific):
   - Load operand from memory (if needed)
   - Perform operation
   - Store result (if needed)

3. **Return Phase** (Address 71):
   - Prepare for next instruction fetch
   - Reset control address register

### Conditional Branching (JMPGEZ)
The JMPGEZ instruction uses ALU flags to determine branching:
- **ACC ≥ 0**: Execute jump (load target address to PC)
- **ACC < 0**: Continue to next instruction (no jump)

## Control Address Register (CAR) Management

The CAR is managed through three control signals:
- **C0**: Normal increment (CAR = CAR + 1)
- **C1**: Conditional/unconditional branch (CAR = target address)
- **C2**: Reset to fetch cycle (CAR = 0)

### Branch Target Calculation
For instruction decode (Address 3), the target address is calculated as:
```
target_address = base_address + (opcode * addresses_per_instruction)
```

Where:
- STORE (0x01): Address 10
- LOAD (0x02): Address 5
- ADD (0x03): Address 14
- SUB (0x04): Address 19
- JMPGEZ (0x05): Address 24
- JMP (0x06): Address 33
- HALT (0x07): Address 38
- MPY (0x08): Address 41
- AND (0x0A): Address 46
- OR (0x0B): Address 51
- NOT (0x0C): Address 56
- SHIFTR (0x0D): Address 61
- SHIFTL (0x0E): Address 66

## Timing Considerations

Each microinstruction executes in one clock cycle. The typical instruction timing is:
- **Fetch**: 4 clock cycles (addresses 0-3)
- **Execute**: 3-5 clock cycles (instruction-dependent)
- **Return**: 1 clock cycle (address 71)

Total instruction execution time: 8-10 clock cycles per instruction.

## Implementation Notes

1. **Microcode Memory**: Implemented as a 72×32 ROM in the control unit
2. **Control Signal Generation**: Direct mapping from microcode memory output
3. **Conditional Logic**: Implemented in CAR update logic for JMPGEZ
4. **Reset Behavior**: CAR initializes to 0 on system reset
5. **Halt Implementation**: HALT instruction loops indefinitely at the same microcode address
