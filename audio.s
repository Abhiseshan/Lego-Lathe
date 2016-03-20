.equ ADDR_AUDIODACFIFO, 0xFF203040
.equ time_alarm, 10000
.equ ALARM_SOUND, 0x7000000 
.equ ALARM_SOUND1, 0x8000000

.global audio

audio: 
	movia 	r16, ADDR_AUDIODACFIFO
	movia 	r17, ALARM_SOUND
	stwio 	r17,	8(r16)      /* Echo to left channel */
	stwio 	r17,	12(r16)     /* Echo to right channel */
	movui 	r4, %lo(time_alarm) 	
	movui 	r5, %hi(time_alarm)
	subi	sp, sp, 4
	stw 	ra, 0(sp)
	call 	timer
	movia 	r17, ALARM_SOUND1
	stwio 	r17,	8(r16)      /* Echo to left channel */
	stwio 	r17,	12(r16)     /* Echo to right channel */
	call 	timer
	ldw 	ra, 0(sp)
	addi 	sp, sp, 4
	ret
	