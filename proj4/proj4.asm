# CSE 220 Programming Project #4
# Katheryn Martinez Hernandez
# ***REMOVED***
# ***REMOVED***

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text
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
jr $ra

compare_to:
jr $ra

packetize:
jr $ra

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
