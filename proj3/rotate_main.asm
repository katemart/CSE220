.data
#piece:
#.byte 2
#.byte 3
#.asciiz "OOO.O."  # not null-terminated during grading!
#rotation: .word 13
#rotated_piece: .asciiz "????????"   # not null-terminated during grading!
piece:
.byte 3
.byte 2
.asciiz "O.OO.O"  # not null-terminated during grading!
rotation: .word 4
rotated_piece: .asciiz "GB8uJnHG"   # not null-terminated during grading!

.text
main:
la $a0, piece
lw $a1, rotation
la $a2, rotated_piece
jal rotate

# report return value
move $a0, $v0
li $v0, 1
syscall

li $v0, 11
li $a0, '\n'
syscall

# report the contents of the rotated_piece buffer
la $t0, rotated_piece
lb $a0, 0($t0)
li $v0, 1
syscall

li $v0, 11
li $a0, ' '
syscall

lb $a0, 1($t0)
li $v0, 1
syscall

li $v0, 11
li $a0, ' '
syscall

# replace this syscall 4 with some of your own code that prints the game field in 2D
move $a0, $t0
addi $a0, $a0, 2
li $v0, 4
syscall

li $v0, 11
li $a0, '\n'
syscall


###################################### PRINT 2D ######################################
la $t0, rotated_piece
lbu $t1, 0($t0)
lbu $t2, 1($t0)
addi $t0, $t0, 2
outerloop:
move $t3, $t2
innerloop:
li $v0, 11
lbu $a0, 0($t0)
syscall
addi $t3, $t3, -1
addi $t0, $t0, 1
bgtz $t3, innerloop
li $v0, 11
li $a0, '\n'
syscall
addi $t1, $t1, -1
bgtz $t1, outerloop
#######################################################################################

li $v0, 10
syscall

.include "proj3.asm"
