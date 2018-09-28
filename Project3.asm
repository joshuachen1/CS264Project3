# Who:  Joshua Chen
# What: Project3.asm
# Why:  To learn how to create procedures that utilize the stack pointer.
# When: Created: 5/15/18	Due: 5/16/18
# How:  List the uses of registers
#	$t0 is used to keep tracker of the number of integers to be pushed onto the stack.
#	$t1 is used as a temporary variable to allow for easy swapping within the stack.
#	$s0 is used to keep track of the address of the bottom of the stack.
#	$s5 is used to hold the address above $sp; also used to traverse addresses if a swap occurs within the stack.
#	$s6 is used to hold the value at $s5.
#	$s7 is used to hold the address below $s5.
#	$a1 holds the address of the bottom of the stack.
#	$a2 holds the value of the incoming integer.

.data
	numberOfInts:	.asciiz		"Number of Integers to Store: "
	promptInt:	.asciiz		"Enter Integer: "
	printSort:	.asciiz		"Your Sorted Integers: "
	invalidSize:	.asciiz		"\nYour Must Be Greater Than Zero.\n\n"
	addspace:	.asciiz		" "
	newLine:	.asciiz		"\n"
	
.text
.globl main


main:					# program entry

	li	$t0, 0			# $a1 is the counter i = 0

initializeNumInts:
	li	$v0, 4
	la	$a0, numberOfInts
	syscall				# "Number of Integers to Store: "
	li	$v0, 5
	syscall
	
	ble	$v0, $0, reinitialize
	
	move	$s0, $v0
	addi	$sp, $sp, -4		# Allocate space for the array size
	sw	$s0, 0($sp)		# Store arraysize at the bottom of the stack
	la	$a1, 0($sp)		# Remember the address of the bottom of the stack

insertToStack:
	bge	$t0, $s0, prePrintStack
	
	li	$v0, 4			
	la	$a0, promptInt
	syscall				# "Enter Integer: "
	li	$v0, 5
	syscall

	jal	preSortStack
	
	addi	$t0, $t0, 1		# counter++
	
	j	insertToStack
	
	
prePrintStack:
	li	$v0, 4
	la	$a0, printSort		
	syscall				# "Your Sorted Integers: "

printStack:
	beq	$a1, $sp, terminate	# If the stack pointer is at the end of the stack, terminate
	
	li	$v0, 1
	lw	$a0, 0($sp)		# Get value at top of stack
	syscall
	li	$v0, 4
	la	$a0, addspace
	syscall
	
	addi	$sp, $sp, 4		# Pop top of stack
	
	j	printStack
	
terminate:

	li $v0, 10			# terminate the program
	syscall

reinitialize:
	li	$v0, 4
	la	$a0, invalidSize
	syscall
	j	initializeNumInts

preSortStack:
	move	$a2, $v0		# Place integer into argument
	addi	$sp, $sp, -4		# Allocate space for incoming integer
	la	$s5, 0($sp)		# Keeps track of addresses in the stack
	sw	$a2, 0($sp)		# Push incoming integer onto the stack to account for first input

sortStack:
	addi	$s5, $s5, 4		# Go to the the address above $s5
	addi	$s7, $s5, -4		# $s7 keeps track of the address before $s5
	beq	$a1, $s5, exitSort	# If the address above the tracker is the bottom of the stack, exit the sort
	
	lw	$s6, 0($s5)		# Get the value at the tracker
	bgt	$a2, $s6, swap		# if (incoming integer > value at below it in the stack), then swap values
	
	sw	$a2, 0($sp)		# If the value above >= the incoming integer, push incoming integer onto stack
	
exitSort:
	jr	$ra			
	
swap:	
	
	move	$t1, $s6		# $t1 holds the value at tracker
	sw	$a2, 0($s5)		# Store the incoming integer at the tracker
	sw	$t1, 0($s7)		# Store $t1 at top of stack
	
	j	sortStack		# Go back to sorting the stack in case there are smaller values above

