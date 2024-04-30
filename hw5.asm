.text

init_student:
	sll $t0, $a0, 10	# shift id to the left 10 bits to make room for credits
	or $t0, $t0, $a1	# mask id and credits together
	sw $t0, 0($a3)		# store id and credits in bytes 0-3 of $a3
	sw $a2, 4($a3)		# store the address of the name in bytes 4-7 of $a3
	jr $ra 			# exit procedure
	
print_student:
	move $t2, $a0		# store the bytestring's address in $t0
	lw $t0, 0($t2)		# grab the first word of the bytestring
	srl $t1, $t0, 10	# get the id
	move $a0, $t1		# put it in $a0
	li $v0, 1		# print integer
	syscall		
	
	li $a0, 32		# load ASCII value for a space
	li $v0, 11		# print character
	syscall
	
	andi $t1, $t0, 0x3FF	# mask to get the rightmost 10 bits (credits)
	move $a0, $t1		# put it in $a0
	li $v0, 1		# print integer
	syscall
	
	li $a0, 32		# load ASCII value for a space
	li $v0, 11		# print character
	syscall
	
	lw $a0, 4($t2)		# grab the second word of the bytestring and put it directly into $a0
	li $v0, 4		# print string
	syscall
	
	jr $ra 			# exit procedure
	
init_student_array:
	move $t9, $a0		# amount of students to add stored in $t0
	move $t1, $a1		# grab array of ids
	move $t2, $a2		# grab array of credits
	move $t3, $a3		# grab pointer to string of names
	
	
	li $t4, 0		# current loop iteration
	_init_loop:
		beq $t9, $t4, _exit_init_loop	# exit loop if we reached the end of the students
		sll $t5, $t4, 2			# calculate current index of integer arrays in bytes
		
		add $t6, $t5, $t1		# calculate byte index of current id
		lw $a0, 0($t6)			# load id into $a0
		
		add $t6, $t5, $t2		# calculate byte index of current credits
		lw $a1, 0($t6)			# load credits into $a1
		
		move $t8, $t3			# copy string into $t8
		_get_name_loop:
			lb $t7, 0($t8)			# load the current character from the string
			beqz, $t7, _exit_name_loop	# if current character is null terminator, exit loop
			addi $t8, $t8, 1			# increment pointer to the next character
			j _get_name_loop
			
			
		_exit_name_loop:
		move $a2, $t3			# load address of string into $a2
		move $t3, $t8			# "remove" that name from the string
		addi $t3, $t3, 1		# increment pointer to the next character (past the null terminator)
			
		sll $t5, $t4, 3			# calculate current index of pointer
		add $t6, $t5, $s0		# calculate address of current record
		move $a3, $t6			# load address of current record into $a3
		
		move $t5, $ra
		jal init_student
		move $ra, $t5
		
		addi $t4, $t4, 1	# increment loop iteration
		j _init_loop

	_exit_init_loop:
	jr $ra 			# exit procedure
	
insert:
	jr $ra 			# exit procedure
	
search:
	jr $ra 			# exit procedure

delete:
	jr $ra			# exit procedure
