.data
.align 2
packets: .space 500 # adjust as needed to store all bytes of the packets
#msg: .asciiz "Grace Murray Hopper was one of the first computer programmers to work on the Harvard Mark I."
random_junk: .asciiz "1234567890"
msg: .asciiz "i want to stop testing cases and want to go to sleep"
.align 2
payload_size: .word 8
############# NOTE: ONLY WORKS WHEN payload_size IS MULTIPLE OF 4!!!!!!! #############
version: .word 5
msg_id: .word 154
priority: .word 7
protocol: .word 289
src_addr: .word 161
dest_addr: .word 89
v0: .asciiz "v0: "
version_str: .asciiz "Version: "
msg_id_str: .asciiz "Msg ID #: "
total_len_str: .asciiz "Total Length: "
priority_str: .asciiz "Priority: "
flags_str: .asciiz "Flags: "
protocol_str: .asciiz "Protocol: "
frag_off_str: .asciiz "Fragment Offset: "
checksum_str: .asciiz "Checksum: "
src_addr_str: .asciiz "Source Address: "
des_addr_str: .asciiz "Dest Address: "
payload_str: .asciiz "Payload: "

.text
.globl main
main:
la $a0, packets
la $a1, msg
lw $a2, payload_size
lw $a3, version
lw $t4, msg_id
lw $t5, priority
lw $t6, protocol
lw $t7, src_addr
lw $t8, dest_addr
addi $sp, $sp, -20
sw $t4, 0($sp)  # msg_id
sw $t5, 4($sp)  # priority
sw $t6, 8($sp)  # protocol
sw $t7, 12($sp) # src_addr
sw $t8, 16($sp) # dest_addr

jal packetize
addi $sp, $sp, 20
move $s0, $v0  # number of packets

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

la $a0, random_junk
li $v0, 4
syscall

li $a0, '\n'
li $v0, 11
syscall

# You should consider writing some code here to print out the contents of the packets[] array.
la $t0, packets
# $s0 = num of times to loop
print_packets:
# first line
lw $t1, 0($t0)
andi $t2, $t1, 0xFFFF							# $t2 = total_len
move $t8, $t2									# $t8 = total_len
srl $t3, $t1, 16
srl $t1, $t3, 12								# $t1 = version
andi $t3, $t3, 0xFFF							# $t3 = msg_id
la $a0, version_str
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
la $a0, msg_id_str
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
la $a0, total_len_str
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
la $a0, priority_str
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
la $a0, flags_str
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
la $a0, protocol_str
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
la $a0, frag_off_str
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
la $a0, des_addr_str
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
la $a0, src_addr_str
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
la $a0, checksum_str
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
la $a0, payload_str
li $v0, 4
syscall
li $a0, '\t'
li $v0, 11
syscall
syscall
move $t7, $t0									# $t7 = packets (copy)
addi $t9, $t8, -12								# $t8 = total_len - header = counter
payload_loop:
lbu $t1, 12($t0)								# $t1 = first char of payload
beqz $t1, print_packets_cont
move $a0, $t1
li $v0, 11
syscall
addi $t0, $t0, 1								# go to next char of payload
addi $t9, $t9, -1								# counter--
bgtz $t9, payload_loop							# if counter > 0, loop again
# loop again:
print_packets_cont:
li $a0, '\n'
li $v0, 11
syscall
syscall
move $t0, $t7									# $t0 = packets (original)
add $t0, $t0, $t8								# pointer += total_length
addi $s0, $s0, -1								# num_of_packets--
bgtz $s0, print_packets

li $v0, 10
syscall

.include "proj4.asm"

# Expected array of packets:
.data
.align 2
.byte 0x18 0x00 0x9A 0x50 0x00 0x10 0x52 0x07 0x59 0xA1 0xDA 0x02 0x47 0x72 0x61 0x63 0x65 0x20 0x4D 0x75 0x72 0x72 0x61 0x79
.byte 0x18 0x00 0x9A 0x50 0x0C 0x10 0x52 0x07 0x59 0xA1 0xE6 0x02 0x20 0x48 0x6F 0x70 0x70 0x65 0x72 0x20 0x77 0x61 0x73 0x20
.byte 0x18 0x00 0x9A 0x50 0x18 0x10 0x52 0x07 0x59 0xA1 0xF2 0x02 0x6F 0x6E 0x65 0x20 0x6F 0x66 0x20 0x74 0x68 0x65 0x20 0x66
.byte 0x18 0x00 0x9A 0x50 0x24 0x10 0x52 0x07 0x59 0xA1 0xFE 0x02 0x69 0x72 0x73 0x74 0x20 0x63 0x6F 0x6D 0x70 0x75 0x74 0x65
.byte 0x18 0x00 0x9A 0x50 0x30 0x10 0x52 0x07 0x59 0xA1 0x0A 0x03 0x72 0x20 0x70 0x72 0x6F 0x67 0x72 0x61 0x6D 0x6D 0x65 0x72
.byte 0x18 0x00 0x9A 0x50 0x3C 0x10 0x52 0x07 0x59 0xA1 0x16 0x03 0x73 0x20 0x74 0x6F 0x20 0x77 0x6F 0x72 0x6B 0x20 0x6F 0x6E
.byte 0x18 0x00 0x9A 0x50 0x48 0x10 0x52 0x07 0x59 0xA1 0x22 0x03 0x20 0x74 0x68 0x65 0x20 0x48 0x61 0x72 0x76 0x61 0x72 0x64
.byte 0x15 0x00 0x9A 0x50 0x54 0x10 0x12 0x07 0x59 0xA1 0x2A 0x03 0x20 0x4D 0x61 0x72 0x6B 0x20 0x49 0x2E 0x00
