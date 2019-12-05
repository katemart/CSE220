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
lw $t4, 0($sp)  									# msg_id
lw $t5, 4($sp)  									# priority
lw $t6, 8($sp)  									# protocol
lw $t7, 12($sp) 									# src_addr
lw $t8, 16($sp) 									# dest_addr
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
move $s0, $a0										# $s0 = packets
move $s1, $a1										# $s1 = msg
move $s2, $a2										# $s2 = payload_size
move $s3, $a3										# $s3 = version
move $s4, $t4										# $s4 = msg_id
move $s5, $t5										# $s5 = priority
move $s6, $t6										# $s6 = protocol
move $s7, $t7										# $s7 = src_addr
# must save $t8 each time before jumping -- DO NOT OVERWRITE!! --
li $t2, 0											# total_len = 0
li $t3, 0											# frag_offset = 0
li $t7, 0											# num_of_packets ($v0) = 0
packetize_loop:
li $t0, 0											# counter
li $t4, 1											# flags = 1
add $s0, $s0, $t2									# pointer = packets[] + total_len
move $t9, $s0										# $t9 = packets (copy)
packetize_loop_start:
lbu $t1, 0($s1)										# $t1 = first char from msg
sb $t1, 12($s0)										# save $t1 into packets[12]
beqz $t1, packetize_cont_null						# if $t1 = null-term, it is last packet
bge $t0, $s2, packetize_cont						# if counter => payload_size, cont packetizing
addi $t0, $t0, 1									# counter++
addi $s0, $s0, 1									# packets[i]++
addi $s1, $s1, 1									# msg[i]++
j packetize_loop_start								# loop again
packetize_cont_null:
li $t4, 0											# flags = 0
addi $t0, $t0, 1									# counter++
packetize_cont:
move $s0, $t9										# $s0 = packets (starting addr)
addi $t2, $t0, 12									# total_len = payload + header (which is always 12)
sll $t5, $s3, 28									# $t5 = version shifted 28 to the left
sll $t6, $s4, 16									# $t6 = msg_id shifted 15 to the left
or $t5, $t5, $t6									# $t5 = version OR msg_id
or $t5, $t5, $t2									# $t5 = $t5 OR total_len
sw $t5, 0($s0)										# save $t5 to packets[]
sll $t5, $s5, 24									# $t5 = priority shifted 24 to the left
sll $t6, $t4, 22									# $t6 = flags shifted 22 to the left
or $t5, $t5, $t6									# $t5 = priority OR flags
sll $t6, $s6, 12									# $t6 = protocol shifted 12 to the left
or $t5, $t5, $t6									# $t5 = $t5 OR protocol
or $t5, $t5, $t3									# $t5 = $t5 OR frag_offset
sw $t5, 4($s0)										# save $t5 to packets[]
sll $t5, $s7, 8										# $t5 = src_addr shifted 8 to the left
or $t5, $t5, $t8									# $t5 = src_addr OR dest_addr
sh $t5, 8($s0)										# save $t5 to packets[]
# WHEN CALC CHECKSUM NEED TO PRESERVE $t2, $t3, $t4, $t8 AND $t9!!
# save $t regs on stack
addi $sp, $sp, -20
sw $t2, 0($sp)
sw $t3, 4($sp)
sw $t4, 8($sp)
sw $t8, 12($sp)
sw $t9, 16($sp)
# call checksum
move $a0, $s0										# $a0 = packet
jal compute_checksum								# go to compute_checksum
sh $v0, 10($s0)										# save checksum to packets[]
# restore $t regs from stack 
lw $t9, 16($sp)
lw $t8, 12($sp)
lw $t4, 8($sp)
lw $t3, 4($sp)
lw $t2, 0($sp)
addi $sp, $sp, 20
# continue looping
li $t0, 0
addi $t7, $t7, 1									# num_of_packets++
beq $t0, $t4, packetize_end							# if flags = 0, end looping
add $t3, $t3, $s2									# frag_offset += payload_size
j packetize_loop									# loop again
packetize_end:
move $v0, $t7										# $v0 = num_of_packets
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


