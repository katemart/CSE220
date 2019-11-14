# CSE 220 Programming Project #3
# Katheryn Martinez Hernandez
# ***REMOVED***
# ***REMOVED***

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text
# PART I
initialize:
	# check that num_rows and num_cols are valid
	bgtz $a1, init_check_cols					# if num_rows > 0, check num_cols
	li $a1, -1									# else num_rows = -1
	li $a2, -1									# and num_cols = -1
	init_check_cols:
	bgtz $a2, init_start						# if num_cols > 0, initialize
	li $a1, -1									# else num_rows = -1
	li $a2, -1									# and num_cols = -1
	j init_end									# and end function w/ no changes to mem
	# if num_rows and num_cols are valid, initialize
	init_start:
	sb $a1, 0($a0)								# store num_rows in struct
	sb $a2, 1($a0)								# store num_cols in struct
	mul $t0, $a1, $a2							# $t0 = row * col
	init_loop:
	sb $a3, 2($a0)								# store char in struct
	addi $a0, $a0, 1							# go to next char of struct
	addi $t0, $t0, -1							# $t0 = $t0 - 1
	bgtz $t0, init_loop							# if $t0 > 0, go to init_loop
	init_end:
	move $v0, $a1								# $v0 = num_rows
	move $v1, $a2								# $v1 = num_cols
	jr $ra										# return to where the function was called

# PART II
load_game:
	# allocate room on stack for 6 regs
	addi $sp, $sp, -24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $ra, 20($sp)
	# declare vars
	move $s0, $a0								# $s0 = struct 
	move $s1, $a1								# $s1 = file name
	# open file to read
	li $v0, 13									# syscall for open file
	move $a0, $s1								# $a0 = file name
	li $a1, 0									# $$a1 = 0 (read only flag)
	li $a2, 0									# mode is ignored
	syscall
	move $s2, $v0								# $s2 = file descriptor
	# check that file exists
	bltz $s2, load_file_error
	# if file exists, read and save num_rows into state
	addi $sp, $sp, -1							# buffer space
	jal read_digits								# get the num_rows
	bltz $v0, load_file_error
	move $s3, $v0								# $s3 = num_rows
	sb $s3, 0($s0)								# save num_rows into state
	# read and save num_cols into state
	jal read_digits								# get the num_cols
	bltz $v0, load_file_error
	move $s4, $v0								# $s4 = num_cols
	sb $s4, 1($s0)								# save num_cols into state
	# read and save rest of chars into state
	read_chars:
	li $t0, '\n'
	li $t1, 'O'
	li $t2, '.'									
	li $t3, 0									# O's_counter = 0
	li $t4, 0									# invalid_char_counter = 0
	mul $t5, $s3, $s4							# $t5 = num_rows * num_cols
	read_chars_loop:
	li $v0, 14									# syscall for read from file
	move $a0, $s2								# $a0 = file descriptor
	move $a1, $sp								# $a1 = buffer (which is $sp)
	li $a2, 1									# $a2 = read one char at a time
	syscall
	blez $v0, load_file_error
	lbu $t6, 0($sp)
	beqz $t6, end_of_file
	beq $t0, $t6, read_chars_loop				# if $t4 = \n, read next
	beq $t1, $t6, char_is_O						# if $t4 = O, char is valid
	bne $t2, $t6, char_is_invalid				# if $t4 != '.' it is an invalid char
	# if it isn't any of these cases, it is a '.'
	sb $t2, 2($s0)								# save . to struct
	j cont_read_chars_loop						# go to cont_read_chars_loop
	char_is_O:
	sb $t6, 2($s0)								# save O to struct
	addi $t3, $t3, 1							# O's_counter++
	j cont_read_chars_loop						# go to cont_read_chars_loop
	char_is_invalid:
	sb $t2, 2($s0)								# save . to struct
	addi $t4, $t4, 1							# invalid_char_counter++
	j cont_read_chars_loop						# go to cont_read_chars_loop
	cont_read_chars_loop:
	addi $s0, $s0, 1							# go to next char of struct
	addi $t5, $t5, -1							# decrement $t5
	bgtz $t5, read_chars_loop					# if $t5 > 0, loop again
	load_file_error:
	li $v0, -1									# $v0 = -1 to indicate error
	li $v1, -1									# $v1 = -1 to indicate error
	j end_load_game
	end_of_file:
	addi $sp, $sp, 1							# restore buffer space
	# close file 
	li $v0, 16									# syscall for close file
	move $a0, $s2								# $a0 = file descriptor
	syscall
	move $v0, $t3								# $v0 = O's_counter
	move $v1, $t4								# $v1 = invalid_char_counter
	end_load_game:
	# restore regs from stack
	lw $ra, 20($sp)
	lw $s4, 16($sp)
	lw $s3, 12($sp)
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 24
    jr $ra										# return to where the function was called  
# helper functions for load_game
read_digits:
	# get first digit
	li $v0, 14									# syscall for read from file
	move $a0, $s2								# $a0 = file descriptor
	move $a1, $sp								# $a1 = buffer (which is $sp)
	li $a2, 1									# $a2 = read one char at a time
	syscall
	blez $v0, num_reading_error					# if $v0 <= 0, something went wrong
	lbu $t0, 0($sp)								# $t0 = first char
	addi $t0, $t0, -48							# to convert to dec (first digit)
	# get second digit
	li $v0, 14									# syscall for read from file
	move $a0, $s2								# $a0 = file descriptor
	move $a1, $sp								# $a1 = buffer (which is $sp)
	li $a2, 1									# $a2 = read one char at a time
	syscall
	lbu $t1, 0($sp)								# $t1 = second char
	li $t2, '\n'							
	beq $t1, $t2, no_second_digit				# if $t1 = new line, there is only one digit
	addi $t1, $t1, -48							# else convert to dec (second digit)
	# read \n
	li $v0, 14									# syscall for read from file
	move $a0, $s2								# $a0 = file descriptor
	move $a1, $sp								# $a1 = buffer (which is $sp)
	li $a2, 1	
	syscall
	# combine two digits into one
	li $t2, 10
	mul $t3, $t0, $t2							# $t3 = first digit * 10
	add $t3, $t1, $t3							# $t3 = (first dig * 10) + second digit
	move $v0, $t3								# $t3 = final digit (first + second together)
	j end_read_num
	no_second_digit:
	move $v0, $t0								# $t3 = final digit (only first)
	j end_read_num
	num_reading_error:
	li $v0, -1									# $v0 = -1 to indicate something went wrong
	end_read_num:
	jr $ra										# return to where the function was called

