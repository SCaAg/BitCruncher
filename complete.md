# CPU设计 

■ 此部分要求设计一个简单的CPU。该CPU拥有基本的指令集，并且能够使用指令集运行简单的程序。另外，CPU的控制器部分（CU）要求必须采用微程序设计方式。

# CPU结构 

■ 取指：CPU要从存储器中读取指令。
■ 译码：翻译指令用以确定要执行的操作。
■ 取数据：指令执行可能会要求从存储器或I/O模块中读取数据。
■ 处理数据：指令执行可能会要求对数据进行算术或逻辑运算操作。
■ 写数据：指令执行的结果可能需要写入存储器或者I/O模块中。

系统时钟
CPU操作

# 设计架构 

## 外部存储器

![img-5.jpeg](images/img-5.jpeg.png)

# 0-CPU指令 

- 本课程中，采用单地址的指令集结构。指令字包括两部分：
■操作码（OPCODE），用来定义指令的功能；

■地址段(Address Part)，用来存放要被操作的指令的地址，称之为直接寻址（Direct Addressing）。

- 以 16 位 处 理 器 为 例，假 设 内 存 的 大 小 为 256*16Bits。
■每个指令字有 16 比特，其中操作码 8 位，地址段 8 位。
■最大256条指令或数据。

| OPCODE | ADDRESS |
| :--: | :--: |
| $[15 . .8]$ | $[7 . .0]$ |

# 0-CPU指令集 

| INSTRUCTION | OPCODE | COMMENTS |
| :--: | :--: | :--: |
| STORE X | 00000001 | $\mathrm{ACC} \rightarrow[\mathrm{X}]$ |
| LOAD X | 00000010 | $[\mathrm{X}] \rightarrow \mathrm{ACC}$ |
| ADD X | 00000011 | $\mathrm{ACC}+[\mathrm{X}] \rightarrow \mathrm{ACC}$ |
| SUB X | 00000100 | $\mathrm{ACC}-[\mathrm{X}] \rightarrow \mathrm{ACC}$ |
| JMPGEZ X | 00000101 | If ACC $\geq 0$ then $\mathrm{X} \rightarrow \mathrm{PC}$ else $\mathrm{PC}+1 \rightarrow \mathrm{PC}$ |
| JMP X | 00000110 | $\mathrm{X} \rightarrow \mathrm{PC}$ |
| HALT | 00000111 | Halt a program |
|  |  |  |
| MPY X | 00001000 | $\mathrm{ACC} \times[\mathrm{X}] \rightarrow$ MR, ACC |
|  |  |  |
|  |  |  |
| AND X | 00001010 | ACC and $[\mathrm{X}] \rightarrow \mathrm{ACC}$ |
| OR X | 00001011 | ACC or $[\mathrm{X}] \rightarrow \mathrm{ACC}$ |
| NOT X | 00001100 | NOT $[\mathrm{X}] \rightarrow \mathrm{ACC}$ |
| SHIFTR | 00001101 | SHIFT [X] to Right 1bit, Logic Shift |
| SHIFTL | 00001110 | SHIFT [X] to Left 1bit, Logic Shift |
|  |  |  |

# 0-CPU微指令 

系统时钟
指令流程
微指令步骤
![img-6.jpeg](images/img-6.jpeg.png)

## ![img-7.jpeg](images/img-7.jpeg.png)

## 电子微指令对应一台控制信号

系统相应的微指令

# 0-基于微控制器的CPU内部接构 

![img-8.jpeg](images/img-8.jpeg.png)

# 1-CPU内部容存器 

■ MAR (Memory Address Register)

- MAR存放着要从存储器中读取或要写入存储器的存储器地址。
- 此处，"读"定义为CPU从内存中读。"写"定义为CPU把数据写入内存。
- 本课程的设计中，MAR拥有 8 比特，可以存取 256 个地址。
![img-9.jpeg](images/img-9.jpeg.png)

# 1-CPU内部容存器 

- MBR（Memory Buffer Register）
- MBR存储着将要被存入内存或者最后一次从内存中读出来的数值。
- 本课程的设计中，MBR有16比特。

■ PC（Program Counter）
■ PC 寄存器用来跟踪程序中将要使用的指令。
・本课程中，PC有 8 比特。
![img-10.jpeg](images/img-10.jpeg.png)

# 1-CPU内部寄存器 

■ IR(Instruction Register)

- IR存放指令的OPCODE（操作码）部分
- 本课程中，IR有8比特

■BR(Buffer Register)
![img-11.jpeg](images/img-11.jpeg.png)

- BR作为ALU的一个输入，存放着ALU的一个操作数
- ALU另一个操作数暂存在ACC中
- 本课程中,BR有16比特

