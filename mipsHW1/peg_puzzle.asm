
#This is the code for peg_puzzle.asm. 
#The program runs a makeshift peg solitaire game.
#Name: Kang-hee Cho
#Course: CSCI250 Section 3
#Professor: Phil White
#Project 1


	.data #data section
welcome_message1:	.asciiz		"************************\n"
welcome_message2:	.asciiz		"**     Peg Puzzle     **\n"
welcome_message3:	.asciiz		"************************\n"

board_columns:		.asciiz		"\n    0  1  2  3  4  5  6"
board_dashes:		.asciiz		"\n        +---------+\n"
board_row0:		.asciiz		"0       |"
board_row01:		.asciiz		"|      \n"
board_row1:		.asciiz		"1 +-----+"
board_row11:		.asciiz		"+-----+\n"
board_row2: 		.asciiz		"2| "
board_row21:		.asciiz		"|\n"
board_row3:		.asciiz		"3| "
board_row31:		.asciiz		"|\n"
board_row4:		.asciiz		"4| "
board_row41:		.asciiz		"|\n"
board_row5:		.asciiz		"5 +-----+"
board_row51:		.asciiz		"+-----+\n"
board_row6:		.asciiz		"6       |"
board_row61:		.asciiz		"|      \n"
space:			.asciiz		"   "
valid:			.asciiz		" X "
invalid:		.asciiz		" I "


peg_to_move_message:	.asciiz		"Enter the location of the peg to move (RC, -1 to quit): "
moving_peg_message:     .asciiz		"Enter the location where the peg is moving to (RC, -1 to quit): "

illegal_location:	.asciiz		"Illegal location.\n" 
illegal_source:		.asciiz		"Illegal move, no peg at source location.\n" 
illegal_destination:	.asciiz		"Illegal move, destination location is occupied.\n"
illegal_long_distance:	.asciiz		"Illegal move, can only jump over one peg, re-enter move.\n"
illegal_short_distance: .asciiz		"Illegal move, no peg being jumped over, re-enter move.\n"

quit_message: 		.asciiz		"Player quit.\n"
no_more_moves:		.asciiz		"There are no more legal moves.\n"

you_left:		.asciiz		"You left "
pegs_on_the_board:	.asciiz		" pegs on the board.\n"
number_pegs:		.word		32
array:			.space		196	
	
	.text #assembly instructions
	.globl main
main:
	jal	print_welcome_message
	jal	set_up_board
	j	main_loop

main_loop:
	add	$s6, $zero, $zero #set s6 to zero for use later
	add	$s7, $zero, $zero #set s7 to zero for use later
	jal	print_board
	li	$v0, 4 #to print all the messages that appear on the window
	jal     are_valid_moves #check if there are any valid moves left
	beq	$s6, $s7, is_not_valid_move_left #if they are equal, this means that there aren't any valid moves left
	bne	$s6, $s7, is_valid_move_left #if they are not equal, then there is a valid move left. Now we can move on.

is_valid_move_left:
	add	$s6, $zero, $zero #set s6 back to zero to check validity again
	#get user input for peg location here
	li	$v0, 4	#to print a message
	la	$a0, peg_to_move_message #load the appropriate message
	syscall	#print the message
	jal	get_peg_location #get the calculated coordinates from the user input
	jal	check_valid_location #check if the location of the peg is valid
	beq	$s6, $s7, is_not_valid_location #jump back to get a new location if not valid
	bne	$s6, $s7, is_valid_location #location is valid, move on
	
is_valid_location:
	add 	$s6, $zero, $zero #need to set s6 back to 0 to check for validity again
	#get user input for peg destination here
	li	$v0, 4 #to print a message
	la	$a0, moving_peg_message #load the message
	syscall #print the message
	jal	get_peg_destination #get the calculated coordinates from the user input
	jal	check_valid_destination #check if the destination of the said peg is valid
	beq	$s6, $s7, is_not_valid_destination #jump back to get a new destination if it's not a valid destination
	bne	$s6, $s7, is_valid_distance #move on if the destination is valid
	
