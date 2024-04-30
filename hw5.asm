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
	jr $ra 			# exit procedure
	
insert:
	jr $ra 			# exit procedure
	
search:
	jr $ra 			# exit procedure

delete:
	jr $ra			# exit procedure
