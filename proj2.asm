# CSE 220 Programming Project #2
# Katheryn Martinez Hernandez
# ***REMOVED***
# ***REMOVED***

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text

# PART I
strlen:
	li $t0, 0							# length = 0
	strlen_loop:
	lbu $t1, 0($a0)						# $t1 = str[i]
	beqz $t1, end_strlen				# if str[i] = 0, go to end_strlen
	addi $t0, $t0, 1					# else length++
	addi $a0, $a0, 1					# and go to next char
	j strlen_loop						# and loop again
	end_strlen:
	move $v0, $t0						# $v0 = $t0
    jr $ra								# return to where func was called

# PART II
index_of:
	li $t0, 0							# index = 0
	index_loop:
	lbu $t1, 0 ($a0)					# $t1 = str[i]
	beq $t1, $a1, end_index_of			# if str[i] = char passed, go to end_index_of
	beqz $t1, index_not_found			# if str[i] = 0, go to index_not_found
	addi $t0, $t0, 1					# else index++
	addi $a0, $a0, 1					# and go to next char
	j index_loop						# and loop again
	index_not_found:
	li $t0, -1							# if index not found, $t0 = -1
	end_index_of:
	move $v0, $t0						# $v0 = $t0
    jr $ra								# return to where func was called

# PART III
bytecopy:
	lw $t0, 0($sp)						# $t0 = first elem from stack (which should be length arg)	
	li $t1, 0							# i = 0
	li $t2, 0							# j = 0
	li $t3, 0							# return_value = 0
	# if len <= 0 or src_pos and/or des_pos < 0, no changes to memory
	blez $t0, no_bytecopy				# if length <= 0, no_bytecopy
	bltz $a1, no_bytecopy				# if src_pos < 0, no_bytecopy
	bltz $a3, no_bytecopy				# if des_pos < 0, no_bytecopy
	bytecopy_loop:
	beq $t3, $t0, end_bytecopy			# if return_value = length, end_bytecopy
	lbu $t4, 0($a0)						# $t4 = src[i]
	beq $t1, $a1, start_bytecopy		# if i = src_pos, start_bytecopy
	addi $t1, $t1, 1					# else i++
	addi $a0, $a0, 1					# go to next char
	j bytecopy_loop						# loop again
	start_bytecopy:
	lbu $t5, 0($a2)						# $t5 = des[j]
	beq $t2, $a3, cont_bytecopy			# if j = des_pos, cont_bytecopy
	addi $t2, $t2, 1					# else j++
	addi $a2, $a2, 1					# go to next char
	j start_bytecopy					# loop again
	cont_bytecopy:
	sb $t4, 0($a2)						# save src[i] into des[j]
	addi $t3, $t3, 1					# return_value++
	addi $a0, $a0, 1					# go to next char
	addi $a2, $a2, 1					# go to next char
	j bytecopy_loop						# loop again
	no_bytecopy:
	li $t3, -1							# return_value = -1
	end_bytecopy:
	move $v0, $t3						# $v0 = $t3
	jr $ra								# return to where func was called

