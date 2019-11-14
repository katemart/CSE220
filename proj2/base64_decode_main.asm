.data
decoded_str: .ascii "This is random garbage! Notice that it is not null-terminated! You should not be seeing this text!"
encoded_str: .asciiz "kkV=\0"
base64_table: .asciiz "JacdT30UI79KV1povPfwrkjlZznDYELQGH/Ohm6BXu2itbe8xRWsgC5q4SyAM+FN"
trash: .ascii "random garbage"

.text
.globl main
main:
la $a0, decoded_str
la $a1, encoded_str
la $a2, base64_table
jal base64_decode

move $a0, $v0
li $v0, 1
syscall

li $a0, '\n'
li $v0, 11
syscall

la $a0, decoded_str
li $v0, 4
syscall

li $a0, '\n'
li $v0, 11
syscall

# test if buffer is overextended #
la $a0, trash
li $v0, 4
syscall
##################################

li $v0, 10
syscall

.include "proj2.asm"