is_valid_distance:
	add	$s6, $zero, $zero #must set s6 back to 0 to check for validity again
	jal	check_valid_distance #check if the distance of the move and the move in general is a valid one.
	beq	$s6, $s7, is_not_valid_distance #go all the way back and ask user for a new location and destination for a new move. 
	bne	$s6, $s7, move_the_peg #move the peg if the distance is valid
	#branch here according to the validity of the move distance
	
move_the_peg:
	j	move_piece #everything is valid including the move, location of the peg, and the destination of the peg. Now it is time to move the peg from the location to the destination and update it in the stack
	#update the stack 
	j	main_loop #restart the loop
is_not_valid_move_left:
	li	$v0, 4 #to print a message
	la	$a0, no_more_moves #load the message for this case
	syscall	#print the message
	j	end_program #end the program if there are no more valid moves left

is_not_valid_location:
	li	$v0, 4 #to print a message
	la	$a0, illegal_location #load the address of the appropriate message
	syscall #print the message
	la	$a0, illegal_source #load the second message for this type of error
	syscall	#print the second part of this message
	j	is_valid_move_left #must get a new location from the user

is_not_valid_destination:
	li	$v0, 4 #to print a message
	la	$a0, illegal_location #load the appropriate message
	syscall	#print the first part of this error message
	la	$a0, illegal_destination #load the approriate message
	syscall #print rhe message
	j	is_valid_location #must get a new destination from the user

is_not_valid_distance:
	#need to know whether illegal short or illegal long distance
	j	is_valid_move_left #must get new location and distance from the user

end_program:
	li	$v0, 4	#for string printing
	la	$a0, quit_message #load the quit message
	syscall #print the quit message
	la	$a0, you_left #load the address of the first part of the message
	syscall #print the first part of the message
	li	$v0, 1 #to print the integer value of pegs left
	lw	$a0, number_pegs #load the number of pegs left
	syscall #print the number of pegs left
	li	$v0, 4 #change back to 4 to print the rest of the message
	la	$a0, pegs_on_the_board #load the last part of this message
	syscall #print the rest of this message
	j	end
#
#
#The function below prints the welcome message that is intended to be displayed once right after the game has started.
#
#
print_welcome_message:
	li	$v0, 4 #to print a string, we need to use 4 as the system call code
	la	$a0, welcome_message1 #load the address of the first part of the welcome message
	syscall #print first line of welcome message
	la	$a0, welcome_message2 #load the address of the second part of the welcome message
	syscall #print second line of welcome message
	la	$a0, welcome_message3 #load the address of the third and final part of the welcome message
	syscall #print third line of welcome message
	jr	$ra
	

#
#
#This function sets up the whole board using an array declared in the data section.
#For every space on the board, the pegs are labeled as 1's in the array, spaces are labeled as 2's,
#and invalid spaces are labeled with 0's.
#The array progresses like (0,0), (0,1), (0,2)....(6,6) on the game board respectively.  
#
#	
set_up_board:
	add	$t0, $zero, $zero #set up t0 for use to keep track of row number
	add	$t1, $zero, $zero #set up t1 for use to keep track of how many added
	addi	$t2, $zero, 49 #end at count 49
	add	$t3, $zero, $zero #keep track of index
	add	$s7, $zero, $zero #to store all the information (pegs, invalid, space)
	j	setup_loop
setup_loop:
	beq	$t1, $t2, end_setup_loop #end the loop if everything was added
	addi	$t7, $zero, 0
	beq	$t0, $t7, add_with_invalid
	addi    $t7, $zero, 1
	beq	$t0, $t7, add_with_invalid
	addi    $t7, $zero, 2
	beq	$t0, $t7, add_without_invalid
	addi    $t7, $zero, 3
	beq	$t0, $t7, add_with_space
	addi    $t7, $zero, 4
	beq	$t0, $t7, add_without_invalid
	addi    $t7, $zero, 5
	beq	$t0, $t7, add_with_invalid
	addi    $t7, $zero, 6
	beq	$t0, $t7, add_with_invalid