# PART IV
scramble_encrypt:
	li $t0, 0							# return_value = 0
	# allocate room on stack for 1 register
	addi $sp, $sp, -4
	sw $s0, 0($sp)

	# algorithm:
	# For uppercase: index = dec val - 65. Example: S (dec val 83) - 65 = 18 index
	# For lowercase: index = dec val - 71. Example: l (dec val 108) - 71 = 37 index
	
	scr_encrypt_loop:
	# check values (A = 65, Z = 90, a = 97, z = 122)
	li $t1, 65							# $t1 = 'A'
	lbu $t2, 0($a1)						# $t2 = plaintext[i]
	beqz $t2, end_scr_encrypt			# if $t2 = 0, end_scr_encrypt
	blt $t2, $t1, no_scr_encrypt		# if $t2 < 'A', no_scr_encrypt
	addi $t1, $t1, 57					# $t1 = 65 + 57 = 122 = 'z'
	bgt $t2, $t1, no_scr_encrypt		# if $t2 > 'z', no_scr_encrypt
	addi $t1, $t1, -25					# $t1 = 122 - 25 = 97 = 'a'
	bge $t2, $t1, scr_lower_encrypt		# if $t2 => 'a', scr_lower_encrypt	
	addi $t1, $t1, -7					# $t1 = 97 - 7 = 90 = 'Z'
	ble $t2, $t1, scr_upper_encrypt		# if $t2 <= 'Z', scr_upper_encrypt
	bgt $t2, $t1, no_scr_encrypt		# if $t2 > 'Z', no_scr_encrypt
	# apply algorithm to lowercase chars
	scr_lower_encrypt:
	li $t3, 0							# j = 0
	addi $t4, $t2, -71					# $t4 = $t2 - 71 ($t4 = index)
	move $s0, $a2						# $s0 = $a2
	scr_lower_encrypt_loop:
	lbu $t5, 0($s0)						# $t5 = alphabet[j]
	beq $t3, $t4, scr_start_encrypt		# if j = index, scr_start_encrypt
	addi $t3, $t3, 1					# else j++
	addi $s0, $s0, 1					# and go to next char
	j scr_lower_encrypt_loop			# and loop again
	# apply algorithm to uppercase chars
	scr_upper_encrypt:
	li $t3, 0							# j = 0
	addi $t4, $t2, -65					# $t4 = $t2 - 65 ($t4 = index)
	move $s0, $a2						# $s0 = $a2
	scr_upper_encrypt_loop:
	lbu $t5, 0($s0)						# $t5 = alphabet[j]
	beq $t3, $t4, scr_start_encrypt		# if j = index, scr_start_encrypt
	addi $t3, $t3, 1					# else j++
	addi $s0, $s0, 1					# and go to next char
	j scr_upper_encrypt_loop			# and loop again
	# no algorithm applied
	no_scr_encrypt:
	sb $t2, 0($a0)						# save $t2 into ciphertext[i]
	addi $a1, $a1, 1					# go to next char of plaintext
	addi $a0, $a0, 1					# go to next char of ciphertext
	j scr_encrypt_loop					# go to scr_encrypt_loop
	# save result into ciphertext
	scr_start_encrypt:
	sb $t5, 0($a0)						# save $t5 into ciphertext[i]
	addi $t0, $t0, 1					# return_value++
	addi $a1, $a1, 1					# go to next char of plaintext
	addi $a0, $a0, 1					# go to next char of ciphertext
	j scr_encrypt_loop					# go to scr_encrypt_loop
	end_scr_encrypt:
	sb $0, 0($a0)						# null terminate ciphertext
	# restore register from stack
	lw $s0, 0($sp)					
	addi $sp, $sp, 4				
	move $v0, $t0						# $v0 = return_value
	jr $ra								# return to where func was called

# PART V
scramble_decrypt:
	# allocate room on stack for 7 registers
	addi $sp, $sp, -28
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $ra, 24($sp)
	# declare variables
	move $s0, $a0						# $s0 = plaintext[]
	move $s1, $a1						# $s1 = ciphertext
	li $s2, 0							# return_value = 0
	li $s3, 0							# use for ciphertext[i]
	
	# algorithm:
	# For index 0-25: index + 65 = char dec value. 
	# For index 26-51: index + 71 = char dec value
	
	scr_decrypt_loop:
	li $t0, 65							# $t0 = 'A'
	lbu $s3, 0($s1)						# $s3 = ciphertext[i]
	beqz $s3, end_scr_decrypt			# if $s3 = 0, end_scr_decrypt
	blt $s3, $t0, no_scr_decrypt		# if $s3 < 'A', no_scr_decrypt
	addi $t0, $t0, 57					# $t0 = 65 + 57 = 122 = 'z'
	bgt $s3, $t0, no_scr_decrypt		# if $s3 > 'z', no_scr_decrypt
	addi $t0, $t0, -25					# $t0 = 122 - 25 = 97 = 'a'
	bge $s3, $t0, scr_decrypt			# if $s3 > 'a', scr_decrypt
	addi $t0, $t0, -7					# $t0 = 97 - 7 = 90 = 'Z'
	ble $s3, $t0, scr_decrypt			# if $s3 < 'Z', scr_decrypt
	bgt $s3, $t0, no_scr_decrypt		# if $s3 > 'Z', no_scr_decrypt
	scr_decrypt:
	move $a0, $a2						# $a0 = alphabet
	lbu $a1, 0($s1)						# $a1 = ciphertext[i]
	jal index_of
	li $t0, 25							# $t0 = 25 (for dividing alphabet into 0-25, 26-51)
	li $s4, 0							# index = 0
	add $s4, $s4, $v0					# index = result from index_of
	bltz $s4, cont_scr_decrypt			# if index < 0, cont_src_decrypt
	ble $s4, $t0, scr_decrypt_lower		# if index <= 25, scr_decrypt_lower
	bgt $s4, $t0, scr_decrypt_upper		# if index > 25, scr_decrypt_upper
	scr_decrypt_lower:
	li $s5, 0							# $s5 = 0 (use for result)
	addi $s5, $s4, 65					# $s5 = index + 65
	j cont_scr_decrypt					# go to cont_scr_decrypt
	scr_decrypt_upper:
	li $s5, 0							# $s5 = 0
	addi $s5, $s4, 71					# $s5 = index + 71
	j cont_scr_decrypt					# go to cont_scr_decrypt
	no_scr_decrypt:
	sb $s3, 0($s0)						# save $s3 into plaintext[i]
	addi $s1, $s1, 1					# go to next char of ciphertext
	addi $s0, $s0, 1					# go to next char of plaintext
	j scr_decrypt_loop					# go to scr_decrypt_loop
	cont_scr_decrypt:
	sb $s5, 0($s0)						# save $s5 into plaintext[i]
	addi $s2, $s2, 1					# return_value++
	addi $s1, $s1, 1					# go to next char of ciphertext
	addi $s0, $s0, 1					# go to next char of plaintext
	j scr_decrypt_loop					# go to scr_decrypt_loop
	end_scr_decrypt:
	sb $0, 0($s0)						# null-terminate plaintext
	move $v0, $s2						# $v0 = return_value
	# restore registers from stack
	lw $ra, 24($sp)
	lw $s5, 20($sp)
	lw $s4, 16($sp)
	lw $s3, 12($sp)
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 28
	jr $ra								# return to where function was called

