# Katheryn Martinez Hernandez
# ***REMOVED***
# ***REMOVED***

.data
# Command-line arguments
num_args: .word 0
addr_arg0: .word 0
addr_arg1: .word 0
no_args: .asciiz "You must provide at least one command-line argument.\n"

# Error messages
invalid_operation_error: .asciiz "INVALID_OPERATION\n"
invalid_args_error: .asciiz "INVALID_ARGS\n"

# Output strings
royal_flush_str: .asciiz "ROYAL_FLUSH\n"
straight_flush_str: .asciiz "STRAIGHT_FLUSH\n"
four_of_a_kind_str: .asciiz "FOUR_OF_A_KIND\n"
full_house_str: .asciiz "FULL_HOUSE\n"
simple_flush_str: .asciiz "SIMPLE_FLUSH\n"
simple_straight_str: .asciiz "SIMPLE_STRAIGHT\n"
high_card_str: .asciiz "HIGH_CARD\n"

zero_str: .asciiz "ZERO\n"
neg_infinity_str: .asciiz "-INF\n"
pos_infinity_str: .asciiz "+INF\n"
NaN_str: .asciiz "NAN\n"
floating_point_str: .asciiz "_2*2^"

# Put your additional .data declarations here, if any.

# Main program starts here
.text
.globl main
main:
    # Do not modify any of the code before the label named "start_coding_here"
    # Begin: save command-line arguments to main memory
    sw $a0, num_args
    beqz $a0, zero_args
    li $t0, 1
    beq $a0, $t0, one_arg
two_args:
    lw $t0, 4($a1)
    sw $t0, addr_arg1
one_arg:
    lw $t0, 0($a1)
    sw $t0, addr_arg0
    j start_coding_here
zero_args:
    la $a0, no_args
    li $v0, 4
    syscall
    j exit
    # End: save command-line arguments to main memory

start_coding_here:
    # Start the assignment by writing your code here
# PART I
    lw $t0, num_args						# $t0 = number of args from command-line
    lw $s0, addr_arg0						# $s0 = address of first arg from command-line
    lw $s1, addr_arg1						# $s1 = address of second arg from command-line
    lbu $t1, 0($s0)							# $t1 = first char of first arg
    li $t2, 2								# $t2 = 2
	# check if first arg length = 1
    lbu $t3, 1($s0)							# $t3 = second char of first arg
    bnez $t3, print_invalid_operation		# if second char != 0 print operation error
    j check_first_char						# else go check first char
	# check if first arg = F, M, or P
check_first_char:
	li $t3, 'F'								# $t3 = F
	bne $t1, $t3, first_is_M				# if first char != F, go to next case
	bne $t0, $t2, print_invalid_args		# else check num args, if != 2 print invalid args error
	j hex_to_float							# if first is F and num of args = 2, go to hex to float
first_is_M:
	li $t3, 'M'								# $t3 = M
	bne $t1, $t3, first_is_P				# if first char != M, go to next case
	bne $t0, $t2, print_invalid_args		# else check num args, if != 2 print invalid args error
	j hex_to_rtype							# if first is M and num of args = 2, go to hex to rtype
first_is_P:									
	li $t3, 'P'								# $t3 = P
	bne $t1, $t3, first_is_invalid			# if first char != P, print invalid operation error
	bne $t0, $t2, print_invalid_args		# else check num args, if != 2 print invalid args error
	j poker_hand							# if first is M and num of args = 2, go to poker hand
first_is_invalid:
	j print_invalid_operation				# default case, if all cases above fail print invalid oper error