add_with_invalid:
	add	$s7, $zero, $zero
	sw	$s7, array($t3)
	addi	$t3, $t3, 4 
	sw	$s7, array($t3)
	addi	$s7, $zero, 1
	addi 	$t3, $t3, 4
	sw	$s7, array($t3)
	addi	$t3, $t3, 4
	sw	$s7, array($t3)
	addi	$t3, $t3, 4
	sw	$s7, array($t3)
	addi	$t3, $t3, 4
	add	$s7, $zero, $zero
	sw	$s7, array($t3)
	addi	$t3, $t3, 4
	sw	$s7, array($t3)
	addi	$t0, $t0, 1 #increment number of rows
	addi	$t1, $t1, 7 #increment number of elements
	addi	$t3, $t3, 4 
	j	setup_loop
add_with_space:
	addi	$s7, $zero, 1 #peg value added to all 7 spaces in the array
	sw	$s7, array($t3) 
	addi	$t3, $t3, 4 
	sw	$s7, array($t3)
	addi	$t3, $t3, 4
	sw	$s7, array($t3)
	addi	$t3, $t3, 4
	addi	$s7, $zero, 2 #add the space value of 2
	sw	$s7, array($t3)
	addi	$t3, $t3, 4
	addi	$s7, $zero, 1
	sw	$s7, array($t3)
	addi	$t3, $t3, 4
	sw	$s7, array($t3)
	addi	$t3, $t3, 4
	sw	$s7, array($t3)
	addi	$t0, $t0, 1 #increment number of rows
	addi	$t1, $t1, 7 #increment number of elements in array
	addi	$t3, $t3, 4
	j	setup_loop
add_without_invalid:
	addi	$s7, $zero, 1 #peg value added to all 7 spaces in the array
	sw	$s7, array($t3) 
	addi	$t3, $t3, 4 
	sw	$s7, array($t3)
	addi	$t3, $t3, 4
	sw	$s7, array($t3)
	addi	$t3, $t3, 4
	sw	$s7, array($t3)
	addi	$t3, $t3, 4
	sw	$s7, array($t3)
	addi	$t3, $t3, 4
	sw	$s7, array($t3)
	addi	$t3, $t3, 4
	sw	$s7, array($t3)
	addi	$t0, $t0, 1 #increment number of rows
	addi	$t1, $t1, 7 #incrememnt number of elements in array
	addi	$t3, $t3, 4 
	j	setup_loop
end_setup_loop:
	jr	$ra
	


#
#
#This function velow gets the number input from the user and calculates the row and column of the selected peg. The funtion then stores the row and the column of the selected peg in the s0 and s1 registers, respectfully.
#
#
get_peg_location:
	add 	$s2, $zero, $zero #initialize s2 to zero
	add	$s3, $zero, $zero #initialize s3 to zero
	add	$t0, $zero, $zero #initialize t0 to zero
	add	$t1, $zero, $zero #initialize t1 to zero
	add	$t2, $zero, $zero #initialize t2 to zero
	addi 	$t0, $t0, 10	  #add 10 to t0 for use in division later
	div	$s0, $t0	  #divide the user input by 10
	mfhi	$t1		  #remainder stored in t1
	mflo	$t2		  #quotient stored in t2
	add	$s2, $s2, $t2	  #s2 now contains the row of the peg location
	add	$s3, $s3, $t1	  #s3 now contains the column of the peg location
	jr	$ra		  #jump back to the main program


