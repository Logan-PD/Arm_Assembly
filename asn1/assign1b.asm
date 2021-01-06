/*------------------------------------
 Logan Perry-Din
 UCID: 30070661
 cpsc 355 spring 2019
 Assignment 1b (macros, optimized loop)

 Finds max of y= -5x^3 - 31x^2 + 4x + 31
 in the interval -6 <= x <= 5
-------------------------------------*/


define(x_r, x19)							// Macro for x value
define(yMax_r, x20)							// Macro for max y value
define(yC_r, x21)							// Macro for computed y value
define(a_r, x22)							// Macro for first term: -5x^3
define(b_r, x23)							// Macro for second term: -31x^2
define(c_r, x24)							// Macro for third term: 4x
define(coe_r, x25)							// Macro for coefficients


fmt:
	.string "For x = %d, y = %d.\nCurrent maximum is y = %d\n"	// String format for output message
	.balign 4							// Aligns instructions


	.global main							// Makes main visible to OS
main:
	stp	x29,	x30,	[sp, -16]!				// Save fp and lr to stack, allocating 16 bytes
	mov	x29,	sp						// Update fp to current sp
	
setup:
	mov	x_r,	-6						// Register for X value, starting at lowest domain and acting as loop counter
	mov	yMax_r,	-999						// Register for computed max Y value, starting at -999
	
	b test								// Branch to test before loop (pre-test loop)	



loop:	
	// Calculate Y
	mov	coe_r,	4						// Move 4 to coefficient register
	mul	c_r,	x_r,	coe_r					// 4x
	add	yC_r,	c_r,	31					// y = 4x + 31

	mul	b_r,	x_r,	x_r					// x*x=x^2

	mul	a_r,	x_r,	b_r					// x^2*x=x^3 (use x^2 calculation once for first and second term of equation)

	mov	coe_r,	-31						// Move -31 into the coefficient register
	madd	yC_r,	b_r,	coe_r,	yC_r				// y = x^2 * -31 + (4x+31)

	mov	coe_r,	-5						// Move -5 into coefficient register
	madd	yC_r,	a_r,	coe_r,	yC_r				// y = x^3 * -5 + (-31x^2+4x+31)


updateYMax:
	cmp	yC_r,	yMax_r						// if computed y value is greater than last y
	b.le	display							// if not, branch to display
	mov	yMax_r,	yC_r						// if it is, update to new max value


display:
	adrp	x0,	fmt						// Set 1st argument of printf
	add	x0,	x0,	:lo12:fmt				// Set lower 12 bits
	mov	x1,	x_r						// Place value of x into x1 register for printf
	mov	x2,	yC_r						// Place value of computed y into x2 register for printf
	mov	x3,	yMax_r						// Place value of max y into x3 register for printf
	bl	printf							// Call printf function
	
	add	x_r,	x_r,	1					// Add 1 to domain, to increment loop and update calculation



test:
	cmp	x_r,	6						// Loop condition to ensure x is in domain
	b.lt	loop							// If x is less than 6, reiterate loop


done:
	ldp	x29,	x30,	[sp], 16				// Return fp and lr from stack
	ret								// Return to caller

