/************************
 * Logan Perry-Din
 * 30070661
 * CPSC 355 Spring 2019
 * Assignment 5a assembly

 * Contains functions to be called from main in C file.
 * Functions are used to implement a FIFO queue data structure.
*************************/

/* Defines */
QUEUESIZE = 8
MODMASK = 0x7
FALSE = 0
TRUE = 1

fp	.req	x29				// Frame pointer
lr	.req	x30				// Link Register

/* Global variables */
	.data
queue:	.skip	QUEUESIZE * 4			// Array of uninitialize ints, 	
head:	.word	-1
tail:	.word	-1


/* String formats */
queueOverFlow:	.string	"\nQueue overflow! cannot enqueue into a full queue.\n"
emptyQueue:	.string	"\nEmpty queue\n"
contents:	.string	"\nCurrent queue contents:\n"
disp:		.string	" %d"
headArrow:	.string	" <-- head of queue"
tailArrow:	.string	" <-- tail of queue"
newLine:	.string	"\n"
underflow:	.string "\nQueue underflow! Cannot dequeue from an empty queue.\n"

	.text
	.balign 4
	.global enqueue
	.global display
	.global	dequeue
/*
 * void enqueue (int value)
 * @param value: integer to be added to queue.
 * Checks if queue is full, otherwise adds the int to the queue
 */
enqueue:
	stp	fp,	lr,	[sp,-16]!		// Allocate memory for frame pointer and link register
	mov	fp,	sp				// Update stack pointer
	
	mov	w19,	w0				// Save argument given

	bl queueFull					// Branch to queueFull
	cmp	w0,	TRUE				// See if queueFull returned true
	b.eq	full					// If true: branch to full

	
	bl	queueEmpty				// Branch to queueEmpty
	cmp	w0,	TRUE				// See if queueEmtpy returned true
	b.ne	notEmptyEN				// If not true: branch to notEmptyEM
	
							// if(queueEmpty()) == true
	ldr	x20,	=head				// Load address of head
	str	wzr,	[x20]				// Store zero into address of head

	ldr	x20,	=tail				// Load tail and change it to 0
	str	wzr,	[x20]
	b	insert					// Skip queueFull == true


notEmptyEN:						// if(queueEmpty()) == False
	ldr	x20,	=tail				// Load address of tail
	ldr	w21,	[x20]				// Load value of address

	add	w21,	w21,	1			// tail = ++tail
	and	w21,	w21,	MODMASK			// tail = tail & MODMASk
	
	str	w21,	[x20]				// Store new tail value
	
	b	insert					// Skip queueFull == true

full:
	ldr	x0,	=queueOverFlow			// Print output message
	bl	printf
	b	done					// Branch to end of function

insert:
	ldr	x27,	=tail				// Load tail
	ldr	w21,	[x27]

	ldr	x20,	=queue				// Store value into queue at position tail
	str	w19,	[x20,w21,sxtw 2]		// queue[tail] = value


done:	
	ldp	fp,	lr,	[sp],	16		// Restore fp and lr
	ret						// Return 


/*
int dequeue()
Removes value at head of queue from array.
return: value of int removed from queue
*/

dequeue:
	stp	fp,	lr,	[sp,-16]!
	mov	fp,	sp

	bl	queueEmpty				// Check if queue is empty	
	cmp	w0,	TRUE
	b.ne	notEmptyDE				
	
	ldr	x0,	=underflow			// If queueEmpty == true
	bl	printf					// Print output message

	mov	x0,	-1				// Return -1
	b	doneDE					// Branch to end of function

notEmptyDE:						// If queueEmpty == false
	ldr	x20,	=head				// Load head
	ldr	w21,	[x20]
	
	ldr	x20,	=queue				// Load queue
	ldr	w19,	[x20,w21,sxtw 2]		// value = queue[head]


	ldr	x20,	=tail				// Load tail
	ldr	w22,	[x20]

	cmp	w21,	w22				// if(head == tail)
	b.eq	equalDE					// if true: branch to equalDE

	
	ldr	x20,	=head				// else:
	ldr	w21,	[x20]				// load head

	add	w21,	w21,	1			// head = ++head & MODMASK
	and	w21,	w21,	MODMASK

	str	w21,	[x20]				// Store new head value

	b	skip					// skip true

