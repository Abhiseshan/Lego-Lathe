.equ ADDR_AUDIODACFIFO, 0xFF203040
.equ time_alarm, 10000
.equ time_alarm_wait, 49000000
.equ ALARM_SOUND, 0x7000000 
.equ ALARM_SOUND1, 0x8000000

.global audio

audio: 
	subi	sp, sp, 4
	stw 	ra, 0(sp)
	
	#Move the number of beeps into r18
	movi 	r18, 5
	
	#Call for one beep
beep:	
	movia 	r16, ADDR_AUDIODACFIFO
	movia 	r17, ALARM_SOUND
	stwio 	r17,	8(r16)      /* Echo to left channel */
	stwio 	r17,	12(r16)     /* Echo to right channel */
	movui 	r4, %lo(time_alarm) 	
	movui 	r5, %hi(time_alarm)
	call 	timer
	movia 	r17, ALARM_SOUND1
	stwio 	r17,	8(r16)      /* Echo to left channel */
	stwio 	r17,	12(r16)     /* Echo to right channel */
	call 	timer
	
	#Check if the number of beeps (5) are done, otherwise generate another beep
	subi 	r18, r18, 1
	bne 	r18, r0, wait
	
	#Restore the return address
	ldw 	ra, 0(sp)
	addi 	sp, sp, 4
	ret
	
wait:
	movui 	r4, %lo(time_alarm_wait) 	
	movui 	r5, %hi(time_alarm_wait)
	call 	timer	
	br 		beep