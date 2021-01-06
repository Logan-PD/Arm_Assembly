/******************************
 * Logan Perry-Din
 * 30070661
 * CPSC 355 Spring 2019
 * Assignment 4
 *
 * Creates structs stored in the stack, views their data,
 * manipulates them and outputs the manipulated data.
*****************************/

/* String formats */
printB:	.string	"Box %s origin = (%d, %d) width = %d height = %d area = %d\n"
init:	.string	"Initial box values:\n"
first:	.string	"first"
second:	.string	"second"
chngd:	.string	"\nChanged box values:\n"

/* Defines */
FALSE = 0
TRUE = 1
SIZE = 50		// This line is in the C code, but never used (error?)


/* Offsets */
point_x = 0		// Point struct
point_y = 4		// containing 2 ints

dim_wid = 0		// Dimension struct
dim_ht = 4		// containing 2 ints

			// Box struct, containing a point, dimension and int
origin = 0		// Origin: point struct
size =8			// Size: dimension struct
area = 16		// int
box_size = 20		// box_size = point(2 ints) + dimension(2 ints) + area(int)

box_1 = box_size	// First box size
box_2 = box_size *2	// Second box size

b1_s = 16		// Box_1 offset
b2_s = 36		// Box_2 offset

base = 16		// 16 bytes from x29 and x30

fp	.req	x29	// frame pointer
lr	.req	x30	// link register


/* Memory Allocation */
allocM = -(16+box_size*2) & -16		// Main: 2 box instances
deallocM = -allocM

allocB = -(16+box_size) & -16		// newBox(): one box
deallocB = -allocB

allocE = -(16+4) & -16			//equal: has one local int variable
deallocE = -allocE


	.balign 4
	.global main

main:
	stp	fp,	lr,	[sp,allocM]!		// Allocate memory for 2 box structs
	mov	fp,	sp				// Update sp

	/* Create new structs */
	add	x8,	fp,	b1_s			// Calculate address of first box in stack
	bl	newBox					// Branch and link to new box
	add	x8,	fp,	b2_s			// Second box
	bl	newBox			


	/* Print initial values */
	ldr	x0,	=init				// Print inital values title
	bl	printf
	
	ldr	x0,	=first				// Load first parameter with string
	add	x1,	fp,	b1_s			// Calculate box_1 base address and store as second parameter
	bl	printBox				// Branch to printBox with string and box_1's address as parameters

	ldr	x0,	=second				// Repeat for second box
	add	x1,	fp,	b2_s
	bl	printBox



	/* Call equal */
	add	x0,	fp,	b1_s			// Store address of box_1 into parameter register x0
	add	x1,	fp,	b2_s			// Store address of box_2 into parameter register x1
	bl	equal					// Branch to equal 

	cmp	x0,	TRUE				// See if result of equal is true
	b.ne	false					// If not, branch to false
	
							
	/* if(equal) */
	/* Call move*/					// If true:
	add	x0,	fp,	b1_s			// Calculate address of box1
	mov	w1,	-5				// Load -5 and 7 as arguments for move
	mov	w2,	7	
	bl	move					// Branch to move
	
	/* Call expand */
	add	x0,	fp,	b2_s			// Calculate address of box2
	mov	w1,	3				// Load 3 as argument for expand
	bl	expand					// Branch to expand


false:
	/* Print changed values */
	ldr	x0,	=chngd				// Print changed values title
	bl	printf

	ldr	x0,	=first				// Print first box
	add	x1,	fp,	b1_s
	bl	printBox

	ldr	x0,	=second				// Print second box
	add	x1,	fp,	b2_s
	bl	printBox


	ldp	fp,	lr,	[sp],	deallocM	// Deallocate memory and return
	ret

	/******** end of main ******/
	

newBox:
	stp	fp,	lr,	[sp,allocB]!		// Allocate memory for one box: 20 bytes
	mov	fp,	sp				// Update sp
	

							// Initialize struct and store as variable local to newBox
	str	wzr,	[fp, base+origin+point_x]	// x = 0, store to stack at address: base(16) + origin(0) + point_x(0) = 16
	str	wzr,	[fp, base+origin+point_y]	// y = 0, store to stack at address: base(16) + origin(0) + point_y(4) = 20
	
	mov	w10,	1
	str	w10,	[fp, base+size+dim_wid]		// width = 1, store to stack at address: base(16) +  size(8) + dim_wid(0) = 24

	mov	w11,	1		
	str	w11,	[fp, base+size+dim_ht]		// height = 1, store to stack at address: base(16) +  size(8) + dim_ht(4) = 28
	
	mul	w12,	w10,	w11			// area = width * height
	str	w12,	[fp, base+area]			// store to stack at address: base(16) + area(16) = 32 



	ldr	w9,	[fp, base+origin+point_x]	// Load local struct into temporay registers
	ldr	w10,	[fp, base+origin+point_y]
	ldr	w11,	[fp, base+size+dim_wid]
	ldr	w12,	[fp, base+size+dim_ht]
	ldr	w13,	[fp, base+area]



	str	w9,	[x8, origin+point_x]		// Store local struct to main struct with address x8 as base of main frame record
	str	w10,	[x8, origin+point_y]
	str	w11,	[x8, size+dim_wid]
	str	w12,	[x8, size+dim_ht]
	str	w13,	[x8, area]

	

	ldp	fp,	lr,	[sp],	deallocB	// Deallocate memory and return
	ret 



printBox:
	stp	fp,	lr,	[sp, -base]!		// Allocate memory and update sp since printBox calls printf
	mov	fp,	sp


	ldr	w2,	[x1,origin+point_x]		// Load parameters for printf using x1 as base address of box struct
	ldr	w3,	[x1,origin+point_y]
	ldr	w4,	[x1,size+dim_wid]
	ldr	w5,	[x1,size+dim_ht]
	ldr	w6,	[x1,area]
	
	mov	x1,	x0				// Move string parameter to x1
	ldr	x0,	=printB				// in order to load x0 with string format for printf

	bl printf					// Call printf function
	
	ldp	fp,	lr,	[sp],	base		// Deallocate memory and return
	ret



equal:
	stp	fp,	lr,	[sp,allocE]!		// Allocate 16 bytes for frame record + 4 for local int variable
	mov	fp,	sp

	mov	x9,	FALSE				// Initialize temporary result register to false
	str	x9,	[sp,base]			// Store result to stack local to equal
	
	ldr	x10,	[x0,origin+point_x]		// Load box_1 point_x from stack, with parameter x0 as offset
	ldr	x11,	[x1,origin+point_x]		// Load box_2 point_x from stack, with parameter x1 as offset
	cmp	x10,	x11				// Compare both point_x's
	b.ne	notEqual				// If not equal, branch to end of subroutine

	ldr	x10,	[x0,origin+point_y]		// Repeat for y, width, and height 
	ldr	x11,	[x1,origin+point_y]
	cmp	x10,	x11
	b.ne	notEqual

	ldr	x10,	[x0,size+dim_wid]
	ldr	x11,	[x1,size+dim_wid]
	cmp	x10,	x11
	b.ne	notEqual
	
	ldr	x10,	[x0,size+dim_ht]
	ldr	x11,	[x1,size+dim_ht]
	cmp	x10,	x11
	b.ne	notEqual

	mov	x9,	TRUE				// If all comparisons evaluate to true, move true to temprorary result register
	str	x9,	[fp,base]			// Store result to stack

notEqual:
	ldr	x0,	[sp,base]			// Load result from stack to return register x0

	ldp	fp,	lr,	[sp],	deallocE	// Deallocate memory and return
	ret
	

move:
	ldr	w9,	[x0,origin+point_x]		// Load point_x and point_y from main stack into temporary registers
	ldr	w10,	[x0,origin+point_y]		// Using x0 as base address
	
	add	w9,	w9,	w1			// point_x += 2nd param from w1
	add	w10,	w10,	w2			// point_y += 3rd param from w2

	str	w9,	[x0,origin+point_x]		// Store updated values to main
	str	w10,	[x0,origin+point_y]		

	ret						// Return


expand:
	ldr	w9,	[x0,size+dim_wid]		// Load width anb height from main stack into temporary registers
	ldr	w10,	[x0,size+dim_ht]		// using x0 as base address

	mul	w9,	w9,	w1			// width *= 2nd param from w1
	mul	w10,	w10,	w1			// height *= 2nd param from w1
	mul	w11,	w10,	w9			// Calculate new area

	str	w9,	[x0,size+dim_wid]		// Store updated values to main
	str	w10,	[x0,size+dim_ht]
	str	w11,	[x0,area]

	ret						// Return


