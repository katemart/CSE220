# This is example 4 from the PDF. You will need to adjust the size of the memory buffer
# to store the game state struct.
.data
#state:
#.byte 99
#.byte 77
#.asciiz "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP" # not null-terminated during grading!
#filename: .asciiz "game2.txt"
#moves: .asciiz "I005Z005S001I104O605O000I009O202I107"
#rotated_piece: .asciiz "????????" # not null-terminated during testing!
#num_pieces_to_drop: .word 9

state:
.byte 99
.byte 77
.asciiz "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu" # not null-terminated during grading!
filename: .asciiz "game5.txt"
moves: .asciiz "O500I212S916L508L310J607L609Z503S309Z719L418O619O806J511L506I610O101O520Z514S512"
rotated_piece: .asciiz "????????" # not null-terminated during testing!
num_pieces_to_drop: .word 20

pieces_arr:
# T piece
.byte 2
.byte 3
.ascii "OOO.O."
# J piece
.byte 2
.byte 3
.ascii "OOO..O"
# Z piece
.byte 2
.byte 3
.ascii "OO..OO"
# O piece
.byte 2
.byte 2
.ascii "OOOO.."
# S piece
.byte 2
.byte 3
.ascii ".OOOO."
# L piece
.byte 2
.byte 3
.ascii "OOOO.."
# I piece
.byte 1
.byte 4
.ascii "OOOO.."


.text
main:
la $a0, state
la $a1, filename
la $a2, moves
la $a3, rotated_piece
addi $sp, $sp, -8
lw $t0, num_pieces_to_drop
sw $t0, 0($sp)
la $t0, pieces_arr
sw $t0, 4($sp)
li $t0, 28132 # trashing $t0
jal simulate_game
addi $sp, $sp, 8

# report return values
move $a0, $v0
li $v0, 1
syscall

li $v0, 11
li $a0, ' '
syscall

move $a0, $v1
li $v0, 1
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

la $a0, filename
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
