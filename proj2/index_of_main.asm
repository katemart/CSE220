.data
str: .asciiz "**[CSE 220 Fall 2019]!!!**\0"
char: .byte '0'

.text
.globl main
main:
la $a0, str
lbu $a1, char
jal index_of

move $a0, $v0
li $v0, 1
syscall

li $a0, '\n'
li $v0, 11
syscall

li $v0, 10
syscall

.include "proj2.asm"
