.equ TIMER_INTERRUPT, 0xFF202000
.equ interrupt_time, 100000
.equ PUSHBUTTON, 0xFF200050
.equ LEGOCONTROLLER, 0xFF200060

/*
 * Fixed Registers
 * r8  - Status Register - If the machine is in stop=0/start=1 mode
 * r15 - Lego Controller
 *
 * Timers
 * Timer 1: Interrrupt to move the motors
 * Timer 2: Polling for time the motors should be on
 *
 * Motors
 * Motor 0: Base movement motor
 * Motor 1: Drill movement motor
 * Motor 2: Drill motor
 * Motor 3: Material Rotation Motor
 */

.section .exceptions, "ax"

ISR:
	subi 	sp, sp, 16
	stw 	et, (sp)
	rdctl 	et, estatus 
	stw 	et, 4(sp)
	stw 	ea, 8(sp)
	stw 	ra, 12(sp)
	
	#irq1 (Pushbutton) 
	rdctl 	et, ipending
	andi 	et, et, 0x2
	bne 	et, r0, InterruptPushButton
	
	#irq0 (timer) 
	rdctl 	et, ipending
	andi 	et, et, 0x1
	bne 	et, r0, InterruptTimer
	
	br 		exitInterrupt
	
InterruptPushButton:
	movia	et, PUSHBUTTON
	ldwio 	r9, (et)
	movi 	r10, 0xF 				#Mask all the bits
	andi 	r9, r9, r10
	movi 	r10, 0x4
	beq 	r10, r9, STOP
	movi 	r10, 0x2
	beq 	r10, r9, START
	
	br 		exitInterrupt
	
STOP:
	movi 	r8, 0x0
	
	#Stop the interrupt timer
	movia 	et, TIMER_INTERRUPT
	movia 	r9, 0b1000
	stw		r9, 4(et)	
	
	#Stop all the motors (drill motor and material rotation motor)
	movia	r9, 0xffffffff			
	stwio 	r9, 0(r15)	
	
	br 		exitInterrupt
	
START:
	movi 	r8, 0x1
	
	#Start the timer interrupt
	movia 	et, TIMER_INTERRUPT
	movia 	r9, 0b0111
	stw		r9, 4(et)
	
InterruptTimer:
	movia 	et, TIMER_INTERRUPT
	ldwio 	r9, (et)
	andi 	r9, r9, 0b10
	stw 	r9, (et)  					#set timeout bit to 0

	#move the base motor
	bne 	r8, 0x1, exitInterrupt		#If mode not start, exit
	
	movia  	r9, 0xfffffffc 				#enabling the motor 0, direction to forward
  	stwio  	r9, 0(r15)					#Turn on motor
	call 	timer
	movia	r9, 0xffffffff			
	stwio 	r9, 0(r15)					#Turn off motor
	
	#Start the drill motor
	movia 	r9, 0xffffffcf
	stwio 	r9, 0(r15)
	
	#Start the material rotation motor
	movia 	r9, 0xffffff3f
	stwio 	r9, 0(r15)
	
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
	movia 	r15, LEGOCONTROLLER
	
	#Initialize the LEGO Controller
	movia  	r9, 0x07f557ff       	/* Set the direction registers */
	stwio 	r9, 4(r15)
	movia 	r9, 0xffffffff
	stwio 	r9, 0(r8)

	#Initialize the interrupt timer
	movia 	r9, TIMER_INTERRUPT
	movui 	r10, %lo (interrupt_time)
	stwio 	r10, 8(r9)
	movui 	r10, %hi (interrupt_time)
	stwio 	r10, 12(r9)
	stwio 	r0, 0(r8)
	
	#Start the timer
	movui 	r10, 0b111
	stwio 	r10, 4(r9)
	
	