# PART VI
base64_encode:
	li $t0, 0							# i = 0
	li $t8, 0							# return_value = 0
	# allocate room on stack for 5 registers
	addi $sp, $sp, -20
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	b64_encode_loop:
	# algorithm: use 3 chars at a time to get 24 bits (each char has 8 bits x 3 = 24)
	# get first value to use
	li $t1, 0							# clear register
	lbu $s1, 0($a1)						# $s1 = first char from str 
	beqz $s1, end_b64_encode			# if $s1 = 0, end_base64_encode
	andi $t1, $s1, 0x3					# $t1 = 2 rightmost bits of first char
	srl $s1, $s1, 2						# $s1 = 6 leftmost bits of first char (1st val)
	# get second value to use
	li $t2, 0							# clear register
	lbu $s2, 1($a1)						# $s2 = second char from str
	beqz $s2, b64_encode_pad2			# if $s2 = 0, will pad with two ==
	andi $t2, $s2, 0xF					# $t2 = 4 rightmost bits of second char
	srl $s2, $s2, 4						# $s2 shifted 4 to the right
	sll $t1, $t1, 4						# $t1 shifted 4 to the left
	or $s2, $t1, $s2					# $s2 = $t1 OR $s2 (2nd val)
	# get third and fourth values to use
	li $s3, 0							# clear register
	lbu $s4, 2($a1)						# $s4 = third char from str
	beqz $s4, b64_encode_pad1			# if $s4 = 0, will pad with one =
	srl $s3, $s4, 6						# $s3 = $s4 shifted 6 to the right
	andi $s4, $s4, 0x3F					# $s4 = 6 rightmost bits from third char (4th val)
	sll $t2, $t2, 2						# $t2 = $t2 shifted 2 to the left
	or $s3, $t2, $s3					# $s3 = $t2 OR $s3 (3rd val)
	# start encoding values
	b64_cont_encode1:
	li $t0, 0							# reset i to zero
	move $s0, $a2						# $s0 = base64_table
	b64_encode_loop1:
	bgt $t0, $s1, b64_cont_encode2		# if i > 1st val, go to b64_cont_encode2
	lbu $t3, 0($s0)						# $t3 = base64_table[i]
	addi $t0, $t0, 1					# i++
	addi $s0, $s0, 1					# go to next char of base64_table
	j b64_encode_loop1					# loop again
	b64_cont_encode2:
	li $t0, 0							# reset i to zero
	move $s0, $a2						# $s0 = base64_table
	b64_encode_loop2:
	bgt $t0, $s2, b64_cont_encode3		# if i > 2nd val, go to b64_cont_encode3
	lbu $t4, 0($s0)						# $t4 = base64_table[i]
	addi $t0, $t0, 1					# i++
	addi $s0, $s0, 1					# go to next char of base64_table
	j b64_encode_loop2					# loop again
	b64_cont_encode3:
	li $t0, 0							# reset i to zero
	move $s0, $a2						# $s0 = base64_table
	b64_encode_loop3:
	bgt $t0, $s3, b64_cont_encode4		# if i > 3rd val, go to b64_cont_encode4
	lbu $t5, 0($s0)						# $t5 = base64_table[i]
	addi $t0, $t0, 1					# i++
	addi $s0, $s0, 1					# go to next char of base64_table
	j b64_encode_loop3					# loop again
	b64_cont_encode4:
	li $t0, 0							# reset i to zero
	move $s0, $a2						# $s0 = base64_table
	b64_encode_loop4:
	bgt $t0, $s4, b64_cont_encode		# if i > 4th val, go to b64_cont_encode
	lbu $t6, 0($s0)						# $t6 = base64_table[i]
	addi $t0, $t0, 1					# i++
	addi $s0, $s0, 1					# go to next char of base64_table
	j b64_encode_loop4					# loop again
	# padding to have one '=' at the end
	b64_encode_pad1:
	li $t0, 0							# reset i to zero
	li $t7, 61							# $t7 = '='
	move $s0, $a2						# $s0 = base64_table
	b64_encode_pad1_loop1:
	bgt $t0, $s1, b64_cont_encode_p1l2	# if i > 1st val, go to b64_cont_encode_p1l2
	lbu $t3, 0($s0)						# $t3 = base64_table[i]
	addi $t0, $t0, 1					# i++
	addi $s0, $s0, 1					# go to next char of base64_table
	j b64_encode_pad1_loop1				# loop again
	b64_cont_encode_p1l2:
	li $t0, 0							# reset i to zero
	move $s0, $a2						# $s0 = base64_table
	b64_encode_pad1_loop2:
	bgt $t0, $s2, b64_cont_encode_p1l3	# if i > 2nd val, go to b64_cont_encode_p1l3
	lbu $t4, 0($s0)						# $t4 = base64_table[i]
	addi $t0, $t0, 1					# i++
	addi $s0, $s0, 1					# go to next char of base64_table
	j b64_encode_pad1_loop2				# loop again
	b64_cont_encode_p1l3:
	li $t0, 0							# reset i to zero
	move $s0, $a2						# $s0 = base64_table
	sll $t2, $t2, 2						# $t2 = $t2 shifted 2 to the left
	b64_encode_pad1_loop3:
	bgt $t0, $t2, end_b64_encode_pad1	# if i > 3rd val, go to end_b64_encode_pad1
	lbu $t5, 0($s0)						# $t5 = base64_table[i]
	addi $t0, $t0, 1					# i++
	addi $s0, $s0, 1					# go to next char of base64_table
	j b64_encode_pad1_loop3				# loop again
	end_b64_encode_pad1:
	sb $t3, 0($a0)						# save $t3 into encoded_str[i]
	sb $t4, 1($a0)						# save $t4 into encoded_str[i]
	sb $t5, 2($a0)						# save $t5 into encoded_str[i]
	sb $t7, 3($a0)						# save $t7 into encoded_str[i]
	addi $a1, $a1, 2					# go to next 2 char of str
	addi $a0, $a0, 4					# go to next 4 char of encoded_str
	addi $t8, $t8, 4					# return_value + 4
	j b64_encode_loop					# go to b64_encode_loop
	# padding to have '==' at the end
	b64_encode_pad2:
	li $t0, 0							# reset i to zero
	li $t7, 61							# $t7 = '='
	move $s0, $a2						# $s0 = base64_table
	b64_encode_pad2_loop1:
	bgt $t0, $s1, b64_cont_encode_p2l2	# if i > 1st val, go to b64_cont_encode_p2l2
	lbu $t3, 0($s0)						# $t3 = base64_table[i]
	addi $t0, $t0, 1					# i++
	addi $s0, $s0, 1					# go to next char of base64_table
	j b64_encode_pad2_loop1				# loop again
	b64_cont_encode_p2l2:
	li $t0, 0							# reset i to zero
	move $s0, $a2						# $s0 = base64_table
	sll $t1, $t1, 4						# $t1 = $t1 shifted 4 to the left
	b64_encode_pad2_loop2:
	bgt $t0, $t1, end_b64_encode_pad2	# if i > 2nd val, go to end_b64_encode_pad2
	lbu $t4, 0($s0)						# $t4 = base64_table[i]
	addi $t0, $t0, 1					# i++
	addi $s0, $s0, 1					# go to next char of base64_table
	j b64_encode_pad2_loop2				# loop again
	end_b64_encode_pad2:
	sb $t3, 0($a0)						# save $t3 into encoded_str[i]
	sb $t4, 1($a0)						# save $t4 into encoded_str[i]
	sb $t7, 2($a0)						# save $t7 into encoded_str[i]
	sb $t7, 3($a0)						# save $t7 into encoded_str[i]
	addi $a1, $a1, 1					# go to next char of str
	addi $a0, $a0, 4					# go to next 4 char of encoded_str
	addi $t8, $t8, 4					# return_value + 4
	j b64_encode_loop					# go to b64_encode_loop
	# encoding with no padding
	b64_cont_encode:
	sb $t3, 0($a0)						# save $t3 into encoded_str[i]
	sb $t4, 1($a0)						# save $t4 into encoded_str[i]
	sb $t5, 2($a0)						# save $t5 into encoded_str[i]
	sb $t6, 3($a0)						# save $t6 into encoded_str[i]
	addi $a1, $a1, 3					# go to next 3 char of str
	addi $a0, $a0, 4					# go to next 4 char of encoded_str
	addi $t8, $t8, 4					# return_value + 4
	j b64_encode_loop					# go to b64_encode_loop
	end_b64_encode:
	sb $0, 0($a0)						# null terminate encoded_str
	move $v0, $t8						# $v0 = return_value
	# restore registers from stack
	lw $s4, 16($sp)
	lw $s3, 12($sp)
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 20
	jr $ra								# return to where function was called

