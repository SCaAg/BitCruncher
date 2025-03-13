```
BitCruncher/
├── rtl/             # Verilog RTL (Register-Transfer Level) 源代码
│   ├── registers/    # 寄存器模块
│   │   ├── MAR.v       # 存储器地址寄存器 (MAR) 模块
│   │   ├── MBR.v       # 存储器缓冲寄存器 (MBR) 模块
│   │   ├── PC.v        # 程序计数器 (PC) 模块
│   │   ├── IR.v        # 指令寄存器 (IR) 模块
│   │   ├── ACC.v       # 累加器 (ACC) 模块
│   │   ├── BR.v        # 缓冲寄存器 (BR) 模块
│   ├── memory/       # 存储器模块
│   │   ├── Memory.v    # 存储器 (Memory) 模块
│   ├── alu/          # 算术逻辑单元模块
│   │   ├── ALU.v       # 算术逻辑单元 (ALU) 模块
│   ├── control_unit/ # 控制单元模块 (微程序控制)
│   │   ├── ControlUnitTop.v  # 控制单元 (CU) 模块，包含微程序控制器逻辑
│   │   ├── ControlUnit/
|   |   |   ├── # 具体内容参见COAreview27
│   ├── top/          # 顶层模块
│   │   ├── CPU_Top.v   # CPU 顶层模块，例化所有子模块并连接
│   └── common/       # 通用模块或定义 (如果需要)
│       ├── defines.v   # 参数定义、操作码定义等 (可选)
├── microprogram/   # 微程序相关文件
│   ├── microprogram.txt # 微程序存储器 CM 的初始化数据文件
├── sim/             # 仿真相关文件
│   ├── tb/          # Testbench 文件
│   │   ├── CPU_Top_tb.v # CPU 顶层模块的 Testbench
│   ├── scripts/     # 仿真脚本 (例如 ModelSim .do 脚本) (可选)
├── constraints/    # FPGA 约束文件 (UCF 或 XDC) (如果硬件实现)
│   ├── constraints.ucf  # 或 constraints.xdc (根据你的开发板)
├── doc/             # 文档目录
│   ├── CPU_DesignSpec.md # CPU 设计规范文档 (你提供的文档)
│   ├── README.md       # 项目 README 文件
└── proj/            # FPGA 工程文件 (例如 Vivado 工程) (可选)
```

文件职责详细划分：

1. rtl/registers/MAR.v

模块名: MAR

职责: 存储器地址寄存器模块。

功能： 接收地址数据输入 data_in，在 load_mar 控制信号有效时，将 data_in 加载到内部寄存器，并通过 data_out 输出存储的地址值。

宽度： 8-bit，用于寻址 256 字节的存储器。

输入： clk, rst, load_mar, data_in[7:0]

输出： data_out[7:0]

2. rtl/registers/MBR.v

模块名: MBR

职责: 存储器缓冲寄存器模块。

功能： 临时存储从存储器读取的数据，或将要写入存储器的数据。 可以接收 data_in 输入，在 load_mbr 控制信号有效时加载数据，通过 data_out 输出存储的数据。 通常是双向缓冲器，既可以接收来自 Memory 的数据，也可以输出数据到 Memory。

宽度： 16-bit，与存储器数据宽度一致。

输入： clk, rst, load_mbr, data_in[15:0]

输出： data_out[15:0]

3. rtl/registers/PC.v

模块名: PC

职责: 程序计数器模块。

功能： 存储下一条要执行的指令的地址。

操作： 可以被加载新地址 (load_pc)，可以自增 (increment_pc)，并通过 data_out 输出当前 PC 值。

宽度： 8-bit，可以寻址 256 字节的程序空间。

输入： clk, rst, load_pc, increment_pc, data_in[7:0] (加载 PC 时的数据源)

输出： data_out[7:0]

4. rtl/registers/IR.v

模块名: IR

职责: 指令寄存器模块。

功能： 存储当前正在执行的指令的操作码部分。

操作： 接收指令操作码 data_in，在 load_ir 控制信号有效时加载数据，并通过 opcode_out 输出存储的操作码。 可能也会输出整个指令字，或者地址段部分。

宽度： 操作码部分 8-bit (根据指令格式)。

输入： clk, rst, load_ir, data_in[7:0] (来自 MBR 的指令操作码部分)

输出： opcode_out[7:0]

5. rtl/registers/ACC.v

模块名: ACC

职责: 累加器模块。

功能： 用于算术和逻辑运算，作为 ALU 的一个操作数，并存储 ALU 的结果。

操作： 接收数据输入 data_in，在 load_acc 控制信号有效时加载数据，并通过 data_out 输出存储的累加器值。

宽度： 16-bit。

输入： clk, rst, load_acc, data_in[15:0]

输出： data_out[15:0]

6. rtl/registers/BR.v

模块名: BR

职责: 缓冲寄存器模块。

功能： 作为 ALU 的另一个输入操作数寄存器。

操作： 接收数据输入 data_in，在 load_br 控制信号有效时加载数据，并通过 data_out 输出存储的缓冲寄存器值。

宽度： 16-bit。

输入： clk, rst, load_br, data_in[15:0]

输出： data_out[15:0]

7. rtl/memory/Memory.v

模块名: Memory

职责: 外部存储器模块 (模拟)。

功能： 存储程序指令和数据。 提供读 (mem_read) 和写 (mem_write) 操作接口。

容量： 256 x 16-bit (可寻址 256 个 16-bit 字)。

接口： 接收地址 addr，数据输入 data_in (写操作)，输出数据 data_out (读操作)。

输入： clk, rst, mem_read, mem_write, addr[7:0], data_in[15:0]

输出： data_out[15:0]

8. rtl/alu/ALU.v

模块名: ALU

职责: 算术逻辑单元模块。

功能： 执行算术和逻辑运算，例如加法、减法、乘法、AND、OR、NOT、移位等。

操作： 接收两个操作数 operand_a, operand_b 和操作码 alu_op，根据 alu_op 选择执行相应的运算，并通过 alu_result 输出运算结果。

输入： operand_a[15:0], operand_b[15:0], alu_op[3:0] (或根据需要调整操作码宽度)

输出： alu_result[15:0]

9. rtl/control_unit/ControlUnit.v

模块名: ControlUnit

职责: 控制单元模块 (微程序控制器)。

功能： 负责生成所有控制信号，控制 CPU 的指令执行流程 (取指-译码-执行周期)。 基于微程序设计，从控制存储器读取微指令，并根据当前微指令、指令操作码、条件 (例如 ACC 状态) 决定下一条微指令的地址。

操作： 接收指令操作码 opcode (来自 IR) 和 ACC 的值 acc_value (用于条件跳转)，输出 32-bit 控制信号 control_signals，以及控制地址寄存器输出 car_out (可选，用于 debug)。

输入： clk, rst, opcode[7:0], acc_value[15:0]

输出： control_signals[31:0], car_out[7:0] (可选)

10. rtl/control_unit/ControlMemory.v

模块名: ControlMemory

职责: 控制存储器模块 (ROM)。

功能： 存储微程序。 根据控制地址寄存器 (CAR) 的地址输入 addr，输出对应的微指令 micro_instruction。

初始化： 从 microprogram.txt 文件加载微程序数据。

容量： 256 行 x 40-bit (或根据实际微程序大小调整)。

输入： addr[7:0] (来自 CAR)

输出： micro_instruction[39:0]

11. rtl/top/CPU_Top.v

模块名: CPU_Top

职责: CPU 顶层模块。

