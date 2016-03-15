.equ JTAG, 0x10001020
.equ POS, 0x01

.global _start

_start:
	movia 	r7, JTAG
	
#Reads sensors and speed data
READ:
	movi 	r4, 2
	call 	WRITE_POLL
	call 	READ_POLL

READ_SNS:
	call	READ_POLL
	mov		r5, r3 						#Stores sensor data
	call	READ_POLL
	mov 	r6, r3						#Stores speed data

	movi 	r10, 0x1F
	beq 	r5, r10, GO_STRAIGHT

	movi 	r10, 0x0F
	beq 	r5, r10, GO_LEFT

	movi 	r10, 0x07
	beq 	r5, r10, GO_HARD_LEFT

	movi 	r10, 0x1C
	beq 	r5, r10, GO_HARD_RIGHT

	movi 	r10, 0x1E
	beq 	r5, r10, GO_RIGHT


GO_STRAIGHT:
	movi 	r4, 5
	call 	WRITE_POLL
	movi 	r4, 0
	call 	WRITE_POLL

	movi 	r4, 4
	call 	WRITE_POLL
	call 	GET_ACCEL 				#Gets accleration based on a function 
	call 	WRITE_POLL

	br		READ

GO_RIGHT:
	movi 	r4, 5
	call 	WRITE_POLL
	movi 	r4, 62
	call 	WRITE_POLL

	movi 	r4, 4
	call 	WRITE_POLL
	call 	GET_DECEL				#Gets deceleration based on a function 
	call 	WRITE_POLL

	br		READ

GO_HARD_RIGHT:
	movi 	r4, 5
	call 	WRITE_POLL
	movi 	r4, 127
	call 	WRITE_POLL

	movi 	r4, 4
	call 	WRITE_POLL
	movi 	r4, -127				#Max deceleration
	call 	WRITE_POLL

	br		READ

GO_HARD_LEFT:
	movi 	r4, 5
	call 	WRITE_POLL
	movi 	r4, -127
	call 	WRITE_POLL

	movi 	r4, 4
	call 	WRITE_POLL
	movi 	r4, -127				#Max deceleration
	call 	WRITE_POLL

	br		READ

GO_LEFT:
	movi 	r4, 5
	call 	WRITE_POLL
	movi 	r4, -62
	call 	WRITE_POLL

	movi 	r4, 4
	call 	WRITE_POLL
	call 	GET_DECEL				#Gets deceleration based on a function 
	call 	WRITE_POLL

	br		READ

#Writes from r4
WRITE_POLL:
	ldwio 	r3, 4(r7)
	srli	r3, r3, 16
	beq		r3, r0, WRITE_POLL
	stwio 	r4, 0(r7)
	ret

#Reads into R3
READ_POLL:
	ldwio 	r2, 0(r7)
	andi 	r3, r2, 0x8000
	beq 	r3, r0, READ_POLL
	andi	r3, r2, 0x00FF
	ret

#Gets deceleration based on speed
GET_DECEL:
	movi 	r16, 45
	bgt 	r6, r16, SET_DECEL_90
	movi 	r16, 35
	bgt 	r6, r16, SET_DECEL_20
	movi 	r16, 20
	bgt 	r6, r16, SET_DECEL_15
	movi 	r16, 10
	bgt 	r6, r16, SET_DECEL_10
SET_DECEL_0:
	movi	r4, 127
	ret
SET_DECEL_10:
	movi	r4, 80
	ret	
SET_DECEL_15:
	movi	r4, 50
	ret	
SET_DECEL_20:
	movi  	r4, -80
	ret

SET_DECEL_60:
	movi 	r4, -100
	ret
	
SET_DECEL_90:
	movi 	r4, -127
	ret
	
#Gets accleration based on speed
GET_ACCEL:
	movi 	r16, 48
	bgt 	r6, r16, SET_DECEL_90
	#movi 	r16, 40
	#bgt 	r6, r16, SET_ACCEL_90
	movi 	r4, 127
	ret
	
SET_ACCEL_90:
	movi 	r4, 50
	ret