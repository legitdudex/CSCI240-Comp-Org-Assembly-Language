

#Part B of the first MIPS programming homework
#Name:Kang-hee Cho
#Course: CS240 TuFr 9:15am - 10:30am
#Professor: Dr.Simina Fluture




.data
constArray:		.space		40

.text
prompt_message:		.asciiz		"Please enter a constant value: \n"



.globl main

main:
	li	$v0, 4 #to print a string
	la	$a0, prompt_message #load the address of the message
	syscall #print the message prompt	
	li	$v0, 5 #to get an integer as input
	syscall #get the user input
	move	$s0, $v0 #move the input into $s0
	add	$s1, $zero, $zero #set s0 to zero. We will be using it as an increment
	add	$s3, $zero, $zero #for the array increment 
	j	theForLoop

theForLoop:
	slti	$t0, $s1, 10 #if $s0 < 10, $t0 will be set to 1, 0 otherwise
	beq	$t0, $zero, print_loop_1 #if $s0 is greater than or equal to 10, end the program
	add	$s2, $s0, $s1 #J + constant is stored into register $s2
	sw	$s2, constArray($s3) #store the result in the array
	addi	$s3, $s3, 4 #increment so we can store the next element in the array
	addi	$s1, $s1, 1 #increment the for loop counter
	j	theForLoop #jump back to the loop


print_loop_1:
	### now we need to retrive our results back from the array and then print them ###
	addi	$s3, $zero, 0 #set the array index back to 0
	addi	$s1, $zero, 0 #set the for loop counter back to 0
	j	print_loop_2

print_loop_2:
	slti	$t0, $s1, 10 #if $s0 < 10, $t0 will be set to 1, 0 otherwise
	beq	$t0, $zero, end_program #end the program when we are done printing
	lw	$a0, constArray($s3) #load the array value into the argument register
	li	$v0, 1 #to print an integer
	syscall	#print the array value
	addi	$s3, $s3, 4 #increment the array address
	addi	$s1, $s1, 1 #increment the for loop counter
	j	print_loop_2

end_program:

