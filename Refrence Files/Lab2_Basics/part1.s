.equ RED_LEDS, 0xFF200000   # (Hint: See DESL website for documentation on LEDs/Switches)

.data                  # "data" section for input and output lists

IN_LIST:               # List of 10 words starting at location IN_LIST
    .word 1
    .word -1
    .word -2
    .word 2
    .word 0
    .word -3
    .word 100
    .word 0xffffff9c
    .word 0x100
    .word 0b1111
    
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
    .skip 40           	# Reserve space for 10 output words

#-----------------------------------------

.text                  # "text" section for (read-only) code

    # Register allocation:
    #   r0 is zero, and r1 is "assembler temporary". Not used here.
    #   r2  Holds the number of negative numbers in the list
    #   r3  Holds the number of non-negative numbers in the list
    #   r_  A pointer to ___
    #   r_  loop counter for ___
    #   r16 Register for short-lived temporary values.
    #   etc...

.global _start
_start:

    # Your program here. Pseudocode and some code done for you:
    
    # Begin loop to process each number
    
        # Process a number here:
        #    if (number is negative) { 
        #        insert number in OUT_NEGATIVE list
        #        increment count of negative values (r2)
        #    } else {
        #        insert number in OUT_POSITIVE list
        #        increment count of non-negative values (r3)
        #    }
        # Done processing.

	movia 	r6, OUT_NEGATIVE 	#Storing OUT_NEGATIVE into r6
	movia 	r7, OUT_POSITIVE	#Storing OUT_POSITIVE int r7
	movia 	r4, IN_LIST			#Storing input data into r4
	addi 	r5, r0, 10			#initiliazing counter to 10
	addi 	r2, r0, 0			#initializing r2 to 0
	addi 	r3, r0, 0			#initializing r3 to 0

	loop:
		ldw 	r10, (r4)			#Loading value of r4 into r10
		bge 	r10, r0, positive	#if (r10 > 0) goto positive
		blt 	r10, r0, negative	#if (r10 < 0) goto negative
		
	positive:
		stw 	r10, (r6)			#value into r6
		addi 	r6, r6, 4			#increment the -ve list by 4 bytes
		addi 	r3, r3, 1			#increment -ve count by 1
		br		continue
	
	negative:
		stw 	r10, (r7)			#value into r7
		addi 	r7, r7, 4			#increment the +ve list by 4 bytes
		addi 	r2, r2, 1			#increment +ve count by 1
	
	continue:
		addi 	r4, r4, 4			#move r4 by 4 bytes
		subi 	r5, r5, 1			#add 1 to counter
		
        # (You'll learn more about I/O in Lab 4.)
        movia  r16, RED_LEDS       	# r16 and r17 are temporary values
        ldwio  r17, 0(r16)
        addi   r17, r17, 1
        stwio  r17, 0(r16)
        # Finished output to LEDs.
		
	bgt 	r5, r0, loop 			#Runs still r5 > 0
	
	# End loop


LOOP_FOREVER:
    br LOOP_FOREVER               	# Loop forever.
    
