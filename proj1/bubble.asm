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
	
	li $v0, 4	        ## Going to be printing out a string
	la $a0, sort_info_str	## String prompting user input
	syscall
		
	li $t5, 9	## length of array, n //TODO: Consider making this an s register????
	addi $t1, $t5, 0
	
	jal printLoop		## Printing out the first string
		
	li $t0, -1	## k  = 0
	li $t2, 0	## min
	li $t3, 0	## j = 0
	
	OUTER_MAIN_LOOP:
		bge $t0, $t5, END_printData ## break if k >= length
		addi $t2, $t0, 0 ## min = k
		
		li $t4, 5
		
		li $v0, 1		##
		add $a0, $zero, $t4	## Testing to see how many times this executes
		syscall 		##
		
		addi $t0, $t0, 1	##k++
		j OUTER_MAIN_LOOP
	END_OUTER_MAIN_LOOP:
END_main:

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
## Ending the loop
############################	
li $v0, 10         # exit program
syscall
