.equ ADDR_JP1, 0xFF200060

.section .text
.global	_start



_start:

	movia  r8, ADDR_JP1
	movia  r13, 0x07f557ff       
	stwio  r13, 4(r8)
	movia  r13, 0xffffffff			# resetting all value to 1 
	stwio  r13, 0(r8)

firstsensor:
	ldbio     r15,(r8)
	andi    r15,r15,0x03
	movia	r10,0xfffffbff			/* Enable only sensor 0 */
	movia   r18,0xFFFFFFFC
	and    r10,r10,r18
	add     r10,r10,r15
	stwio	r10,0(r8)
	ldwio	r5,	0(r8)
	srli	r5,	r5,11				/* Shift to ready register for Sensor 0 */
	andi	r5,	r5,0x1
	bne	    r0,r5,firstsensor		/* Loops till sensor is ready */
	ldwio   r11, 0(r8)
	srli    r11, r11, 27
	andi    r11, r11, 0x0f 
	

secondsensor:
    ldbio   r15,(r8)
	andi    r15,r15,0x03
	movia	r10,0xFFFFEFFf 			/* Enable only sensor 1 */
	movia   r18,0xFFFFFFFC	
	and     r10,r10,r18
	add     r10,r10,r15
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
  	br firstsensor	
forward: 							

	movia  r13, 0xfffffffc			/* enabling the motor, direction to forward*/  
  	stwio  r13, 0(r8)
  	br firstsensor		
	
equal:

	movia  r13, 0xffffffff      	/* motor disabled */
  	stwio  r13, 0(r8)
	br firstsensor