# PART VII
base64_decode:
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
	#declare variables
	move $s0, $a0						# $s0 = decoded_str
	move $s1, $a1						# $s1 = encoded_str
	move $s2, $a2						# $s2 = base64_table
	li $s3, 0							# return_value = 0
	b64_decode_loop:
	# load 4 chars at a time from str to decode
	# get first value
	lbu $s4, 0($s1)						# $s4 = first char from encoded_str
	beqz $s4, end_b64_decode			# if $s4 = 0, go to end_b64_decode
	# for index_of: $a0 = table, $a1 = char to look for
	move $a0, $s2						# $a0 = base64_table
	move $a1, $s4						# $a1 = char to look for in table
	jal index_of						# go to index_of
	move $s4, $v0						# $s4 = index from index_of
	# get second value
	lbu $s5, 1($s1)						# $s5 = second char from encoded_str
	move $a0, $s2						# $a0 = base64_table
	move $a1, $s5						# $a1 = char to look for in table
	jal index_of						# go to index_of
	move $s5, $v0						# $s5 = index from index_of
	# get final first val
	li $t0, 0							# reset $t0 to zero
	srl $t0, $s5, 4						# $t0 = $s5 shifted 4 to the right (to get leftmost 2 bits)
	sll $s4, $s4, 2						# $s4 = $s4 shifted 2 to the left
	or $s4, $s4, $t0					# $s4 = $s4 OR $t0 (1st val)
	# get third value
	lbu $s6, 2($s1)						# $s6 = third char from encoded_str
	li $t0, 61							# $t0 = '='
	beq $s6, $t0, b64_decode_pad2	 	# if $s6 = $t0, go to b64_decode_pad2
	move $a0, $s2						# $a0 = base64_table
	move $a1, $s6						# $a1 = char to look for in table
	jal index_of						# go to index_of
	move $s6, $v0						# $s6 = index from index_of
	# get final second val
	andi $s5, $s5, 0xF					# $s5 = 4 leftmost bits from $s5
	li $t0, 0							# reset $t0 to zero
	srl $t0, $s6, 2						# $t0 = $s6 shifted 2 to the right (to get leftmost 4 bits)
	sll $s5, $s5, 4						# $s5 = $s5 shifted 4 to the left
	or $s5, $s5, $t0					# $s5 = $s5 or $t0 (2nd val)
	# get fourth value
	lbu $s7, 3($s1)						# $s7 = fourth char from encoded_str
	li $t0, 61							# $t0 = '='
	beq $s7, $t0, b64_decode_pad1	 	# if $s7 = $t0, go to b64_decode_pad1
	move $a0, $s2						# $a0 = base64_table
	move $a1, $s7						# $a1 = char to look for in table
	jal index_of						# go to index_of
	move $s7, $v0						# $s7 = index from index_of
	# get final third val
	andi $s6, $s6, 0x3					# $s6 = 2 rightmost bits from $s6
	sll $s6, $s6, 6						# $s6 = $s6 shifted 6 to the left
	or $s6, $s6, $s7					# $s6 = $s6 OR $s7 (3rd val)
	j b64_cont_decode					# go to b64_cont_decode
	b64_decode_pad1:
	sb $s4, 0($s0)						# save $s4 into decoded_str[i]
	sb $s5, 1($s0)						# save $s5 into decoded_str[i]
	addi $s1, $s1, 4					# go to next 4 char of encoded_str
	addi $s0, $s0, 2					# go to next 2 char of decoded_str
	addi $s3, $s3, 2					# return_value + 2
	j b64_decode_loop
	b64_decode_pad2:
	sb $s4, 0($s0)						# save $s4 into decoded_str[i]
	addi $s1, $s1, 4					# go to next 4 char of encoded_str
	addi $s0, $s0, 1					# go to next char of decoded_str
	addi $s3, $s3, 1					# return_value + 1
	j b64_decode_loop
	b64_cont_decode:
	sb $s4, 0($s0)						# save $s4 into decoded_str[i]
	sb $s5, 1($s0)						# save $s5 into decoded_str[i]
	sb $s6, 2($s0)						# save $s6 into decoded_str[i]
	addi $s1, $s1, 4					# go to next 4 char of encoded_str
	addi $s0, $s0, 3					# go to next 3 char of decoded_str
	addi $s3, $s3, 3					# return_value + 3
	j b64_decode_loop
	end_b64_decode:
	sb $0, 0($s0)						# null terminate decoded_str
	move $v0, $s3						# $v0 = return_value
	# restore registers from stack
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
	jr $ra								# return to where function was called
	
