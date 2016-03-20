.equ ADDR_AUDIODACFIFO, 0xFF203040
.equ time_alarm, 10000
.equ ALARM_SOUND, 0x7000000 
.equ ALARM_SOUND1, 0x8000000

.global audio

audio: 
	movia 	r2, ADDR_AUDIODACFIFO
	movia 	r3, ALARM_SOUND
	stwio 	r3,	8(r2)      /* Echo to left channel */
	stwio 	r3,	12(r2)     /* Echo to right channel */
	movui 	r4, %lo(time_alarm) 	
	movui 	r5, %hi(time_alarm)
	call 	timer
	movia 	r3, ALARM_SOUND1
	stwio 	r3,	8(r2)      /* Echo to left channel */
	stwio 	r3,	12(r2)     /* Echo to right channel */
	ret
	