#
#
#This function below gets the number input from the user and calculates the row and column of the new location for the selected peg and stores the row and the column in the s2 and s3 registers, respectfully.
#
#
get_peg_destination:
	add	$s4, $zero, $zero #initialize s4 to zero
	add	$s5, $zero, $zero #initialize s5 to zero
	add 	$t0, $zero, $zero #initialize t0 to zero
	add	$t1, $zero, $zero #initialize t1 to zero
	add	$t2, $zero, $zero #initialize t2 to zero
	addi	$t0, $t0, 10	  #add 10 to t0 for use in division later
	div	$s1, $t0	  #divide the user input by 10
	mfhi 	$t1		  #remainder stored in t1
	mflo	$t2		  #quotient stored in t2
	add	$s4, $s4, $t2	  #s4 now contains the row of the location the peg is to be moved
	add	$s5, $s5, $t1     #s5 now contains the col of the location the peg is to be moved
	jr	$ra		  #jump back to the main program

#
#
#This function below checks if the peg exists at the location intended and if it can be moved. If the location of the said peg is indeed valid, then the function sets s6 to 1. Otherwise, the function does nothing and leaves s6 as zero.
#
#
check_valid_location:
	add	$t7, $zero, $s2
	addi	$t0, $zero, 7
	mult	$t7, $t0
	mflo	$t7
	add	$t7, $t7, $s3
	#t7 now contains the index value of the element in the array
	addi	$t0, $zero, 4
	mult	$t7, $t0 #to get the byte location in the array
	mflo	$t7
	lw	$t6, array($t7)
	addi	$t1, $zero, 1
	beq	$t6, $t1, this_is_a_valid_location
	bne	$t6, $t1, this_is_not_a_valid_location
this_is_a_valid_location:
	addi	$s6, $zero, 1 #one means valid
	jr	$ra
	
this_is_not_a_valid_location:
	addi	$s6, $zero, 0 #zero means not valid
	jr	$ra


#
#
#This function below checks if the peg in question can move to the destination intended by the user according to the game's rules. If the destination of the said peg is indeed valid, then the function sets s6 to 1. Otherwise, the function does nothing and leaves s6 as zero.
#
#
check_valid_destination:
	add	$t7, $zero, $s4
	addi	$t0, $zero, 7
	mult	$t7, $t0
	mflo	$t7
	add	$t7, $t7, $s5
	#t7 now contains the index value of the element in the array
	addi	$t0, $zero, 4
	mult	$t7, $t0 #to get the byte location in the array
	mflo	$t7
	lw	$t6, array($t7)
	addi	$t1, $zero, 1
	beq	$t6, $t1, this_is_a_valid_destination
	bne	$t6, $t1, this_is_not_a_valid_destination
this_is_a_valid_destination:
	addi	$s6, $zero, 1 #one means valid
	jr	$ra
	
this_is_not_a_valid_destination:
	addi	$s6, $zero, 0 #zero means not valid
	jr	$ra


#
#
#This function below checks if the distance the peg will be moving is valid, according to the game's rules. This function also checks if the move adheres to all the game's rules in general. The function will set s6 to 1 if the move and it's distance are both valid and legal. Otherwise, this function does nothing and leaves s6 as zero.
#
#
check_valid_distance:
	addi	$t6, $zero, 1 #base case: row difference and col difference must be only 1 but both can't be one
	add	$t7, $zero, $zero #to calculate difference
	add	$t5, $zero, $zero #to calculate difference
	add	$t4, $zero, $zero #to calculate if they are both the same (can't move diagonally)
	
	sub	$t7, $s5, $s3
	sub	$t5, $s4, $s2
	blez	$t7, less_than_zero_one
checkpoint_valid_one:
	blez	$t5, less_than_zero_two
checkpoint_valid_two:
	beq	$t5, $t7, this_is_not_a_valid_distance
	bne	$t5, $t7, this_is_a_valid_distance
less_than_zero_one:
	sub	$t7, $zero, $t7
	j	checkpoint_valid_one
less_than_zero_two:
	sub	$t5, $zero, $t5
	j	checkpoint_valid_two
