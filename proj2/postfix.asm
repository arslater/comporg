##
## proj2: Assembly convertingto postfix expression
## ISCI:404
## 
## by Anita Slater, 
##

#########################
## Varaiable declarations (strings)
##
.data
	enter_prompt_str: .asciiz "Expression to Evaluate:"
	space:            .asciiz " "
	input:            .space 80 	## 20 element array, allocating size ahead of time
	opstack:          .space 80
	postfix:	  .space 80	## 20 element array for postfix resultant string
	A:                .word   0:100		
.text

########
## RETURN VALUES ARE $s0!!!!!!!
## COMMAND ARGUEmntS ARE $s1 AND $s2 for the thing to add!!!!!!

main:
	li $v0, 4	                ## Going to be printing out a string
	la $a0, enter_prompt_str	## String prompting user input
	syscall
	
	la $a0, input
	li $v0, 8	## Get user input, store in data string
	li $a1, 20
	move $t0, $a0
	syscall
	
	la $a1, input	
	li $t5, 0

	#li $
	la $s1, input
	addi $s2, $zero, 57
	#sb $s2, ($t0)
	#la $s2, ($t0)
	jal push
	
	#jal printData
		
	li $v0, 10         # exit program
	syscall
 
END_main:

push:
	## want to "move the whole array
	## set the second index to the first index, overwriting
	## the first index 
	la $s3, ($s1)	## backup pointer
	li $t3, 0	## iteration value starting @ zero
	
	lbu $t1, ($s1)  ##t1 = A[0]
	sb $s2, ($s1)	##A[0] = arg
	addi $t3, $t3,1 ##i++
	la $s1, ($s3)
	
	LOOP_push: beq $t1, 10, END_LOOP_push
		
		addu $s1, $s1, $t3
		lbu $t0, ($s1)
		sb $t1, ($s1)		##A[2]=t1
		addi $t3, $t3,1 ##i++
		la $s1, ($s3)
		beq $t0, 10, END_LOOP_push
		
		addu $s1, $s1, $t3	
		lbu  $t1, ($s1)		## t1 = A[1]
		sb $t0, ($s1)		##A[1] = t0
		addi $t3, $t3,1 ##i++
		la $s1, ($s3)
		
		j LOOP_push
	END_LOOP_push:
	
	j printData
	#li, $v0, 11
	#addu $s0, $s0, 2
	#lbu $a0, ($s0)	## loading the specified byte
	#syscall
	
	
	## Change the first element to the second element
	
	
	
	
	#pop_LOOP: beq $t0, 10, END_pop_LOOP
	#	sw $t0, $s0($t5)
	#	addi $t5, 1
	#	lw $t0, $s0($t5)
	#	j pop_LOOP
	#END_pop_LOOP:
	
	## testing, should print out the first value of the array
	#li $v0, 11
	#addu $s0, $s0, $zero
	#lbu $a0, ($a1)
	#syscall
	
	jr $ra
	
END_push:

printData:
	# while (n > 0)
	printLoop: beq $a0, 0, END_printLoop
		
		## print the charachter
		li, $v0, 11
		addu $a1, $a1, $t5
		lbu $a0, ($a1)
		beq $a0, 0, END_printLoop
		syscall
		
		add $t5, $t5, 1	#i++
		la $a1, input   # only increment the index, reset $a1 to be input[0]
		j printLoop
	END_printLoop:
	jr $ra
END_printData:
