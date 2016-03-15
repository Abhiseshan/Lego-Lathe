.equ RED_LEDS, 0xFF200000   # (Hint: See DESL website for documentation on LEDs/Switches)

.data                  # "data" section for input and output lists

IN_LINKED_LIST:           # Used only in Part 3
    A: .word 1,           B
    B: .word -1,          C
    C: .word -2,          E + 8
    D: .word 2,           A - 0x1000
    E: .word 0,           K
    F: .word -3,          G
    G: .word 100,         J
    H: .word 0xffffff9c,  D + 4
    I: .word 0x100,       H
    J: .word 0b1111,      IN_LINKED_LIST + 0x40
    K: .word 1234,        0
    
    
OUT_NEGATIVE:
    .skip 40            # Reserve space for 10 output words
    
OUT_POSITIVE:
    .skip 40            # Reserve space for 10 output words

#-----------------------------------------

.text                  # "text" section for (read-only) code

.global _start
_start:
		addi r2, r2, 0 				#register for counting the number of negatives
		addi r3, r3, 0 				#register for counting the number of positives
		movia r4, IN_LINKED_LIST 
		movia r5, OUT_NEGATIVE
		movia r6, OUT_POSITIVE

	
	loop: 
		ldw r7, (r4)  				#store the first element - store 1 for first case
		addi r4, r4, 4				#increment the pointer by 4 , r4 points to B memory location
		ldw r9, (r4)				#store the second element -1 - store B for first case
		bge r7, r0, POSITIVE_LIST   #if element is greater than zero go to POSITIVE_LIST
		addi r2, r2, 1				#increment the counter for NEGATIVE_LIST
		stw r7,(r5)    				#store the negative value in the NEGATIVE_LIST
		beq r9, r0, LOOP_FOREVER	#if the element is zero go to LOOP_FOREVER
		addi r5, r5, 4				#increment the pointer in the negative list
		addi r4,r9,0				#move the value of r9 into r4
		br loop						#loop back
		
	POSITIVE_LIST: 
		stw r7,(r6)    			 	#store into r6
		addi r3, r3, 1				#increment the positives list counter
		addi r6, r6, 4				#store the next element 
		addi r4,r9,0				#move the value of r9 into r4
		br loop						#loop back
	
	LOOP_FOREVER:
		br LOOP_FOREVER                   # Loop forever.
	
        # (You'll learn more about I/O in Lab 4.)
        movia  r16, RED_LEDS          # r16 and r17 are temporary values
        ldwio  r17,(r16)
        addi   r17,r17, 1
        stwio  r17,(r16)
        # Finished output to LEDs.
    # End loop



    