# PART VIII
bifid_encrypt:
	lw $t0, 0($sp)						# $t0 = index_buffer
	lw $t1, 4($sp)						# $t1 = block_buffer
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
	# declare variables
	move $s0, $a0						# $s0 = ciphertext
	move $s1, $a1						# $s1 = plaintext (free after getting indices)
	move $s2, $a2						# $s2 = key_square
	move $s3, $a3						# $s3 = period
	move $s4, $t0						# $s4 = index_buffer
	move $s5, $t1						# $s5 = block_buffer
	# check period
	blez $s3, end_encr_return_neg_val	# if period <= 0, go to end_encr_return_neg_val
	# to preserve $s4 starting point
	move $s6, $s4
	# get length of index_buffer to use for bytecopy later
	move $a0, $s1						# $a0 = plaintext
	jal strlen							# go to strlen
	move $s7, $v0						# $s7 = plaintext length
	# store all i into index_buffer
	bifid_encr_save_i:
	# check if empty
	move $t5, $s1						# $t5 = plaintext
	lbu $t1, 0($t5)						# first char of plaintext to encrypt
	beqz $t1, bifid_encr_return_val		# if empty, go to bifid_encr_return_val
	bifid_encr_save_i_loop:
	# get value
	lbu $t1, 0($t5)						# first char of plaintext to encrypt
	beqz $t1, bifid_encr_save_j			# if $t1 = 0, go to bifid_encr_save_j
	# for index_of: $a0 = key_square, $a1 = char to look for
	move $a0, $s2						# $a0 = key_square
	move $a1, $t1						# $a1 = $t1
	jal index_of						# go to index_of
	move $t1, $v0						# $t1 = index from index_of
	# find i
	li $t2, 9							# $t2 = 9
	div $t1, $t2						# index / 9
	mflo $t3							# i = lo
	# store i
	addi $t3, $t3, 48					# convert i to ascii
	sb $t3, 0($s4)						# save i to index_buffer[0]
	addi $s4, $s4, 1					# go to next char of index_buffer
	addi $t5, $t5, 1					# go to next char of plaintext
	j bifid_encr_save_i_loop			# loop again
	# store all j into index_buffer
	bifid_encr_save_j:
	move $t5, $s1						# $t5 = plaintext
	bifid_encr_save_j_loop:
	# get value
	lbu $t1, 0($t5)						# first char of plaintext to encrypt
	beqz $t1, bifid_cont_encrypt		# if $t1 = 0, go to bifid_cont_encrypt
	# for index_of: $a0 = key_square, $a1 = char to look for
	move $a0, $s2						# $a0 = key_square
	move $a1, $t1						# $a1 = $t1
	jal index_of						# go to index_of
	move $t1, $v0						# $t1 = index from index_of
	# find j
	li $t2, 9							# $t2 = 9
	div $t1, $t2						# index / 9
	mfhi $t3							# j = hi
	# store j
	addi $t3, $t3, 48					# convert j to ascii
	sb $t3, 0($s4)						# save j to index_buffer[0]
	addi $s4, $s4, 1					# go to next char of index_buffer
	addi $t5, $t5, 1					# go to next char of plaintext
	j bifid_encr_save_j_loop
	# for bytecopy: $a0 = src, $a1 = src_pos, $a2 = dest, $a3 = dest_pos, 5th arg = length
	bifid_cont_encrypt:
	move $s4, $s6						# $s4 = index_buffer
	li $s1, 0							# $s1 = 0 (to be used for src_pos)
	li $s6, 0							# clear register
	li $t5, 0							# clear register
	bifid_cont_encrypt_loop:
	sub $s6, $s7, $s1					# $s6 = length - src_pos
	blt $s6, $s3, bifid_encr_block_buf  # if $s6 < period, then we have a "partial" block
	move $s6, $s3 						# else we have a "full" block
	bifid_encr_block_buf:
	move $a0, $s4						# $a0 = index_buffer
	move $a1, $s1						# $a1 = src_pos
	move $a2, $s5						# $a2 = block_buffer
	move $a3, $0						# $a3 = 0
	# allocate space for 5th arg
	addi $sp, $sp, -4
	sw $s6, 0($sp)						# 5th arg = length
	jal bytecopy						# go to bytecopy
	move $a0, $s4						# $a0 = index_buffer
	add $a1, $s1, $s7					# $a1 = src_pos + length = second half index
	move $a2, $s5						# $a2 = block_buffer
	move $a3, $s6						# $a3 = min(length-src_pos, period)
	sw $s6, 0($sp)						# 5th arg = length
	jal bytecopy						# go to bytecopy
	addi $sp, $sp, 4					# move pointer back
	bifid_encr_block_buffer_start:
	move $t0, $s6						# $t0 = min(period, src_pos - period)
	move $t1, $s5						# $t1 = block_buffer
	bifid_encr_block_buffer_loop:
	lbu $t2, 0($t1)						# $t2 = (i) char from block_buffer
	beqz $t2, bifid_end_encr_block_loop	# if $t2 = 0, go to bifid_end_encr_block_loop
	addi $t2, $t2, -48					# convert from ascii to dec
	lbu $t3, 1($t1)						# $t3 = (j) char from block_buffer
	beqz $t3, bifid_end_encr_block_loop	# if $t3 = 0, go to bifid_end_encr_block_loop
	addi $t3, $t3, -48					# convert from ascii to dec
	li $t4, 9							# $t4 = 9
	mul $t4, $t2, $t4					# $t4 = i * 9
	add	$t4, $t4, $t3					# $t4 = (i * 9) + j
	add $t5, $s2, $t4					# $t5 = baseaddr key_square + ((i*9)+j)
	lbu	$t6, 0($t5)						# $t6 = first char from $t5
	sb $t6, 0($s0)						# save $t6 into ciphertext
	addi $s0, $s0, 1					# go to next char of ciphertext
	addi $t1, $t1, 2					# go to next 2 char of block_buffer
	addi $t0, $t0, -1					# decrement until zero
	bgtz $t0, bifid_encr_block_buffer_loop
	bifid_end_encr_block_loop:
	add $s1, $s1, $s3					# go to next $s3 char of src_pos
	blt $s1, $s7, bifid_cont_encrypt_loop # if src_pos < length, loop again
	# get return value
	bifid_encr_return_val:				
	sb $0, 0($s0)						# null terminate ciphertext
	div $s7, $s3 						# divide plaintext length by period
	mfhi $t0							# $t0 = remainder
	mflo $t1							# $t1 = quotient
	beqz $t0, end_encr_return_val		# if remainder = 0 (i.e., len is multiple of period)
	addi $t1, $t1, 1					# else quotient = quotient + 1
	j end_encr_return_val				# go to end_encr_return_val
	end_encr_return_neg_val:
	li $t1, -1							# $t1 = -1
	end_encr_return_val:
	move $v0, $t1						# $v0 = return_value
	# restore registers from stack
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
	jr $ra								# return to where function was called

