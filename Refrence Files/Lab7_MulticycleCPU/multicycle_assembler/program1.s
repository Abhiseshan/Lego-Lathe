; this is just a simple loop that counts from 10 to 0

0	ori 	10    ; load 10 into r1
1  	add	r3,r1
2	sub	r1,r1
3	ori		1     ; load 1 into r1
4loop	sub	r3,r1
5	bnz		loop
6	add		r2,r1
7	ori 	-7
8	db %01001100
