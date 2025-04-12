## 指令集
![[Pasted image 20250321150625.png]]

## 控制信号表
| Bits | Micro-operation  | Meaning                                                                  |
| ---- | ---------------- | ------------------------------------------------------------------------ |
| C0   | CAR ← CAR + 1    | Control Address Increment                                                |
| C1   | CAR ← ***        | Control Address Redirection, depends on the position of microinstruction |
| C2   | CAR ← 0          | Reset Control Address to zero position                                   |
| C3   | MBR ← memory     | Memory Content to MBR                                                    |
| C4   | IR ← MBR[15:8]   | Copy MBR[15:8] to IR for OPCODE                                          |
| C5   | PC ← MBR[7:0]    | Increment PC for indicating position                                     |
| C6   | PC ← PC + 1      | (Meaning not fully clear in the image, possibly “Increment PC”)          |
| C7   | BR ← MBR         | Copy MBR to BR for buffer to ALU                                         |
| C8   | ACC ← 0          | Reset ACC register to zero                                               |
| C9   | ACC ← ACC + BR   | Add BR to ACC, it can be used for LOAD                                   |
| C10  | MAR ← PC         | Copy PC value to MAR for next address                                    |
| C11  | memory ← MBR     | MBR to Memory Content                                                    |
| C12  | MBR ← ACC        | Copy PC value to MBR for calculate result                                |
| C13  | ACC ← ACC - BR   | Sub BR to ACC                                                            |
| C14  | PC ← MBR[7:0]    | Increment PC for indicating position                                     |
| C15  | ACC ← ACC × BR   | Mul BR to ACC                                                            |
| C16  | ACC ← ACC / BR   | Div BR to ACC                                                            |
| C17  | ACC ← ACC >>>    | Logic shift right                                                        |
| C18  | ACC ← ACC <<<    | Logic shift left                                                         |
| C19  | ACC ← ACC and BR | AND                                                                      |
| C20  | ACC ← ACC or BR  | OR                                                                       |
| C21  | ACC ← not ACC    | NOT                                                                      |
| C22  | ACC Enable       | Enable ALU   to write back to ACC register                                 |
