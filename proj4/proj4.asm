# CSE 220 Programming Project #4
# Katheryn Martinez Hernandez
# ***REMOVED***
# ***REMOVED***

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text
# PART I
compute_checksum:
lw $t0, 0($a0)										# $t0 = first 4 bytes from packet
andi $v0, $t0, 0xFFFF								# $v0 = total_length (first 2 bytes)
srl $t0, $t0, 16									# $t0 = $t0 shifted 16 to the right
andi $t1, $t0, 0xFFF								# $t1 = msg_id (3rd byte and a half)
add $v0, $v0, $t1									# $v0 = total_length + msg_id
srl $t0, $t0, 12									# $t0 = $t0 shifted 12 to the right
add $v0, $v0, $t0									# $v0 = $v0 + version
lw $t0, 4($a0)										# $t0 = next 4 bytes from packet
andi $t1, $t0, 0xFFF								# $t1 = frag_offset (5th byte and a half)
add $v0, $v0, $t1									# $v0 = $v0 + frag_offset
srl $t0, $t0, 12									# $t0 = $t0 shifted 12 to the right
andi $t1, $t0, 0x3FF								# $t1 = protocol (byte and a quarter)
add $v0, $v0, $t1									# $v0 = $v0 + protocol
srl $t0, $t0, 10									# $t0 = $t0 shifted 10 to the right
andi $t1, $t0, 0x3									# $t1 = flags (quarter of a byte)
add $v0, $v0, $t1									# $v0 = $v0 + flags
srl $t0, $t0, 2										# $t0 = $t0 shifted 2 to the right
add $v0, $v0, $t0									# $v0 = $v0 + priority
lbu $t0, 8($a0)										# $t0 = dest_addr
add $v0, $v0, $t0									# $v0 = $v0 + dest_addr
lbu $t0, 9($a0)										# $t0 = src_addr
add $v0, $v0, $t0									# $v0 = $v0 + src_addr
li $t0, 1											# $t0 = 1
sll $t0, $t0, 16									# $t0 = 2^16
addi $t0, $t0, -1									# $t0 = 2^16 - 1
and $v0, $v0, $t0									# $v0 = $v0 and (2^16 - 1)
jr $ra												# return to where func was called


# PART II
compare_to:
# need to retrieve msg_id, frag_offset, src_addr to compare
# compare msg_id from 1st and 2nd packets:
lhu $t1, 2($a0)										# $t1 = 3rd and 4th bytes from 1st packet
andi $t1, $t1, 0xFF									# $t1 = p1.msg_id
lhu $t2, 2($a1)										# $t2 = 3rd and 4th bytes from 2nd packet
andi $t2, $t2, 0xFF									# $t2 = p2.msg_id
blt $t1, $t2, compare_less							# if p1.msg_id < p2.msg_id return -1
bgt $t1, $t2, compare_greater						# if p1.msg_id > p2.msg_id return 1
# compare frag_offset from 1st and 2nd packets:
lhu $t1, 4($a0)										# $t1 = 5th and 6th bytes from 1st packet
andi $t1, $t1, 0xFFF								# $t1 = p1.fragment_offset
lhu $t2, 4($a1)										# $t2 = 5th and 6th bytes from 2nd packet
andi $t2, $t2, 0xFFF								# $t2 = p2.fragment_offset
blt $t1, $t2, compare_less							# if p1.frag_off < p2.frag_off return -1
bgt $t1, $t2, compare_greater						# if p1.frag_off > p2.frag_off return 1
# compare src_addr from 1st and 2nd packets:
lbu $t1, 9($a0)										# $t1 = p1.src_addr
lbu $t2, 9($a1)										# $t2 = p2.src_addr
blt $t1, $t2, compare_less							# if p1.src_addr < p2.src_addr return -1
bgt $t1, $t2, compare_greater						# if p1.src_addr > p2.src_addr return 1
li $v0, 0											# else return 0
j end_compare_to									# go to end func
compare_less:
li $v0, -1											# $v0 = -1
j end_compare_to									# go to end func
compare_greater:
li $v0, 1											# $v0 = 1
end_compare_to:
jr $ra												# return to where func was called


# PART III
packetize:
# retrieve args from stack
lw $t0, 0($sp)  # msg_id
lw $t1, 4($sp)  # priority
lw $t2, 8($sp)  # protocol
lw $t3, 12($sp) # src_addr
lw $t4, 16($sp) # dest_addr
# allocate room on stack for registers
addi $sp, $sp, -36
sw $s0, 0($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)
sw $s3, 12($sp)
sw $s4, 16($sp)
sw $s5, 20($sp)
sw $s6, 24($sp)
sw $s7, 28($sp)
sw $ra, 32($sp)
# declare vars



# restore regs from stack
lw $ra, 32($sp)
lw $s7, 28($sp)
lw $s6, 24($sp)
lw $s5, 20($sp)
lw $s4, 16($sp)
lw $s3, 12($sp)
lw $s2, 8($sp)
lw $s1, 4($sp)
lw $s0, 0($sp)
jr $ra												# return to where func was called

clear_queue:
jr $ra

enqueue:
jr $ra

dequeue:
jr $ra

assemble_message:
jr $ra


#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
