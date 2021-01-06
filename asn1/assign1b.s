/*------------------------------------
 Logan Perry-Din
 UCID: 30070661
 cpsc 355 spring 2019
 Assignment 1b (macros, optimized loop)

 Finds max of y= -5x^3 - 31x^2 + 4x + 31
 in the interval -6 <= x <= 5
-------------------------------------*/


							// Macro for x value
							// Macro for max y value
							// Macro for computed y value
							// Macro for first term: -5x^3
							// Macro for second term: -31x^2
							// Macro for third term: 4x
							// Macro for coefficients


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
	
	b test								// Branch to test before loop (pre-test loop)	



loop:	
	// Calculate Y
	mov	x25,	4						// Move 4 to coefficient register
	mul	x24,	x19,	x25					// 4x
	add	x21,	x24,	31					// y = 4x + 31

	mul	x23,	x19,	x19					// x*x=x^2

	mul	x22,	x19,	x23					// x^2*x=x^3 (use x^2 calculation once for first and second term of equation)

	mov	x25,	-31						// Move -31 into the coefficient register
	madd	x21,	x23,	x25,	x21				// y = x^2 * -31 + (4x+31)

	mov	x25,	-5						// Move -5 into coefficient register
	madd	x21,	x22,	x25,	x21				// y = x^3 * -5 + (-31x^2+4x+31)


updateYMax:
	cmp	x21,	x20						// if computed y value is greater than last y
	b.le	display							// if not, branch to display
	mov	x20,	x21						// if it is, update to new max value


display:
	adrp	x0,	fmt						// Set 1st argument of printf
	add	x0,	x0,	:lo12:fmt				// Set lower 12 bits
	mov	x1,	x19						// Place value of x into x1 register for printf
	mov	x2,	x21						// Place value of computed y into x2 register for printf
	mov	x3,	x20						// Place value of max y into x3 register for printf
	bl	printf							// Call printf function
	
	add	x19,	x19,	1					// Add 1 to domain, to increment loop and update calculation



test:
	cmp	x19,	6						// Loop condition to ensure x is in domain
	b.lt	loop							// If x is less than 6, reiterate loop


done:
	ldp	x29,	x30,	[sp], 16				// Return fp and lr from stack
	ret								// Return to caller