# PART II
# main function
hex_to_rtype:	
	# get opcode value
	lbu $t1, 0($s1)							# $t1 = first char of second arg
	jal ascii_converter1					# go to function to convert ascii to dec
	andi $t2, $t1, 0x3F						# to get 4 -> 6 bits; $t2 = $t1
	lbu $t1, 1($s1)							# $t1 = second char of second arg
	jal ascii_converter1					# go to function to convert ascii to dec
	srl $t3, $t1, 2							# $t3 = $t1 shifted 2 to the right
	or $t1, $t2, $t3						# $t1 = $t2 OR $t3
	bnez $t1, print_invalid_args			# if $t1 value (opcode) != 0 print error
	jal print_rtype							# go to print rtype
	# get rs_field value
	lbu $t1, 1($s1)							# $t1 = second char of second arg
	jal ascii_converter1					# go to function to convert ascii to dec
	andi $t2, $t1, 0x1F						# to get 4 -> 5 bits; $t2 = $t1
	sll $t2, $t2, 3							# $t2 = $t2 shifted 3 to the left
	lbu $t1, 2($s1)							# $t1 = third char of second arg
	jal ascii_converter1					# go to function to convert ascii to dec
	srl $t3, $t1, 1							# $t3 = $t1 shifted 1 to the right
	or $t1, $t2, $t3						# $t1 = $t2 OR $t3
	jal print_rtype							# go to print rtype
	# get rt_field value			
	lbu $t1, 2($s1)							# $t1 = third char of second arg
	jal ascii_converter1					# go to function to convert ascii to dec
	andi $t2, $t1, 0x1F						# to get 4 -> 5 bits; $t2 = $t1
	andi $t2, $t2, 0x1						# $t2 = $t2 ANDI 1 (done to preserve last 1 bit from $t2)
	sll $t2, $t2, 4							# $t2 = $t2 shifted 4 to the left
	lbu $t1, 3($s1)							# $t1 = fourth char of second arg
	jal ascii_converter1					# go to function to convert ascii to dec
	move $t3, $t1							# $t3 = $t1 (copy value)
	or $t1, $t2, $t3						# $t1 = $t2 OR $t3
	jal print_rtype							# go to print rtype
	# get rd_field value
	lbu $t1, 4($s1)							# $t1 = fifth char of second arg
	jal ascii_converter1					# go to function to convert ascii to dec
	andi $t2, $t1, 0x1F						# to get 4 -> 5 bits; $t2 = $t1
	sll $t2, $t2, 1							# $t2 = $t2 shifted 1 to the left
	lbu $t1, 5($s1)							# $t1 = sixth char of second arg
	jal ascii_converter1					# go to function to convert ascii to dec
	srl $t3, $t1, 3							# $t3 = $t1 shifted 3 to the right
	or $t1, $t2, $t3						# $t1 = $t2 OR $t3
	jal print_rtype							# go to print rtype
	# get shamt_field value
	lbu $t1, 5($s1)							# $t1 = sixth char of second arg
	jal ascii_converter1					# go to function to convert ascii to dec
	andi $t2, $t1, 0x1F						# to get 4 -> 5 bits; $t2 = $t1
	andi $t2, $t2, 0x7						# $t2 = $t2 ANDI 7 (done to preserve last 3 bits from $t2)
	sll $t2, $t2, 2							# $t2 = $t2 shifted 2 to the left
	lbu $t1, 6($s1)							# $t1 = seventh char of second arg
	jal ascii_converter1					# go to function to convert ascii to dec
	srl $t3, $t1, 2							# $t3 = $t1 shifted 2 to the right
	or $t1, $t2, $t3						# $t1 = $t2 OR $t3
	jal print_rtype							# go to print type
	# get funct_field value
	lbu $t1, 6($s1)							# $t1 = seventh char of second arg
	jal ascii_converter1					# go to function to convert ascii to dec
	andi $t2, $t1, 0x3F						# to get 4 -> 6 bits; $t2 = $t1
	andi $t2, $t2, 3						# $t2 = $t2 ANDI 3 (done to preserve last 2 bits from $t2)
	sll $t2, $t2, 4							# $t2 = $t2 shifted 4 to the left
	lbu $t1, 7($s1)							# $t1 = eighth char of second arg
	jal ascii_converter1					# go to function to convert ascii to dec
	move $t3, $t1							# $t3 = $t1 (copy value)
	or $t1, $t2, $t3						# $t1 = $t2 OR $t3
	jal print_rtype							# go to print rtype
	j exit									# terminate function
# helper functions
ascii_converter1:
	li $t0, 'A'								# $t2 = 41 (in hex), lower bound A-F
	bge $t1, $t0, letter1					# if $t1 >= 'A' go to letter1
	addi $t1, $t1, -48						# else $t1 = $t1 - 48 (this will give dec value, when num)
	jr $ra									# jump back to where function was called from
	letter1:
	addi $t1, $t1, -55						# $t1 = $t1 - 55 (this will give dec value, when letter)
	jr $ra									# jump back to where function was called from
