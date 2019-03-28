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
	newstack:	  .space 80	## 20 element array for reverse string
	evalstack:	  .space 80	## 20 element array for reverse string
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
	la $s1, input
	addi $s2, $zero, 57

	jal pf
	end_pf: la $s1, postfix
	
	jal reverse 
	#end_rev:
	end_reverse:la $s1, newstack
	jal printData
	
	la $s1, newstack
	jal eval	
	#la $s1, evalstack
	
	lbu $a0, evalstack
	li $v0, 1
	syscall
	
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
	
	LOOP_push: beq $t1, 0, END_LOOP_push
		
		addu $s1, $s1, $t3
		lbu $t0, ($s1)
		sb $t1, ($s1)		##A[2]=t1
		addi $t3, $t3,1 ##i++
		la $s1, ($s3)
		beq $t0, 0, END_LOOP_push
		
		addu $s1, $s1, $t3	
		lbu  $t1, ($s1)		## t1 = A[1]
		sb $t0, ($s1)		##A[1] = t0
		addi $t3, $t3,1 ##i++
		la $s1, ($s3)
		
		j LOOP_push
	END_LOOP_push:

	jr $ra
	
END_push:

pop:
	################
	## Removes the first element of the "stack" (array) specified by $s1
	## by moving up all of the array elements. Returns (sets $s0 equal to)
	## the first element of the stack
	
	li $t3, 0	# i =0	
	la $s3, ($s1)	## backing up pointer to beginning of stack
	
	## Return the first element
	lbu $s0, ($s1)
	
	LOOP_pop: beq $t1, 0, END_LOOP_pop
		#############
		## starting at the first element, kind of the opposite of push()
		## move everything up an index
		lbu $t1, 1($s1)
		sb $t1, ($s1)
		
		addi $t3, $t3,1 ##i++
		la $s1, ($s3)
		addu $s1, $s1, $t3
		
		j LOOP_pop
	END_LOOP_pop:

	jr $ra
END_pop:

pf:
	################################
	## Actual postfixing done here.
	## This assumes a valid infix expression
	
	li $t4, 0	## i = 0
	
	process_LOOP:
		
		lbu $t1, input($t4)
		beqz $t1, END_process_LOOP
		beq $t1 43, plus
		beq $t1 45, minus
		beq $t1 40, lparen	## no whitespaces
		beq $t1 32, lparen
		beq $t1 41, rparen
		bne $t1 41, operand
		## instead of making an else, I'm just doing
		## reverse logic of having all of these commands go to their
		## respective 'if' statmeents then jumping
		## back to the beginning of the loop
		plus:
			la $s1, opstack
			addi $s2, $t1, 0
			jal push
		
			j iter
		minus:
			la $s1, opstack
			addi $s2, $t1, 0
			jal push
			
			j iter
		lparen:	#(
			addi $t4, $t4, 1
			
			j process_LOOP	## basically just ignore it
		rparen: #)
			la $s1, opstack
			jal pop
			
			la $s1, postfix
			addi $s2, $s0, 0
			jal push
			
			j iter
	
		operand:
			la $s1, postfix
			addi $s2, $t1, 0
			jal push
			
			j iter
		
		iter:
			addi $t4, $t4, 1
		
			#la $s1, opstack
			#jal printData
			#la $s1, postfix
			#jal printData
			j process_LOOP	
			
	END_process_LOOP:
	addi $s0, $t4, 0
	j end_pf
END_pf:

reverse:
	li $t4, 0
	la $s4, ($s1)
	la $s0, newstack
	li $t6, 1
	reverse_LOOP: beqz $t6, END_reverse_LOOP
		addu $s1, $s1, $t4
		lbu $t6, ($s1)
		beqz $t6, END_reverse_LOOP
		la $s1, newstack
		addi $s2, $t6, 0
		jal push
		
		la $s1, ($s4)
		addi $t4, $t4, 1
		j reverse_LOOP
	END_reverse_LOOP:
	addi $s0, $t4, 0
	j end_reverse
	
eval:
	la $s4, ($s1) ## backing up
	la $s6, ($ra)
	li $t1, 1
	li $t4, 0
	eval_LOOP: 
		addu $s1, $s1, $t4
		lbu $t1, ($s1)
		
		beq $t1, 10, END_eval_LOOP
		beq $t1, 43, p	## plus
		beq $t1, 45, m	## minus
		bne $t1, 45, o	## operand
		p:
			# do evaluation
			la $s1, evalstack	## get first operand
			jal pop
			subi $t5, $s0, 0
			la $s1, evalstack
			jal pop			## get second operand
			subi $t6, $s0, 0
			add $s2, $t6, $t5
			la $s1, evalstack
			jal push		## push result back on the stack
			j i
		m:
			## do evaluation
			la $s1, evalstack
			jal pop
			subi $t5, $s0, 0
			la $s1, evalstack
			jal pop
			subi $t6, $s0, 0
			sub $s2, $t6, $t5
			la $s1, evalstack
			jal push
			j i
		o:
			## add operands to evalstack
			la $s1, evalstack
			subi $s2, $t1, 48
			jal push
			j i
		i:
			la $s1, ($s4)
			addi $t4, $t4, 1
			j eval_LOOP
	END_eval_LOOP:
	la $ra, ($s6)
	jr $ra
END_eval:
printData:
	# while (n > 0)
	
	## want to start at the top of the stack, not the bottom
	li $a0, 1
	la $s2, ($s1)
	
	printLoop: blt $a0, 0, END_printLoop
		
		## print the charachter
		li $v0, 11
		addu $s1, $s1, $t5
		lbu $a0, ($s1)
		beq $a0, 0, END_printLoop
		syscall
		
		addi $t5, $t5, 1	#i++
		la $s1, ($s2)   # only increment the index, reset $a1 to be input[0]
		j printLoop
	END_printLoop:
	li $t5, 0
	jr $ra
END_printData:
