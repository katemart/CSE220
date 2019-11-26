.data
.align 2
packet1: 
.byte 0x24 0x00 0x9A 0x50 0x00 0x10 0x52 0x07 0x59 0xA1 0xE6 0x02 0x47 0x72 0x61 0x63 0x65 0x20 0x4D 0x75 0x72 0x72 0x61 0x79 0x20 0x48 0x6F 0x70 0x70 0x65 0x72 0x20 0x77 0x61 0x73 0x20
.align 2
packet2: 
.byte 0x24 0x00 0x9A 0x50 0x18 0x10 0x52 0x07 0x59 0xA1 0xFE 0x02 0x6F 0x6E 0x65 0x20 0x6F 0x66 0x20 0x74 0x68 0x65 0x20 0x66 0x69 0x72 0x73 0x74 0x20 0x63 0x6F 0x6D 0x70 0x75 0x74 0x65
v0: .asciiz "v0: "
version: .asciiz "Version: "
msg_id: .asciiz "Msg ID #: "
total_len: .asciiz "Total Length: "
priority: .asciiz "Priority: "
flags: .asciiz "Flags: "
protocol: .asciiz "Protocol: "
frag_off: .asciiz "Fragment Offset: "
checksum: .asciiz "Checksum: "
src_addr: .asciiz "Source Address: "
des_addr: .asciiz "Dest Address: "
payload: .asciiz "Payload: "

.text
.globl main
main:
la $a0, packet1
la $a1, packet2
#la $a0, packet2
#la $a1, packet1
#la $a0, packet1
#la $a1, packet1
jal compare_to
move $s0, $v0

la $a0, v0
li $v0, 4
syscall

move $a0, $s0 
li $v0, 1
syscall

li $a0, '\n'
li $v0, 11
syscall
syscall

################################### print packet 1 ###################################
la $t0, packet1
# first line
lw $t1, 0($t0)
andi $t2, $t1, 0xFFFF							# $t2 = total_len
move $t8, $t2									# $t8 = total_len
srl $t3, $t1, 16
srl $t1, $t3, 12								# $t1 = version
andi $t3, $t3, 0xFFF							# $t3 = msg_id
la $a0, version
li $v0, 4
syscall
li $a0, '\t'
li $v0, 11
syscall
syscall
move $a0, $t1
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
la $a0, msg_id
li $v0, 4
syscall
li $a0, '\t'
li $v0, 11
syscall
syscall
move $a0, $t3
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
la $a0, total_len
li $v0, 4
syscall
li $a0, '\t'
li $v0, 11
syscall
syscall
move $a0, $t2
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
# second line
lw $t1, 4($t0)
andi $t2, $t1, 0xFFF							# $t2 = frag_offset
srl $t3, $t1, 12
srl $t4, $t3, 10
andi $t3, $t3, 0x3FF							# $t3 = protocol
srl $t1, $t4, 2									# $t1 = priority
andi $t4, $t4, 0x3								# $t4 = flags
la $a0, priority
li $v0, 4
syscall
li $a0, '\t'
li $v0, 11
syscall
syscall
move $a0, $t1
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
la $a0, flags
li $v0, 4
syscall
li $a0, '\t'
li $v0, 11
syscall
syscall
syscall
move $a0, $t4
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
la $a0, protocol
li $v0, 4
syscall
li $a0, '\t'
li $v0, 11
syscall
syscall
move $a0, $t3
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
la $a0, frag_off
li $v0, 4
syscall
li $a0, '\t'
li $v0, 11
syscall
move $a0, $t2
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
# third line
lw $t1, 8($t0)
andi $t2, $t1, 0xFF								# $t2 = des_addr
srl $t3, $t1, 8	
srl $t1, $t3, 8									# $t1 = checksum
andi $t3, $t3, 0xFF								# $t3 = src_addr
la $a0, des_addr
li $v0, 4
syscall
li $a0, '\t'
li $v0, 11
syscall
syscall
move $a0, $t2
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
la $a0, src_addr
li $v0, 4
syscall
li $a0, '\t'
li $v0, 11
syscall
move $a0, $t3
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
la $a0, checksum
li $v0, 4
syscall
li $a0, '\t'
li $v0, 11
syscall
syscall
move $a0, $t1
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
# fourth line
la $a0, payload
li $v0, 4
syscall
li $a0, '\t'
li $v0, 11
syscall
syscall
addi $t8, $t8, -12								# $t8 = payload size = counter
payload_loop:
lbu $t1, 12($t0)								# $t1 = first char of payload
move $a0, $t1
li $v0, 11
syscall
addi $t0, $t0, 1								# go to next char of payload
addi $t8, $t8, -1								# counter--
bgtz $t8, payload_loop							# if counter > 0, loop again
######################################################################################