this_is_a_valid_distance:
	addi	$s6, $zero, 1
	jr	$ra
this_is_not_a_valid_distance:
	addi	$s6, $zero, 0
	jr	$ra


#
#
#This function below checks if there are any valid moves left in the game.
#This function also sets s6 to 1 if there are indeed more valid moves that haven't been made in the game and leaves it as 0 otherwise.
#
#
are_valid_moves:
	add	$t0, $zero, $zero
	lw	$t0, number_pegs
	addi	$t1, $zero, 1
	beq	$t0, $t1, no_valid_moves_left_now
	bne	$t0, $t1, valid_moves_still_remain
valid_moves_still_remain:
	addi	$s6, $zero, 1 #more valid moves left, s6 will be 1
	jr	$ra
no_valid_moves_left_now:
	add	$s6, $zero, $zero #no more valid moves left, s6 will be 0
	jr	$ra


#
#
#Pre-requisites:
#	1. There are valid moves that have not been made yet. (The game is not over)
#	2. The location of the peg is valid.
#	3. The destination of the peg is valid.
#	4. The move distance and the move itself are both valid and legal
#
#This function moves the peg on the board and updates the stack to reflect that of the move. This function should also change the board in accordance to the rules of the game.
#	
#
#
move_piece:
	add	$t7, $zero, $s2
	addi	$t4, $zero, 7
	mult	$t7, $t4
	mflo	$t7
	add	$t7, $t7, $s3
	#t7 now contains the index value of the location element in the array
	addi	$t4, $zero, 4
	mult	$t7, $t4 #to get the byte location in the array
	mflo	$t7
	lw	$t0, array($t7)
	
	add	$t2, $zero, $s4
	addi	$t4, $zero, 7
	mult	$t2, $t4
	mflo	$t2
	add	$t2, $t2, $s5
	#t2 now contains the index value of the destination element in the array
	addi	$t4, $zero, 4
	mult	$t2, $t4 #to get the byte location in the array
	mflo	$t2
	lw	$t1, array($t2)
	jr	$ra	
	sw	$t0, array($t7)
	sw	$t1, array($t2)
	lw	$t0, number_pegs
	sub	$t0, $t0, 1
	sw	$t0, number_pegs
	jr	$ra

#
#
#The functon below prints out the game board in its entirety. I used the stack to store all the elements of the board. The stack represents a 1-d array where I can simply store the contents of a 2-d array in. 
#
#
print_board:
	add	$t5, $zero, $zero #keep track of rows
	add	$t6, $zero, $zero #to keep track of index
	add	$t7, $zero, $zero #to keep track of value
	li	$v0, 4 #to print a the column numbers (already declared)
	la	$a0, board_columns #load the message
	syscall	#print the message
	la	$a0, board_dashes #load the dashes
	syscall
	la	$a0, board_row0
	syscall
	addi	$t0, $zero, 3
checkpoint_one:
	beq	$t0, $zero, checkpoint_one_one
	add	$t7, $zero, $zero #reset the value to read again
	lw	$t7, array($t6) #read in the value
	beq	$t7, $zero, if_invalid
	beq	$t7, 1, if_valid
	beq	$t7, 2, if_space
checkpoint_one_one:
	addi	$t5, $t5, 1
	la	$a0, board_row01
	syscall
	la	$a0, board_row1
	syscall
	addi	$t0, $zero, 3
checkpoint_two:
	beq	$t0, $zero, checkpoint_two_one
	add	$t7, $zero, $zero #reset the value to read again
	lw	$t7, array($t6) #read in the value
	beq	$t7, $zero, if_invalid
	beq	$t7, 1, if_valid
	beq	$t7, 2, if_space
checkpoint_two_one:
	addi	$t5, $t5, 1
	la	$a0, board_row11
	syscall
	la	$a0, board_row2
	syscall
	addi	$t0, $zero, 7
