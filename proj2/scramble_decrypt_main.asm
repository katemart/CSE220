.data
plaintext: .ascii "This is random garbage! Notice that it is not null-terminated! You should not be seeing this text!"
ciphertext: .asciiz "EA WAir pAzLMArq XmC goiCW! KTP 220, TeS, OXBB 2019!!!\0"
alphabet: .asciiz "QeKEPOslaJbkfxUDdGTIStNwhjXnYCLvRpyFqBzmAuHrgoiZMcWV"
trash: .ascii "random garbage"

.text
.globl main
main:
la $a0, plaintext
la $a1, ciphertext
la $a2, alphabet
jal scramble_decrypt

move $a0, $v0
li $v0, 1
syscall

li $a0, '\n'
li $v0, 11
syscall

la $a0, plaintext
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
