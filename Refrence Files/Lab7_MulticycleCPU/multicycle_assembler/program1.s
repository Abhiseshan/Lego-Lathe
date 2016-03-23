; this is just a simple loop that counts from 10 to 0

	ori 	10    ; load 10 into r1
	add	r3,r1
	sub	r1,r1
	ori		1     ; load 1 into r1
loop	sub	r3,r1
	bnz		loop
	add		r2,r1
