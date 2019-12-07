.data
.align 2
max_queue_size: .word 7
queue:  # random garbage
.half 4829  # size
.half 8383  # max_size
.word 0x0359ecda, 0x11219f6d, 0x0594776c, 0x313694e0, 0x1a103fc2, 0x110f37bd, 0x06e48f83
#.word 0x0359ecda
v0: .asciiz "v0: "

.text
.globl main
main:
la $a0, queue
lw $a1, max_queue_size
jal clear_queue
move $t0, $v0

# print $v0
la $a0, v0
li $v0, 4
syscall
move $a0, $t0
li $v0, 1
syscall

li $a0, '\n'
li $v0, 11
syscall
syscall

# You will need to write your own code here to check the contents of the queue.
la $t0, queue
lw $t2, max_queue_size
blez $t2, end_main
li $t3, 4
print_queue:
lw $t1, 0($t0)
move $a0, $t1
li $v0, 34
syscall
li $a0, ' '
li $v0, 11
syscall
syscall
print_queue_loop:
lw $t1, 4($t0)
move $a0, $t1
li $v0, 34
syscall
li $a0, ' '
li $v0, 11
syscall
syscall
addi $t0, $t0, 4
addi $t2, $t2, -1
bgtz $t2, print_queue_loop

end_main:
li $v0, 10
syscall

.include "proj4.asm"