功能： 例化所有子模块 (寄存器、存储器、ALU、控制单元)，并将它们连接起来，构成完整的 CPU 系统。 负责处理顶层接口 (时钟、复位、外部接口 - 例如用于硬件验证的 LED, 数码管, 开关, 按键等)，以及定义 CPU 内部模块之间的连接关系 (数据通路、控制信号通路)。

输入： clk, rst, 以及可能的外部接口信号。

输出： 可能的外部接口信号 (例如 LED, 数码管)，以及 debug 用的内部信号输出 (用于仿真观察)。

内部： 例化 MAR, MBR, PC, IR, ACC, BR, Memory, ALU, ControlUnit 等模块，并进行信号连接。

12. rtl/common/defines.v (可选，如果使用)

模块名: defines (通常不使用 module 关键字，而是直接定义 parameters 和 `define 宏)

职责: 定义全局使用的常量、参数、操作码、状态编码等。 方便统一管理和修改这些定义。

例如： 操作码定义 (parameter STORE_OPCODE = 8'b00000001;)，ALU 操作码定义 (parameter ADD_OP = 4'b0000;)，微程序状态地址定义 (parameter FETCH_START_ADDRESS = 8'h00;) 等等。

13. microprogram/microprogram.txt

文件类型: 文本文件

职责: 存储控制存储器 ControlMemory 的初始化数据，即微程序本身。

格式： 每行表示一条微指令，用 16 进制表示。 微指令的格式需要与 ControlMemory.v 模块中定义的 micro_instruction 格式一致 (例如 40-bit 微指令，其中前 32-bit 是控制信号，后 8-bit 是下一微指令地址)。

14. sim/tb/CPU_Top_tb.v

模块名: CPU_Top_tb

职责: CPU 顶层模块的 Testbench 文件。

功能： 用于对 CPU_Top.v 模块进行仿真验证。

操作： 例化 CPU_Top 模块，提供时钟、复位信号，加载测试程序到 Memory 模块中，驱动输入信号 (如果有)，并监测输出信号和内部信号，以验证 CPU 的功能是否正确。

15. sim/scripts/ (可选)

目录: 仿真脚本目录

文件: 例如 sim/scripts/run_sim.do (ModelSim 仿真脚本)。

职责: 存储仿真运行脚本，自动化仿真流程，例如编译 Verilog 文件，加载 Testbench，设置波形观察，运行仿真等。

16. constraints/constraints.ucf 或 constraints.xdc

文件类型: 约束文件 (UCF - User Constraints File 或 XDC - Xilinx Design Constraints)

职责: 用于硬件实现 (FPGA 下载) 时，对设计进行约束，例如指定时钟频率，绑定顶层模块的输入输出端口到 FPGA 开发板的特定引脚 (例如 LED, 开关, 按键端口)，进行时序约束等。 具体的文件类型和内容取决于你使用的 Xilinx 开发板和开发工具。

17. doc/CPU_DesignSpec.md 和 doc/README.md

目录: 文档目录

文件: CPU_DesignSpec.md (CPU 设计规范文档，即你提供的文档) 和 README.md (项目 README 文件)。

职责: 存储项目相关的文档，例如设计规范、README 说明文件、设计文档等。 README.md 文件通常包含项目简介、文件结构说明、编译仿真运行指南、硬件实现说明等信息。

18. proj/ (可选)

目录: FPGA 工程目录 (例如 Vivado 工程)。

文件: 例如 cpu_project.xpr (Vivado 工程文件)。

职责: 如果使用 FPGA 进行硬件实现，则包含 FPGA 工程文件，用于管理 FPGA 工程，包括添加 Verilog 源代码、约束文件、设置编译选项、生成比特流、下载到 FPGA 开发板等。

总结:

这个文件目录结构和职责划分旨在清晰地组织 Verilog CPU 项目的各个部分，模块化设计有助于代码维护、理解和复用。 你可以根据实际情况进行调整，例如如果 common/ 目录不需要，可以省略。 关键是保持结构清晰，方便后续的开发、仿真和硬件验证工作。