# PART III
get_slot:
	# check that row is within range
	bltz $a1, gs_invalid_range					# if row < 0, it is invalid
	lbu $t0, 0($a0)								# $t0 = num_rows from struct
	bge $a1, $t0, gs_invalid_range				# if num_rows => row, it is invalid
	# check that col is within range
	bltz $a2, gs_invalid_range					# if col < 0, it is invalid
	lbu $t1, 1($a0)								# $t1 = num_cols from struct
	bge $a2, $t1, gs_invalid_range				# if num_cols => col, it is invalid
	# get value for slot
	# formula: ((row * col_num) + col) * element_size which is 1
	# so, (($a1 * $t1) + $a2) * 1
	mul $t2, $a1, $t1							# $t2 = row * num_cols
	add $t2, $t2, $a2							# $t2 = (row * num_cols) + col
	addi $a0, $a0, 2							# $a0 = baseaddr struct + 2 (bc row_num & col_num at beg)
	add $t2, $a0, $t2							# $t2 = baseaddr struct + $t2
	lbu $v0, 0($t2)								# $v0 = value from $t2
	j end_get_slot								# go to end_get_slot
	gs_invalid_range:
	li $v0, -1									# $v0 = -1
	end_get_slot:								
    jr $ra										# return to where the function was called

# PART IV
set_slot:
	# check that row is within range
	bltz $a1, ss_invalid_range					# if row < 0, it is invalid
	lbu $t0, 0($a0)								# $t0 = num_rows from struct
	bge $a1, $t0, ss_invalid_range				# if num_rows => row, it is invalid
	# check that col is within range
	bltz $a2, ss_invalid_range					# if col < 0, it is invalid
	lbu $t1, 1($a0)								# $t1 = num_cols from struct
	bge $a2, $t1, ss_invalid_range				# if num_cols => col, it is invalid
	# set value for slot
	# formula: ((row * col_num) + col) * element_size which is 1
	# so, (($a1 * $t1) + $a2) * 1
	mul $t2, $a1, $t1							# $t2 = row * num_cols
	add $t2, $t2, $a2							# $t2 = (row * num_cols) + col
	addi $a0, $a0, 2							# $a0 = baseaddr struct + 2 (bc row_num & col_num at beg)
	add $t2, $a0, $t2							# $t2 = baseaddr struct + $t2
	sb $a3, 0($t2)								# save $a3 (char given) into struct
	move $v0, $a3								# $v0 = val of char given
	j end_set_slot								# go to end_set_slot
	ss_invalid_range:
	li $v0, -1									# $v0 = -1
	end_set_slot:
    jr $ra										# return to where the function was called

# PART V
rotate:
	# allocate room on the stack for 7 registers
	addi $sp, $sp, -28
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $ra, 24($sp)
	# declare vars
	move $s0, $a0								# $s0 = piece
	move $s1, $a1								# $s1 = rotation
	move $s2, $a2								# $s2 = rotated_piece
	bltz $s1, invalid_rotation					# check if rotation is valid
	# check if piece given is O
	li $t0, 2
	lbu $s3, 0($s0)								# $t1 = num_rows of piece
	lbu $s4, 1($s0)								# $t2 = num_cols of piece
	bne $t0, $s3, cont_rotate					# if num_rows != 2, check rest of pieces
	bne $t0, $s4, cont_rotate					# if num_cols != 2, check rest of pieces
	jal rotate_init_original					# set rotated_piece for O
	j end_rotate								# go to end_rotate
	# if piece is not O, check rest of pieces
	cont_rotate:
	li $t0, 1
	li $t1, 2
	li $t2, 3
	li $t3, 4
	div $s1, $t3								# divide rotation by 4
	mfhi $s5									# $s5 = remainder
	beqz $s5, rotate_zero						# when $s5 = 0, leave at original pos (rotations for 0 or muliples of 4)
	beq $s5, $t0, rotate_once					# when $s5 = 1, rotate once
	beq $s5, $t1, rotate_twice					# when $s5 = 2, rotate twice
	beq $s5, $t2, rotate_thrice					# when $s5 = 3, rotate thrice
rotate_zero:
	jal check_rotated_I							# check if given piece is I, rotated I or not I	
	li $t0, 2									# $t0 = 2
	beq $t0, $v0, cont_check_zero				# if $t0 = $v0, then it is not I so cont checking
	jal rotate_init_original					# else if it is I go to rotate_init_original
	j end_rotate								# and go to end_rotate
	# non-rotated piece is given:
	cont_check_zero:
	jal check_rotated_piece						# check if given piece is rotated
	bltz $v0, invalid_rotation					# if $v0 < 0, it is an invalid piece
	li $t0, 1
	beq $t0, $v0, cont_rotate_zero				# if $t0 = $v0, then piece is rotated so cont rotating
	jal rotate_init_original					# initialize piece
	rotate_zero_loop1:
	li $s3, 0									# $s3 = 0
	li $s4, 2									# $s4 = 2 (value for loop)
	start_rotate_zero_loop1:
	move $a0, $s0								# $a0 = (original) piece
	li $a1, 0									# $a1 = 0
	move $a2, $s3								# $a2 = $s3
	jal get_slot								# go to get_slot
	move $a0, $s2								# $a0 = rotated_piece
	li $a1, 0									# $a1 = 0
	move $a2, $s3								# $a2 = $s3
	move $a3, $v0								# $a3 = char from get_slot
	jal set_slot								# go to set_slot
	addi $s3, $s3, 1							# increment col index
	ble $s3, $s4, start_rotate_zero_loop1		# if col index <= 2, loop again
	li $s3, 0									# $s3 = 0
	cont_rotate_zero_loop1:
	move $a0, $s0								# $a0 = (original) piece
	li $a1, 1									# $a1 = 1
	move $a2, $s3								# $a2 = $s3
	jal get_slot								# go to get_slot
	move $a0, $s2								# $a0 = rotated_piece
	li $a1, 1									# $a1 = 1
	move $a2, $s3								# $a2 = $s3
	move $a3, $v0								# $a3 = char from get_slot
	jal set_slot								# go to set_slot	
	addi $s3, $s3, 1							# increment col index
	ble $s3, $s4, cont_rotate_zero_loop1		# if col index <= 2, loop again																			
	j end_rotate								# go to end_rotate
	# rotated piece is given:
	cont_rotate_zero:
	jal rotate_init_original					# initialize piece
	rotate_zero_loop2:
	li $s3, 0									# $s3 = 0
	li $s4, 2									# $s4 = 2 (value for loop)
	start_rotate_zero_loop2:
	move $a0, $s0								# $a0 = (original) piece
	move $a1, $s3								# $a1 = $s3
	li $a2, 0									# $a2 = 0
	jal get_slot								# go to get_slot
	move $a0, $s2								# $a0 = rotated_piece
	move $a1, $s3								# $a1 = $s3
	li $a2, 0									# $a2 = 0
	move $a3, $v0								# $a3 = char from get_slot
	jal set_slot								# go to set_slot
	move $a0, $s0								# $a0 = (original) piece
	move $a1, $s3								# $a1 = $s3
	li $a2, 1									# $a2 = 1
	jal get_slot								# go to get_slot
	move $a0, $s2								# $a0 = rotated_piece
	move $a1, $s3								# $a1 = $s3
	li $a2, 1									# $a2 = 1
	move $a3, $v0								# $a3 = char from get_slot
	jal set_slot								# go to set_slot
	addi $s3, $s3, 1							# increment col index
	ble $s3, $s4, start_rotate_zero_loop2		# if col index <= 2, loop again
	j end_rotate								# go to end_rotate
rotate_once:
	jal check_rotated_I							# check if given piece is I, rotated I or not I	
	li $t0, 2									# $t0 = 2
	beq $t0, $v0, cont_check_once				# if $t0 = $v0, then it is not I so cont checking
	jal rotate_init_flip						# else if it is I go to rotate_init_flip
	j end_rotate								# and go to end_rotate
	# non-rotated piece is given:
	cont_check_once:
	jal check_rotated_piece						# check if given piece is rotated
	bltz $v0, invalid_rotation					# if $v0 < 0, it is an invalid piece
	li $t0, 1
	beq $t0, $v0, cont_rotate_once				# if $t0 = $v0, then piece is rotated so cont rotating
	jal rotate_init_flip						# initialize piece
	rotate_once_loop1:
	li $s3, 0									# $s3 = 0
	li $s4, 2									# $s4 = 2 (value for loop)
	start_rotate_once_loop1:
	move $a0, $s0								# $a0 = (original) piece
	li $a1, 0									# $a1 = 0
	move $a2, $s3								# $a2 = $s3
	jal get_slot								# go to get_slot
	move $a0, $s2								# $a0 = rotated_piece
	move $a1, $s3								# $a1 = $s3
	li $a2, 1									# $a2 = 1
	move $a3, $v0								# $a3 = char from get_slot
	jal set_slot								# go to set_slot
	addi $s3, $s3, 1							# increment (get_slot) col index
	ble $s3, $s4, start_rotate_once_loop1		# if col index <= 2, loop again
	li $s3, 0
	cont_rotate_once_loop1:
	move $a0, $s0								# $a0 = (original) piece
	li $a1, 1									# $a1 = 1
	move $a2, $s3								# $a2 = $s3
	jal get_slot								# go to get_slot
	move $a0, $s2								# $a0 = rotated_piece
	move $a1, $s3								# $a1 = $s3
	li $a2, 0									# $a2 = 0
	move $a3, $v0								# $a3 = char from get_slot
	jal set_slot								# go to set_slot	
	addi $s3, $s3, 1							# increment (get_slot) col index
	ble $s3, $s4, cont_rotate_once_loop1		# if col index <= 2, loop again																			
	j end_rotate								# go to end_rotate		
	# rotated piece is given:	
	cont_rotate_once:
	jal rotate_init_flip						# initialize piece
	rotate_once_loop2:
	li $s3, 0									# $s3 = 0
	li $s4, 2									# $s4 = 2
	li $s5, 2									# $s5 = 2 (value for loop)
	start_rotate_once_loop2:
	move $a0, $s0								# $a0 = (original) piece
	move $a1, $s3								# $a1 = $s3
	li $a2, 0									# $a2 = 0
	jal get_slot								# go to get_slot
	move $a0, $s2								# $a0 = rotated_piece
	li $a1, 0									# $a1 = 0
	move $a2, $s4								# $a2 = $s4
	move $a3, $v0								# $a3 = char from get_slot
	jal set_slot
	move $a0, $s0								# $a0 = (original) piece
	move $a1, $s3								# $a1 = $s3
	li $a2, 1									# $a2 = 1
	jal get_slot								# go to get_slot
	move $a0, $s2								# $a0 = rotated_piece
	li $a1, 1									# $a1 = 1
	move $a2, $s4								# $a2 = $s4
	move $a3, $v0								# $a3 = char from get_slot
	jal set_slot								# go to set_slot
	addi $s4, $s4, -1							# decrement (set_slot) col index
	addi $s3, $s3, 1							# increment (get_slot) col index
	ble $s3, $s5, start_rotate_once_loop2		# if col index <= 2, loop again
	j end_rotate								# go to end_rotate
rotate_twice:
	jal check_rotated_I							# check if given piece is I, rotated I or not I	
	li $t0, 2									# $t0 = 2
	beq $t0, $v0, cont_check_twice				# if $t0 = $v0, then it is not I so cont checking
	jal rotate_init_original					# else if it is I go to rotate_init_original
	j end_rotate								# and go to end_rotate
	# non-rotated piece is given:
	cont_check_twice:
	jal check_rotated_piece						# check if given piece is rotated
	bltz $v0, invalid_rotation					# if $v0 < 0, it is an invalid piece
	li $t0, 1
	beq $t0, $v0, cont_rotate_twice				# if $t0 = $v0, then piece is rotated so cont rotating
	jal rotate_init_original					# initialize piece
	rotate_twice_loop1:
	li $s3, 0									# $s3 = 0
	li $s4, 2									# $s4 = 2
	li $s5, 2									# $s5 = 2 (value for loop)
	start_rotate_twice_loop1:
	move $a0, $s0								# $a0 = (original) piece
	li $a1, 0									# $a1 = 0
	move $a2, $s3								# $a2 = $s3
	jal get_slot								# go to get_slot
	move $a0, $s2								# $a0 = rotated_piece
	li $a1, 1									# $a1 = 1
	move $a2, $s4								# $a2 = $s4
	move $a3, $v0								# $a3 = char from get_slot
	jal set_slot								# go to set_slot
	addi $s4, $s4, -1							# decrement (set_slot) col index
	addi $s3, $s3, 1							# increment (get_slot) col index
	ble $s3, $s5, start_rotate_twice_loop1		# if col index <= 2, loop again
	li $s3, 0
	li $s4, 2
	cont_rotate_twice_loop1:
	move $a0, $s0								# $a0 = (original) piece
	li $a1, 1									# $a1 = 1
	move $a2, $s3								# $a2 = $s3
	jal get_slot								# go to get_slot
	move $a0, $s2								# $a0 = rotated_piece
	li $a1, 0									# $a1 = 0
	move $a2, $s4								# $a2 = $s4
	move $a3, $v0								# $a3 = char from get_slot
	jal set_slot								# go to set_slot
	addi $s4, $s4, -1							# decrement (set_slot) col index
	addi $s3, $s3, 1							# increment (get_slot) col index
	ble $s3, $s5, cont_rotate_twice_loop1		# if col index <= 2, loop again
	j end_rotate								# go to end_rotate		
	# rotated piece is given:	
	cont_rotate_twice:
	jal rotate_init_original					# initialize piece
	rotate_twice_loop2:
	li $s3, 0									# $s3 = 0
	li $s4, 2									# $s4 = 2
	li $s5, 2									# $s5 = 2 (value for loop)
	start_rotate_twice_loop2:
	move $a0, $s0								# $a0 = (original) piece
	move $a1, $s3								# $a1 = $s3
	li $a2, 0									# $a2 = 0
	jal get_slot								# go to get_slot
	move $a0, $s2								# $a0 = rotated_piece
	move $a1, $s4								# $a1 = $s4
	li $a2, 1									# $a2 = 1
	move $a3, $v0								# $a3 = char from get_slot
	jal set_slot								# go to set_slot
	move $a0, $s0								# $a0 = (original) piece
	move $a1, $s3								# $a1 = $s3
	li $a2, 1									# $a2 = 1
	jal get_slot								# go to get_slot
	move $a0, $s2								# $a0 = rotated_piece
	move $a1, $s4								# $a1 = $s4
	li $a2, 0									# $a2 = 0
	move $a3, $v0								# $a3 = char from get_slot
	jal set_slot								# go to set_slot
	addi $s4, $s4, -1							# decrement (set_slot) row index
	addi $s3, $s3, 1							# increment (get_slot) row index
	ble $s3, $s5, start_rotate_twice_loop2		# if col index <= 2, loop again
	j end_rotate								# go to end_rotate
rotate_thrice:
	jal check_rotated_I							# check if given piece is I, rotated I or not I	
	li $t0, 2									# $t0 = 2
	beq $t0, $v0, cont_check_thrice				# if $t0 = $v0, then it is not I so cont checking
	jal rotate_init_flip						# else if it is I go to rotate_init_flip
	j end_rotate								# and go to end_rotate
	# non-rotated piece is given:
	cont_check_thrice:
	jal check_rotated_piece						# check if given piece is rotated
	bltz $v0, invalid_rotation					# if $v0 < 0, it is an invalid piece
	li $t0, 1
	beq $t0, $v0, cont_rotate_thrice			# if $t0 = $v0, then piece is rotated so cont rotating
	jal rotate_init_flip						# initialize piece 
	rotate_thrice_loop1:
	li $s3, 0									# $s3 = 0
	li $s4, 2									# $s4 = 2
	li $s5, 2									# $s5 = 2 (value for loop)
	start_rotate_thrice_loop1:
	move $a0, $s0								# $a0 = (original) piece
	li $a1, 0									# $a1 = 0
	move $a2, $s3								# $a2 = $s3
	jal get_slot								# go to get_slot
	move $a0, $s2								# $a0 = rotated_piece
	move $a1, $s4								# $a1 = $s4
	li $a2, 0									# $a2 = 0
	move $a3, $v0								# $a3 = char from get_slot
	jal set_slot								# go to set_slot
	addi $s4, $s4, -1							# decrement (set_slot) row index
	addi $s3, $s3, 1							# increment (get_slot) col index
	ble $s3, $s5, start_rotate_thrice_loop1		# if col index <= 2, loop again
	li $s3, 0
	li $s4, 2
	cont_rotate_thrice_loop1:
	move $a0, $s0								# $a0 = (original) piece
	li $a1, 1									# $a1 = 1
	move $a2, $s3								# $a2 = $s3
	jal get_slot								# go to get_slot
	move $a0, $s2								# $a0 = rotated_piece
	move $a1, $s4								# $a1 = $s4
	li $a2, 1									# $a2 = 1
	move $a3, $v0								# $a3 = char from get_slot
	jal set_slot								# go to set_slot
	addi $s4, $s4, -1							# decrement (set_slot) col index
	addi $s3, $s3, 1							# increment (get_slot) col index
	ble $s3, $s5, cont_rotate_thrice_loop1		# if col index <= 2, loop again
	j end_rotate								# go to end_rotate		
	# rotated piece is given:
	cont_rotate_thrice:
	jal rotate_init_flip						# initialize piece
	rotate_thrice_loop2:
	li $s3, 0									# $s3 = 0
	li $s4, 2									# $s4 = 2 (value for loop)
	start_rotate_thrice_loop2:
	move $a0, $s0								# $a0 = (original) piece
	move $a1, $s3								# $a1 = $s3
	li $a2, 0									# $a2 = 0
	jal get_slot								# go to get_slot
	move $a0, $s2								# $a0 = rotated_piece
	li $a1, 1									# $a1 = 1
	move $a2, $s3								# $a2 = $a3
	move $a3, $v0								# $a3 = char from get_slot
	jal set_slot								# go to set_slot
	move $a0, $s0								# $a0 = (original) piece
	move $a1, $s3								# $a1 = $s3
	li $a2, 1									# $a2 = 1
	jal get_slot								# go to get_slot
	move $a0, $s2								# $a0 = rotated_piece
	li $a1, 0									# $a1 = 0
	move $a2, $s3								# $a2 = $a3
	move $a3, $v0								# $a3 = char from get_slot
	jal set_slot								# go to set_slot
	addi $s3, $s3, 1							# increment (get_slot) row index
	ble $s3, $s4, start_rotate_thrice_loop2		# if col index <= 2, loop again
	j end_rotate								# go to end_rotate
	invalid_rotation:
	li $s1, -1									# num of rotations = -1
	end_rotate:
	move $v0, $s1								# $v0 = number of rotations
	# restore regs from stack
	lw $ra, 24($sp)
	lw $s5, 20($sp)
	lw $s4, 16($sp)
	lw $s3, 12($sp)
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 28
    jr $ra										# go back to where function was called
# rotate helper functions
rotate_init_original:
	move $s5, $ra
	li $t0, 'O'
	move $a0, $s2								# $a0 = rotated_piece
	move $a1, $s3								# $a1 = num_rows
	move $a2, $s4								# $a2 = num_cols
	move $a3, $t0								# $a3 = 'O'
	jal initialize								# go to initialize piece
	move $ra, $s5
	jr $ra										# go back to where function was called
rotate_init_flip:
	move $s5, $ra
	li $t0, 'O'
	move $a0, $s2								# $a0 = rotated_piece
	move $a1, $s4								# $a1 = num_rows
	move $a2, $s3								# $a2 = num_cols
	move $a3, $t0								# $a3 = 'O'
	jal initialize								# go to initialize piece
	move $ra, $s5
	jr $ra										# go back to where function was called
