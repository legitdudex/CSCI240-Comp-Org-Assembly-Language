

#This is the second MIPS programming homework
#Name: Kang-hee Cho
#Course: CS240 TuFr 9:15am - 10:30am
#Professor: Dr.Simina Fluture
#The program works!!!



.data
message_prompt1:                .asciiz         "Please enter the value for n where n >= 0\n"
message_prompt2:                .asciiz         "Enter -99 to exit.\n"
message_prompt3:                .asciiz         "n = "
invalid_input:                  .asciiz         "Invalid input.\n"
newline:                        .asciiz         "\n"
output_message1:               .asciiz         "f("
output_message2:               .asciiz         ") = "
output_message3:               .asciiz         "+ 3("
output_message4:               .asciiz         ") "
output_message5:               .asciiz         "4 * "


.text


.globl main

main:
	li	$v0, 4 #load 4 into a0 to print a string
	la	$a0, message_prompt1 #to print the first input prompt
	syscall	#print the message
	la	$a0, message_prompt2 #to print the second input prompt
	syscall #print the second message
	la	$a0, message_prompt3 #to print the third input prompt
	syscall	#print the third message
	li	$v0, 5 #to get an integer as user input
	syscall #call for input
	move	$s0, $v0 #move the user input into the register s0
	li	$v0, 4 #to print a string 
	la	$a0, newline #to print a new line to clean things up
	syscall #print a new line
	j	handle_input

handle_input:
	bgez	$s0, is_valid_input_and_compute_result #if the input is greater than or equal to 0, the input was valid and we can move on
	j	is_not_valid_input #if the input was not valid, we cannot move on

is_not_valid_input:
	addi	$s0, $s0, 99 #to check if the user wanted to exit the program
	beq	$s0, $zero, end_program #if the user entered -99, exit the program
	li	$v0, 4 #to print a string
	la	$a0, invalid_input #load the address of the invalid input message into a0
	syscall #print the message
	j	main #start the process over again and prompt for input once more
	
is_valid_input_and_compute_result:
	### If we got this far, the input was indeed valid. ###
	jal 	recursive_case #now we have to compute the result of the program
	
	### Now at this point, the final result string should have been printed ###
	li	$v0, 4 #to print a string
	la	$a0, newline #to print a new line for neatness 
	syscall	#print the new line
	addi	$sp, $sp, 12 #deallocate the stack memory
	j	end_program #end the program

base_case:
	li	$v0, 4 #to print a string
	la	$a0, output_message1 #to print f(
	syscall #print
	li	$v0, 1 #to print an integer
	move	$a0, $zero #to print a 0
	syscall #print the 0
	li	$v0, 4 #to print a string
	la	$a0, output_message2 #to print ) = 
	syscall #print it 
	li	$v0, 1 #to print an integer 
	li	$a0, 8 #print 8 as a result of f(0)
	syscall #print 
	li	$v0, 4 #to print a string
	la	$a0, newline #to print a newline
	syscall	#print the new line
	
	### At this point, the program should have printed f(0) = 8\n ###
	### Now we get into the syntax and the actual calculations ###
	
	addi	$v0, $zero, 8 #make the return value 8 for the base case
	sw	$v0, 4($sp) #store the result into the stack
	j       base_done #jump back to caller	
###
#This is where the program gets confusing so hold on to your horses
#I wasn't able to find a way to jump and link after finding out n is zero,
#	so I decided to just jump to the base case and jump back to the end of the recursive call.
#	Now, the stack should still be at f(1) with n = 1 and the return address leading back to f(2)
#	However, since I was not able to jump and link after the base case, I was forced to store it's result into f(1)'s result stack
#So, from reading this, you should understand that I always stored the previous function call's results into the current stack's result frame
#So from this logic, we can store the results of f(1) into f(2)'s stack space and f(2)'s results into f(3)'s stack space
#This took me some time to figure out but I managed to make it work if I keep the result inside a temporary register, only saving the 
#	result until I have deallocated the previous function call's stack space. 
#Please e-mail me for more information if this is confusing.
recursive_case:
	beq	$s0, $zero, base_case #jump to the base case if n == 0
	sub	$sp, $sp, 12 #make space on the stack for new values
	sw	$ra, 8($sp) #save the return address
	sw	$s0, 0($sp) #save n
	addi	$t1, $zero, 1 #to subtract 1 from n
	sub	$s0, $s0, $t1 #subtract 1 from s0
	jal	recursive_case #call the function on n - 1
base_done:	
	### At this point, the recursions are going back up the stack
	lw	$v0, 4($sp) #load the result from the stack
	sll	$v0, $v0, 2 #multiply the result by 4
	lw	$s0, 0($sp) #load n from the stack
	sll	$t2, $s0, 2 #for n * 2^2
	sub	$t0, $t2, $s0 #result of multiplying n by 3 since n * 2^2 - n = 3n
	add	$v0, $v0, $t0 #to get the final result 
	move	$t4, $v0 #move into a temp register to store on stack later
	### Now starts the printing part of this segment ###
	li	$v0, 4 #to print a string
	la	$a0, output_message1 #to print the first part of the output message "f("
	syscall #print
	li	$v0, 1 #to print an integer
	lw	$a0, 0($sp) #get n from the stack
	syscall #print n. Now the message is "f(n"
	li	$v0, 4 #to print a string
	la	$a0, output_message2 #to print the second part of the output message
	syscall	#print the output message. Now the message is "f(n) = "
	la	$a0, output_message5 #print the next part of the output message
	syscall #print. Now the message is "f(n) = 4 * "
	la	$a0, output_message1 #to print the next part 
	syscall	#print. Now the message is "f(n) = 4 * f("
	addi	$t5, $zero, 1 #add 1 to t5
	lw	$s0, 0($sp) #load n back into $s0
	sub	$t5, $s0, $t5 #t5 now holds n - 1
	li	$v0, 1 #to print an integer
	move	$a0, $t5 #to print n - 1
	syscall #print. Now the message is "f(n) = 4 * f(n - 1"
	li	$v0, 4 #to print a string
	la	$a0, output_message4 #to print the next part of the output message
	syscall #print. Now the message is "f(n) = 4 * f(n - 1)"
	la	$a0, output_message3 #to print the next part of the output message
	syscall #print. Now the message is "f(n) = 4 * f(n - 1) + 3("
	li	$v0, 1 #to print an integer
	lw	$a0, 0($sp) #load n into a0
	syscall #print. Now the message is "f(n) = 4 * f(n - 1) + 3(n"
	li	$v0, 4 #to print a string
	la	$a0, output_message2 #to print tne next part of the output message
	syscall #print. Now the message is "f(n) = 4 * f(n - 1) + 3(n) = "
	li	$v0, 1 #to print an integer
	move	$a0, $t4 #to print the result
	syscall #print the result of f(n). Now the final result of the message is "f(n) = 4 * f(n - 1) + 3(n) = result"
	li	$v0, 4 #to print a string
	la	$a0, newline #to print a newline. Now our output is cleaned up by the newline to make room for another output
	syscall	#print

	### Now ends the printing part of this segment ###
	lw	$ra, 8($sp) #get the return address from the stack
	addi	$sp, $sp, 12
	sw	$t4, 4($sp) #store the saved previous result into the stack
	jr	$ra #jump back to the caller


end_program:
