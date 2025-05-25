#!/usr/bin/env python3

import sys
import argparse
import re
import struct

# Instruction Opcodes extracted from instruction_set.vh
OPCODES = {
    "STORE":   0b00000001,
    "LOAD":    0b00000010,
    "ADD":     0b00000011,
    "SUB":     0b00000100,
    "JMPGEZ":  0b00000101,
    "JMP":     0b00000110,
    "HALT":    0b00000111,
    "MPY":     0b00001000,
    "AND":     0b00001010,
    "OR":      0b00001011,
    "NOT":     0b00001100,
    "SHIFTR":  0b00001101,
    "SHIFTL":  0b00001110,
}

# Pseudo-instructions
PSEUDO_OPS = {"DATA"}

# Segment directives
SEGMENT_DIRECTIVES = {"CODE", "DATA", "END"}

# Instruction width parameters from instruction_set.vh
OPCODE_WIDTH = 8
ADDR_WIDTH = 8
INSTR_WIDTH = OPCODE_WIDTH + ADDR_WIDTH
DATA_WIDTH = 16 # Assuming data width matches memory width for simplicity
MAX_ADDR = (1 << ADDR_WIDTH) - 1
MAX_DATA_VAL = (1 << DATA_WIDTH) - 1

# Memory space constraints
CODE_START_ADDR = 0
CODE_END_ADDR = 127
DATA_START_ADDR = 128
DATA_END_ADDR = 255

# Instructions that don't require an explicit operand in assembly
# (although they still have an address field in the binary format)
NO_OPERAND_INSTRUCTIONS = {"HALT"}

def parse_value(value_str, max_val, context):
    """Parses a numeric string (decimal or hex) into an integer."""
    value_str = value_str.strip()
    if not value_str:
         raise ValueError(f"Missing value {context}")

    try:
        # Try parsing as hex
        if value_str.startswith(('0x', '0X')):
            value = int(value_str, 16)
        # Try parsing as decimal
        elif value_str.isdigit() or (value_str.startswith('-') and value_str[1:].isdigit()):
             value = int(value_str, 10)
        else:
            raise ValueError(f"Invalid numeric literal: '{value_str}' {context}")

        # Validate range (unsigned for now)
        # TODO: Handle signed values if needed
        if not (0 <= value <= max_val):
             raise ValueError(f"Value '{value_str}' ({value}) out of range [0, {max_val}] {context}")
        return value
    except ValueError as e:
        # Re-raise with context if it's not already our ValueError
        if isinstance(e, ValueError) and context in str(e):
             raise e
        else:
             raise ValueError(f"Invalid value '{value_str}' {context}: {e}")


def parse_operand(operand_str, symbol_table, current_addr):
    """Parses an operand string (label, dec, hex) into an integer address."""
    operand_str = operand_str.strip()
    if not operand_str:
        return 0 # Default address if operand is missing (e.g., for HALT)

    # Try parsing as hex/dec number first
    try:
        value = parse_value(operand_str, MAX_ADDR, f"for operand at address {current_addr}")
        return value
    except ValueError as e:
         # If it failed parsing as a number, check if it's a label
         if operand_str in symbol_table:
             return symbol_table[operand_str]
         else:
             # If it's not a number and not a defined label, raise the original error
             # or a new one if it wasn't a ValueError initially
             if "Invalid numeric literal" in str(e) or "Invalid value" in str(e):
                 raise ValueError(f"Undefined label or invalid operand: '{operand_str}' at address {current_addr}") from None
             else: # Propagate range errors etc.
                 raise e