check_rotated_I:
	move $s5, $ra
	li $t0, 1
	li $t1, 4
	li $v0, 0									# $v0 = 0
	lbu $s3, 0($s0)								# $s3 = num_rows of piece
	lbu $s4, 1($s0)								# $s4 = num_cols of piece
	bne $t0, $s3, cont_check_rotated_I			# if num_rows != 1, it can = 4 (rotated I)
	bne $t1, $s4, cont_check_rotated_I			# if num_cols != 4, it can = 1 (rotated I)
	j end_check_rotated_I						# I is not rotated, return 0
	cont_check_rotated_I:
	bne $t1, $s3, not_I							# if num_rows != 4, go rotate rest of pieces (bc not I)
	bne $t0, $s4, not_I							# if num_cols != 1, go rotate rest of pieces (bc not I)
	li $v0, 1									# I is rotated, return 1 
	j end_check_rotated_I						# go to end_check_rotated_I
	not_I:
	li $v0, 2									# piece is not I, return 2
	end_check_rotated_I:
	move $ra, $s5	
	jr $ra										# go back to where function was called
check_rotated_piece:
	move $s5, $ra
	li $t0, 2
	li $t1, 3
	li $v0, 0									# $v0 = 0
	lbu $s3, 0($s0)								# $s3 = num_rows of piece
	lbu $s4, 1($s0)								# $s4 = num_cols of piece
	bne $t0, $s3, cont_check_rotated_piece		# if num_rows != 2, it can = 3 (rotated piece)
	bne $t1, $s4, cont_check_rotated_piece		# if num_cols != 3, it can = 2 (rotated piece)
	j end_check_rotated_piece					# piece is not rotated, return 0
	cont_check_rotated_piece:
	bne $t1, $s3, invalid_piece					# if num_rows != 3, it is not a valid piece
	bne $t0, $s4, invalid_piece					# if num_cols != 2, it is not a valid piece
	li $v0, 1									# piece is rotated, return 1
	j end_check_rotated_piece
	invalid_piece:
	li $v0, -1									# piece is not valid, return -1
	end_check_rotated_piece:
	move $ra, $s5		
	jr $ra										# go back to where function was called

# PART VI
count_overlaps:
	# allocate room on stack for 9 registers
	addi $sp, $sp, -36
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
	sw $ra, 32($sp)
	# declare vars
	move $s0, $a0								# $s0 = state
	move $s1, $a1								# $s1 = row
	move $s2, $a2								# $s2 = col
	move $s3, $a3								# $s3 = piece
	# check that args for row and col are valid
	bltz $s1, invalid_placement					# if row < 0, invalid placement
	bltz $s2, invalid_placement					# if col < 0, invalid placement
	lbu $s4, 0($s0)								# $s4 = num_rows of state
	lbu $s5, 1($s0)								# $s5 = num_cols of state
	bgt $s1, $s4, invalid_placement				# if row > num_rows of state, invalid placement
	bgt $s2, $s5, invalid_placement				# if col > num_cols of state, invalid placement
	# check if piece given is O
	li $t0, 2
	lbu $s4, 0($s3)								# $s4 = num_rows of piece
	lbu $s5, 1($s3)								# $s5 = num_cols of piece
	bne $t0, $s4, count_overlaps_I				# if num_rows != 2, check if I
	bne $t0, $s5, count_overlaps_I				# if num_cols != 2, check if I
	# check that O fits 
	addi $t0, $s1, 1							# $t0 = row + 1
	addi $t1, $s2, 1							# $t1 = col + 1
	lbu $s4, 0($s0)								# $s4 = num_rows of state
	lbu $s5, 1($s0)								# $s5 = num_cols of state
	# has to be bge instead of bgt bc error when doing example 1 9 with 2 2
	bge $t0, $s4, invalid_placement				# if (row + 1) => num_rows of state, invalid placement
	bge $t1, $s5, invalid_placement				# if (col + 1) => num_cols of state, invalid placement
	# if O fits, count the overlaps
count_overlaps_O:
	li $t6, 'O'
	li $t7, 4									# counter
	addi $t8, $s1, 1							# $t8 = row + 1
	li $s7, 0									# return val
	count_overlaps_O_loop:
	lbu $s5, 2($s3)								# third char of piece
	bne $s5, $t6, count_overlaps_O_loop_cont	# if $s5 != 'O' check next char
	move $a0, $s0								# $a0 = state
	move $a1, $s1								# $a1 = row
	move $a2, $s2								# $a2 = col
	jal get_slot								# go to get_slot
	bne $s5, $v0, count_overlaps_O_loop_cont	# if $s5 != $v0, check next
	addi $s7, $s7, 1							# else returnval++
	count_overlaps_O_loop_cont:
	lbu $s5, 4($s3)								# fifth char of piece
	bne $s5, $t6, count_overlaps_O_loop_next	# if $s5 != 'O' check next char
	move $a0, $s0								# $a0 = state
	move $a1, $t8								# $a1 = row + 1
	move $a2, $s2								# $a2 = col
	jal get_slot								# go to get_slot
	bne $s5, $v0, count_overlaps_O_loop_next	# if $s5 != $v0, check next
	addi $s7, $s7, 1							# else returnval++
	count_overlaps_O_loop_next:
	addi $s2, $s2, 1							# col++
	addi $s3, $s3, 1							# go to next char of piece
	addi $t7, $t7, -2							# decrement counter
	bgtz $t7, count_overlaps_O_loop				# if counter > 0, loop again
	j end_count_overlaps						# else go to end func
count_overlaps_I:
	move $s6, $s0								# $s6 = state (temp)
	move $s7, $s3								# $s7 = piece (temp)
	move $s0, $s3								# $s0 = piece (to use check_rotated_I func)
	jal check_rotated_I							# check if I
	move $s0, $s6								# $s0 = state (original val)
	move $s3, $s7								# $s3 = piece (original val)
	li $t0, 2	
	beq $t0, $v0, count_overlaps_rest			# if $v0 = 2, it is not I so check rest
	li $t0, 1
	beq $t0, $v0, count_overlaps_I_rot			# if $t1 = 1, it is a rotated I
	# check that non-rotated I fits
	addi $t0, $s2, 3							# $t0 = col + 3
	lbu $s4, 1($s0)								# $s4 = num_cols of state
	bge $t0, $s4, invalid_placement				# if (col + 3) => num_cols of state, invalid placement
	# if non-rotated I fits, count the overlaps (free to use $s4, $s5, $s6, $s7)
	li $t6, 'O'
	li $t7, 4									# counter
	li $s7, 0									# return val
	count_overlaps_I_loop:
	lbu $s5, 2($s3)								# third char of piece
	bne $s5, $t6, count_overlaps_I_loop_next	# if $s5 != 'O' check next char
	move $a0, $s0								# $a0 = state
	move $a1, $s1								# $a1 = row
	move $a2, $s2								# $a2 = col
	jal get_slot								# go to get_slot
	bne $s5, $v0, count_overlaps_I_loop_next	# if $s5 != $v0, check next
	addi $s7, $s7, 1							# else returnval++							
	count_overlaps_I_loop_next:
	addi $s2, $s2, 1							# col++
	addi $s3, $s3, 1							# go to next char of piece
	addi $t7, $t7, -1							# decrement counter
	bgtz $t7, count_overlaps_I_loop				# if counter > 0, loop again
	j end_count_overlaps						# else go to end func
