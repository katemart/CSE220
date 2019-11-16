.data
#state:
#.byte 8
#.byte 6
#.asciiz "...O.....OO..OOOO..OOOO.OOOOOOOOOOOOOOOOOOOOOOOO" # not null-terminated during grading!
#row: .word 5

state:
.byte 8
.byte 6
.asciiz "...O.....OO..OOOO..OOOO.OOOOOOOOOOOOOOOOOOOOOOOO"  # not null-terminated during grading!
row: .word 19

.text
main:
la $a0, state
lw $a1, row
jal check_row_clear

# report return value
move $a0, $v0
li $v0, 1
syscall

li $v0, 11
li $a0, ' '
syscall

li $v0, 11
li $a0, '\n'
syscall

# report the contents of the game state struct
la $t0, state
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
li $v0, 11
li $a0, '\n'
syscall

la $t0, state
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

# the contents of rotated_piece will not be checked during grading, so we don't print it here

li $v0, 10
syscall

.include "proj3.asm"
