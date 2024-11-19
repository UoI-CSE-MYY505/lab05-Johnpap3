# ----------------------------------------------------------------------------------------
# lab05.s 
#  Verifies the correctness of some aspects of a 5-stage pipelined RISC-V implementation
# ----------------------------------------------------------------------------------------

.data
storage:
    .word 1
    .word 10
    .word 11

.text
# ----------------------------------------------------------------------------------------
# prepare register values.
# ----------------------------------------------------------------------------------------
#  la breaks into 2 instructions, which have a data dependence. Ignore this 
    la   a0, storage
    addi s0, zero, 0
    addi s1, zero, 1
    addi s2, zero, 2
    addi s3, zero, 3

# ----------------------------------------------------------------------------------------
# Verify forwarding from the previous ALU instruction to input Op1 of ALU
# There should be no added delay here.
    addi t1,   s0, 1     
    add  t2,   t1, s2 
    # nop instructions added between examples
    add  zero, zero, zero  
    add  zero, zero, zero  
    add  zero, zero, zero  

# ----------------------------------------------------------------------------------------
# Verify load-use 1 cycle stall and correct passing of load's value
    lw   t3, 4(a0)
    add  t4, zero, t3   # t4 should be storage[1] = 10
    # nop instructions added between examples
    add  zero, zero, zero  
    add  zero, zero, zero  
    add  zero, zero, zero  

# ----------------------------------------------------------------------------------------
# Check how many cycles are lost due to pipe flush following a jump.
# Also verify that the instruction(s) following the jump are not executed (i.e. writing to a register)
    j    next
    add  t5, s1, s2
    add  t6, s1, s2
next:
    # nop instructions added between examples
    add  zero, zero, zero  
    add  zero, zero, zero  
    add  zero, zero, zero  

# ----------------------------------------------------------------------------------------
# Verify that no cycles are lost when a branch is NOT taken
    beq  s1, s2, next
    add  t5, s1, s2
    add  t6, s1, s3

# ----------------------------------------------------------------------------------------
# Check how many cycles are lost when a branch IS taken
    beq  s1, s1, taken
    add  t0, zero, s3
    add  t1, zero, s2
taken:

# ----------------------------------------------------------------------------------------
# Example where an instruction passes its result to the 2nd following instruction
# There should be no stalls
# ----------------------------------------------------------------------------------------
    addi t0, zero, 5    # t0 = 5
    addi t1, t0, 2      # t1 = t0 + 2 = 7
    add  t2, t0, t1     # t2 = t0 + t1 = 5 + 7 = 12
    # nop instructions added between examples
    add  zero, zero, zero  
    add  zero, zero, zero  
    add  zero, zero, zero  

# ----------------------------------------------------------------------------------------
# Example with a double hazard, ensuring that the newest value is forwarded
# No stalls expected
# ----------------------------------------------------------------------------------------
    addi t3, zero, 5    # t3 = 5
    addi t3, t3, 2      # t3 = t3 + 2 = 7
    add  t4, t3, t3     # t4 should use the newest value of t3 (7), so t4 = 7 + 7 = 14
    # nop instructions added between examples
    add  zero, zero, zero  
    add  zero, zero, zero  
    add  zero, zero, zero  

# ----------------------------------------------------------------------------------------
# Example with load passing value to a NOT-TAKEN branch (1 cycle stall)
# Identify if this is a data or control hazard
# ----------------------------------------------------------------------------------------
    lw   t5, 8(a0)      # Load t5 with storage[2] = 11
    beq  t5, s0, after_load # Branch is NOT taken (t5 != 0)
    add  t6, t5, s1     # This instruction will execute; t6 = 11 + 1 = 12
after_load:
    # nop instructions added between examples
    add  zero, zero, zero  
    add  zero, zero, zero  
    add  zero, zero, zero  

# ----------------------------------------------------------------------------------------
# Example with a taken branch to the next instruction (self-referential branch)
# ----------------------------------------------------------------------------------------
    beq  s1, s1, immediate_next # This branch will be taken
immediate_next:
    # nop instructions added between examples
    add  zero, zero, zero  
    add  zero, zero, zero  
    add  zero, zero, zero  

# ----------------------------------------------------------------------------------------
# Exit program
# ----------------------------------------------------------------------------------------
exit:  
    addi      a7, zero, 10    
    ecall  

