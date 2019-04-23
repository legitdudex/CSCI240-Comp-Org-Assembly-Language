

#Part A of the first MIPS programming homework 
#Name: Kang-hee Cho
#Course: CS240 TuFr 9:15am - 10:30am
#Professor: Dr.Simina Fluture
#This is a program that gets 2 inputs and stores them in the s0 and s1 registers
#Then, the program multplies s0 by 4 and puts the result back into s0
#The program subtracts 3 from the second input, s1 and then puts the result back into s1
#The program then adds the two results and puts the result of the addition into s2
#Then finally, the program prints the result along with a pretty message to go along with it


	.data #data section
welcome_message:		.asciiz		"Welcome to the program.\n"
exit_message:			.asciiz		"Enter 99 to exit.\n"
input_error_message_2:		.asciiz		"Invalid input. Input too low.\n"
input_error_message_1:		.asciiz 	"Invalid input. Input too high\n"
input_message_1:		.asciiz		"Please enter an integer in the range [-20, 0]\n"
input_message_2:		.asciiz		"Please enter an integer in the range [10, 30]\n"
completing_message_1:		.asciiz		"The result of (4*"
completing_message_2:		.asciiz		") + ("
completing_message_3:		.asciiz		" - 3) is "
completing_message_4:		.asciiz		"\n"

	.text

	.globl main

main:
	li	$v0, 4 #to print a string, we need to use 4 as the system call code
	la	$a0, welcome_message #load the address of the welcome message into $a0
	syscall #print the welcome message
	j	user_input_1 #get user input for the first integer

user_input_1:
	jal	prompt_for_input_1 #get user input for the first integer
	beq	$s0, 99, end_program #if the user entered 99, exit the program
	bgtz	$s0, invalid_input1_1 #input was invalid if it was greater than 0
	addi	$t0, $zero, $20
	add	$t1, $s0, $t0 #add 20 to the input to see if it is in the range
	bltz	$t1, invalid_input_1_2 #input was invalid if it was less than -20
	### at this point, the user input for the first integer was valid ###
	### now, we can jump and get user input for the second integer ###
	j	user_input_2 #get user input for the second integer

user_input_2:
	jal	primpt_for_input_2 #get user input for the second integer
	beq	$s1, 99, end_program #if the user entered 99, exit the program
	addi	$t0, $zero, 10 
	sub	$t1, $s1, $t0 #subtract 10 from the user input for the second integer
	bltz	$t1, invalid_input_2_2 #if the result is less than 0, the user input was too small
	addi	$t0, $zero, 30
	sub	$t1, $s1, $t0 #subtract 30 from the user input for the second integer
	bgtz	$t1, invalid_input_2_1 #if the result is greater than 0, the input was too large
	### at this point, the user input for the first and the second integer is valid ###
	### it is now time to do the arithmetic 
	j	compute_result


prompt_for_input_1:
	li	$v0, 4 #to print a string, we need to use 4 as the system call code
	la	$a0, input_message_1 #load the address of the first input message 
	syscall #print the input message
	la	$a0, exit_message #load the address of the possible exit message
	syscall #print the message
	li	$v0, 5 #to get an integer as user input
	syscall #prompt for user input
	move	$s0, $v0 #move the input from the $v0 register into the $s0 register
	jr	$ra #jump back to the calling function

invalid_input_1_1: #errors for an integer greater than the input boundaries 
	li	$v0, 4 #to print a string, we need to use 4 as the system call code
	la	$a0, input_error_message_1 #load the address of the correct message
	syscall #print the message
	j	user_input_1 #jump back to the first input prompt

invalid_input_1_2: #errors for an integer less than the input boundaries 
	li	$v0, 4 #to print a string, we need to use 4 as the system call code
	la	$a0, input_error_message_2 #load the address of the correct message
	syscall	#print the message
	j	user_input_1 #jump back to the first input prompt


prompt_for_input_2:
	li	$v0, 4 #to print a string, we need to use 4 as the system call code
	la	$a0, input_message_2 #load the address of the second input message
	syscall #print the message
	la	$a0, exit_message #load the address of the possible exit message
	syscall #print the message
	li	$v0, 5 #to get an integer as user input
	syscall #prompt for user input
	move	$s1, $v0 #move the input from the $v0 register into the #s1 register
	jr	$ra #jump back to the calling function 	

invalid_input_2_1: #errors for an integer greater than the input boundaries
	li	$v0, 4 #to print a string, we need to use 4 as the system call code
	la	$a0, input_error_message_1 #load the address of the correct message
	syscall #print the message
	j	user_input_2 #jump back to the second input prompt
	
invalid_input_2_2: #errors for an integer less than the input boundaries
	li	$v0, 4 #to print a string, we need to use 4 as the system call code
	la	$a0, input_error_message_2 #load the address of the correct message
	syscall	#print the message
	j	user_input_2 #jump back to the second input prompt

compute_result:
	### first, compute the result of multiplying the first input by 4 ###
	move	$t1, $s0 #move the original value of the first input into t1 for later use when printing 
	sll	$s0, $s0, 2 #need to shift left 2 times to multiply by 2^2 or 4
	### now, $s0 retains the value of the first input multiplied by 4 ###
	### now, compute the result of the second input minus 3 ###
	move	$t2, $s1 #move the original value of the second input into t2 for later use when printing
	addi	$t0, $zero, 3
	sub	$s1, $s1, $t0 #subtract 3 from the second input
	### now, $s1 retains the value of the second input minus 3 ###
	### finally, it is time to add the modified inputs ###
	add	$s2, $s0, $s1 #add the modified first input to the modified second input and store it into $s2
	### finally, the register $s2 holds the result of our program ###
	### now we need to print it along with a message ###
	li	$v0, 4 #to print a string, we need to use 4 as the system call code
	la	$a0, completing_message_1 #load the address of the first completing message
	syscall #print the first completing message
	li	$v0, 1 #to print an integer
	move 	$a0, $t1 #move the first input into $a0
	syscall #print it 
	li	$v0, 4 #to print a string
	la	$a0, completing_message_2 #print the second part of the result 
	syscall #print rhe string 
	li	$v0, 1 #need 1 to print an integer 
	move	$a0, $t2 #move the second input into $a0
	syscall #print it 
	li	$v0, 4 #to print a string
	la	$a0, completing_message_3 #print the third part of the completing message
	syscall #print it 
	li	$v0, 1 #to print an integer
	move	$a0, $s2 #move the result of the program into $a0
	syscall #print the result of the program
	li	$v0, 4 #to print a string
	la	$a0, completing_message_4 #load the address of the newline
	syscall #print the new line to complete the program
	j	user_input_1 #jump back and restart the program
	
end_program:
