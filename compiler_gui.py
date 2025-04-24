# compiler_gui.py
import streamlit as st
import subprocess
import tempfile
import os
import time # To create unique output filenames
import shlex # Better command splitting

# --- Configuration ---
# !!! IMPORTANT: Change this command to match your assembler !!!
# Use placeholders {input_file} and {output_file}
COMPILER_COMMAND_TEMPLATE = "python ./assembler.py {input_file} {output_file}"
OUTPUT_FILE_EXTENSION = ".bin" # Adjust if your compiler creates different output (e.g., ".o", ".hex")

# --- Flashing Configuration ---
# Using -eval with semicolon-separated commands
# Note the quoting: Outer quotes for -eval arg, inner escaped quotes for the path
FLASH_COMMAND_TEMPLATE = "xsct.bat -eval \"connect; target 3; dow -data 0xC0000000 \\\"{bin_file}\\\"; exit\""
# Path conversion to forward slashes might still be safer for Tcl inside -eval

# --- Default Code ---
DEFAULT_ASM_CODE = """
// Simple program example
// Add your assembly code here

start:
    LOAD    val1      // Load value from val1 address into ACC
    ADD     val2      // Add value from val2 address to ACC
    STORE   result    // Store ACC content to result address
    HALT              // Halt execution

// --- Data Section ---
val1:      DATA 5      // Define data value 5 at address val1
val2:      DATA 10     // Define data value 10 at address val2
result:    DATA 0      // Reserve space for the result, initialized to 0
"""

# --- Initialize Session State --- (Ensure these keys exist)
if 'asm_code' not in st.session_state:
    st.session_state.asm_code = DEFAULT_ASM_CODE
if 'output_bin_path' not in st.session_state:
    st.session_state.output_bin_path = None
if 'flash_triggered' not in st.session_state: # To track if flash button was clicked
    st.session_state.flash_triggered = False

# --- Streamlit App UI ---
st.set_page_config(layout="wide", page_title="Simple Compiler & Flasher GUI")

st.title("🖥️ Simple Assembler & Flasher GUI")
st.caption("Compile your assembly code and flash it to the device.")

# Add some spacing and explanation
st.info(f"""
**Instructions:**
1.  Enter your assembly code.
2.  Click **Compile**.
3.  If successful, a **Download** button and a **Flash to Device** button will appear.
4.  Click **Flash to Device** to connect, set target, and download the binary using `xsct.bat -eval`.

**Compiler Command:** `{COMPILER_COMMAND_TEMPLATE.format(input_file='[your_code.asm]', output_file='[output.bin]')}`
**Note:** Commands run on the server hosting this app. Ensure tools (`python`, `xsct.bat`) are in the PATH.
""")

st.markdown("---")

# Use columns for layout
col1, col2 = st.columns(2)

with col1:
    st.header("Assembly Code Input")
    asm_code = st.text_area("Enter Assembly Code:", height=400, key="asm_code", label_visibility="collapsed")

with col2:
    st.header("Compilation & Flashing")
    compile_button = st.button("Compile ✨", use_container_width=True)

    # Compilation Output Area
    st.subheader("Compilation Output")
    compile_output_placeholder = st.empty() # Placeholder for compile status messages
    compile_stdout_expander = st.expander("Compiler Standard Output (stdout)", expanded=False)
    compile_stderr_expander = st.expander("Compiler Standard Error / Logs (stderr)", expanded=True)
    download_placeholder = st.empty() # Placeholder for download button

    # Flashing Area - Initially hidden, shown on successful compile
    flash_ui_placeholder = st.empty() # Container for flash button and output

# --- Compilation Logic --- (Runs when Compile button is clicked)
if compile_button:
    # Reset state for flash and previous output when compiling again
    st.session_state.output_bin_path = None
    st.session_state.flash_triggered = False
    download_placeholder.empty()
    flash_ui_placeholder.empty() # Clear previous flash UI
    compile_output_placeholder.empty()
    compile_stdout_expander.empty()
    compile_stderr_expander.empty()

    if not asm_code.strip():
        compile_output_placeholder.warning("⚠️ Please enter some assembly code.")
    else:
        compile_output_placeholder.info("⏳ Compiling...")
        input_filename = None
        output_filename = None
        compile_process = None

        try:
            # Create temp input file in current directory
            with tempfile.NamedTemporaryFile(mode='w+', suffix='.asm', delete=False, encoding='utf-8', dir='.') as temp_input_file:
                input_filename = temp_input_file.name
                temp_input_file.write(asm_code)
                # File is closed automatically here

            output_filename = f"output_{int(time.time())}{OUTPUT_FILE_EXTENSION}"
            compile_command = COMPILER_COMMAND_TEMPLATE.format(
                input_file=input_filename,
                output_file=output_filename
            )

            # Use shlex.split for safer command splitting, especially on Windows
            compile_args = shlex.split(compile_command, posix=False) # Use Windows-style splitting if needed

            compile_stdout_expander.text(f"Running command: {' '.join(compile_args)}")
            compile_stderr_expander.text("")

            compile_process = subprocess.run(
                compile_args,
                capture_output=True,
                text=True,
                timeout=30,
                check=False
            )

            compile_stdout_expander.code(compile_process.stdout or "(No standard output)", language=None)
            compile_stderr_expander.code(compile_process.stderr or "(No standard error)", language=None)

            if compile_process.returncode == 0:
                compile_output_placeholder.success("✅ Compilation Successful!")
                # Store path for flashing and download
                st.session_state.output_bin_path = os.path.abspath(output_filename) # Store absolute path

                # Offer download immediately
                try:
                    with open(output_filename, "rb") as fp:
                        download_placeholder.download_button(
                            label=f"Download {os.path.basename(output_filename)}",
                            data=fp,
                            file_name=f"compiled_output{OUTPUT_FILE_EXTENSION}",
                            mime="application/octet-stream",
                            use_container_width=True,
                            key="download_button"
                        )
                except FileNotFoundError:
                    compile_stderr_expander.error(f"Error: Output file '{output_filename}' not found after successful compilation.")
                    st.session_state.output_bin_path = None # Invalidate path
                except Exception as e:
                    compile_stderr_expander.error(f"Error reading output file for download: {e}")
                    st.session_state.output_bin_path = None # Invalidate path
            else:
                compile_output_placeholder.error(f"❌ Compilation Failed (Return Code: {compile_process.returncode})")
                compile_stderr_expander.error("Compilation failed. Check compiler stderr.")
                st.session_state.output_bin_path = None # Clear path on failure

        except FileNotFoundError:
            compile_output_placeholder.error("❌ Error: Compiler command not found.")
            compile_stderr_expander.error(f"Could not find command: '{compile_args[0] if 'compile_args' in locals() else COMPILER_COMMAND_TEMPLATE.split()[0]}'. In PATH?")
            st.session_state.output_bin_path = None
        except subprocess.TimeoutExpired:
            compile_output_placeholder.error("❌ Error: Compilation timed out.")
            compile_stderr_expander.error("Compilation took too long.")
            st.session_state.output_bin_path = None
        except Exception as e:
            compile_output_placeholder.error(f"❌ Compilation Error: {e}")
            compile_stderr_expander.error(str(e))
            st.session_state.output_bin_path = None
        finally:
            # Clean up temporary input file
            if input_filename and os.path.exists(input_filename):
                try:
                    os.remove(input_filename)
                except OSError as e:
                    compile_stderr_expander.warning(f"Could not delete temp input file: {input_filename}. Error: {e}")
            # Output file is kept if compilation succeeded (for download/flash), else deleted
            if output_filename and os.path.exists(output_filename):
                if compile_process is None or compile_process.returncode != 0:
                    try:
                        os.remove(output_filename)
                    except OSError as e:
                         compile_stderr_expander.warning(f"Could not delete temp output file: {output_filename}. Error: {e}")