count_overlaps_I_rot:
	# check that rotated I fits
	addi $t0, $s1, 3							# $t0 = row + 3
	lbu $s4, 0($s0)								# $s4 = num_rows of state
	bge $t0, $s4, invalid_placement				# if (row + 3) => num_rows of state, invalid placement
	# if rotated I fits, count the overlaps (free to use $s4, $s5, $s6, $s7)
	li $t6, 'O'
	li $t7, 4									# counter
	li $s7, 0									# return val
	count_overlaps_I_rot_loop:
	lbu $s5, 2($s3)								# third char of piece
	bne $s5, $t6, count_overlaps_I_rot_loop_next# if $s5 != 'O' check next char
	move $a0, $s0								# $a0 = state
	move $a1, $s1								# $a1 = row
	move $a2, $s2								# $a2 = col
	jal get_slot								# go to get_slot
	bne $s5, $v0, count_overlaps_I_rot_loop_next# if $s5 != $v0, check next
	addi $s7, $s7, 1							# else returnval++
	count_overlaps_I_rot_loop_next:
	addi $s1, $s1, 1							# row++
	addi $s3, $s3, 1							# go to next char of piece
	addi $t7, $t7, -1							# decrement counter
	bgtz $t7, count_overlaps_I_rot_loop			# if counter > 0, loop again
	j end_count_overlaps						# else go to end func
count_overlaps_rest:
	move $s6, $s0								# $s6 = state (temp)
	move $s7, $s3								# $s3 = piece (temp)
	move $s0, $s3								# $s0 = piece (to use check_rotated_piece func)
	jal check_rotated_piece						# check if piece is rotated
	move $s0, $s6								# $s0 = state (original val)
	move $s3, $s7								# $s3 = piece (original val)
	bltz $v0, invalid_placement					# if $v0 < 0, it is an invalid piece
	li $t0, 1
	beq $t0, $v0, count_overlaps_rest_rot		# if $v0 = 1, it is a rotated piece
	# check that non-rotated piece fits
	addi $t0, $s1, 1							# $t0 = row + 1
	addi $t1, $s2, 2							# $t1 = col + 2
	lbu $s4, 0($s0)								# $s4 = num_rows of state
	lbu $s5, 1($s0)								# $s5 = num_cols of state
	bge $t0, $s4, invalid_placement				# if (row + 1) => num_rows of state, invalid placement
	bge $t1, $s5, invalid_placement				# if (col + 2) => num_cols of state, invalid placement
	# if rotated piece fits, count the overlaps (free to use $s4, $s5, $s6, $s7)
	li $t6, 'O'
	li $t7, 6									# counter
	addi $t8, $s1, 1							# $t8 = row + 1
	li $s7, 0									# return val
	count_overlaps_rest_loop:
	lbu $s5, 2($s3)								# third char of piece
	bne $s5, $t6, count_overlaps_rest_loop_cont	# if $s5 != 'O' check next char
	move $a0, $s0								# $a0 = state
	move $a1, $s1								# $a1 = row
	move $a2, $s2								# $s2 = col
	jal get_slot								# go to get_slot
	bne $s5, $v0, count_overlaps_rest_loop_cont	# if $s5 != $v0, check next
	addi $s7, $s7, 1							# else returnval++
	count_overlaps_rest_loop_cont:
	lbu $s5, 5($s3)								# sixth char of piece
	bne $s5, $t6, count_overlaps_rest_loop_next	# if $s5 != 'O' check next char
	move $a0, $s0								# $a0 = state
	move $a1, $t8								# $a1 = row + 1
	move $a2, $s2								# $a2 = col
	jal get_slot								# go to get_slot
	bne $s5, $v0, count_overlaps_rest_loop_next	# if $s5 != $v0, check next
	addi $s7, $s7, 1							# else returnval++
	count_overlaps_rest_loop_next:
	addi $s2, $s2, 1							# col++
	addi $s3, $s3, 1							# go to next char of piece
	addi $t7, $t7, -2							# decrement counter
	bgtz $t7, count_overlaps_rest_loop			# if counter > 0, loop again
	j end_count_overlaps						# else go to end func
count_overlaps_rest_rot:
	# check that rotated piece fits
	addi $t0, $s1, 2							# $t0 = row + 2
	addi $t1, $s2, 1							# $t1 = col + 1
	lbu $s4, 0($s0)								# $s4 = num_rows of state
	lbu $s5, 1($s0)								# $s5 = num_cols of state
	bge $t0, $s4, invalid_placement				# if (row + 2) => num_rows of state, invalid placement
	bge $t1, $s5, invalid_placement				# if (col + 1) => num_cols of state, invalid placement
	# if rotated piece fits, count the overlaps (free to use $s4, $s5, $s6, $s7)
	li $t6, 'O'
	li $t7, 6									# counter
	addi $t8, $s2, 1							# $t8 = col + 1
	li $s7, 0									# return val
	count_overlaps_rest_rot_loop:
	lbu $s5, 2($s3)								# third char of piece
	bne $s5, $t6, count_overlaps_rest_rot_loop_cont # if $s5 != 'O' check next char
	move $a0, $s0								# $a0 = state
	move $a1, $s1								# $a1 = row
	move $a2, $s2								# $a2 = col
	jal get_slot								# go to get_slot
	bne $s5, $v0, count_overlaps_rest_rot_loop_cont # if $s5 != $v0, check next
	addi $s7, $s7, 1							# else returnval++
	count_overlaps_rest_rot_loop_cont:
	lbu $s5, 3($s3)								# fourth char of piece
	bne $s5, $t6, count_overlaps_rest_rot_loop_next # if $s5 != 'O' check next char
	move $a0, $s0								# $a0 = state
	move $a1, $s1								# $a1 = row
	move $a2, $t8								# $a2 = col + 1
	jal get_slot								# go to get_slot
	bne $s5, $v0, count_overlaps_rest_rot_loop_next # if $s5 != $v0, check next
	addi $s7, $s7, 1							# else returnval++
	count_overlaps_rest_rot_loop_next:
	addi $s1, $s1, 1							# row++
	addi $s3, $s3, 2							# go to next 2 chars of piece
	addi $t7, $t7, -2							# decrement counter
	bgtz $t7, count_overlaps_rest_rot_loop		# if counter > 0, loop again
	j end_count_overlaps						# else go to end func
	invalid_placement:
	li $s7, -1									# num of overlaps = -1
	end_count_overlaps:	
	move $v0, $s7								# $v0 = num of overlaps
	# restore regs from stack
	lw $ra, 32($sp)
	lw $s7, 28($sp)
	lw $s6, 24($sp)
	lw $s5, 20($sp)
	lw $s4, 16($sp)
	lw $s3, 12($sp)
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 36
	jr $ra										# go back to where function was called

