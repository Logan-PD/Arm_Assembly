/************************
 * Logan Perry-Din
 * 300070661
 * CPSC 355 spring 2019
 * 
 * Assignment 5 b
 * Generates output message displaying the entered
 * month and day formatted into a string with appropriate 
 * suffix, as well as the season.
************************/

/* Register equates */
argc	.req	x19
argv	.req	x20
day	.req	x21
month	.req	x22
season	.req	x23

seaAdr	.req	x24
monAdr	.req	x25

fp	.req	x29
lr	.req	x30

	.text
//Months
jan:	.string	"January"
feb:	.string	"February"
mar:	.string	"March"
apr:	.string	"April"
may:	.string	"May"
jun:	.string	"June"
jul:	.string	"July"
aug:	.string	"August"
sep:	.string	"September"
oct:	.string	"October"
nov:	.string	"November"
dec:	.string	"December"

//Seasons
win:	.string	"Winter"
spr:	.string	"Spring"
sum:	.string	"Summer"
fal:	.string	"Fall"

//Suffixes
fmt_st:	.string	"%s %dst is %s\n"
fmt_nd:	.string	"%s %dnd is %s\n"
fmt_rd:	.string	"%s %drd is %s\n"
fmt_th:	.string	"%s %dth is %s\n"

error:	.string	"usage: a5b mm dd\n"


/* array of pointer */
	.data
	.balign 8
months:	.dword	jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec
seas:	.dword	win, spr, sum, fal

	.text
	.balign 4
	.global main

main:
	stp	fp,	lr,	[sp,-16]!		// Allocate memory and update stack pointer
	mov	fp,	sp
	
	mov	argc,	x0				// store command line arguments into registers
	mov	argv,	x1

	cmp	argc,	3				// check if usage is correct
	b.ne	errUsage				// if there are not 3 arguments, branch

	
	ldr	x0,	[argv,8]			// convert seond  parameter to int, 8 bytes away from first
	bl	atoi
	
	mov	month,	x0				// Move int into register

	cmp	month,	12				// check is usage is correct (<= 12)
	b.gt	errUsage
	cmp	month,	0				// > 0
	b.lt	errUsage


	ldr	x0,	[argv,16]			// convert second argument to int
	bl	atoi

	mov	day,	x0

	cmp	day,	31				// check for usage
	b.gt	errUsage				// 0 < day < 31
	cmp	day,	0
	b.lt	errUsage

				
	ldr	seaAdr,	=seas				// Load address of arrays
	ldr	monAdr,	=months


/* Determine season */
checkWin:	
	cmp	month,	3
	b.lt	isWinter		// month < 3, thus winter
	b.eq	checkMar		// month == 3, check day

	cmp	month,	12		// month == 12, check day
	b.eq	checkDec
	b.lt	checkSpr		// 3 < month < 12, check spring

checkMar:
	cmp	day,	20
	b.gt	isSpring		// month == 3, day > 20, thus spring
	b	isWinter		// month == 3, day < 20, thus winter

checkDec:
	cmp	day,	21
	b.lt	isFall			// month == 12, day < 21, thus fall

isWinter:
	ldr	season,	[seaAdr]	// Load first element in array into season
	b	suffix			// branch to determine suffix





checkSpr:
	cmp	month,	6
	b.lt	isSpring		// month < 6, skipped winter true, thus spring
	b.eq	checkJun		// month == 6, check day
	b.gt	checkSum		// month > 6, check Summer

checkJun:
	cmp	day,	20		
	b.gt	isSum			// month == 6, day > 20, thus summer
	b	isSpring		// month == 6, day < 20, thus spring

isSpring:
	ldr	season,	[seaAdr,8]	// Load second element in array, 8 bytes after first
	b	suffix




checkSum:
	cmp	month,	9
	b.lt	isSum			// 6 < month < 9, thus summer
	b.eq	checkSept		// month == 9, check day
	b.gt	isFall			// 9 < month < 12, thus fall

checkSept:
	cmp	day,	20
	b.gt	isFall			// month == 9, day > 20, thus fall
	b	isSum			// month == 9, day <= 20, thus summer

isSum:
	ldr	season,	[seaAdr,16]	// 3rd element, 16 bytes
	b	suffix



isFall:
	ldr	season,	[seaAdr,24]	// 4th element, 24 bytes


/* determine suffix */

suffix:
	
	cmp	day,	1		// If day ends in 1, branch to load "st"
	b.eq	st
	cmp	day,	21
	b.eq	st
	cmp	day,	31
	b.eq	st

	cmp	day,	2		// if day ends in 2, branch to load "nd"
	b.eq	nd
	cmp	day,	22
	b.eq	nd

	cmp	day,	3		// If day ends in 3, branch to load "rd"
	b.eq	rd
	cmp	day,	23
	b.eq	rd

	ldr	x0,	=fmt_th		// else: load "th"
	b	printOut

st:
	ldr	x0,	=fmt_st	
	b	printOut
nd:
	ldr	x0,	=fmt_nd
	b	printOut

rd:
	ldr	x0,	=fmt_rd
	b	printOut
	

errUsage:
	ldr	x0,	=error		// Load error string
	bl	printf			// Print error message
	b	done			// Branch to done


printOut:
	sub	month,	month,	1		// Subtract 1 so index begins at 0
	lsl	month,	month,	3		// Multiply by 8, since address of string is 8 bytes
	ldr	x1,	[monAdr,month]		// load first param with element in month array, specified by month
	mov	x2,	day			// Load day
	mov	x3,	season			// Load season
	bl	printf				// Print out string
	
done:
	ldp	fp,	lr,	[sp],	16	// Deallocate memory
	ret
