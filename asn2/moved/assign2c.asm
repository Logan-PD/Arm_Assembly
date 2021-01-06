/*
 * CPSC355 spring 2019
 * Assignment 2c
 *
 * Logan Perry-Din
 * UCID: 30070661
 * 
 * Integer Multiplication Program, translasted from C code.
 */


			/* Define macros */

							// 32-bit
	define(mplier, w19)				// multiplier
	define(mcand, w20)				// multiplicand
	define(prod, w21)				// product
	define(i, w22)					// for loop counter
	define(neg, w23)				// negative

							// 64-bit
	define(result, x24)				// result of calculation
	define(temp1, x25)				// temporary registers
	define(temp2, x26)



			/* String formats */

												// Initial print
	fmt_initial: .string	"multiplier = 0x%08x (%d) multiplicand = 0x%08x (%d)\n\n"

												// Product and multiplier
	fmt_pro_mult: .string	"product = 0x%08x multiplier = 0x%08x\n\n"

												// Result
	fmt_result: .string "64-bit result = 0x%016lx (%ld)\n"


	.balign 4					// Aligns instructions
	.global main					// Makes main visible to OS

main:

	stp	x29,	x30,	[sp, -16]!		// Save FP and LR to stack, allocating 16 bytes
	mov	x29,	sp				// Update FP to current SP


							/* Initialize variables */
	mov	mplier,	-256
	mov	mcand,	-252645136
	mov	prod,	0				
	mov	i,	0				// for loop counter
	


							/* Print inital values */
	ldr	x0,	=fmt_initial			// Load register x0 with address of string
	mov	w1,	mplier				// Load registers with values to be printed
	mov	w2,	mplier
	mov	w3,	mcand
	mov	w4,	mcand
	bl	printf					// Call function printf


							/* Check if multiplier is negative */
	cmp	mplier,	wzr				// Compare multiplier with zero register
	b.lt	isNeg					// If multiplier is less than zero, branch to isNeg
	mov	neg,	0				// If not, move 0 (false) into neg
	
	b	skipNeg					// Skip instruction where mplier is negative

isNeg:
	mov	neg,	1				// Move 1 (true) into neg
	
skipNeg:
							/* Start of loop */
	b	test					// Branch to test condition


loop:
	tst	mplier,	0x1				// Test if bit-0 of mplier is 1 or 0, if(mplier & 0x1)
	b.eq	mZero					// If bit-0 of mplier is 0, branch to skip instruction
	add	prod,	prod,	mcand			// Else, bit-0 of mplier is 1: prod = prod + mcand
	
mZero:
	asr	mplier,	mplier,	1			// Arithmetic shift right mplier by 1 bit

	tst	prod,	0x1				// Test if bit-0 of prod is 1 or 0, if(prod & 0x1)
	b.ne	pZero					// If bit-0 of prod is 0, branch to skip instruction
	and	mplier,	mplier,	0x7FFFFFFF		// Else, mplier = mplier & 0x7FFFFFFF
	b	skipIf					// Skip instruction so that only & or | operation is performed, not both

pZero:
	orr	mplier,	mplier,	0x80000000		// bit-0 of prod is 0: mplier = mplier  | 0x80000000

skipIf:
	asr	prod,	prod,	1			// Arithmetic shift right prod by 1 bit
	
	add	i,	i,	1			// Increment loop counter by 1

test:
	cmp	i,	32				// Test condition for loop: if (i<32)
	b.lt	loop					// If condition true, (i<32), branch for another iteration

	cmp	neg,	0				// if(negative): if neg == 1
	b.eq	notNeg					// Branch to skip instruction if neg != 1	
	sub	prod,	prod,	mcand			// Else, neg == 1: prod = prod - mcand
	
notNeg:
							/* Print out product and multiplier */
	ldr	x0,	=fmt_pro_mult			// Load address of string format
	mov	w1,	prod				// Load registers with values to be printed (prod and mplier)
	mov	w2,	mplier
	bl	printf					// Call printf


							/* Combine product and multiplier together */
	sxtw	temp1,	prod				// Place value of prod into temp1 in order to compute 64-bit result
	and	temp1,	temp1,	0xffffffff		// temp1 = prod & 0xFFFFFFFF
	lsl	temp1,	temp1,	32			// temp1 = temp1 << 32 (logical shift left by 32 bits)
	sxtw	temp2,	mplier				// Place value of mplier into temp2
	and	temp2,	temp2,	0xffffffff		// temp2 = mplier & 0xFFFFFFFF
	add	result,	temp1,	temp2			// result = temp1 + temp2
	

							/* Print out 64-bit result */
	ldr	w0,	=fmt_result			// Load register with address of string format
	mov	x1,	result				// Load result into registers
	mov	x2,	result
	bl	printf

done:
	ldp	x29,	x30,	[sp],	16		// Restore FP and LR from stack
	ret						// Return to caller

