print_rtype:
	move $a0, $t1							# $a0 = $t1 (prepare to print int value)
	li $v0, 1
	syscall
	li $a0, ' '								# $a0 = ' ' (prepare to print space)
	li $v0, 11
	syscall
	jr $ra									# jump back to where function was called from
	
# PART III
hex_to_float:
	li $t0, 48								# $t0 = '0'
	li $t1, 57								# $t1 = '9'
	li $t2, 65								# $t2 = 'A'
	li $t3, 70								# $t3 = 'F'
# check that chars are between 0-9, A-F and convert 
check_first:
	lbu $s2, 0($s1)							# $s2 = first char of second arg
	blt $s2, $t0, print_invalid_args		# if first char < '0', print error
	bgt $s2, $t3, print_invalid_args		# if first char > 'F', print error
	ble $s2, $t1, first_is_digit			# if first char <= '9', use digit conversion
	bge $s2, $t2, first_is_letter			# if first char => 'A', use letter conversion
	first_is_digit:
	addi $s2, $s2, -48						# if first is digit, subtract 48 to get value
	j check_second							# then go check second char
	first_is_letter:						
	addi $s2, $s2, -55						# else if first is letter, subtract 55 to get value then check second char
check_second:
	lbu $s3, 1($s1)							# $s3 = second char of second arg
	blt $s3, $t0, print_invalid_args		# if second char < '0', print error
	bgt $s3, $t3, print_invalid_args		# if second char > 'F', print error
	ble $s3, $t1, second_is_digit			# if second char <= '9', use digit conversion
	bge $s3, $t2, second_is_letter			# if second char => 'A', use letter conversion
	second_is_digit:
	addi $s3, $s3, -48						# if second is digit, subtract 48 to get value
	j check_third							# then go check third char
	second_is_letter:
	addi $s3, $s3, -55						# else if second is letter, subtract 55 to get value then check third char
check_third:
	lbu $s4, 2($s1)							# $s4 = third char of second arg
	blt $s4, $t0, print_invalid_args		# if third char < '0', print error
	bgt $s4, $t3, print_invalid_args		# if third char > 'F', print error
	ble $s4, $t1, third_is_digit			# if third char <= '9', use digit conversion
	bge $s4, $t2, third_is_letter			# if third char => 'A', use letter conversion
	third_is_digit:
	addi $s4, $s4, -48						# if third is digit, subtract 48 to get value
	j check_fourth							# then go check fourth char
	third_is_letter:
	addi $s4, $s4, -55						# else if third is letter, subtract 55 to get value then check fourth char
check_fourth:
	lbu $s5, 3($s1)							# $s5 = fourth char of second arg
	blt $s5, $t0, print_invalid_args		# if fourth char < '0', print error
	bgt $s5, $t3, print_invalid_args		# if fourth char > 'F', print error
	ble $s5, $t1, fourth_is_digit			# if fourth char <= '9', use digit conversion
	bge $s5, $t2, fourth_is_letter			# if fourth char => 'A', use letter conversion
	fourth_is_digit:
	addi $s5, $s5, -48						# if fourth is digit, subtract 48 to get value
	j get_float								# then go convert values to float 
	fourth_is_letter:
	addi $s5, $s5, -55						# else if fourth is letter, subtract 55 to get value then convert values to float
# convert to one floating-point value
get_float:
	# get leading bit
	srl $t0, $s2, 3							# $t0 = $s2 shifted 3 to the right
	# get exponent value
	andi $t1, $s2, 0x1F						# to get 4 -> 5 bits
	andi $t1, $s2, 0x7						# $t1 = $s2 ANDI 7 (to keep last 3 bits)
	sll $t1, $t1, 2							# $t1 = $t1 shifted 2 to the left
	srl $t3, $s3, 2							# $t3 = $s3 shifted 2 to the right
	or $t1, $t1, $t3						# $t1 = $t1 OR $t3
	# get fraction value
	andi $t2, $s3, 0x3FF					# to get 4 -> 10 bits
	andi $t2, $t2, 0x3						# $t2 = $t2 ANDI 2 (to keep last 2 bits)
	sll $t2, $t2, 8							# $t2 = $t2 shifted 8 to the left (to bring to "front")
	andi $t5, $s4, 0xFF						# to get 4 -> 8 bits
	sll $t5, $t5, 4							# $t5 = $t5 shifted 4 to the left (to bring to "front")
	or $t2, $t2, $t5						# $t2 = $t2 OR $t5
	or $t2, $t2, $s5						# $t2 = $t2 OR $s5 
