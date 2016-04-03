; this is a sample program that demonstrates
; all possible instructions

; Create constant 3A = 1D*2
		ori		$1d
		shiftl	r1,1

		add		r2,r1
		add		r3,r2
		add		r0,r2
		sub		r1,r2
		ori		$15
lbl1		nand		r0,r1
		shiftl	r0,1
		shiftr	r3,2
		store		r1,(r2)
		load		r0,(r2)
		bz		lbl2
		bnz		lbl1

lbl2		org		15