# PART IV
clear_queue:
li $v0, 0
# check that max_queue is valid
blez $a1, invalid_init_queue						# if max_size <= 0, it is invalid
# if valid, clear queue
sh $0, 0($a0)										# set lower half-word to zero
sh $a1, 2($a0)										# set upper half-word to max_queue_size
clear_queue_loop:
sw $0, 4($a0)										# set next word in queue to zero
addi $a0, $a0, 4									# go to next word in queue
addi $a1, $a1, -1									# counter--
bgtz $a1, clear_queue_loop							# if counter > 0, loop again
j end_clear_queue									# go to end_clear_queue
invalid_init_queue:
li $v0, -1											# $v0 = -1 (if invalid)
end_clear_queue:
jr $ra												# return to where func was called


# PART V
enqueue:
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
move $s0, $a0										# $s0 = queue
move $s1, $a1										# $s1 = packet
# check if size = max_size
lhu $s2, 0($s0)										# $s2 = queue size
lhu $s3, 2($s0)										# $s3 = queue max_size
beq $s2, $s3, end_enqueue							# if $s2 = $s3, make no changes
# if max_size is not reached, increment queue size and insert new node
move $s3, $s2										# $s3 = queue size
addi $s3, $s3, 1									# $s3 = queue size + 1
sh $s3, 0($s0)										# update queue size to new size
addi $s0, $s0, 4									# get starting address of arr																					
sll $s4, $s2, 2										# $s4 = queue size * 4
add $s4, $s0, $s4									# get ending address of arr
sw $s1, 0($s4)										# save packet into queue[i]
enqueue_loop:
lw $s5, 0($s4)										# elem from end of arr
# find parent
addi $s6, $s2, -1									# $s6 = i - 1
srl $s6, $s6, 1										# $s6 = (i-1)/2
sll $s6, $s6, 2										# $s6 = $s5 * 4
add $s6, $s0, $s6									# parent addr = queue + addr_offset
lw $s7, 0($s6)										# $s7 = parent elem
# compare new node with parent
move $a0, $s5										# $a0 = new node
move $a1, $s7										# $a1 = parent
jal compare_to										# call compare_to
li $t0, -1											# $t0 = -1 
bne $v0, $t0, end_enqueue							# if new node => parent, end func
# if new node < parent, swap
sw $s5, 0($s6)										# save new node to parent's addr
sw $s7, 0($s4)										# save parent node to new node's addr
# continue looping
srl $s2, $s2, 1										# $s2 = size / 2
sll $s4, $s2, 2										# $s4 = queue size * 4
add $s4, $s0, $s4									# get ending address of arr
bgtz $s2, enqueue_loop								# if size > 0, loop again
end_enqueue:
move $v0, $s3										# $v0 = queue size (after insertion)
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
addi $sp, $sp, 36
jr $ra												# return to where func was called
						

