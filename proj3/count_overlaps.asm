.data
#state:
#.byte 6
#.byte 10
#.asciiz "....................OOO.......OOOO.....OOOOOO....OOOOOOO..OO"  # not null-terminated during grading!
#row: .word 4  # this is test case #3 in the PDF
#col: .word 0
#piece:
#.byte 2
#.byte 3
#.asciiz "OOOO.." # not null-terminated during testing!

state:
.byte 6
.byte 10
.asciiz "....................OOO.......OOOO.....OOOOOO....OOOOOOO..OO"  # not null-terminated during grading!
row: .word -3 # this is test case #3 in the PDF
col: .word 2
piece:
.byte 2
.byte 3
.asciiz "OOOO.." # not null-terminated during testing!

.text
main:
la $a0, state
lw $a1, row
lw $a2, col
la $a3, piece
jal count_overlaps

# report return value
move $a0, $v0
li $v0, 1
syscall

li $v0, 11
li $a0, '\n'
syscall

################# PRINTING TO SEE THAT DATA ISNT CHANGED #################
# report the contents of the state
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

# report the contents of the rotated_piece buffer
la $t0, piece
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

li $v0, 10
syscall

.include "proj3.asm"
