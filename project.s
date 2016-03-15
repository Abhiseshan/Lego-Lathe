.equ TIMER, 0xFF202000
.equ PUSHBUTTON, 0xFF200050

.section .exceptions, "ax"

/*
 * Register index
 * r8 - Status Register - If the machine is in stop=0/start=1 mode
 */

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
	br 		exitInterrupt
	
START:
	movi 	r8, 0x1
	br 		exitInterrupt
	
InterruptTimer:
	 
	
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