# PART VII
drop_piece:
	lw $t0, 0($sp)								# $t0 = rotated_piece from stack
	# allocate room on stack for 9 registers
	addi $sp, $sp, -36
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
	sw $ra, 32($sp)
	# declare vars
	move $s0, $a0								# $s0 = state
	move $s1, $a1								# $a1 = col
	move $s2, $a2								# $s2 = piece
	move $s3, $a3								# $s3 = rotation
	move $s4, $t0								# $s4 = rotated_piece
	# check that num of rotations and col arg are valid otherwise return -2
	bltz $s3, invalid_drop_args					# if num of rotation is neg, invalid drop
	bltz $s1, invalid_drop_args					# if col is neg, invalid drop for col
	lbu $s5, 1($s0)								# $s5 = num_cols from state
	bge $s1, $s5, invalid_drop_args				# if col => state.num_cols, invalid drop for col
	# if arguments pass, rotate function
	move $a0, $s2								# $a0 = piece
	move $a1, $s3								# $a1 = rotation
	move $a2, $s4								# $a2 = rotated_piece
	jal rotate									# go to rotate
	bltz $v0, invalid_drop_piece				# if $v0 < 0, it is an invalid piece
	# check that rotated piece fits in state otherwise return -3 ($s5, $s6, $s7 free to use)
	drop_piece_validate:
	lbu $s5, 0($s4)								# $s5 = rotated_piece.num_rows (to use for calculating bottom)
	lbu $s6, 0($s0)								# $s6 = state.num_rows (to use for calculating bottom)
	sub $s6, $s6, $s5							# $s6 = state.num_rows - rotated_piece.num_rows (as far as piece can go from bottom)
	li $s7, 0									# counter for row #
	# check row #0 and then the rest:
	move $a0, $s0								# $a0 = state
	move $a1, $s7								# $a1 = 0 (start at row zero)
	move $a2, $s1								# $a2 = col
	move $a3, $s4								# $a3 = rotated_piece
	jal count_overlaps							# go to count_overlaps
	bltz $v0, invalid_drop_rotation				# if piece "pokes out", it is invalid to drop
	bgtz $v0, invalid_drop						# if piece cant go into state, return -1
	# else piece fits into state so continue iterating:
	drop_piece_val_loop:
	addi $s7, $s7, 1							# counter++
	move $a0, $s0								# $a0 = state
	move $a1, $s7								# $a1 = 1 (start at row one)
	move $a2, $s1								# $a2 = col
	move $a3, $s4								# $a3 = rotated_piece
	jal count_overlaps							# go to count_overlaps
	bltz $v0, invalid_drop_rotation				# if piece "pokes out", it is invalid to drop
	bgtz $v0, drop_piece_val_loop_overlap		# if piece overlaps, set piece at row# - 1
	addi $s6, $s6, -1							# state.num_rows--
	bgtz $s6, drop_piece_val_loop				# if $s6 > 0, loop again
	j drop_piece_val_loop_no_overlap			# if piece doesnt overlap, set piece at row#
	drop_piece_val_loop_overlap:
	addi $s7, $s7, -1							# decrement $s7 (bc valid row is before it "hit" something)
	drop_piece_val_loop_no_overlap:
	# check if piece is O (free to use $s2, $s3, $s5, $s6)
	li $t0, 2								
	lbu $s5, 0($s4)								# rotated_piece.num_rows
	lbu $s6, 1($s4)								# rotated_piece.num_cols
	bne $t0, $s5, drop_piece_I					# if rotated_piece.num_rows != 2, check if I
	bne $t0, $s6, drop_piece_I					# if rotated_piece.num_cols != 2, check if I
drop_piece_O:
	li $s5, 0									# val for col (for get_slot)
	li $s6, 1									# counter for loop
	addi $t8, $s7, 1							# $t8 = row + 1
	drop_piece_O_loop:
	move $a0, $s4								# $a0 = rotated_piece
	li $a1, 0									# $a1 = 0
	move $a2, $s5								# $a2 = $s5
	jal get_slot								# go to get_slot
	move $a0, $s0								# $a0 = state
	move $a1, $s7								# $a1 = row val 
	move $a2, $s1								# $a2 = col val
	move $a3, $v0								# $a3 = char from get_slot
	jal set_slot								# go to get_slot
	move $a0, $s4								# $a0 = rotated_piece
	li $a1, 1									# $a1 = 1
	move $a2, $s5								# $a2 = $s5
	jal get_slot								# go to get_slot
	move $a0, $s0								# $a0 = state
	move $a1, $t8								# $a1 = row + 1
	move $a2, $s1								# $a2 = col val
	move $a3, $v0								# $a3 = char from get_slot
	jal set_slot								# go to get_slot
	addi $s1, $s1, 1							# increment col index (for set_slot)
	addi $s5, $s5, 1							# increment col index (for get_slot)
	ble $s5, $s6, drop_piece_O_loop				# if col index <= 1, loop again
	j end_drop_piece							# else end func
drop_piece_I:
	# check if piece is I (free to use $s2, $s3, $s5, $s6)
	move $t8, $s0								# state (temp)
	move $t9, $s4								# rotated_piece (temp)
	move $s0, $s4								# $s0 = piece (to use check_rotated_I func)
	jal check_rotated_I							# check if I
	move $s0, $t8								# $s0 = state (original val)
	move $s4, $t9								# $s4 = piece (original val)
	li $t0, 2									
	beq $t0, $v0, drop_piece_rest				# if $v0 = 2, it is not I so check rest
	li $t0, 1					
	beq $t0, $v0, drop_piece_I_rot				# if $v0 = 1, it is a rotated I
	li $s5, 0									# val for col (for get_slot)
	li $s6, 4									# counter for loop
	drop_piece_I_loop:
	move $a0, $s4								# $a0 = rotated_piece
	li $a1, 0									# $a1 = 0
	move $a2, $s5								# $a2 = $s5
	jal get_slot								# go to get_slot
	move $a0, $s0								# $a0 = state
	move $a1, $s7								# $a1 = row val
	move $a2, $s1								# $a2 = col val
	move $a3, $v0								# $a3 = char from get_slot
	jal set_slot								# go to get_slot
	addi $s1, $s1, 1							# increment col index (for set_slot)
	addi $s5, $s5, 1							# increment col index (for get_slot)
	addi $s6, $s6, -1							# counter--
	bgtz $s6, drop_piece_I_loop					# if $s6 > 0, loop again
	j end_drop_piece							# else end func
