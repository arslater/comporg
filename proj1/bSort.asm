##
## Implementing Bubble sort in assembly
## ISCI:333
## 
## by Anita Slater, 
##

#########################
## Varaiable declarations (strings)
##
.data
	size_prompt_str:  .asciiz "Size of input array: "
	enter_prompt_str: .asciiz "Enter number: "
	A:  .word   0:100
	space:            .asciiz " "
.text
##########################
## Getting the size of the array 
##########################

main:
li $v0, 4	        ## Going to be printing out a string
la $a0, size_prompt_str	## String prompting user input
syscall

## Getting user input of array size ##
li $v0, 5	      ##
syscall		      ##		    
add $t0, $v0, $zero   ## n=$t0 (upper bound=$t0)

la $s0, A  ## save $s0 as the start of the memory denoted by A

# $t0 = upper limit
# $t1 = i
# $t3 = user input
# $s0 = base address

###################################
## Building array with user inputs
###################################
build_LOOP:
	# for(i=0; i<$t0; i++)		
	bge $t1, $t0, END_LOOP 
	li $v0, 4                ## Printing out the promping string
	la $a0, enter_prompt_str ##
	syscall
	
	li $v0, 5		 ##
	syscall			 ## Grabbing the input, saving in $t3
	add $t3, $v0, $zero	 ##
	
	sw $t3, ($s0)		 ## Storing in memory starting at $s0
	addi $s0, $s0, 4	 ## Increasing the offset 1 word	
	addi $t1, $t1, 1	 ## i++
	j build_LOOP
END_LOOP:

la $s0, A	 # Save the location of $s0 as the start of the address of A
li $t1, 0	 # i = =
subi $t0, $t0, 1 # n--, works better for calculations

##################
## Variable declaratons within sorting loop
##
## $t2 = j
## t4 = current value....A[j]
## t5 = following value..A[j+1]
## $t3(bool), 1=true, 0=false

##################################
## Doing actual sorting         ##
sort_LOOP:                      ##
        # for(i=0;i<$t0; i++)   ##
	beq $t0, $t1, END_sort
	li $t3, 0	## sorted=false	
	li $t2, 0	## j = 0
	
	la $s0, A	 ## $s0 is at memory address of A
	la $s1, A	 ## $s1 is also at memory address of A
	
	inner_LOOP:	
	bge $t2, $t0, END_inner_LOOP ## while (j=0 to loop-1	
		addi $s1, $s1, 4     ## A[j+1]
		lw $t4, ($s0)	     ## $t4=A[j]
		lw $t5, ($s1)	     ## $t5=A[j+1]	    
		ble $t4, $t5, ELSE	## if( $t4 > $t5)
			sw $t5, ($s0)	 ## A[j]=$t5
			sw $t4, ($s1)    ## A[j+1]=$t4
			subi $s1, $s1, 4 ## 'reset' $s1 to account for changing the offset
			li $t3, 1	# swap found, boolean to TRUE
			j ENDIF
		ELSE:
			addi $s0, $s0, 4 ## Increasing the index by grabbing the next word ( A[j++] )
			addi $t2, $t2, 1 ## j++
		ENDIF:		
		j inner_LOOP		
	END_inner_LOOP:
	## Ending the inner loop
	##################################
	
	## If no matches found, break out of the loop ##   
	bgtz $t3, END_chk  ## if($t3 == 0)
		j END_sort
	END_chk:
	
	addi $t1, $t1, 1   # i++		
	j sort_LOOP
END_sort:
## Ending the sorting loop
##################################
la $s0, A	 # resetting $s0 to the base address of the array
addi $t0, $t0, 1 # n++	

#############################
## Final loop to print values
print_LOOP:
	# while (n > 0)
	beqz $t0, END_print	
	lw $t1, ($s0)		## $t0 = A[i]
				
	li $v0, 1		##
	add $a0, $zero, $t1	## Print integer
	syscall 		##

	subi $t0, $t0, 1	# i--
	addi $s0, $s0, 4	# Incrementing to the next index
	
	li $v0, 4	        ## Going to be printing out a string
	la $a0, space	        ## Printing out a space
	syscall	
	j print_LOOP
END_print:
## Ending the loop
############################	
li $v0, 10         # exit program
syscall