.equ ADDR_AUDIODACFIFO, 0xFF203040
.equ time_alarm, 1000
.equ time_alarm_wait, 49000000
.equ ALARM_SOUND, 0x9000000 
.equ ALARM_SOUND1, 0x4000000

.global audio

audio: 
	subi	sp, sp, 24
	stw 	ra, 0(sp)
	stw 	r16, 4(sp)
	stw 	r17, 8(sp)
	stw 	r18, 12(sp)
	stw 	r19, 16(sp)
	stw 	r20, 20(sp)
	
	#Move the number of beeps into r18
	movi 	r18, 5
	#Call for one beep
beep:	

	movi 	r19, 10000
	movi 	r20, 1000
wave:	
	movia 	r16, ADDR_AUDIODACFIFO
	movia 	r17, ALARM_SOUND
	stwio 	r17,	8(r16)      /* Echo to left channel */
	stwio 	r17,	12(r16)     /* Echo to right channel */
	
	subi 	r20, r20, 1
	bne 	r20, r20, wave
	
	movi 	r20, 1000
wave2:
	movia 	r17, ALARM_SOUND1
	stwio 	r17,	8(r16)      /* Echo to left channel */
	stwio 	r17,	12(r16)     /* Echo to right channel */

	subi 	r20, r20, 1
	bne 	r20, r20, wave2
	
	subi	r19, r19, 1
	bne 	r19, r0, wave
	
	#Check if the number of beeps (5) are done, otherwise generate another beep
	subi 	r18, r18, 1
	bne 	r18, r0, wait
	
	#Restore the return address
	ldw 	ra, 0(sp)
	ldw 	r16, 4(sp)
	ldw 	r17, 8(sp)
	ldw 	r18, 12(sp)
	ldw 	r19, 16(sp)
	ldw 	r20, 20(sp)
	addi 	sp, sp, 20
	ret
	
wait:
	movui 	r4, %lo(time_alarm_wait) 	
	movui 	r5, %hi(time_alarm_wait)
	call 	timer	
	br 		beep
	
	