drop_piece_I_rot:
	li $s5, 0									# val for row (for get_slot)
	li $s6, 4									# counter for loop
	move $t8, $s7								# $t8 = row val (temp)
	drop_piece_I_rot_loop:
	move $a0, $s4								# $a0 = rotated_piece
	move $a1, $s5								# $a1 = $s5
	li $a2, 0									# $a2 = 0
	jal get_slot								# go to get_slot
	move $a0, $s0								# $a0 = state
	move $a1, $t8								# $a1 = row val
	move $a2, $s1								# $a2 = col val
	move $a3, $v0								# $a3 = char from get_slot
	jal set_slot								# go to set_slot
	addi $s5, $s5, 1							# increment row index (for get_slot)
	addi $t8, $t8, 1							# increment row index (for set_slot)
	addi $s6, $s6, -1							# counter--
	bgtz $s6, drop_piece_I_rot_loop				# if $s6 > 0, loop again
	j end_drop_piece							# else end func
drop_piece_rest:
	# piece is not O or I (free to use $s2, $s3, $s5, $s6)
	move $t8, $s0								# state (temp)
	move $t9, $s4								# rotated_piece (temp)
	move $s0, $s4								# $s0 = piece (to use check_rotated_piece func)
	jal check_rotated_piece						# check if piece is rotated
	move $s0, $t8								# $s0 = state (original val)
	move $s4, $t9								# $s4 = piece (original val)
	bltz $v0, invalid_drop_piece				# if $v0 < 0, it is an invalid piece
	li $t0, 1									
	beq $t0, $v0, drop_piece_rest_rot			# if $v0 = 1, it is a rotated piece
	li $s5, 0									# val for col (for get_slot)
	li $s6, 6									# counter for loop
	addi $t8, $s7, 1							# $t8 = row val + 1
	li $t9, 'O'
	drop_piece_rest_loop:
	move $a0, $s4								# $a0 = rotated_piece
	li $a1, 0									# $a1 = 0
	move $a2, $s5								# $a2 = $s5
	jal get_slot								# go to get_slot
	bne $t9, $v0, drop_piece_rest_loop_next		# if $v0 != 'O', check next
	move $a0, $s0								# $a0 = state
	move $a1, $s7								# $a1 = row val
	move $a2, $s1								# $a2 = col val
	move $a3, $v0								# $a3 = char from get_slot
	jal set_slot								# go to set_slot
	drop_piece_rest_loop_next:
	move $a0, $s4								# $a0 = rotated_piece
	li $a1, 1									# $a1 = 0
	move $a2, $s5								# $a2 = $s5
	jal get_slot								# go to get_slot
	bne $t9, $v0, drop_piece_rest_loop_cont		# if $v0 != 'O', continue to next 2
	move $a0, $s0								# $a0 = state
	move $a1, $t8								# $a1 = row val
	move $a2, $s1								# $a2 = col val
	move $a3, $v0								# $a3 = char from get_slot
	jal set_slot								# go to set_slot
	drop_piece_rest_loop_cont:
	addi $s1, $s1, 1							# increment col index (for set_slot)
	addi $s5, $s5, 1							# increment col index (for get_slot)
	addi $s6, $s6, -2							# counter--
	bgtz $s6, drop_piece_rest_loop				# if $s6 > 0, loop again
	j end_drop_piece							# else end func
drop_piece_rest_rot:	
	li $s5, 0									# val for col (for get_slot)
	li $s6, 6									# counter for loop
	addi $t7, $s1, 1							# $t7 = col val + 1
	move $t8, $s7								# $t8 = row val (temp)
	li $t9, 'O'
	drop_piece_rest_rot_loop:
	move $a0, $s4								# $a0 = rotated_piece
	move $a1, $s5								# $a1 = $s5
	li $a2, 0									# $a2 = 0
	jal get_slot								# go to get_slot
	bne $t9, $v0, drop_piece_rest_rot_loop_next	# if $v0 != 'O', check next
	move $a0, $s0								# $a0 = state
	move $a1, $t8								# $a1 = row val
	move $a2, $s1								# $a2 = col val
	move $a3, $v0								# $a3 = char from get_slot
	jal set_slot								# go to set_slot
	drop_piece_rest_rot_loop_next:
	move $a0, $s4								# $a0 = rotated_piece
	move $a1, $s5								# $a1 = $s5
	li $a2, 1									# $a2 = 1
	jal get_slot								# go to get_slot
	bne $t9, $v0, drop_piece_rest_rot_loop_cont	# if $v0 != 'O', check next
	move $a0, $s0								# $a0 = state
	move $a1, $t8								# $a1 = row val
	move $a2, $t7								# $a2 = col val
	move $a3, $v0								# $a3 = char from get_slot
	jal set_slot								# go to set_slot
	drop_piece_rest_rot_loop_cont:
	addi $s5, $s5, 1							# increment row index (for get_slot)
	addi $t8, $t8, 1							# increment row index (for set_slot)
	addi $s6, $s6, -2							# counter--
	bgtz $s6, drop_piece_rest_rot_loop			# if $s6 > 0, loop again
	j end_drop_piece							# else end func
	invalid_drop_piece:
	li $s7, -69									# row num = -69 (invalid piece)
	j end_drop_piece							# go to end_drop_piece
	invalid_drop_args:
	li $s7, -2									# row num = -2 (invalid cols)
	j end_drop_piece							# go to end_drop_piece
	invalid_drop_rotation:
	li $s7, -3									# row num = -3 (invalid rotation)
	j end_drop_piece							# go to end_drop_piece
	invalid_drop:
	li $s7, -1									# roe num = -1 (invalid drop)
	end_drop_piece:	
	move $v0, $s7								# $v0 = row num (or invalid)
	# restore regs from stack
	lw $ra, 32($sp)
	lw $s7, 28($sp)
	lw $s6, 24($sp)
	lw $s5, 20($sp)
	lw $s4, 16($sp)
	lw $s3, 12($sp)
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 36
	jr $ra										# go back to where function was called

# PART VIII
check_row_clear:
	
	jr $ra

# PART IX
simulate_game:
	jr $ra

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