# check for special values
	li $t3, 31								# $t3 = 11111 (to compare exponent for special value)
	bnez $t1, cont_check_exp				# if exp != 0, continue checking value of exp
	bnez $t2, print_final_value				# if fraction != 0, go to print final value 
	j print_zero							# otherwise, print zero
	cont_check_exp:
	bne $t1, $t3, print_final_value			# if exp != 11111, print final value
	bnez $t2, NaN_value						# if fraction != 0, go to NaN value
	bnez $t0, print_neg_infinity			# if leading bit != 0, go to print neg inf
	j print_pos_infinity					# otherwise, print pos infinity
	NaN_value:
	li $t3, 0x3FF							# $t3 = 1111111111
	ble $t2, $t3, print_NaN					# if fraction <= $t3, go to print NaN		
print_final_value:		
	li $t3, 1								# $t3 = 1 (to be used for printing num 1 as neg or pos)
	# print 1 when leading bit is "pos" or -1 when leading bit is "neg"
	bnez $t0, leading_neg					# if leading bit != zero, go to leading_neg
	move $a0, $t3							# prepare to print 1 (when leading is positive)
	li $v0, 1
	syscall
	li $a0, '.'								# prepare to print radix point
	li $v0, 11
	syscall
	j print_fraction						# go print fraction
	leading_neg:
	li $a0, '-'								# prepare to print minus sign (when leading is neg)
	li $v0, 11
	syscall
	move $a0, $t3							# prepare to print 1
	li $v0, 1
	syscall
	li $a0, '.'								# prepare to print radix point
	li $v0, 11
	syscall
	print_fraction:
	li $t3, 1								# $t3 = 1 (i = 1)
	li $t4, 10								# $t4 = 10 (length)
	move $t5, $t2							# $t5 = $t2 (copy of fraction value)
	fraction_loop:
	bgt $t3, $t4, print_exponent			# when i > 10, go to print exponent
	sub $t6, $t4, $t3						# $t6 = length - i
	srlv $t7, $t5, $t6						# $t7 = $t5 shifted to the right by num of places specified in $t6
	andi $t7, $t7, 0x1						# $t7 = $t7 ANDI 1 (to preserve last 1 bit only)
	move $a0, $t7							# prepare to print $t7
	li $v0, 1
	syscall
	addi $t3, $t3, 1						# $t3 = $t3 + 1 (i++)
	j fraction_loop							# loop again
	print_exponent:
	la $a0, floating_point_str				# prepare to print "2*2ˆ"
	li $v0, 4
	syscall
	addi $t1, $t1, -15						# subtract 15 from exponent value
	move $a0, $t1							# prepare to print exponent value
	li $v0, 1
	syscall
	j exit									# terminate function
# printing special values strings
print_zero:
	la $a0, zero_str
	li $v0, 4
	syscall
	j exit
print_pos_infinity:
	la $a0, pos_infinity_str
	li $v0, 4
	syscall
	j exit
print_neg_infinity:
	la $a0, neg_infinity_str
	li $v0, 4
	syscall
	j exit
print_NaN:
	la $a0, NaN_str
	li $v0, 4
	syscall
	j exit
	
