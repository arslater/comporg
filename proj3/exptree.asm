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
	tree:             .word 0:100
	subtree:	  .word 0:25
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
	end_reverse:la $s1, newstack
	#end_reverse:
	jal printData
	
	###print newline
	li $v0, 11
	li $a0, 10
	syscall
	
	la $s1, newstack
	jal buildTree
	
	la $s1, tree
	
	jal evalTree
	
	li $v0, 1
	addi $a0, $s0, 0
	syscall
	
	#jal printData
	
	
	##printing equal sign
#	li $a0, 61
#	li $v0, 11
#	syscall
	
	## getting evaluated value
#	la $s1, newstack
#	jal eval	
#	## printing it out as an int
#	lbu $a0, evalstack
#	li $v0, 1
#	syscall
	
	
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
	beq $a3, 1, word1
	sb $s2, ($s1)	##A[0] = arg
	j END_word
	word1:
		sw $s2, ($s1)
	END_word:
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
	
	li $t1, 1	## IMPORTANT!!! Need this or loop will never run!!
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

buildTree:
	li $t0, 0
	li $t4, 0
	li $t5, 1
	li $a3, 0	## remove flag
	la $t6, subtree
	la $s4, ($s1)	## backing up $s1
	la $a2, ($ra)	## backign up return pointer
	lbu $t5, ($s1)
	
	t_buildLOOP: beq $t5, 10, END_t_buildLOOP
		
		beq $t5, 43, t_operator
		beq $t5, 45, t_operator
		bne $t5, 45, t_operand
		
		t_operator: # + or -
			## When encountering an operator
			## we want to push it to our "opstack" ($t0)
			## and then push the whole opstack to the tree
			
			la $s1, ($t6)
			addi $s2, $t5, 0
			jal push		## pushing operator to opstack
			
			
			li $a3, 1		## flag that we're pushing subtree
			la $s1, tree
			lw $s2, ($t6)
			jal pushAddr		## pushing subtree to tree
			
			
			
			## erase opstack
			li $s1, 0
			la $t6, subtree
			sw $s1, ($t6)
			
			li $a3, 0	## remove flag
			j t_iter
		t_operand: # operand ( the numbers )
			la $s1, ($t6)
			subi $s2, $t5, 48
			jal push		## pushing to the "opstack"
			
			j t_iter
		t_iter:
			addi $t4, $t4, 1
			la $s1, ($s4)
			addu $s1, $s1, $t4
			lbu $t5, ($s1)
			 j t_buildLOOP
	END_t_buildLOOP:
	
	la $s1, tree

lbu $s3, 1($s1)

lw $a0, ($s1)
li $v0, 11
syscall
li $a0, 10
syscall


lw $a0, 4($s1)

#addi $a0, $a0, 48
li $v0, 11
syscall
li $a0, 10
syscall

lw $a0, 8($s1)
li $v0, 11
#addi $a0, $a0, 48
syscall
li $a0, 10
syscall	

li $v0, 10         # exit program
	syscall
	la $ra, ($a2)
	jr $ra
END_buildTree:

evalTree:
	la $s4, ($s1) ## backing up pointer
	la $a3, ($ra)
	li $t4, 0
	lbu $t5, ($s1)
	t_evalLOOP: beqz $t5, END_t_evalLOOP
		
		beq $t5, 43, eval_plus
		beq $t5, 45, eval_sub
		bne $t5, 45, eval_operand
		
		eval_plus:
		
			la $t5, tree
			
			## pop the operator
			la $s1, ($t5)
			jal pop
			
			## pop second element and save in $t6
			la $s1, ($t5)
			jal pop
			addi $t6, $s0, 0
			
			## pop third element and save in $t7
			la $s1, ($t5)
			jal pop
			addi $t7, $s0, 0
			
			## pop the "root" node
			la $s1, ($s4)
			jal pop
			
			## Perform the plus operator, save in $t6
			add $t6, $t6, $t5
			
			## push the result back on the stack
			addi $s2, $t6, 0
			la $s1, ($s4)
			jal push
			
			j t_eval_iter
			
		eval_sub:
			## pop the operator
			
			la $t5, tree
			la $s1, ($t5)
			jal pop
			
			## pop second element and save in $t6
			la $s1, ($t5)
			jal pop
			addi $t6, $s0, 0
			
			## pop third element and save in $t7
			la $s1, ($t5)
			jal pop
			addi $t7, $s0, 0
			
			## pop the "root" node
			la $s1, ($s4)
			jal pop
			
			## Perform the plus operator, save in $t6
			sub $t6, $t6, $t5
			
			## push the result back on the stack
			addi $s2, $t6, 0
			la $s1, ($s4)
			jal push
			
			j t_eval_iter
			
		eval_operand:
		
		t_eval_iter:
			li $t6, 0
			li $t7, 0
			la $s1, ($s4)
			addi $t4, $t4, 1
			add $s1, $s1, $t4
			lbu $t5 ($s1)
			j t_evalLOOP
	END_t_evalLOOP:
	la $ra, ($a3)
	lbu $s0, ($s1)
	jr $ra
endEvalTree:

printData:
	## want to start at the top of the stack, not the bottom
	li $a0, 1
	la $s2, ($s1)
	li $t5, 0
	
	printLoop: beq $a0, 0, END_printLoop
		
		## print the charachter
		li $v0, 11
		addu $s1, $s1, $t5
		lbu $a0, ($s1)
		beq $a0, 10, END_printLoop	# no newline chars
		beq $a0, 0, END_printLoop
		syscall
		
		addi $t5, $t5, 1	#i++
		la $s1, ($s2)   # only increment the index, reset $a1 to be input[0]
		j printLoop
	END_printLoop:
	li $t5, 0
	jr $ra
END_printData:


pushAddr:
	li $t0, 0	# i =0
	la $s3, ($s1)	## backing up
	lw $t1, ($s1)
	
	addr_LOOP: beqz $t1, addItem
		addi $t0,$t0, 4 ## i +=4
		la $s1, ($s3)	# reset so doesnt douple increment
		add $s1, $s1, $t0
		lw $t1, ($s1)
		j addr_LOOP
	addItem:
	
		sw $s2, ($s1)
		jr $ra
		
END_pushAddr: