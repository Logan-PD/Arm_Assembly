/*
 * CPSC355 spring 2019
 * Assignment 2a
 *
 * Logan Perry-Din
 * UCID: 30070661
 * 
 * Integer Multiplication Program, translasted from C code.
 */


			/* Define macros */

							// 32-bit
					// multiplier
					// multiplicand
					// product
						// for loop counter
					// negative

							// 64-bit
					// x24 of calculation
					// temporary registers
	



			/* String formats */

												// Initial print
	fmt_initial: .string	"multiplier = 0x%08x (%d) multiplicand = 0x%08x (%d)\n\n"

												// Product and multiplier
	fmt_pro_mult: .string	"product = 0x%08x multiplier = 0x%08x\n\n"

												// Result
	fmt_result: .string "64-bit x24 = 0x%016lx (%ld)\n"


	.balign 4					// Aligns instructions
	.global main					// Makes main visible to OS

main:

	stp	x29,	x30,	[sp, -16]!		// Save FP and LR to stack, allocating 16 bytes
	mov	x29,	sp				// Update FP to current SP


							/* Initialize variables */
	mov	w19,	70
	mov	w20,	-16843010
	mov	w21,	0				
	mov	w22,	0				// for loop counter
	


							/* Print inital values */
	ldr	x0,	=fmt_initial			// Load register x0 with address of string
	mov	w1,	w19				// Load registers with values to be printed
	mov	w2,	w19
	mov	w3,	w20
	mov	w4,	w20
	bl	printf					// Call function printf


							/* Check if multiplier is negative */
	cmp	w19,	wzr				// Compare multiplier with zero register
	b.lt	isNeg					// If multiplier is less than zero, branch to isNeg
	mov	w23,	0				// If not, move 0 (false) into w23
	
	b	skipNeg					// Skip instruction where w19 is negative

isNeg:
	mov	w23,	1				// Move 1 (true) into w23
	
skipNeg:
							/* Start of loop */
	b	test					// Branch to test condition


loop:
	tst	w19,	0x1				// Test if bit-0 of w19 is 1 or 0, if(w19 & 0x1)
	b.eq	mZero					// If bit-0 of w19 is 0, branch to skip instruction
	add	w21,	w21,	w20			// Else, bit-0 of w19 is 1: w21 = w21 + w20
	
mZero:
	asr	w19,	w19,	1			// Arithmetic shift right w19 by 1 bit

	tst	w21,	0x1				// Test if bit-0 of w21 is 1 or 0, if(w21 & 0x1)
	b.ne	pZero					// If bit-0 of w21 is 0, branch to skip instruction
	and	w19,	w19,	0x7FFFFFFF		// Else, w19 = w19 & 0x7FFFFFFF
	b	skipIf					// Skip instruction so that only & or | operation is performed, not both

pZero:
	orr	w19,	w19,	0x80000000		// bit-0 of w21 is 0: w19 = w19  | 0x80000000

skipIf:
	asr	w21,	w21,	1			// Arithmetic shift right w21 by 1 bit
	
	add	w22,	w22,	1			// Increment loop counter by 1

test:
	cmp	w22,	32				// Test condition for loop: if (w22<32)
	b.lt	loop					// If condition true, (w22<32), branch for another iteration

	cmp	w23,	0				// if(negative): if w23 == 1
	b.eq	notNeg					// Branch to skip instruction if w23 != 1	
	sub	w21,	w21,	w20			// Else, w23 == 1: w21 = w21 - w20
	
notNeg:
							/* Print out product and multiplier */
	ldr	x0,	=fmt_pro_mult			// Load address of string format
	mov	w1,	w21				// Load registers with values to be printed (w21 and w19)
	mov	w2,	w19
	bl	printf					// Call printf


							/* Combine product and multiplier together */
	sxtw	x25,	w21				// Place value of w21 into x25 in order to compute 64-bit x24
	and	x25,	x25,	0xffffffff		// x25 = w21 & 0xFFFFFFFF
	lsl	x25,	x25,	32			// x25 = x25 << 32 (logical shift left by 32 bits)
	sxtw	x26,	w19				// Place value of w19 into x26
	and	x26,	x26,	0xffffffff		// x26 = w19 & 0xFFFFFFFF
	add	x24,	x25,	x26			// x24 = x25 + x26
	

							/* Print out 64-bit x24 */
	ldr	w0,	=fmt_result			// Load register with address of string format
	mov	x1,	x24				// Load x24 into registers
	mov	x2,	x24
	bl	printf

done:
	ldp	x29,	x30,	[sp],	16		// Restore FP and LR from stack
	ret						// Return to caller

