# PART IV		
poker_hand:
# validate input (separated into rank validation and suit validation for easier looping and comparison)
validate_hand:
	li $t0, '2'
	li $t1, '9'
	li $t2, 'T'
	li $t3, 'J'
	li $t4, 'Q'
	li $t5, 'K'
	li $t6, 'A'
	li $t7, 0								# i = 0
	li $t8, 5								# $t8 = 5 (for length)
	li $s4, 'S'								
	li $s5, 'C'
	li $s6, 'H'
	li $s7, 'D'
	hand_validation_loop:
	lbu $s2, 0($s1)							# $s2 = first char of 10 char input (it is a rank)
	blt $s2, $t0, print_invalid_args		# if char < '2' print error
	bgt $s2, $t1, letter_rank				# if char > '9' check for letter rank
	j validate_suit							# else move on to validate suit
	letter_rank:
	bgt $s2, $t2, print_invalid_args		# if char > 'T' print error
	bne $s2, $t2, not_T						# if char != 'T' keep checking
	j validate_suit							# else move on to validate suit
	not_T:
	bne $s2, $t3, not_J						# if char != 'J' keep checking
	j validate_suit							# else move on to validate suit
	not_J:
	bne $s2, $t4, not_Q						# if char != 'Q' keep checking
	j validate_suit							# else move on to validate suit
	not_Q:
	bne $s2, $t5, not_K						# if char != 'K' keep checking
	j validate_suit							# else move on to validate suit
	not_K:
	bne $s2, $t6, print_invalid_args		# if char != 'A' (or any of the above) print error
	validate_suit:
	lbu $s3, 1($s1)							# $s3 = second char of 10 char input (it is a suit)
	bne $s3, $s4, not_S						# if char != 'S' keep checking
	j check_next_card						# else check next card
	not_S:
	bne $s3, $s5, not_C						# if char != 'C' keep checking
	j check_next_card						# else check next card
	not_C:
	bne $s3, $s6, not_H						# if char != 'H' keep checking
	j check_next_card						# else check next card
	not_H:
	bne $s3, $s7, print_invalid_args		# if char != 'D' print invalid args
	check_next_card:
	addi $t7, $t7, 1						# i++
	addi $s1, $s1, 2						# go to next next char of 10 char input
	bne $t7, $t8, hand_validation_loop		# if i != 5, loop again
# encode ranks for hand:
# to keep track of the rank, this program will be using positions in register $s2
# if a hand contains a certain rank it will mark it with a '1' in the register
# the position chart to follow is: 2 3 4 5 6 7 8 9 T J Q K A 
# for example, if there is 2, 3, 4, K, A in a given hand this will correspond to 1 1100 0000 0011
# it will then make use of shifting/masking to get a value to aid in printing the correct type of hand	
set_ranks:
	lw $s1, addr_arg1						# $s1 = address of second arg from command-line
	li $s2, 0								# clear register
	li $s3, 0								# clear register
	li $t0, 0								# i = 0
	li $t1, 5								# $t1 = 5 (for length of loop)
	li $t2, 'A'
	li $t3, 'K'
	li $t4, 'Q'
	li $t5, 'J'
	li $t6, 'T'
ranks_loop:
	li $t7, '9'
	lbu $s2, 0($s1)							# $s2 = first rank of hand
	bne $s2, $t2, not_ace					# if $s2 != 'A', go to not ace
	ori $s3, $s3, 0x1						# else $s3 = 0 0000 0000 0001
	j cont_ranks_loop						# then check next rank
	not_ace:
	bne $s2, $t3, not_king					# if $s2 != 'K', go to not king
	ori $s3, $s3, 0x2						# else $s3 = 0 0000 0000 0010
	j cont_ranks_loop						# then check next rank
	not_king:
	bne $s2, $t4, not_queen					# if $s2 != 'Q', go to not queen
	ori $s3, $s3, 0x4						# else $s3 = 0 0000 0000 0100
	j cont_ranks_loop						# then check next rank
	not_queen:
	bne $s2, $t5, not_jack					# if $s2 != 'J', go to not jack
	ori $s3, $s3, 0x8						# else $s3 = 0 0000 0000 1000
	j cont_ranks_loop						# then check next rank
	not_jack:
	bne $s2, $t6, not_ten					# if $s2 != 'T', go to not ten
	ori $s3, $s3, 0x10						# else $s3 = 0 0000 0001 0000
	j cont_ranks_loop						# then check next rank
	not_ten:
	bne $s2, $t7, not_nine					# if $s2 != '9', go to not nine
	ori $s3, $s3, 0x20						# else $s3 = 0 0000 0010 0000
	j cont_ranks_loop						# then check next rank
	not_nine:
	addi $t7, $t7, -1						# $t7 = '8'
	bne $s2, $t7, not_eight					# if $s2 != '8', go to not eight
	ori $s3, $s3, 0x40						# else $s3 = 0 0000 0100 0000
	j cont_ranks_loop						# then check next rank
	not_eight:
	addi $t7, $t7, -1						# $t7 = '7'
	bne $s2, $t7, not_seven					# if $s2 != '7', go to not seven
	ori $s3, $s3, 0x80						# else $s3 = 0 0000 1000 0000
	j cont_ranks_loop						# then check next rank
	not_seven:
	addi $t7, $t7, -1						# $t7 = '6'
	bne $s2, $t7, not_six					# if $s2 != '6', go to not six
	ori $s3, $s3, 0x100						# else $s3 = 0 0001 0000 0000
	j cont_ranks_loop						# then check next rank
	not_six:
	addi $t7, $t7, -1						# $t7 = '5'
	bne $s2, $t7, not_five					# if $s2 != '5', go to not five
	ori $s3, $s3, 0x200						# else $s3 = 0 0010 0000 0000
	j cont_ranks_loop						# then check next rank
	not_five:
	addi $t7, $t7, -1						# $t7 = '4'		
	bne $s2, $t7, not_four					# if $s2 != '4', go to not four
	ori $s3, $s3, 0x400						# else $s3 = 0 0100 0000 0000
	j cont_ranks_loop						# then check next rank
	not_four:
	addi $t7, $t7, -1						# $t7 = '3'
	bne $s2, $t7, not_three					# if $s2 != '3', go to not three
	ori $s3, $s3, 0x800						# else $s3 = 0 1000 0000 0000
	j cont_ranks_loop						# then check next rank
	not_three:
	addi $t7, $t7, -1						# $t7 = '2'
	bne $s2, $t7, print_invalid_args		# if $s2 != '2', throw error
	ori $s3, $s3, 0x1000					# else $s3 = 1 0000 0000 0000
