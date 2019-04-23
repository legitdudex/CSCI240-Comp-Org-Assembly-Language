

#This is the second MIPS programming homework
#Name: Kang-hee Cho
#Course: CS240 TuFr 9:15am - 10:30am
#Professor: Dr.Simina Fluture



.data


.text
message_prompt1:		.asciiz		"Please enter the value for n where n >= 0\n"
message_prompt2:		.asciiz		"n = "
newline:			.asciiz		"\n"


.globl main

main:
	li	$v0, 4 #load 4 into a0 to print a string
	la	$a0, message_prompt1 #to print the first input prompt
	syscall	#print the message
	la	$a0, message_prompt2 #to print the second input prompt
	syscall #print the second message
	li	$v0, 5 #to get an integer as user input
	move	$s0, $v0 #move the user input into the register s0
	li	$v0, 4 #to print a string 
	la	$a0, newline #to print a new line to clean things up
	syscall #print a new line
	j	handle_input

handle_input:
	
