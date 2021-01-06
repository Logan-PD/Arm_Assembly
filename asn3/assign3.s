/*************************************
 * Logan Perry-Din
 * 30070661
 * CPSC 355 Assignment 3
 *
 * Generates array of 50 random numbers mod 256
 * and sorts them into ascending order using 
 * insertion sort.
 ***********************************/



/*Output Strings*/
fmt1: .string "v[%d], %d\n"
fmt2: .string "\nSorted Array:\n"


/*Offsets*/
size = 50				// Size of array = 50 elements
v_size = size * 4			// size of array * 4 byte words

v_s = 16				// 16 bytes off from frame record
i_s = v_size + 16			// 4 bytes from array		// v_size + 16 (????)
j_s = i_s + 4				// 4 bytes from i_s
temp_s = j_s + 4			// 4 bytes from j_s


/*Defines*/
ALLOC	= -(16+v_size+30) & -16		// Memory needed for allocation: frame record(16)+array(v_size)+(i+j+temp(4+4+4))
	.equ	DEALLOC, -ALLOC

fp	.req	x29
lr	.req	x30

i	.req	w19
j	.req	w20
temp	.req	w21
stor	.req	w22
v_stor	.req	w23

baseV	.req	x22
	
	.balign 4
	.global main

main:
	stp	fp,	lr,	[sp,ALLOC]!
	mov	fp,	sp

	mov	i,	0			// Initialize i to 0
	str	i,	[fp,i_s]		// Stores i into stack variable

	b	test1				// Branch to optimized pre-test loop

loop1:
	bl	rand				// Call rand() function
	and	j,	w0,	0xFF		// j = rand % 0xFF (j is used in first loop as temporary storage)
	
	add	baseV,	fp,	v_s		// Array base address = v_s(16bytes) + frame pointer
	ldr	i,	[fp,i_s]		// Load i from stack
	str	j,	[baseV,i,sxtw 2]	// Store random integer into stack	// sxtw 2 ????
	
	ldr	x0,	=fmt1			// Load output string into x0
	mov	w1,	i			// Move index into w1
	mov	w2,	j			// Move value of v[i] into w2
	bl	printf				// Call printf function
						
	ldr	i,	[fp,i_s]		// Load i from stack
	add	i,	i,	1		// Increment i: i++
	str	i,	[fp,i_s]		// Store i to stack
test1:
	cmp	i,	size			// If(i<size)
	b.lt	loop1				// Branch to loop for iteration	


	/*Start of insert sort*/
	mov	i,	1			// Re-initialize i to 1
	str	i,	[fp,i_s]		// Store i to stack
	
outer:
	ldr	temp,	[baseV,i,sxtw 2]		// Load v[i] to temp	//sxtw 2?r
	mov	j,	i			// Initialize j to i
	str	j,	[fp,j_s]		// Store j to stack
	
inner:
	/*check two conditions*/
	cmp	j,	0			// if(j>0)
	b.le	end_inner			// if not: exit loop
	sub	stor,	j,	1		// storage = j - 1
	ldr	v_stor,	[baseV,stor,sxtw 2]		// Load v[j-i]	//sxtw 2?
	cmp	temp,	v_stor			// if(temp<v[j-1]
	b.ge	end_inner			// if not: exit loop
	

	ldr	v_stor,	[baseV,stor,sxtw 2]		// Get v[j-1] from stack	//sxtw2?
	str	v_stor,	[baseV,j,sxtw 2]		// load v[j-1] into v[j]	//sxtw2?


	ldr	j,	[fp,j_s]		// Load j from stack
	sub	j,	j,	1		// Decrement by 1: j--
	str	j,	[fp,j_s]		// Store j to stack
	b	inner				// Branch for another iteration	


end_inner:
	str	temp,	[baseV,j,sxtw 2]		// v[j] = temp	//sxtw2??

	ldr	i,	[fp,i_s]		// Load i from stack
	add	i,	i,	1		// Increment by 1
	str	i,	[fp,i_s]		// Store i to stack

outerTest:
	cmp	i,	size			// If (i<size)
	b.lt	outer				// Branch for another iteration

	ldr	x0,	=fmt2			// Print sorted array title
	bl	printf				// Branch to printf
	
	
	mov	i,	0			// Re-initialize i to 0
	str	i,	[fp,i_s]		// Store i to stack
	b	testLast			// Branch to last test

printLast:
	ldr	x0,	=fmt1
	ldr	w1,	[fp,i_s]
	ldr	w2,	[baseV,w1,sxtw 2]		// SXTW 2?
	bl printf

	ldr	i,	[fp,i_s]
	add	i,	i,	1
	str	i,	[fp,i_s]


testLast:
	cmp	i,	size
	b.lt	printLast	


	mov	w0,	0
	ldp	fp,	lr,	[sp],	DEALLOC
	ret



















