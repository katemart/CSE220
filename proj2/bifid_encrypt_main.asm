.data
ciphertext: .ascii "This is random garbage! Notice that it is not null-terminated! You should not be seeing this text!"
plaintext: .asciiz "Stony Brook University\0"
key_square: .asciiz "#8yszp,gv4\"huWA!w=lMRatXrEDGeBm5j$Z1Iq?Q*n;PTNV2iC9.H)k06o(f3@d7\'S:%OYK-xL/cUJ bF"
period: .word 6
index_buffer: .ascii "Lorem ipsum dolor sit amet, consectetuer adipi"
trash: .ascii "random garbage"
block_buffer: .ascii "Lore"
junk: .ascii "More random garbage"

.text
.globl main
main:
la $a0, ciphertext
la $a1, plaintext
la $a2, key_square
lw $a3, period
addi $sp, $sp, -8
la $t0, index_buffer
sw $t0, 0($sp)
la $t0, block_buffer
sw $t0, 4($sp)
jal bifid_encrypt
addi $sp, $sp, 8

move $a0, $v0
li $v0, 1
syscall

li $a0, '\n'
li $v0, 11
syscall

la $a0, ciphertext
li $v0, 4
syscall

li $a0, '\n'
li $v0, 11
syscall

la $a0, trash
li $v0, 4
syscall

li $a0, '\n'
li $v0, 11
syscall

la $a0, junk
li $v0, 4
syscall

li $a0, '\n'
li $v0, 11
syscall

li $v0, 10
syscall

.include "proj2.asm"
