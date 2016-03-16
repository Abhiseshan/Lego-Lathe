.equ TIMER_POLL, 0xFF202020 
.equ time, 100000

.global timer

timer:
	movia 		r16, TIMER_POLL   		/* Move address of timer into r16 */
	movui 		r4, %lo(time)
	stwio		r4, 8(r16)
	movui 		r4, %hi(time)
	stwio 		r4, 12(r16)
	stwio 		r0, (r16)			/* Reset timer */
	movi 		r17, 0b0100
	stwio		r17, 4(r16)			/* Start the timer */
	
poll:	
	ldwio		r17, (r16)
	andi 		r17, r17, 1
	beq 		r17, r0, poll
	
	ret
