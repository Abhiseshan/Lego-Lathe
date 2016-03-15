# Print ten in octal, hexadecimal, and decimal
# Use the following C functions:
#     printHex ( int ) ;
#     printOct ( int ) ;
#     printDec ( int ) ;

.global main

main:
# ...

	movei r4,10
	call printOct

	movei r4,10
	call  printHex

	movei r4,10
	call printDec

  ret	# Make sure this returns to main's caller

