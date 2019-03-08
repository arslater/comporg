##
## Implementing Insertion sort in assembly
## ISCI:404
## 
## by Anita Slater, 
##

#########################
## Varaiable declarations (strings)
##
.data
	order_prompt_str:  .asciiz "Enter 0 to sort in descending order "
	order_info_str:    .asciiz "Any number different than 0 will sort in ascending order."
	sort_info_str:     .asciiz "Before sort:"
	enter_prompt_str:  .asciiz "Enter number: "
	space:            .asciiz " "
	list: .word 7, 9, 4, 3, 8, 1, 6, 2, 5
	A:    .word   0:100
		
.text
##########################
## Getting the size of the array 
##########################

main:
	li $v0, 4	         ## Going to be printing out a string
	la $a0, order_prompt_str ## String prompting user input
	syscall
	
	li $v0, 4	        ## Going to be printing out a string
	la $a0, order_info_str	## String prompting user input
	syscall

	## Getting user input acending or descending order ##
	li $v0, 5	      ##
	syscall		      ##		    
	add $t0, $v0, $zero   ## t0 =  direction

	la $s0, list	## $s1 = list[0]
	li $t1, 9	## length of array, n //TODO: Consider making this an s register????
	
	li $v0, 4	        ## Going to be printing out a string
	la $a0, sort_info_str	## String prompting user input
	syscall
	
	jal printData	

	li $t0, 0	## k  = 0
	li $t2, 0	## min
	li $t3, 0	## j
	outerLoop:
		beq $t0, $t1, printData	## print the array if its done
		addi $t2, $t1, 0	## min = k
		
		addi $t0, $t0, 1
		innerLoop:
			beq $t3, $t1, outerLoop
			addi $t3, $t0, 1
			
			addi $a0, $t0, 0	## argument j
			addi $a1, $t2, 0	## argument min
			
			jal CHECK
			
			
			###############
			## Checking to see if this evaluates properly
			li $v0, 1		##
			add $a0, $zero, $a0	## Print integer
			syscall 		##

			addi $t3, $t3, 1
			j innerLoop		
		END_innerLoop:
		

END_main:
#check:
#	bne $s2, 0, ELSE	## if argument == 0  
#END_check:

CHECK:
	beq $s0, 0, ELSE		## if argument != 0
		bgt $a0, $t0 ELIF1  			## if j > min
			li $a0, 0
		ELIF1:
			li $a0, 1
	ELSE:
		blt $a0, $t0 ELIF2  			## if j > min
			li $a0, 0
		ELIF2:
			li $a0, 1
			
	jr $ra

printData:
	# while (n > 0)
	printLoop:
		beqz $t1, END_printLoop	
		lw $t4, ($s0)		## 
				
		li $v0, 1		##
		add $a0, $zero, $t4	## Print integer
		syscall 		##

		subi $t1, $t1, 1	# i--
		addi $s0, $s0, 4	# Incrementing to the next index
	
		li $v0, 4	        ## Going to be printing out a string
		la $a0, space	        ## Printing out a space
		syscall	
		jr $ra
	END_printLoop:
	jr $ra
END_printData:
## Ending the loop
############################	
li $v0, 10         # exit program
syscall