cont_ranks_loop:
	addi $t0, $t0, 1						# i++
	addi $s1, $s1, 2						# increment base address by 2
	bne $t0, $t1, ranks_loop				# if i != 5, loop again	
# now begin checking hand types; start by checking if the suits are the same
	lw $s1, addr_arg1						# $s1 = address of second arg from command-line
	lbu $t0, 1($s1)							# $t0 = first suit
	lbu $t1, 3($s1)							# $t1 = second suit
	lbu $t2, 5($s1)							# $t2 = third suit
	lbu $t3, 7($s1)							# $t3 = fourth suit
	lbu $t4, 9($s1)							# $t4 = fifth suit
	beq $t0, $t1, check_suit2				# if $t0 = $t1, check next
	j check_four_of_a_kind					# else go check for four of a kind
	check_suit2:		
	beq $t0, $t2, check_suit3				# if $t0 = $t2, check next
	j check_four_of_a_kind					# else go check for four of a kind
	check_suit3:
	beq $t0, $t3, check_suit4				# if $t0 = $t3, check next
	j check_four_of_a_kind					# else go check for four of a kind
	check_suit4:
	beq $t0, $t4, check_straight_flush		# if $t0 = $t4, check for straight flush
	j check_four_of_a_kind					# else go check for four of a kind
# if all the suits are the same it will check for a straight flush
# first check if it is a royal (straight) flush
check_straight_flush:
	li $t0, 0x1F							# $t0 = 0 0000 0001 1111
	beq $s3, $t0, print_royal_flush_str		# if $s3 = $t0, it is a royal flush
# else check if it is a (regular) straight flush
	li $t0, 1								# $t0 = 1 (i = 1)
	li $t1, 13								# $t1 = 13 (length)
	li $t4, 0								# clear register
	li $t5, 0								# clear register
	move $s4, $s3							# $s4 = ranks value (copy)
	straight_flush_loop:
	sub $t2, $t1, $t0 						# $t2 = length - i
	srlv $t3, $s4, $t2						# $t3 = $s4 shifted $t2 places to the right
	andi $t4, $t3, 0x1						# $t4 = last bit from shifted value 
	beqz $t4, cont_straight_loop			# if $t4 = 0, continue loop
	# else perform computation to see if consecutive ranks by ORing
	or $t5, $t5, $t3						# $t5 = $t5 OR $t3
	cont_straight_loop:
	addi $t0, $t0, 1						# i++
	ble $t0, $t1, straight_flush_loop		# when i <= 13 loop again
	li $t0, 0x1F							# $t0 = 1 1111 (indicates 5 ranks in consecutive order)
	bne $t5, $t0, check_four_of_a_kind 		# if $t5 != $t0, check if it is a four of a kind
	j print_straight_flush_str				# else it is a straight flush 
check_four_of_a_kind:
	lbu $t0, 0($s1)							# $t0 = first rank 
	lbu $t1, 2($s1)							# $t1 = second rank
	lbu $t2, 4($s1)							# $t2 = third rank
	lbu $t3, 6($s1)							# $t3 = fourth rank
	lbu $t4, 8($s1)							# $t4 = fifth rank
	li $t5, 1								# $t5 = 1 (count = 1)
	li $t6, 4								# $t6 = 4 (to compare when 4 cards are equal)
	bne $t0, $t1, fk_next_rank				# if $t0 != $t1 compare w next
	addi $t5, $t5, 1						# else count++
	fk_next_rank:
	bne $t0, $t2, fk_next_rank2				# if $t0 != $t2 compare w next
	addi $t5, $t5, 1						# else count++
	fk_next_rank2:
	bne $t0, $t3, fk_next_rank3				# if $t0 != $t3 compare w next
	addi $t5, $t5, 1						# else count++
	fk_next_rank3:
	bne $t0, $t4, fk_count					# if $t0 != $t4 get first count
	addi $t5, $t5, 1						# else count++
	fk_count:
	blt $t5, $t6, fk_cont_checking			# if count < 4, keep checking
	j print_four_of_a_kind_str				# else it is a four of a kind
	fk_cont_checking:
	li $t5, 1								# $t5 = 1 (count = 1)
	beq $t1, $t2, fk_next_rank4				# if $t1 = $t2, check next
	j check_full_house						# else go check if it is a full house
	fk_next_rank4:
	addi $t5, $t5, 1						# count++
	beq $t1, $t3, fk_next_rank5				# if $t1 = $t3, check next
	j check_full_house						# else go check if it is a full house
	fk_next_rank5:
	addi $t5, $t5, 1						# count++
	beq $t1, $t4, fk_count2					# if $t1 = $t4, get count
	j check_full_house						# else go check if it is a full house
	fk_count2:
	addi $t5, $t5, 1						#count++
	bge $t5, $t6, print_four_of_a_kind_str	# if count => 4, it is a four of a kind
check_full_house:
	li $t5, 1								# $t5 = 1 (count = 1)
	li $t6, 3								# $t6 = 3 (to compare when 3 cards are equal)
	bne $t0, $t1, fh_next_rank				# if $t0 != $t1 compare w next
	addi $t5, $t5, 1						# else count++
	fh_next_rank:
	bne $t0, $t2, fh_next_rank2				# if $t0 != $t2 compare w next
	addi $t5, $t5, 1						# else count++
	fh_next_rank2:
	bne $t0, $t3, fh_next_rank3				# if $t0 != $t3 compare w next
	addi $t5, $t5, 1						# else count++
	fh_next_rank3:
	bne $t0, $t4, fh_count					# if $t0 != $t4 get first count
	addi $t5, $t5, 1						# else count++
	fh_count:
	bne $t5, $t6, fh_cont_checking			# if count != 3, continue checking
	j check_rem								# else check remaining two cards
	fh_cont_checking:
	li $t5, 1								# reset count to start at 1
	bne $t1, $t2, fh_next_rank4				# if $t1 != $t2 compare w next
	addi $t5, $t5, 1						# else count++
	fh_next_rank4:
	bne $t1, $t3, fh_next_rank5				# if $t1 != $t3 compare w next
	addi $t5, $t5, 1						# else count++
	fh_next_rank5:
	bne $t1, $t4, fh_count2					# if $t1 != $t4 get second count
	addi $t5, $t5, 1						# else count++
	fh_count2:
	bne $t5, $t6, fh_cont_checking2			# if count != 3, continue checking
	j check_rem								# else check remaining two cards
	fh_cont_checking2:
	li $t5, 1								# reset count to start at 1
	beq $t2, $t3, fh_next_rank6				# if $t2 = $t3 compare w next
	j check_simple_flush					# else check if it is a flush
	fh_next_rank6:
	addi $t5, $t5, 1						# count++
	beq $t2, $t4, fh_count3					# if $t2 = $t4 get third count
	j check_simple_flush					# else check if it is a flush
	fh_count3:	
	addi $t5, $t5, 1						# count++
	bne $t5, $t6, check_simple_flush		# if count != 3, check if it is a simple flush else check rem cards
