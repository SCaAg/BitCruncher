# BitCruncher CPU Documentation

This directory contains comprehensive documentation for the BitCruncher CPU project, including design specifications, instruction set definitions, and microcode documentation.

## Documentation Files

### 1. complete.md
**Complete Design Specification**
- Comprehensive CPU design documentation
- Architecture overview and system structure
- Detailed component descriptions
- Microprogram control unit design
- Instruction execution flow diagrams
- Control signal definitions and timing

### 2. instructions.csv
**Instruction Set Reference**
- Complete instruction set in CSV format
- Organized by instruction categories:
  - Data I/O operations (LOAD, STORE)
  - Data calculation operations (ADD, SUB, MPY, AND, OR, NOT, SHIFT)
  - Stream control operations (JMP, JMPGEZ, HALT)
- Includes opcodes and operation descriptions
- Machine-readable format for tools and scripts

### 3. MC_def.md
**Microcode Definitions**
- Detailed microcode sequences for each instruction
- Control signal mappings (C0-C31)
- Timing diagrams for instruction execution
- Common microcode patterns:
  - Fetch cycle (t1-t3)
  - Instruction-specific execution phases
  - Return to fetch cycle
- Conditional branching microcode for JMPGEZ

### 4. 寄组II预定义.md
**Register Organization Specification**
- Register set definitions and bit widths
- Register interconnection specifications
- Data path organization
- Memory interface definitions

## Design Philosophy

The BitCruncher CPU follows a microprogram-controlled architecture with the following key principles:

### Microprogram Control
- Each instruction is implemented as a sequence of microinstructions
- Common fetch-decode-execute cycle
- Hardwired microprogram stored in control memory
- 32-bit control word format for comprehensive control

### Instruction Format
```
15    8 7     0
+------+------+
|OPCODE|ADDR  |
+------+------+
```
- 8-bit opcode field (supports up to 256 instructions)
- 8-bit address field (direct addressing, 256 memory locations)

### Memory Organization
```
Address Range | Usage
0x00 - 0x7F  | Code Segment (128 instructions)
0x80 - 0xFF  | Data Segment (128 data words)
```

## Control Signal Reference

### Core Control Signals (C0-C2)
- **C0**: CAR ← CAR+1 (Control Address Register increment)
- **C1**: CAR ← *** (Control Address Redirection)
- **C2**: CAR ← 0 (Reset Control Address)

### Memory and Register Operations (C3-C14)
- **C3**: MBR ← memory (Load memory to MBR)
- **C4**: IR ← MBR[15:8] (Load OPCODE to IR)
- **C5**: MAR ← MBR[7:0] (Load address part to MAR)
- **C6**: PC ← PC+1 (Increment PC)
- **C7**: BR ← MBR (Load MBR to BR for ALU)
- **C8**: ACC ← 0 (Reset ACC)
- **C10**: MAR ← PC (Copy PC to MAR for next fetch)
- **C11**: Mem[MAR] ← MBR (Store MBR to memory)
- **C12**: MBR ← ACC (Copy ACC to MBR)
- **C14**: PC ← MBR (Jump instruction, load MBR to PC)

### ALU Operations (C9, C13, C15-C21)
- **C9**: ACC ← ACC+BR (Add)
- **C13**: ACC ← ACC-BR (Subtract)
- **C15**: ACC ← ACC*BR (Multiply)
- **C16**: ACC ← ACC/BR (Divide)
- **C17**: ACC ← ACC << BR (Shift left)
- **C18**: ACC ← ACC >> BR (Shift right)
- **C19**: ACC ← ACC & BR (AND)
- **C20**: ACC ← ACC | BR (OR)
- **C21**: ACC ← ~BR (NOT)

## Instruction Execution Examples

### LOAD Instruction
```
t1: MBR ← Mem[MAR] (C3)
t2: IR ← MBR[15:8] (C4)
t3: MAR ← MBR[7:0], PC ← PC+1 (C5|C6)
t4: MBR ← Mem[MAR] (C3)
t5: BR ← MBR, ACC ← 0 (C7|C8)
t6: ACC ← ACC+BR (C9)
```

### ADD Instruction
```
t1-t3: Common fetch cycle
t4: MBR ← Mem[MAR] (C3)
t5: BR ← MBR (C7)
t6: ACC ← ACC+BR (C9)
```

### JMPGEZ Instruction
```
t1-t3: Common fetch cycle
t4: MBR ← Mem[MAR] (C3)
t5: Condition check based on ACC flags
     If ACC ≥ 0: PC ← MBR (C14)
     If ACC < 0: Continue to next instruction
```

## Testing and Verification

The documentation supports comprehensive testing through:

1. **Instruction Set Verification**: Each instruction documented with expected behavior
2. **Microcode Validation**: Timing diagrams for verification
3. **Control Signal Testing**: Complete signal definitions for testbench development
4. **Assembly Programming**: Instruction format specifications for assembler development

## Usage Guidelines

### For Hardware Designers
- Use `complete.md` for overall architecture understanding
- Reference `MC_def.md` for microcode implementation
- Check control signal definitions for RTL development

### For Software Developers
- Use `instructions.csv` for assembler development
- Reference instruction formats for program development
- Check memory organization for program layout

### For Verification Engineers
- Use microcode definitions for testbench development
- Reference timing diagrams for simulation verification
- Check expected behaviors for test case development

## Revision History

- **v1.0**: Initial documentation based on design specification
- **v1.1**: Updated with actual RTL implementation details
- **v1.2**: Added comprehensive microcode definitions
- **v1.3**: Updated with assembly toolchain integration

## Related Files

- `../assembly/assembler.py`: Python assembler implementation
- `../rtl/CU.v`: Control unit RTL implementation
- `../rtl/include/instruction_set.vh`: Verilog instruction definitions
- `../sim/tb/CPU_Top_tb.v`: Main CPU testbench
