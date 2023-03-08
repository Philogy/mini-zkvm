# Mini zkVM

## Model

This zkVM is a simple register machine with 4 registers. The VM has no persistent state and does all
computation on the 4 registers. The program's input is the initial state of the 4 registers and the
output is the final state of these registers. Execution steps are limited to `MAX_TRACE_LENGTH` and
program size is limited to `MAX_PROGRAM_LENGTH`.

## Instruction Set
Every instruction in a program consits of the 8-bit serialization of the opcode and a complementary
field value `V`, `V` is used for certain instructions such as e.g. `SET`, `JUMP` or `JGT` to provide
a direct value / constant in the program.

### Registers

Register|Selector Bits
--------|-------------
R1|00
R2|01
R3|10
R4|11

### Op Codes
OP Serialization (8-bits) |Name|Effect
-------|----|-----
`0000 <r1> <r2>`|ADD  |`R1 = $r1 + $r2`
`0001 <r1> <r2>`|SUB  |`R1 = $r1 - $r2`
`0010 <r1> <r2>`|MUL  |`R1 = $r1 * $r2`
`0011 <r1> <r2>`|DIV  |`R1 = $r1 / $r2`
`0100 [00] <r1>`|ADD1 |`R1 = $r1 + V`
`0101 [00] <r1>`|SUB1 |`R1 = $r1 - V`
`0101 [01] <r1>`|RSUB1|`R1 = V - $r1`
`0110 [00] <r1>`|MUL  |`R1 = $r1 * V`
`0111 [00] <r1>`|DIV1 |`R1 = $r1 / V`
`0111 [01] <r1>`|RDIV1|`R1 = V / $r1`
`1000 <r1> <r2>`|SWAP |`R[r1] = $r2; R[r2] = $r1`
`1001 <r1> <r2>`|COPY |`R[r1] = $r2`
`1010 [00] <r1>`|SET  |`R[r1] = V`
`1011 [00] [00]`|JUMP |`pc = V`
`1100 <r1> <r2>`|JGT  |`if R[r1] > R[r2] then pc = V`
`1101 <r1> <r2>`|JGTE |`if R[r1] >= R[r2] then pc = V`
`1110 <r1> <r2>`|JEQ  |`if R[r1] == R[r2] then pc = V`
`1111 <r1> <r2>`|JNEQ |`if R[r1] != R[r2] then pc = V`
