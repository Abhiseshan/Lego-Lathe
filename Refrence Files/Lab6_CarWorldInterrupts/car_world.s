.equ JTAG_GAME, 0x10001020
.equ JTAG_CMD, 0xFF201000
.equ TIMER, 0xFF202000
.equ time, 4999999
.equ PUSHBUTTON, 0xFF200050

.section .exceptions, "ax"
myISR: 	
	subi 	sp, sp, 16
	stw 	et, (sp)
	rdctl 	et, estatus 
	stw 	et, 4(sp)
	stw 	ea, 8(sp)
	stw 	ra, 12(sp)
	
	#irq8 (JTAG) has higher priority
	rdctl 	et, ipending
	andi 	et, et, 0x100 				#check for irq1
	bne 	et, r0, InterruptJTAG
	
	#irq0 (timer) has lower priority
	rdctl 	et, ipending
	andi 	et, et, 0x1
	bne 	et, r0, InterruptTimer
	br 		exitInterrupt

InterruptJTAG:	
	movia 	et, JTAG_CMD 				# et now contains the base address
	ldwio 	r21, 0(et) 					# Load from JTAG
	andi  	r3, r21, 0x8000             # Mask other bits 
	beq   	r3, r0, InterruptJTAG 		# If this is 0 (branch true), data is not valid
	
	ldwio 	r21, 0(et)
	andi 	r3, r21, 0xFF
	movi 	r21, 0x72 					#R
	beq 	r3, r21, setSensorMode
	movi 	r21, 0x73					#S
	beq 	r3, r21, setSpeedMode
	br 		exitInterrupt
	
setSensorMode:
	movi 	r20, 0b0
	br 		exitInterrupt
	
setSpeedMode:
	movi 	r20, 0b1
	br 		exitInterrupt

InterruptTimer:
	movia 	et, TIMER
	ldwio 	r19, (et)
	andi 	r19, r19, 0b10
	stw 	r19, (et)
		
	movia 	r11, JTAG_CMD
	movia	r19, 0x1b					#Escape sequence to clear the terminal
	stwio 	r19, 0(r11)					#Clears the terminal
	movia	r19, 0x5b					#Escape sequence to clear the terminal
	stwio 	r19, 0(r11)					#Clears the terminal
	movia	r19, 0x32					#Escape sequence to clear the terminal
	stwio 	r19, 0(r11)					#Clears the terminal
	movia	r19, 0x4b					#Escape sequence to clear the terminal
	stwio 	r19, 0(r11)					#Clears the terminal
	
	movia	r19, 0x1b					#Escape sequence to set home
	stwio 	r19, 0(r11)					#Clears the terminal
	movia	r19, 0x5b					#Escape sequence to set home
	stwio 	r19, 0(r11)					#Clears the terminal
	movia	r19, 0x48					#Escape sequence to set home
	stwio 	r19, 0(r11)					#Clears the terminal
	
	#andi 	r20, r20, 0b01 				#Checking if the last bit is 1 or 0
	beq 	r20, r0, dispSensors

dispSpeed:
	andi 	r2, r6, 0x0F
	call 	getASCII
	stwio 	r6, 0(r2)					#Writing speed data
	andi 	r2, r6, 0x0F0
	srli	r2, r2, 4
	call 	getASCII
	stwio 	r6, 0(r2)					#Writing speed data
	br 		exitInterrupt
	
getASCII:
	movi 	r3, 0xA
	blt 	r2, r3, getASCIIDigit
	addi 	r2, r2, 55
	ret

getASCIIDigit:
	addi 	r2, r2, 48
	ret
	
dispSensors:
	movi 	r10, 0x1F
	beq 	r5, r10, WRITE_STRAIGHT

	movi 	r10, 0x0F
	beq 	r5, r10, WRITE_LEFT

	movi 	r10, 0x07
	beq 	r5, r10, WRITE_HARD_LEFT

	movi 	r10, 0x1C
	beq 	r5, r10, WRITE_HARD_RIGHT

	movi 	r10, 0x1E
	beq 	r5, r10, WRITE_RIGHT
	
WRITE_STRAIGHT:
	movi 	r5, 0x31
	stwio 	r5, 0(r11)					#Writing sensor data
	movi 	r5, 0x46
	stwio 	r5, 0(r11)					#Writing sensor data
	br 		exitInterrupt

WRITE_HARD_LEFT:
	movi 	r5, 0x30
	stwio 	r5, 0(r11)					#Writing sensor data
	movi 	r5, 0x37
	stwio 	r5, 0(r11)					#Writing sensor data
	br 		exitInterrupt
	
WRITE_HARD_RIGHT:
	movi 	r5, 0x31
	stwio 	r5, 0(r11)					#Writing sensor data
	movi 	r5, 0x43
	stwio 	r5, 0(r11)					#Writing sensor data
	br 		exitInterrupt
	
WRITE_LEFT:
	movi 	r5, 0x30
	stwio 	r5, 0(r11)					#Writing sensor data
	movi 	r5, 0x46
	stwio 	r5, 0(r11)					#Writing sensor data
	br 		exitInterrupt
	
WRITE_RIGHT:
	movi 	r5, 0x31
	stwio 	r5, 0(r11)					#Writing sensor data
	movi 	r5, 0x45
	stwio 	r5, 0(r11)					#Writing sensor data

exitInterrupt:
	ldw 	et, (sp)
	wrctl 	estatus, et
	ldw 	et, 4(sp)
	ldw 	ea, 8(sp)
	ldw 	ra, 12(sp)
	addi 	sp, sp, 16

	subi 	ea, ea, 4 					#set the return address back to account for the disturbed execution
	eret

.section .text
.global _start

_start:
	#initialize JTAG_GAME
	movia 	r7, JTAG_GAME

	#initialize timer
	movia 	r8, TIMER
	movui	r9, %lo(time)
	stwio 	r9, 8(r8)
	movui 	r9, %hi(time)
	stwio 	r9, 12(r8)
	stwio 	r0, (r8) 					#Set timeout to 0

	#start timer
	movui	r9, 0b111
	stwio 	r9, 4(r8) 					#setting start, cont and Interrupt timeout to 1

	#JTAG CMD input
	movia 	r17, JTAG_CMD
	movi 	r20, 0x1
	stwio 	r20, 4(r17)
	movi 	r20, 0x0

	#enable interrupts for irq0 and irq8
	movi 	r9, 0x101
	wrctl 	ienable, r9					#ctl13

	#enable external interrupts
	movi 	r9, 0b01
	wrctl 	status, r9 					#PIE <- 1

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