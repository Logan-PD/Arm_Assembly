/*------------------------------------
 Logan Perry-Din
 UCID: 30070661
 cpsc 355 spring 2019
 Assignment 1A (no macros)

 Finds max of y= -5x^3 - 31x^2 + 4x + 31
 in the interval -6 <= x <= 5
-------------------------------------*/


fmt:
	.string "For x = %d, y = %d.\nCurrent maximum is y = %d\n"	// String format for output message
	.balign 4							// Aligns instructions


	.global main							// Makes main visible to OS
main:
	stp	x29,	x30,	[sp, -16]!				// Save fp and lr to stack, allocating 16 bytes
	mov	x29,	sp						// Update fp to current sp
	

setup:
	mov	x19,	-6						// Register for X value, starting at lowest domain and acting as loop counter
	mov	x20,	-999						// Register for computed max Y value, starting at -999


test:
	cmp	x19,	5						// Compare x19(X) value with max domain
	b.gt	done							// If x>5, branch to done
	
calc:
	//compute y value
	// First term: -5x^3
	mul	x21,	x19,	x19					// x * x = x^2
	mul	x21,	x19,	x21					// x^2 * x = x^3
	mov	x22,	-5						// put -5 into register x22
	mul	x21,	x21,	x22					// x^3 * -5
	
	// Second term: -31x^2
	mul	x22,	x19,	x19					// x*x=x^2
	mov	x23,	-31						// put -31 into register x23
	mul	x22,	x22,	x23					// x^2 * -31
	
	// Third term: 4x
	mov	x23,	4						// put 4 into register x23
	mul	x23,	x23,	x19					// 4*x
	
	// Add three terms and constant
	add	x24,	x21,	x22					// -5x^3 -31x^2
	add	x24,	x24,	x23					// -5x^3 -31x^2 +4x
	add	x24,	x24,	31					// -5x^3 -31x^2 +4x +31
	

updateYMAx:
	cmp	x24,	x20						// if computed y value is greater than last y
	b.le	display							// if not, branch to display
	mov	x20,	x24						// if it is, update to new max value


display:
	adrp	x0,	fmt						// Set 1st argument of printf
	add	x0,	x0,	:lo12:fmt				// Set lower 12 bits
	mov	x1,	x19						// Place value of x into x1 register for printf
	mov	x2,	x24						// Place value of computed y into x2 register for printf
	mov	x3,	x20						// Place value of max y into x3 register for printf
	bl	printf							// Call printf function


increment:	
	add	x19,	x19,	1					// Add 1 to domain, to increment loop and update calculation
	b	test							// End of loop iteration, branch back to test condition

done:
	ldp	x29,	x30,	[sp], 16				// Return fp and lr from stack
	ret								// Return to caller