def assemble(input_filename, output_filename):
    """Assembles the input assembly file into a binary output file."""
    symbol_table = {}
    program_elements = [] # Stores tuples: (line_num, 'instruction', line, segment) or (line_num, 'data', value, segment)
    
    # Address counters for each segment
    code_addr = CODE_START_ADDR
    data_addr = DATA_START_ADDR
    current_segment = None

    # --- First Pass: Build Symbol Table and identify elements ---
    print("Starting First Pass...")
    try:
        with open(input_filename, 'r') as f:
            for line_num, line in enumerate(f, 1):
                original_line = line # Keep for error messages
                line = line.strip()
                # Remove comments (everything after '#' or ';')
                line = re.split(r'[#;]|//', line, 1)[0].strip()

                if not line:
                    continue # Skip empty lines

                # Check for segment directives
                parts = line.split()
                if len(parts) >= 2 and parts[0].upper() in SEGMENT_DIRECTIVES:
                    directive = parts[0].upper()
                    if directive == "CODE" and parts[1].upper() == "SEGMENT":
                        current_segment = "CODE"
                        continue
                    elif directive == "DATA" and parts[1].upper() == "SEGMENT":
                        current_segment = "DATA"
                        continue
                    elif directive == "END" and parts[1].upper() == "SEGMENT":
                        current_segment = None
                        continue

                # Require segment to be defined
                if current_segment is None:
                    raise ValueError(f"Instruction or data outside segment at line {line_num}")

                # Check for label definition (e.g., "loop:") possibly followed by instruction/data
                label_match = re.match(r'^([a-zA-Z_][a-zA-Z0-9_]*):\s*(.*)', line)
                label = None
                if label_match:
                    label = label_match.group(1)
                    line = label_match.group(2).strip() # Remainder of the line after label

                    if label in symbol_table:
                        raise ValueError(f"Duplicate label definition '{label}' at line {line_num}")
                    if label.upper() in OPCODES or label.upper() in PSEUDO_OPS or label.upper() in SEGMENT_DIRECTIVES:
                        raise ValueError(f"Label '{label}' conflicts with mnemonic/directive at line {line_num}")
                    
                    # Assign address based on current segment
                    if current_segment == "CODE":
                        symbol_table[label] = code_addr
                        print(f"  Found label '{label}' at code address {code_addr:02X}")
                    else:  # DATA segment
                        symbol_table[label] = data_addr
                        print(f"  Found label '{label}' at data address {data_addr:02X}")

                    if not line: # Line only contained a label
                        continue

                # Now process the rest of the line (or the whole line if no label)
                parts = line.split(maxsplit=1)
                mnemonic = parts[0].upper()
                operand_str = parts[1] if len(parts) > 1 else ""

                if mnemonic in OPCODES:
                    if current_segment != "CODE":
                        raise ValueError(f"Instructions must be in CODE segment at line {line_num}")
                    
                    if code_addr > CODE_END_ADDR:
                        raise ValueError(f"Code segment overflow at line {line_num}. Max address is {CODE_END_ADDR}")
                    
                    # Store instruction line for second pass
                    program_elements.append((line_num, 'instruction', line, "CODE"))
                    code_addr += 1 # Instructions take 1 word (address incremented)
                    
                elif mnemonic in PSEUDO_OPS:
                    if mnemonic == "DATA":
                        if current_segment != "DATA":
                            raise ValueError(f"DATA directive must be in DATA segment at line {line_num}")
                        
                        if data_addr > DATA_END_ADDR:
                            raise ValueError(f"Data segment overflow at line {line_num}. Max address is {DATA_END_ADDR}")
                        
                        if not operand_str:
                            raise ValueError(f"Missing value for DATA directive at line {line_num}")
                        try:
                            data_value = parse_value(operand_str, MAX_DATA_VAL, f"for DATA at line {line_num}")
                            program_elements.append((line_num, 'data', data_value, "DATA"))
                            data_addr += 1 # Data takes 1 word (address incremented)
                            print(f"  Found DATA {data_value} (0x{data_value:X}) at address {symbol_table.get(label, data_addr-1):02X}")
                        except ValueError as e:
                             raise ValueError(f"{e} (line {line_num})") from e

                    # Add other pseudo-ops here if needed (e.g., ORG, EQU)
                else:
                    raise ValueError(f"Unknown mnemonic or directive '{parts[0]}' at line {line_num}: {original_line.strip()}")


    except FileNotFoundError:
        print(f"Error: Input file not found: {input_filename}", file=sys.stderr)
        sys.exit(1)
    except ValueError as e:
        print(f"Error during first pass: {e}", file=sys.stderr)
        sys.exit(1)

    print(f"First Pass complete. Found {len(symbol_table)} labels.")
    print(f"Code segment size: {code_addr - CODE_START_ADDR} words")
    print(f"Data segment size: {data_addr - DATA_START_ADDR} words")
    print("Symbol Table:", symbol_table)

    # --- Second Pass: Generate Binary Code ---
    print("\nStarting Second Pass...")
    
    # Create memory map (fill with zeros initially)
    memory_map = [0] * (MAX_ADDR + 1)
    
    try:
        # Process code segment
        for line_num, element_type, element_data, segment in program_elements:
            if segment == "CODE":
                code_addr = program_elements.index((line_num, element_type, element_data, segment)) + CODE_START_ADDR
                if element_type == 'instruction':
                    line = element_data
                    parts = line.split(maxsplit=1)
                    mnemonic = parts[0].upper()
                    operand_str = parts[1] if len(parts) > 1 else ""

                    opcode_val = OPCODES[mnemonic]
                    addr_val = 0

                    if mnemonic in NO_OPERAND_INSTRUCTIONS:
                        if operand_str:
                            print(f"Warning: Operand '{operand_str}' ignored for instruction '{mnemonic}' at line {line_num}", file=sys.stderr)
                        addr_val = 0 # Default address field for HALT etc.
                    elif not operand_str:
                         raise ValueError(f"Missing operand for instruction '{mnemonic}' at line {line_num}")
                    else:
                        try:
                            # Pass current address for context in error messages
                            addr_val = parse_operand(operand_str, symbol_table, code_addr)
                        except ValueError as e:
                             # Add line number context if not already present
                             raise ValueError(f"{e} (line {line_num})") from e

                    # Combine opcode and address into a 16-bit instruction word
                    # Format: [OPCODE (8 bits)] [ADDRESS (8 bits)]
                    instruction_word = (opcode_val << ADDR_WIDTH) | addr_val
                    memory_map[code_addr] = instruction_word
                    print(f"  Addr {code_addr:02X}: {mnemonic:<8} {operand_str:<15} -> INST {instruction_word:0{INSTR_WIDTH//4}X} ({opcode_val:0{OPCODE_WIDTH//4}X} {addr_val:0{ADDR_WIDTH//4}X})")
        
        # Process data segment
        for line_num, element_type, element_data, segment in program_elements:
            if segment == "DATA":
                data_index = sum(1 for elem in program_elements if elem[3] == "DATA" and program_elements.index(elem) <= program_elements.index((line_num, element_type, element_data, segment)))
                data_addr = DATA_START_ADDR + data_index - 1
                
                if element_type == 'data':
                    data_value = element_data
                    memory_map[data_addr] = data_value
                    print(f"  Addr {data_addr:02X}: {'DATA':<8} {data_value:<15} -> DATA {data_value:0{DATA_WIDTH//4}X}")

        # --- Write Binary Output ---
        binary_code = bytearray()
        for word in memory_map:
            # Pack as little-endian 16-bit unsigned integer (2 bytes)
            packed_word = struct.pack('<H', word)
            binary_code.extend(packed_word)
        
        with open(output_filename, 'wb') as f:
            f.write(binary_code)
        print(f"\nSecond Pass complete. Successfully wrote {len(binary_code)} bytes ({len(binary_code)//2} words) to {output_filename}")
        print(f"Addresses 0x00-0x7F: Code segment")
        print(f"Addresses 0x80-0xFF: Data segment")
        
    except ValueError as e:
        print(f"Error during second pass: {e}", file=sys.stderr)
        sys.exit(1)
    except IOError as e:
        print(f"Error writing output file {output_filename}: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Assemble custom assembly language file to binary.")
    parser.add_argument("input_file", help="Path to the input assembly file (.asm)")
    parser.add_argument("output_file", help="Path for the output binary file (.bin)")
    args = parser.parse_args()

    assemble(args.input_file, args.output_file) 