# 1-CPU内部容存器 

## - ACC (Accumulator)

- ACC保存着ALU的另一个操作数，也可以存放着ALU的计算结果。本课程中，ACC有16比特。
![img-12.jpeg](images/img-12.jpeg.png)

# 2-CPU运算器揭单元ALU 

- ALU是用来执行算术和逻辑操作的单元。几乎所有的操作都是将相应的数据带到 ALU来进行处理，然后把结果取出。 Table 3 ALU Operations

| Operations | Explanations |
| :--: | :--: |
| ADD | $(\mathrm{ACC}) \leftrightharpoons(\mathrm{ACC})+(\mathrm{BR})$ |
| SUB | $(\mathrm{ACC}) \leftrightharpoons(\mathrm{ACC})-(\mathrm{BR})$ |
| AND | $(\mathrm{ACC}) \leftrightharpoons(\mathrm{ACC})$ and $(\mathrm{BR})$ |
| OR | $(\mathrm{ACC}) \leftrightharpoons(\mathrm{ACC})$ or $(\mathrm{BR})$ |
| NOT | $(\mathrm{ACC}) \leftrightharpoons$ Not (ACC) |
| SRL | $(\mathrm{ACC}) \leftrightharpoons$ Shift (ACC) to Left 1 bit |
| SRR | $(\mathrm{ACC}) \leftrightharpoons$ Shift (ACC) to Right 1 bit |

# 3-CPU指令的微程序控制单元 

■ CPU指令集中的各个指令，对应着各自不同的步骤，每步骤都有相应的微操作（微指令）。这些微操作的控制信号，由被称之为控制单元（CU）的模块产生。

指令的微指令控制器
![img-13.jpeg](images/img-13.jpeg.png)

# 3-微程序控制器设计 

- 控制器的控制存储器（CM）中存放有每一个指令对应的微程序，微程序包含若干行，每行都是一个微指令。0和1代表着断和通。对每一个微指令而言，控制器做的就是生成一系列控制信号来控制相关寄存器的操作。
- 控制地址寄存器（CAR）控制着下面要读取哪一条微指令，也就是读取哪一个地址，从CM中读取了一条微指令就相当于执行了若干个控制信号。

# 3-控制器内部结构 

![img-14.jpeg](images/img-14.jpeg.png)

# 3-微程序接制器设计 

![img-15.jpeg](images/img-15.jpeg.png)

# 3-微管序接和接制信号 

Table 4 Some Control signals for the LOAD instruction

| Bit in Control Memory | Micro-opentition | Meaning |
| :--: | :--: | :-- |
| C0 | CAR $<=$ CAR +1 | Control Address Increment |
| C1 | CAR $<=* * *$ | Control Address Redirection, depends on <br> the position of microinstruction |
| C2 | CAR $<=0$ | Reset Control Address to zero position |
| C3 | MBR $<=$ memory | Memory Content to MBR |
| C4 | IR $<=$ MBR[15..8] | Copy MBR[15..8] to IR for OPCODE |
| C5 | MAR $<=$ MBR[7..0] | Copy MBR[7..0] to MAR for address |
| C6 | PC $<=$ PC +1 | Increment PC for indicating position |
| C7 | BR $<=$ MBR | Copy MBR data to BR for buffer to ALU |
| C8 | ACC $<=0$ | Reset ACC register to zero |
| C9 | ACC $<=$ ACC +BR | Add BR to ACC |
| C10 | MAR $<=$ PC | Copy PC value to MAR for next address |
| $\ldots$ | $\ldots \ldots$ | $\ldots \ldots$ |

# 接制器设计-Load指令为例 

- 根据CPU的结构和具体设计来决定实际需要的控制信号，下面给出一个例子用来体现该过程。该例是LOAD指令的设计。
![img-16.jpeg](images/img-16.jpeg.png)

LOAD X：[X] ->ACC：地址X中存储的数据放入ACC寄存器

# Load指令的微操作 

## 系统时钟

微指令
（Load为例）
微操作
（Load为例）
![img-17.jpeg](images/img-17.jpeg.png)

# Load括令的微控制信号 

系统时钟
![img-18.jpeg](images/img-18.jpeg.png)

微操作
（加法为例）

| 从外部存储器 <br> 取指令 | 从指令中 <br> 取操作码 | 从操作码 <br> 取微代码入口 | 从指令中 <br> 取操作数地址 | 从外部存储器 <br> 取操作数 | 准备ALU操作数 <br> BR和ACC | ALU运算 | 下一条指令 <br> 复位微代码段 |
| :--: | :--: | :--: | :--: | :--: | :--: | :--: | :--: |

![img-19.jpeg](images/img-19.jpeg.png)

