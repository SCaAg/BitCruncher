Begin of every microcode:

1. $t_1$ MBR <- Mem[MAR]/$C_3$
2. $t_2$ IR <- MBR/$C_4$
3. $t_3$ MAR <- MBR/$C_5$
   $t_3$ PC <- PC + 1/$C_6$
---
For every instruction:

- LOAD X
    - $t_4$ MBR <- Mem[MAR]/$C_3$
    - $t_5$ BR <- MBR/$C_7$
    - $t_5$ ACC <- 0/$C_8$
    - $t_6$ ACC <- ACC + BR/$C_9$

- STORE X
    - $t_4$ MBR <- ACC/$C_{12}$
    - $t_5$ Mem[MAR] <- MBR/$C_{11}$

- ADD X
    - $t_4$ MBR <- Mem[MAR]/$C_3$
    - $t_5$ BR <- MBR/$C_7$
    - $t_6$ ACC <- ACC + BR/$C_9$

- SUB X
    - $t_4$ MBR <- Mem[MAR]/$C_3$
    - $t_5$ BR <- MBR/$C_7$
    - $t_6$ ACC <- ACC - BR/$C_{13}$

- MUL X 
    - $t_4$ MBR <- Mem[MAR]/$C_3$
    - $t_5$ BR <- MBR/$C_7$
    - $t_6$ ACC <- ACC * BR/$C_{15}$

- DIV X
    - $t_4$ MBR <- Mem[MAR]/$C_3$
    - $t_5$ BR <- MBR/$C_7$
    - $t_6$ ACC <- ACC / BR/$C_{16}$

- SHL X
    - $t_4$ MBR <- Mem[MAR]/$C_3$
    - $t_5$ BR <- MBR/$C_7$
    - $t_6$ ACC <- ACC << BR/$C_{17}$

- SHR X
    - $t_4$ MBR <- Mem[MAR]/$C_3$
    - $t_5$ BR <- MBR/$C_7$
    - $t_6$ ACC <- ACC >> BR/$C_{18}$

- AND X
    - $t_4$ MBR <- Mem[MAR]/$C_3$
    - $t_5$ BR <- MBR/$C_7$
    - $t_6$ ACC <- ACC & BR/$C_{19}$

- OR X
    - $t_4$ MBR <- Mem[MAR]/$C_3$
    - $t_5$ BR <- MBR/$C_7$
    - $t_6$ ACC <- ACC | BR/$C_{20}$



- NOT X
    - $t_4$ MBR <- Mem[MAR]/$C_3$
    - $t_5$ BR <- MBR/$C_7$
    - $t_6$ ACC <- ~BR/$C_{21}$



- JMP X
    - $t_4$ MBR <- Mem[MAR]/$C_3$
    - $t_5$ PC <- MBR/$C_{14}$

- JZ X
    - if(ZF==1)
        - $t_4$ MBR <- Mem[MAR]/$C_3$
        - $t_5$ PC <- MBR/$C_{14}$

- JNZ X
    - if(ZF==0)
        - $t_4$ MBR <- Mem[MAR]/$C_3$
        - $t_5$ PC <- MBR/$C_{14}$

- HALT
    - $t_4$ PC <- PC/$C_{15}$

- XOR X
    - $t_4$ MBR <- Mem[MAR]/$C_3$
    - $t_5$ BR <- MBR/$C_7$
    - $t_6$ ACC <- ACC ^ BR/$C_9$

---
End of every microcode:

1. $t_{end}$ PC <- MAR/$C_{10}$


    

---
Other micro control signals:

- $C_1$ CAR <- CAR+1
- $C_2$ CAR<={?} | Control Address Redirection, depends on the position of microinstruction
- $C_3$ CAR <- 0