# --- Flashing UI and Logic --- (Runs on every rerun if bin path is set)
if st.session_state.output_bin_path and os.path.exists(st.session_state.output_bin_path):
    # Use the placeholder established earlier in col2
    with flash_ui_placeholder.container():
        st.markdown("---")
        st.subheader("Device Flashing")

        flash_button = st.button("Flash to Device ⚡", use_container_width=True, key="flash_button")
        flash_output_placeholder = st.empty()
        flash_stdout_expander = st.expander("Flasher Standard Output (stdout)", expanded=False)
        flash_stderr_expander = st.expander("Flasher Standard Error / Logs (stderr)", expanded=True)

        # If flash button was clicked in this run
        if flash_button:
            st.session_state.flash_triggered = True # Mark that flash was initiated
            flash_output_placeholder.info("⏳ Flashing device...")
            flash_stdout_expander.text("") # Clear previous
            flash_stderr_expander.text("") # Clear previous

            bin_file_path = st.session_state.output_bin_path
            flash_process = None

            try:
                # Convert path to forward slashes (often safer for Tcl/xsct)
                tcl_safe_bin_path = bin_file_path.replace('\\', '/')

                # Format the flash command string using -eval
                flash_command = FLASH_COMMAND_TEMPLATE.format(bin_file=tcl_safe_bin_path)

                # Use shlex.split for safer command splitting
                # Important: shlex might struggle with complex nested quotes needed for -eval.
                # Consider passing the command as a list if shlex causes issues.
                # For now, trying shlex first.
                flash_args = shlex.split(flash_command, posix=False) # Use Windows splitting
                # If the above fails due to quoting, construct the list manually:
                # flash_args = ['xsct.bat', '-eval', f'connect; target 3; dow -data 0xC0000000 "{tcl_safe_bin_path}"; exit']

                flash_stdout_expander.text(f"Running command: {' '.join(flash_args)}")
                # Example of manual list construction if needed:
                # flash_stdout_expander.text(f"Running command: {flash_args}") 

                flash_process = subprocess.run(
                    flash_args,
                    capture_output=True,
                    text=True,
                    timeout=60, # Longer timeout for flashing?
                    check=False
                )

                flash_stdout_expander.code(flash_process.stdout or "(No standard output)", language=None)
                flash_stderr_expander.code(flash_process.stderr or "(No standard error)", language=None)

                if flash_process.returncode == 0:
                    flash_output_placeholder.success("✅ Flashing Successful!")
                else:
                    flash_output_placeholder.error(f"❌ Flashing Failed (Return Code: {flash_process.returncode})")
                    flash_stderr_expander.error("Flashing failed. Check flasher stderr.")

            except FileNotFoundError:
                flash_output_placeholder.error("❌ Error: Flashing command not found.")
                cmd_name = 'xsct.bat'
                if 'flash_args' in locals() and flash_args:
                    cmd_name = flash_args[0]
                flash_stderr_expander.error(f"Could not find command: '{cmd_name}'. In PATH?")
            except subprocess.TimeoutExpired:
                flash_output_placeholder.error("❌ Error: Flashing timed out.")
                flash_stderr_expander.error("Flashing took too long.")
            except Exception as e:
                flash_output_placeholder.error(f"❌ Flashing Error: {e}")
                flash_stderr_expander.error(str(e))
            finally:
                # No temporary Tcl script to delete
                # Keep the .bin file
                pass

# Clear flash UI if compile button was pressed (handled at the start of compile logic)
# Or if the bin file somehow disappeared
elif not os.path.exists(st.session_state.output_bin_path or ""):
     st.session_state.output_bin_path = None # Clear invalid path
     flash_ui_placeholder.empty() # Ensure flash UI is hidden if file disappears

# Add a footer or separator
st.markdown("---")
st.caption("Streamlit Compiler & Flasher GUI") 