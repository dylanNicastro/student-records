.text

init_student:
	sll $t0, $a0, 10	# shift id to the left 10 bits to make room for credits
	or $t0, $t0, $a1	# mask id and credits together
	sw $t0, 0($a3)		# store id and credits in bytes 0-3 of $a3
	sw $a2, 4($a3)		# store the address of the name in bytes 4-7 of $a3
	jr $ra 			# exit procedure
	
print_student:
	move $t2, $a0		# store the bytestring's address in $t2
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
	move $t9, $a0		# amount of students to add stored in $t9
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
		lw $t8, 0($sp)			# get value of stack pointer
		add $t6, $t5, $t8		# calculate address of current record
		move $a3, $t6			# load address of current record into $a3
		
		move $t5, $ra
		jal init_student
		move $ra, $t5
		
		addi $t4, $t4, 1	# increment loop iteration
		j _init_loop

	_exit_init_loop:
	jr $ra 			# exit procedure
	
insert:
	# a0 - record (8 bytes - 2 words)
	# a1 - address to the start of the table
	# a2 - size of the table (4 bytes - 1 word)
	# v0 - return -1 if it could not be placed, index of the record otherwise
	
	move $t1, $a0		# store the bytestring's address in $t1
	lw $t0, 0($t1)		# grab the first word of the bytestring
	srl $t0, $t0, 10	# get the id
	div $t0, $a2		# calculate array index (saved into hi)
	mfhi $t0		# save the array index into $t0 (0 to tablesize-1)
	
	sll $t1, $t0, 2		# multiply by 8 to get byte index
	add $t1, $t1, $a1 	# calculate address of the record at that spot in the table
	lw $t2, 0($t1)		# load the word
	blez $t2, _match_found	# if it is null or tombstone, we can place it here
	
	move $t3, $t1		# make a copy of the record address
	move $t4, $t0		# make a copy of the original array index
	addi $t4, $t4, 1	# increment by 1 to start the loop
	_probe_algo:
		div $t4, $a2	# divide index by table size
		mfhi $t0	# get hash table index from remainder
		
		sll $t1, $t0, 2		# multiply by 4 to get byte index
		add $t1, $t1, $a1 	# calculate address of the record at that spot in the table
		beq $t1, $t3, _no_match_found 	# exit if we've fully looped around
		lw $t2, 0($t1)		# load the word
		blez $t2, _match_found
		addi $t4, $t4, 1		# increment array index
		j _probe_algo
	
	_match_found:
	# $t1 holds address of where to insert, $a0 holds address of the record to be inserted
	sw $a0, 0($t1)		# store the address of the record into the proper place to insert
	
	move $v0, $t0		# return the index of the record within the hash table
	jr $ra			# exit procedure
	
	_no_match_found:
	li $v0, -1		# return -1 to indicate we could not place it in the table
	jr $ra 			# exit procedure
	
search:
	# $a0 holds id
	# $a1 points to table
	# $a2 holds table size
	div $a0, $a2		# calculate array index (saved into hi)
	mfhi $t0		# save the array index into $t0 (0 to tablesize-1)
	
	sll $t1, $t0, 2		# multiply by 4 to get byte index
	add $t1, $t1, $a1 	# calculate the address of the spot in the table
	lw $t2, 0($t1)		# load the address of the record
	blez $t2, skip		# if the address is 0x0, skip checking it
	
	lw $t2, 0($t2)		# load the first word 
	srl $t2, $t2, 10		# get the id from the word
	beq $a0, $t2, _item_found	# if the id equals the given id, we found it
	
	skip:
	
	move $t3, $t1		# make a copy of the record address
	move $t4, $t0		# make a copy of the original array index
	addi $t4, $t4, 1	# increment by 1 to start the loop
	_search_algo:
		div $t4, $a2	# divide index by table size
		mfhi $t0	# get hash table index from remainder
		
		sll $t1, $t0, 2		# multiply by 4 to get byte index
		add $t1, $t1, $a1 	# calculate the address of the spot in the table
		beq $t1, $t3, _no_item_found 	# exit if we've fully looped around
		lw $t2, 0($t1)		# load the address of the record
		blez $t2, _skip		# skip checking the id if the address is 0x0
		lw $t2, 0($t2)		# load the first word 
		srl $t5, $t2, 10		# get the id from the word
		beq $a0, $t5, _item_found
		_skip:
		addi $t4, $t4, 1		# increment array index
		j _search_algo
	
	_item_found:
	# $t1 holds address of the found address, $a0 holds address of the record to be inserted
	lw $v0, 0($t1)		# return pointer to the found address
	move $v1, $t0		# return the index of the record within the hash table
	jr $ra			# exit procedure
	
	_no_item_found:
	li $v0, 0		# return NULL since we could not find an address
	li $v1, -1		# return -1 to indicate nothing was found
	jr $ra 			# exit procedure

delete:
	move $t9, $ra		# store $ra value
	jal search		# search for id in the table
	move $ra, $t9		# put proper $ra value back
	# $v0 holds the address to the record
	# $v1 holds the index of the id in the table
	bltz $v1, no_delete	# if no record was found, don't delete anything
	
	sll $t1, $v1, 2		# multiply by 4 to get byte index
	add $t1, $t1, $a1 	# calculate the address of the spot in the table
	li $t2, -1		# create tombstone value
	sw $t2, 0($t1)		# change table value at index to tombstone
	
	no_delete:
	move $v0, $v1		# give return value
	jr $ra			# exit procedure
