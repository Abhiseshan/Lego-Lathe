/*********
 * 
 * Write the assembly function:
 *     printn ( char * , ... ) ;
 * Use the following C functions:
 *     printHex ( int ) ;
 *     printOct ( int ) ;
 *     printDec ( int ) ;
 * 
 * Note that 'a' is a valid integer, so movi r2, 'a' is valid, and you dont need to look up ASCII values.
 *********/

.global	printn
printn:

	#Pushing values from registers onto the stack
	addi 	sp, sp, -16
	stw 	r5, 4(sp) 
	stw 	r6, 8(sp)
	stw 	r7, 12(sp)
	stw 	r16, (sp) 			#register to store a pointer to the numbers
	addi 	r16, sp, 4 			#assing the value of r16 to the register
	
	
	#backing up the rest of the registers
	addi 	sp, sp, -36	
	stw 	ra, (sp)
	stw 	r4, 4(sp)
	stw 	r17, 8(sp)
	stw 	r18, 12(sp)
	stw 	r19, 16(sp)
	stw 	r20, 20(sp)
	stw 	r21, 24(sp)
	stw 	r22, 28(sp)
	stw 	r23, 32(sp)
		
	addi 	r17, r4, 0 			#assiging pointer to the frist register
	
	movi 	r9, 'D'			#assiging D
	movi 	r20, 'O'			#assiging 0	
	
parse: 
	ldb 	r18, (r17) 			#r18 stores the current letter
	ldw 	r22, (r16) 			#r22 stores the current number
	beq 	r18, r0, return
	addi 	r17, r17, 1 		#point to the next letter
	addi 	r16, r16, 4 		#point to the next number
	addi 	r4, r22, 0

	beq 	r18, r20, Octal		#if (r18 == 'O') Octal()
	beq 	r18, r19, Decimal	#else if (r18 == 'D') Decimal()
	
	#else Hex()
	
Hex: 
	call	printHex
	br 		parse

Octal:
	call	printOct
	br 		parse

Decimal:
	call 	printDec
	br 		parse
	
	
return: 
	
	#Restoring all Callee saved registers to their original values
	ldw 	ra,(sp)
	ldw 	r4, 4(sp)
	ldw 	r17, 8(sp)
	ldw 	r18, 12(sp)
	ldw 	r19, 16(sp)
	ldw 	r20, 20(sp)
	ldw 	r21, 24(sp)	
	ldw 	r22, 28(sp)
	ldw 	r23, 32(sp)
	ldw 	r16, 36(sp)
	ldw 	r5, 40(sp) 
	ldw 	r6, 44(sp)
	ldw 	r7, 48(sp)
	addi	 sp, sp, 52
	
	ret