.equ ADDR_AUDIODACFIFO, 0xFF203040
.equ time_alarm, 1000
#.equ time_alarm_wait, 10000000
.equ time_alarm_wait, 49000000
.equ ALARM_SOUND, 0x70000000
.equ ALARM_SOUND1, 0x4000000

.global audio

audio: 
	subi	sp, sp, 28
	stw 	ra, 0(sp)
	stw 	r16, 4(sp)
	stw 	r17, 8(sp)
	stw 	r18, 12(sp)
	stw 	r19, 16(sp)
	stw 	r20, 20(sp)
	stw     r21, 24(sp)
	
	#Move the number of beeps into r18
	movi 	r18, 5
	#Call for one beep
beep:	
	#movi 	r19, 10000
	movia 	r20, 1000000
	
wave:	
	movia 	r16, ADDR_AUDIODACFIFO
	movia 	r17, ALARM_SOUND
	stwio 	r17, 8(r16)      /* Echo to left channel */
	stwio 	r17, 12(r16)     /* Echo to right channel */
	
	movia 	r17, ALARM_SOUND1
	stwio 	r17,	8(r16)      /* Echo to left channel */
	stwio 	r17,	12(r16)     /* Echo to right channel */
	
	subi 	r20, r20, 1
	bne 	r20, r0, wave
	
	br      wait

exit:	
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
	subi    r18,r18,1
	bne     r18,r0, beep
	br 		exit
	
	