checkpoint_three:
	beq	$t0, $zero, checkpoint_three_one
	add	$t7, $zero, $zero #reset the value to read again
	lw	$t7, array($t6) #read in the value
	beq	$t7, $zero, if_invalid
	beq	$t7, 1, if_valid
	beq	$t7, 2, if_space
checkpoint_three_one:
	addi	$t5, $t5, 1
	la	$a0, board_row21
	syscall
	la	$a0, board_row3
	syscall
	addi	$t0, $zero, 7
checkpoint_four:
	beq	$t0, $zero, checkpoint_four_one
	add	$t7, $zero, $zero #reset the value to read again
	lw	$t7, array($t6) #read in the value
	beq	$t7, $zero, if_invalid
	beq	$t7, 1, if_valid
	beq	$t7, 2, if_space
checkpoint_four_one:
	addi	$t5, $t5, 1
	la	$a0, board_row31
	syscall
	la	$a0, board_row4
	syscall
	addi	$t0, $zero, 7
checkpoint_five:
	beq	$t0, $zero, checkpoint_five_one
	add	$t7, $zero, $zero #reset the value to read again
	lw	$t7, array($t6) #read in the value
	beq	$t7, $zero, if_invalid
	beq	$t7, 1, if_valid
	beq	$t7, 2, if_space
checkpoint_five_one:
	addi	$t5, $t5, 1
	la	$a0, board_row41
	syscall
	la	$a0, board_row5
	syscall
	addi	$t0, $zero, 3
checkpoint_six:
	beq	$t0, $zero, checkpoint_six_one
	add	$t7, $zero, $zero #reset the value to read again
	lw	$t7, array($t6) #read in the value
	beq	$t7, $zero, if_invalid
	beq	$t7, 1, if_valid
	beq	$t7, 2, if_space
checkpoint_six_one:
	addi	$t5, $t5, 1
	la	$a0, board_row51
	syscall
	la	$a0, board_row6
	syscall
	addi	$t0, $zero, 3
checkpoint_seven:
	beq	$t0, $zero, checkpoint_seven_one
	add	$t7, $zero, $zero #reset the value to read again
	lw	$t7, array($t6) #read in the value
	beq	$t7, $zero, if_invalid
	beq	$t7, 1, if_valid
	beq	$t7, 2, if_space
checkpoint_seven_one:
	la	$a0, board_row61
	syscall
	la	$a0, board_dashes
	syscall
	jr	$ra
	
if_valid:
	li	$v0, 4
	la	$a0, valid
	syscall
	addi	$t6, $t6, 4 #increment by 4 bytes
	subi	$t0, $t0, 1
	beq	$t5, $zero, checkpoint_one
	beq	$t5, 1, checkpoint_two
	beq	$t5, 2, checkpoint_three
	beq	$t5, 3, checkpoint_four
	beq	$t5, 4, checkpoint_five
	beq	$t5, 5, checkpoint_six
	beq	$t5, 6, checkpoint_seven
	
if_invalid:
	li	$v0, 4
	la	$a0, invalid
	syscall
	addi	$t6, $t6, 4 #increment by 4 bytes
	subi	$t0, $t0, 1
	beq	$t5, $zero, checkpoint_one
	beq	$t5, 1, checkpoint_two
	beq	$t5, 2, checkpoint_three
	beq	$t5, 3, checkpoint_four
	beq	$t5, 4, checkpoint_five
	beq	$t5, 5, checkpoint_six
	beq	$t5, 6, checkpoint_seven
if_space:
	li	$v0, 4
	la	$a0, space
	syscall
	addi	$t6, $t6, 4 #increment by 4 bytes
	subi	$t0, $t0, 1
	beq	$t5, $zero, checkpoint_one
	beq	$t5, 1, checkpoint_two
	beq	$t5, 2, checkpoint_three
	beq	$t5, 3, checkpoint_four
	beq	$t5, 4, checkpoint_five
	beq	$t5, 5, checkpoint_six
	beq	$t5, 6, checkpoint_seven
end:
