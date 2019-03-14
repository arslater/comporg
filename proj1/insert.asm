##
## proj1: Implementing Insertion sort in assembly
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
	after_info_str:    .asciiz "\n After sort:"
	enter_prompt_str:  .asciiz "Enter number: "
	space:            .asciiz " "
	list: .word 7, 9, 4, 3, 8, 1, 6, 2, 5
	A:    .word   0:100
		
.text

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
	add $t9, $v0, $zero   ## t0 =  direction

	la $s0, list		## $s1 = list[0]
	
	li $v0, 4	        ## Going to be printing out a string
	la $a0, sort_info_str	## String prompting user input
	syscall
		
	li $t5, 9		## length of array
	addi $t1, $t5, 0
	
	jal printLoop		## Printing out the first string
		
	li $t0, 0	## k  = 0
	li $t2, 0	## min
	li $t3, 0	## j = 0	
	li $t7, 0	##temp
	
	OUTER_MAIN_LOOP:bge $t0, $t5, END_OUTER_MAIN_LOOP ## break if k >= length
		addi $t2, $t0, 0   ## min = k
		addi $t3, $t0, 1   ## j = k+1
		
		INNER_MAIN_LOOP:bge $t3, $t5, END_INNER_MAIN_LOOP ## break if j== length	        
			jal CHECK
			bne $t6, $zero, ELSE	## I have absolutely NO idea why the reverse doesn't work
				addi $t2, $t3, 0  ## min=j
			ELSE:
			addi $t3, $t3, 1	##j++
			j INNER_MAIN_LOOP
			
		END_INNER_MAIN_LOOP:			
		beq $t2, $t0, END_IF_2
			mul $s1, $t0, 4
			mul $s2, $t2, 4
			
			lw $t7, list($s2) ## tmp  = list[min]
			lw $t8, list($s1) ## tmp1 = list[k]
			sw $t8, list($s2) ## list[min] = list[k]
			sw $t7, list($s1) ## list[k] = tmp
		END_IF_2:
		addi $t0, $t0, 1	##k++	
		j OUTER_MAIN_LOOP
		
	END_OUTER_MAIN_LOOP:
	
	li $v0, 4	         ## Going to be printing out a string
	la $a0, after_info_str   ## String prompting user input
	syscall
	
	la $s0, list
	addi $t1, $t5, 0
	#jal transformLoop
	jal printData
	j END
	
END_main:

CHECK:
	mul $s1, $t3, 4	## getting index of j
	mul $s2, $t2, 4 ## getting index of min
	
	lw $s1, list($s1) ##list[j]
	lw $s2, list($s2) ##list[min]
	
	beqz $t9, CHECK_IF
	j CHECK_ELSE
	CHECK_IF:
		blt $s1, $s2, CHECK_R_IF
		li $t6, 1		## j > min (direction = 0)
		jr $ra
		CHECK_R_IF:
			li $t6, 0	## j < min ( direction = 0)
			jr $ra	
	CHECK_ELSE:
		bgt $s1, $s2, CHECK_R1_IF
		li $t6, 1		## j < min (direction = 1)
		jr $ra
		CHECK_R1_IF:		## j > min (direction = 1)
			li $t6, 0
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
		j printLoop
	END_printLoop:
	jr $ra
END_printData:

END:	
li $v0, 10         # exit program
syscall
