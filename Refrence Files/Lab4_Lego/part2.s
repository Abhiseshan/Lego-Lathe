.equ ADDR_JP1, 0xFF200060  		/* Address GPIO JP1*/
.equ N,	100						/* N value */

.section .text
.global	_start

_start:

	movia  r8, ADDR_JP1
	movia  r13, 0x07f557ff       	/* Set the direction registers */
	stwio  r13, 4(r8)
	movia  r13, 0xffffffff			/* Set Everything to 1. Dissable all sensors and motors */
	stwio  r13, 0(r8)
	movi 	r4, %lo(N)				/* LSB of N into r4 */
	movi	r14, %hi(N)				/* MSB of N into r14 */

firstsensor:
	movia	r10,0xfffffbff			/* Enable only sensor 0 */
	stwio	r10,0(r8)
	ldwio	r5,	0(r8)
	srli	r5,	r5,11				/* Shift to ready register for Sensor 0 */
	andi	r5,	r5,0x1
	bne	    r0,r5,firstsensor		/* Loops till sensor is ready */
	ldwio   r11, 0(r8)
	srli    r11, r11, 27
	andi    r11, r11, 0x0f 
	
secondsensor:
	movia	r10,0xFFFFEFFF 			/* Enable only sensor 1 */
	stwio	r10,0(r8)
	ldwio	r6,	0(r8)
	srli	r6,	r6,13				/* Shift to ready register for Sensor 1 */	
	andi	r6,	r6,0x1
	bne	    r0,r6,secondsensor		/* Loops till sensor is ready */
	ldwio   r12, 0(r8)
	srli    r12, r12, 27
	andi    r12, r12, 0x0f  
	
	beq     r12, r11, equal  		/* if both sensor values are same */
	
	bge     r12, r11, forward		/* if the value of sensor 1 is greater than the value of sensor */ 
	 
backward:

	movia  r13, 0xfffffffe       	/* enabling the motor, direction to backwards */
  	stwio  r13, 0(r8)	
	call 	timer
	movia	r13, 0xffffffff
	stwio 	r13, 0(r8)
  	br firstsensor	
forward: 							

	movia  r13, 0xfffffffc			/* enabling the motor, direction to forward      */ 
  	stwio  r13, 0(r8)				/* Turn on motor */
	call 	timer
	movia	r13, 0xffffffff			
	stwio 	r13, 0(r8)				/* Turn off motor after N cycles */
  	br firstsensor					/* Read from first sensor */
	
equal:

	movia  r13, 0xffffffff      	/* motor disabled */
  	stwio  r13, 0(r8)
	br firstsensor					/* Read from first sensor */				