# to check if the remaining two cards are equal the entire ranks encoding will be used
# if the number of ones in encoding = 2 then the hand is a full house, else it'll check if it is a flush
check_rem:
	li $t0, 0								# $t0 = 0 (j = 0, to be used for counting ones in encoding)
	li $t1, 1								# $t1 = 1 (i = 1)
	li $t2, 13								# $t2 = 13 (length)
	li $t3, 2								# $t3 = 2 (max. value of ones allowed)
	move $s4, $s3							# $s4 = ranks encoding (copy)
	check_rem_loop:
	sub $t4, $t2, $t1						# $t4 = length - i
	srlv $t5, $s4, $t4						# $t5 = $s4 shifted $t4 places to the right
	andi $t6, $t5, 0x1						# $t6 = last bit from shifted value
	beqz $t6, cont_rem_loop					# if $t6 = 0, continue looping
	# else increment count of ones
	addi $t0, $t0, 1						# j++
	cont_rem_loop:
	addi $t1, $t1, 1						# i++
	ble $t1, $t2, check_rem_loop			# if i < len, continue looping, else end loop
	end_rem_loop:
	beq $t0, $t3, print_full_house_str		# if count of ones = 2, it is a full house else check for a simple flush
# check if it is a simple flush
check_simple_flush:
	lw $s1, addr_arg1						# $s1 = address of second arg from command-line
	lbu $t0, 1($s1)							# $t0 = first suit
	lbu $t1, 3($s1)							# $t1 = second suit
	lbu $t2, 5($s1)							# $t2 = third suit
	lbu $t3, 7($s1)							# $t3 = fourth suit
	lbu $t4, 9($s1)							# $t4 = fifth suit
	beq $t0, $t1, sf_suit2					# if $t0 = $t1, check next
	j check_simple_straight					# else go check for a simple straight
	sf_suit2:
	beq $t0, $t2, sf_suit3					# if $t0 = $t2, check next
	j check_simple_straight					# else go check for a simple straight
	sf_suit3:
	beq $t0, $t3, sf_suit4					# if $t0 = $t3, check next
	j check_simple_straight					# else go check for a simple straight
	sf_suit4:
	beq $t0, $t4, print_simple_flush_str	# if $t0 = $t4, it is a simple flush else check for a simple straight
check_simple_straight:
# check if it is a simple straight (following previous "check straight flush" method)
	li $t0, 1								# $t0 = 1 (i = 1)
	li $t1, 13								# $t1 = 13 (length)
	li $t4, 0								# clear register
	li $t5, 0								# clear register
	move $s4, $s3							# $s4 = ranks value (copy)
	simple_straight_loop:
	sub $t2, $t1, $t0 						# $t2 = length - i
	srlv $t3, $s4, $t2						# $t3 = $s4 shifted $t2 places to the right
	andi $t4, $t3, 0x1						# $t4 = last bit from shifted value 
	beqz $t4, cont_simple_flush_loop		# if $t4 = 0, continue loop
	# else perform computation to see if consecutive ranks by ORing
	or $t5, $t5, $t3						# $t5 = $t5 OR $t3
	cont_simple_flush_loop:
	addi $t0, $t0, 1						# else i++
	ble $t0, $t1, simple_straight_loop		# when i <= 13 loop again
	li $t0, 0x1F							# $t0 = 1 1111 (indicates 5 ranks in consecutive order)
	bne $t5, $t0, print_high_card_str		# if $t5 != $t0, it is a high card
	j print_simple_straight_str				# else it is a simple straight																																																																																																																																																																																																																																																				
# printing poker hand strings
print_royal_flush_str:	
	la $a0, royal_flush_str
	li $v0, 4
	syscall
	j exit	
print_straight_flush_str:
	la $a0, straight_flush_str
	li $v0, 4
	syscall 
	j exit
print_four_of_a_kind_str:
	la $a0, four_of_a_kind_str
	li $v0, 4
	syscall
	j exit
print_full_house_str:
	la $a0, full_house_str
	li $v0, 4
	syscall
	j exit
print_simple_flush_str:
	la $a0, simple_flush_str
	li $v0, 4
	syscall
	j exit
print_simple_straight_str:
	la $a0, simple_straight_str
	li $v0, 4
	syscall
	j exit
print_high_card_str:
	la $a0, high_card_str
	li $v0, 4
	syscall
	j exit

# PRINTING "INVALID" STRINGS
print_invalid_args:
	la $a0, invalid_args_error
	li $v0, 4
	syscall
	j exit
print_invalid_operation:
	la $a0, invalid_operation_error
	li $v0, 4
	syscall
	j exit

# END PROGRAM
exit:
    li $v0, 10   # terminate program
    syscall