# PART IX
bifid_decrypt:
	lw $t0, 0($sp)						# $t0 = index_buffer
	lw $t1, 4($sp)						# $t1 = block_buffer
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
	# declare variables
	move $s0, $a0						# $s0 = plainext
	move $s1, $a1						# $s1 = ciphertext 
	move $s2, $a2						# $s2 = key_square
	move $s3, $a3						# $s3 = period
	move $s4, $t0						# $s4 = index_buffer
	move $s5, $t1						# $s5 = block_buffer
	# check period
	blez $s3, end_decr_return_neg_val	# if period <= 0, go to end_decr_return_neg_val
	# to preserve $s4 starting point (save for later use)
	move $s6, $s4
	# get length of index_buffer to use for bytecopy later
	move $a0, $s1						# $a0 = ciphertext
	jal strlen							# go to strlen
	move $s7, $v0						# $s7 = ciphertext length
	# check if empty
	lbu $t1, 0($s1)						# first char of plaintext to encrypt
	beqz $t1, bifid_decr_return_val		# if empty, go to bifid_encr_return_val
	# get and save indices into index_buffer
	bifid_decr_save_indices:
	lbu $t1, 0($s1)						# get first char of ciphertext
	beqz $t1, bifid_decr_block_buffer	# if $t1 = 0, go to bifid_cont_decr
	# for index_of: $a0 = key_square, $a1 = char to look for
	move $a0, $s2						# $a0 = key_square
	move $a1, $t1						# $a1 = char to look for
	jal index_of						# go to index of
	move $t1, $v0						# $t1 = index
	li $t2, 9							# $t2 = 9
	div $t1, $t2						# divide index / 9
	mflo $t3							# $t3 = i (quotient)
	mfhi $t4							# $t4 = j (remainder)
	addi $t3, $t3, 48					# convert i to ascii
	addi $t4, $t4, 48					# convert j to ascii
	sb $t3, 0($s4)						# save i to index_buffer
	sb $t4, 1($s4)						# save j to index_buffer
	addi $s1, $s1, 1					# go to next char of plaintext
	addi $s4, $s4, 2					# go to next 2 char of index_buffer
	j bifid_decr_save_indices			# loop again
	bifid_decr_block_buffer:
	move $s4, $s6						# $s4 = index_buffer
	li $t1, 0							# counter = 0
	li $t5, 0							# counter2 = 0
	move $s1, $s5						# $s1 = block_buffer (to use when converting)
	bifid_decr_block_buffer_loop:
	# condition for blocks to be of period length or partial block
	sub $t0, $s7, $t1					# $t0 = length of plaintext - counter
	blt $t0, $s3, decr_block_buf_loop	# if $t0 < period, then we have a "partial" block
	move $t0, $s3						# else we have a "full" block
	decr_block_buf_loop:
	move $t4, $t0						# $t4 = $t0
	decr_block_buf_loop_cont:
	# get i
	lbu $t2, 0($s4)						# $t2 = first char from index_buffer
	beqz $t2, end_decr_block_buf		# if $t2 = 0, go to end_decr_block_buf
	sb $t2, 0($s5)						# save $t2 to block_buffer
	# get j
	add $s4, $s4, $t0					# move $t0 characters ahead
	lbu $t3, 0($s4)						# $t3 = first char from (moved) index_buffer
	beqz $t3, end_decr_block_buf		# if $t3 = 0, go to end_decr_block_buf
	sb $t3, 1($s5)						# save $t3 to block_buffer
	addi $s5, $s5, 2					# go to next 2 char of block_buffer
	# convert characters to plaintext
	bifid_decr_conversion:
	move $s5, $s1						# $s5 = block_buffer
	lbu $t6, 0($s5)						# first char from block_buffer
	addi $t6, $t6, -48					# convert from ascii
	lbu $t7, 1($s5)						# second char from block_buffer
	addi $t7, $t7, -48					# convert from ascii
	li $t8, 9							# $t8 = 9
	mul $t8, $t6, $t8					# $t8 = i * 9
	add $t8, $t7, $t8					# $t8 = (i * 9) + j
	add $t8, $s2, $t8					# $t8 = baseaddr key_square + ((i*9)+j)
	lbu	$t8, 0($t8)						# $t8 = first char from $t5
	sb $t8, 0($s0)						# save $t8 into plaintext
	addi $s0, $s0, 1					# go to next char of plaintext
	# continue loop
	move $s4, $s6						# gotta reset $s4 to beginning!!
	addi $t5, $t5, 1					# counter2++
	add $s4, $s4, $t5					# $s4 pos = $s4 + counter2
	addi $t4, $t4, -1					# decrement until zero
	bgtz $t4, decr_block_buf_loop_cont	# if $t4 > 0, decr_block_buf_loop_cont
	end_decr_block_buf:
	# continue looping
	add $s4, $s4, $s3					# increment $s4 by period
	add $t5, $t5, $s3					# increment $t5 by period
	add $t1, $t1, $s3					# counter = counter + period
	blt $t1, $s7, bifid_decr_block_buffer_loop # if $t1 < length, loop again
	# get return value
	bifid_decr_return_val:				
	sb $0, 0($s0)						# null terminate ciphertext
	div $s7, $s3						# divide ciphertext length by period
	mfhi $t0							# $t0 = remainder
	mflo $t1							# $t1 = quotient
	beqz $t0, end_decr_return_val		# if remainder = 0 (i.e., len is multiple of period)
	addi $t1, $t1, 1					# else quotient = quotient + 1
	j end_decr_return_val				# go to end_decr_return_val
	end_decr_return_neg_val:
	li $t1, -1							# $t1 = -1
	end_decr_return_val:
	move $v0, $t1						# $v0 = return_value
	# restore registers from stack
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
	jr $ra								# return to where function was called

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