li $a0, '\n'
li $v0, 11
syscall
syscall

################################### print packet 2 ###################################
la $t0, packet2
# first line
lw $t1, 0($t0)
andi $t2, $t1, 0xFFFF							# $t2 = total_len
move $t8, $t2									# $t8 = total_len
srl $t3, $t1, 16
srl $t1, $t3, 12								# $t1 = version
andi $t3, $t3, 0xFFF							# $t3 = msg_id
la $a0, version
li $v0, 4
syscall
li $a0, '\t'
li $v0, 11
syscall
syscall
move $a0, $t1
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
la $a0, msg_id
li $v0, 4
syscall
li $a0, '\t'
li $v0, 11
syscall
syscall
move $a0, $t3
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
la $a0, total_len
li $v0, 4
syscall
li $a0, '\t'
li $v0, 11
syscall
syscall
move $a0, $t2
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
# second line
lw $t1, 4($t0)
andi $t2, $t1, 0xFFF							# $t2 = frag_offset
srl $t3, $t1, 12
srl $t4, $t3, 10
andi $t3, $t3, 0x3FF							# $t3 = protocol
srl $t1, $t4, 2									# $t1 = priority
andi $t4, $t4, 0x3								# $t4 = flags
la $a0, priority
li $v0, 4
syscall
li $a0, '\t'
li $v0, 11
syscall
syscall
move $a0, $t1
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
la $a0, flags
li $v0, 4
syscall
li $a0, '\t'
li $v0, 11
syscall
syscall
syscall
move $a0, $t4
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
la $a0, protocol
li $v0, 4
syscall
li $a0, '\t'
li $v0, 11
syscall
syscall
move $a0, $t3
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
la $a0, frag_off
li $v0, 4
syscall
li $a0, '\t'
li $v0, 11
syscall
move $a0, $t2
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
# third line
lw $t1, 8($t0)
andi $t2, $t1, 0xFF								# $t2 = des_addr
srl $t3, $t1, 8	
srl $t1, $t3, 8									# $t1 = checksum
andi $t3, $t3, 0xFF								# $t3 = src_addr
la $a0, des_addr
li $v0, 4
syscall
li $a0, '\t'
li $v0, 11
syscall
syscall
move $a0, $t2
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
la $a0, src_addr
li $v0, 4
syscall
li $a0, '\t'
li $v0, 11
syscall
move $a0, $t3
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
la $a0, checksum
li $v0, 4
syscall
li $a0, '\t'
li $v0, 11
syscall
syscall
move $a0, $t1
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall
# fourth line
la $a0, payload
li $v0, 4
syscall
li $a0, '\t'
li $v0, 11
syscall
syscall
addi $t8, $t8, -12								# $t8 = payload size = counter
payload_loop2:
lbu $t1, 12($t0)								# $t1 = first char of payload
move $a0, $t1
li $v0, 11
syscall
addi $t0, $t0, 1								# go to next char of payload
addi $t8, $t8, -1								# counter--
bgtz $t8, payload_loop2							# if counter > 0, loop again
######################################################################################

li $v0, 10
syscall

.include "proj4.asm"