equalDE:
	mov	w27,	-1

	ldr	x20,	=head				// head = tail = -1
	str	w27,	[x20]

	ldr	x20,	=tail
	str	w27,	[x20]
	
skip:
	mov	w0,	w19				// Return dequeued value

doneDE:
	ldp	fp,	lr,	[sp],	16
	ret



/*
int queueFull()
Leaf function
*/


queueFull:

	ldr	x9,	=tail				// Load tail and head
	ldr	w10,	[x9]

	ldr	x9,	=head
	ldr	w11,	[x9]


	add	w10,	w10,	1			// tail = tail + 1
	and	w10,	w10,	MODMASK			// tail = tail & modmask

	cmp	w10,	w11				// compare new tail value and head
	b.ne	retFalseFull				// If false: branch
	
	mov	w0,	TRUE				// If true: return true
	b	doneFull				// Skip false

retFalseFull:

	mov	w0,	FALSE				// Return false
doneFull:
	ret	


/* 
int queueEmpty()
Leaf function
*/

queueEmpty:
	
	ldr	x9,	=head				// Load head
	ldr	w10,	[x9]

	mov	w11,	-1				

	cmp	w10,	w11				// If head == -1
	b.ne	retFalseEmpty				// If false: branch

	mov	w0,	TRUE				// If true: return truw
	b	doneEmpty				// Skip false
	
retFalseEmpty:
	mov	w0,	FALSE				// Return False

doneEmpty:
	ret



/*
void display()
Displays queue
*/

display:
	stp	fp,	lr,	[sp,-16]!
	mov	fp,	sp

	bl	queueEmpty				// Check if queue is empty
	cmp	w0,	TRUE
	b.ne	notEmptyD				// If not empty skip true
	
	ldr	x0,	=emptyQueue			// Print output message
	bl	printf
	b	doneD					// Branch to end of function

notEmptyD:
	ldr	x9,	=tail				// Load tail
	ldr	w19,	[x9]

	ldr	x9,	=head				// Load head
	ldr	w20,	[x9]

	
	sub	w21,	w19,	w20			// count = tail - head + 1
	add	w21,	w21,	1

	
	cmp	w21,	wzr				// if count <= 0
	b.gt	b4Loop					// if false: branch
	
	add	w21,	w21,	QUEUESIZE		// if true: count+= queuesize

b4Loop:
	ldr	x0,	=contents			// Print header
	bl	printf

	mov	w22,	w20				// i = head
	mov	w23,	wzr				// j = 0
	b	test					// Branch to test loop condition
	
loop:
			
	ldr	x9,	=queue				// load queue[i]
	ldr	w27,	[x9, w22, sxtw 2]
	
	ldr	x0,	=disp				// print queue[i]
	mov	w1,	w27	
	bl	printf

	cmp	w22,	w20				// if i == head
	b.ne	notHead					// false: skip true
	ldr	x0,	=headArrow			// true: load string
	bl	printf					// print

notHead:
	cmp	w22,	w19				// if i == tail
	b.ne	notTail					// false: skip true
	ldr	x0,	=tailArrow			// true: load string
	bl	printf					// print

notTail:

	ldr	x0,	=newLine			// print a newline
	bl	printf
	
	add	w22,	w22,	1			// i++
	and	w22,	w22,	MODMASK			// i = i & modmask
		
	add	w23,	w23,	1			//j++
test:
	cmp	w23,	w21				// if j < count
	b.lt	loop					// reiterate loop
	
doneD:
	ldp	fp,	lr,	[sp],	16		// deallocate memory
	ret