# PART VI																																												
dequeue:
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
move $s0, $a0										# $s0 = queue
li $t0, 0											# $t0 = 0 (to use as $v0)
# check if queue is empty
lhu $s1, 0($s0)										# $s1 = queue size
beqz $s1, end_enqueue								# if size is 0 (queue is empty), make no changes
# if queue is not empty, swap first node with end node
lw $t0, 4($s0)										# $t0 = addr of root (being removed)
sll $s2, $s1, 2										# $s2 = queue size * 4
add $s2, $s0, $s2									# $s2 = ending address of arr
lw $s3, 0($s2)										# $s3 = end of arr elem
sw $s3, 4($s0)										# root = end elem
sw $0, 0($s2)										# delete end elem 
# update queue size
addi $s1, $s1, -1									# $s1 = queue size - 1 = n
sh $s1, 0($s0)										# update queue size to new size
addi $s0, $s0, 4									# move pointer to first elem
# heapify down
li $s2, 0											# $s3 = i = parent index
li $t4, -1											# $t4 = -1 (to use for comparison)
li $t6, 1											# $t6 = 1 (to use for comparison)
dequeue_loop:	
# get parent 
sll $s3, $s2, 2										# $s3 = parent index * 4
add $s3, $s0, $s3									# $s3 = addr of parent
lw $t3, 0($s3)										# $t3 = parent elem
# get left child
sll $s4, $s2, 1										# $s4 = 2 * i
addi $s4, $s4, 1									# $s4 = (2 * i) + 1 = left child index
bgt $s4, $s1, end_dequeue							# if left child index > queue size, no left child
sll $s5, $s4, 2										# $s5 = left child index * 4
add $s5, $s0, $s5									# $s5 = addr of left child
lw $t5, 0($s5)										# $t5 = left child elem
# get right child
sll $s6, $s2, 1										# $s6 = 2 * i
addi $s6, $s6, 2									# $s6 = (2 * i) + 2 = right child index
sgt $t8, $s6, $s1									# if right child index > queue size $t8 = 1 else $t8 = 0
bnez $t8, compare_left								# if $t8 = 1, go to compare_left
#bgt $s6, $s1, compare_left							# if right child index > queue size, no right child
sll $s7, $s6, 2										# $s7 = right child index * 4
add $s7, $s0, $s7									# $s7 = addr of right child 
lw $t7, 0($s7)										# $t7 = right child elem
# compare left child with right child
# if $v0 = -1 left child < right child, if $v0 = 1 right child < left child, if $v0 = 0 theyre equal
move $a0, $t5										# $a0 = left child
move $a1, $t7										# $a1 = right child
jal compare_to										# call compare_to
beq $v0, $t6, check_right_child						# if $v0 = 1, right child is smaller
# left child <= right child, compare left child with parent and swap if necessary
compare_left:
move $a0, $t5										# $a0 = left child
move $a1, $t3										# $a1 = parent
jal compare_to										# call compare_to
bne $v0, $t4, end_dequeue							# if left child => parent, end func
# if left child < parent, swap
sw $t3, 0($s5)										# save parent to left child's addr
sw $t5, 0($s3)										# save left child to parent's addr
bnez $t8, end_dequeue								# if $t8 = 1 (there's only 1 child), branch to end
addi $s2, $s2, 1									# i = i + 1
j cont_dequeue_loop									# loop from the top
# right child < left child, compare right child with parent and swap if necessary
check_right_child:
move $a0, $t7										# $a0 = right child
move $a1, $t3										# $a1 = parent
jal compare_to										# call compare_to
bne $v0, $t4, end_dequeue							# if right child => parent, end func
# if right child < parent, swap and loop from the top
sw $t3, 0($s7)										# save parent to right child's addr
sw $t7, 0($s3)										# save right child to parent's addr
addi $s2, $s2, 2									# i = i + 2
cont_dequeue_loop:									
blt $s2, $s1, dequeue_loop							# if i < queue size, loop again
end_dequeue:
# restore regs from stack
move $v0, $t0										# $v0 = addr of removed pckt or 0 if empty	
lw $ra, 32($sp)
lw $s7, 28($sp)
lw $s6, 24($sp)
lw $s5, 20($sp)
lw $s4, 16($sp)
lw $s3, 12($sp)
lw $s2, 8($sp)
lw $s1, 4($sp)
lw $s0, 0($sp)
addi $sp, $sp, 36
jr $ra												# return to where func was called


# PART VII
assemble_message:
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
move $s0, $a0										# $s0 = msg
move $s1, $a1										# $s1 = queue
lhu $s2, 0($a1)										# $s2 = queue size
li $t2, 0											# $t2 = num of packets dequeued
li $v1, 0											# $v1 = 0
assemble_loop:
li $s5, 0											# reset payload every time
lw $s3, 4($s1)										# $s3 = first packet addr
lhu $s4, 10($s3)									# $s4 = checksum
move $a0, $s3										# $a0 = packet 
jal compute_checksum								# call compute_checksum
beq $v0, $s4, cont_assemble_loop					# if $v0 = $s4, checksum passes so continue
addi $v1, $v1, 1									# else checksum fails so $v1++
cont_assemble_loop:
lhu $s5, 0($s3)										# $s5 = total_length of packet
addi $s5, $s5, -12									# $s5 = payload length
lhu $s6, 4($s3)										# $s6 = 3rd half word of packet
andi $s6, $s6, 0xFFF								# $s6 = frag_offset
add $s7, $s0, $s6									# start writing to msg at offset
string_loop:
lbu $t3, 12($s3)									# $t3 = payload start
sb $t3, 0($s7)										# $t3 = save char from payload to msg
addi $s7, $s7, 1									# go to next char of msg
addi $s3, $s3, 1									# go to next char of payload
addi $s5, $s5, -1									# decrement payload length
bgtz $s5, string_loop								# if payload length > 0, loop again
# continue looping
addi $t2, $t2, 1									# num_of_pckts_deq++
addi $s1, $s1, 4									# go to next packet of queue
addi $s2, $s2, -1									# queue size - 1
bgtz $s2, assemble_loop								# if queue size > 0, loop again
move $v0, $t2										# $v0 = num_of_pckts_deq
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
addi $sp, $sp, 36
jr $ra												# return to where func was called

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