MBR<=Memory
CAR $<=$ CAR +1
CAR $<=" * *$
MBR<=Memory
CAR $<=$ CAR +1

Table 4 Some Control signals for the LOAD instruction

| Bit in Control Memory | Micro-operation | Meaning |
| :--: | :--: | :-- |
| C0 | $\mathrm{CAR}<=\mathrm{CAR}+1$ | Control Address Increment |
| C1 | $\mathrm{CAR}<=^{+++}$ | Control Address Redirection, depends on <br> the position of microinstruction |
| C2 | $\mathrm{CAR}<=0$ | Reset Control Address to zero position |
| C3 | $\mathrm{MBR} \Rightarrow$ memory | Memory Content to MBR |
| C4 | $\mathrm{IR} \Rightarrow \mathrm{MBR}[15 . .8]$ | Copy MBR[15..8] to IR for OPCODE |
| C5 | $\mathrm{MAR} \Longleftrightarrow \mathrm{MBR}[7 . .0]$ | Copy MBR[7..0] to MAR for address |
| C6 | $\mathrm{PC} \Rightarrow \mathrm{PC}+1$ | Increment PC for indicating position |
| C7 | $\mathrm{BR} \Longleftrightarrow \mathrm{MBR}$ | Copy MBR data to BR for buffer to ALU |
| C8 | $\mathrm{ACC} \Rightarrow 0$ | Reset ACC register to zero |
| C9 | $\mathrm{ACC} \Longleftrightarrow \mathrm{ACC}+\mathrm{BR}$ | Add BR to ACC |
| C10 | $\mathrm{MAR} \Longleftrightarrow \mathrm{PC}$ | Copy PC value to MAR for next address |
| ... | ... | ... |

Table 5 Microprogram for LOAD instruction

| Microprogram | Control signals |
| :-- | :-- |
| MBR $=$ memory, CAR $=\mathrm{CAR}+1$ | C3, C0 |
| IR $=\mathrm{MBR}[15.8]$, CAR $=\mathrm{CAR}+1$ | C4, C0 |
| CAR $<=* * *\left({ }^{* * *}\right.$ is determined by OPCODE) | C1 |
| MAR $=\mathrm{MBR}[7.0]$, PC $=\mathrm{PC}+1, \mathrm{CAR} \Rightarrow \mathrm{CAR}+1$ | C5, C6, C0 |
| MBR $=$ memory, CAR $=\mathrm{CAR}+1$ | C3, C0 |
| BR $=\mathrm{MBR}, \mathrm{ACC} \Rightarrow 0, \mathrm{CAR} \Rightarrow \mathrm{CAR}+1$ | C7, C8, C0 |
| ACC $=\mathrm{ACC}+\mathrm{BR}, \mathrm{CAR} \Rightarrow \mathrm{CAR}+1$ | C9, C0 |
| MAR $=\mathrm{PC}, \mathrm{CAR} \Leftrightarrow 0$ | C10,C2 |

# CPU设计要求（1） 

- 独立设计微程序控制器及外围的各寄存器。
- 要求完成并支持上述基本指令集列出的所有指令。
- 使用实验指导书中的1+2+...+100和相应的乘法例子来验证程序的正确性与完整性。
- CPU设计要求仿真和硬件下载都需要验证。
- 下载硬件采用Xilinx开发板。可以使用按键、开关、LED灯、数码管等配合控制与显示。

题目示例

| CPU验收 |  |  |  |
| :-- | :-- | :-- | :-- |
| 姓名 |  |  |  |
| 电话 |  |  |  |
| 眉目 | 计算 $((2+4+6+\cdots \cdots+20) \times(-12)$ SHL 1Bit) AND $(1+2+\cdots \cdots+40)$ |  |  |
| 理论值 |  |  |  |
| 软件前仿真值 |  |  |  |

# CPU设计要求（2） 

- 2人一组，合作完成。每人需掌握全部设计内容。报告包含设计思路、程序框架、问题及解决方案。
- 实验内容需现场验收。
- 可根据需要增加必要的指令或寄存器。
- 可自定义控制信号。
- 必须采用微程序方式设计控制器，否则不予通过
- 报告于验收完成后三天内提交。

# CPU设计要求（3） 

- 实验报告格式要求:
- COA-CPU报告-学号1-姓名1-学号2-姓名2.zip。其中学号与姓名用自己的替代；中间连字符号-为英文中划线连字符
- 文件格式为：压缩文件（zip/tar/7z...），其中需要包含： (1)实验报告；(2)源代码；(3)仿真激励文件与结果 等文件
- 实验报告通过校园网盘提交：
- https://pan.seu.edu.cn:443/link/361249714F46C2107EF14E1F1ADF89A6
- 有效期限：2026-01-27
- 访问密码：neJ0