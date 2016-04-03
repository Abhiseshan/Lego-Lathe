/*********
 * A simple program which integrate C and Assembly codes. The main program
 * calls the printn function, written in assembly. The printn function then
 * determines the number format (i.e. octal, hex, or decimal) and prints it
 * through JTAG UART terminal.
 *
 * (1) assembly function(s)
 *     printn ( char * , ... ) ;
 * (2) C function(s)
 *     printHex ( int ) ;
 *     printOct ( int ) ;
 *     printDec ( int ) ;
 * 
 * July 21 2007: Supakorn Komthong
 *
 * July 25 2007: Peter Yiannacouras
 *********/

void printn ( char *, ... );		// Function prototype for an assembly function

void checkRegisters1 ();
void checkRegisters2 ();

int main ( )
{

	char* text = "DDDDDDDOOOOOOOHHHHHHH";
 
	checkRegisters1();          // Debugging: Save callee-saved registers to memory. All red LEDs should turn on.
 	printn (
	  text, 10, 11, 12, 13, 14, 15, 16,
		10, 11, 12, 13, 14, 15, 16,
		10, 11, 12, 13, 14, 15, 16
	);
	checkRegisters2();          // Debugging: Check that callee-saved registers did not change. Red LEDs turn on if mismatch.

	return 0;
}

// The code below is used to verify that registers that should be preserved are indeed preserved.

unsigned int regs[10];
void checkRegisters1()
{
	// Record current value of callee-saved registers. 
	// Assumes main routine won't change these before calling printn(), which is currently true.
	__asm__ (
		".word 67407108, 73734468, 75497540, 79696004, 85120644, 89046084, 92277892, 96469572\n"
		"movia r2, regs\n"
		"stw r16,0x0(r2)\n"
		"stw r17,0x4(r2)\n"
		"stw r18,0x8(r2)\n"
		"stw r19,0xc(r2)\n"
		"stw r20,0x10(r2)\n"
		"stw r21,0x14(r2)\n"
		"stw r22,0x18(r2)\n"
		"stw r23,0x1c(r2)\n"
		"stw sp,0x20(r2)\n"
		"stw fp,0x24(r2)\n"
		"movia r2, 0xff200000\n"
		"nor r3, r0, r0\n"
		"stwio r3, 0(r2)\n"
	);
	return;
}
void checkRegisters2()
{
	// Check that the callee-saved registers still have the same value as before.
	// Turn on red LED for each mismatched register. There are 10 registers checked.
	__asm__ (
		"movia r2, regs\n"

		"ldw r3, 0x0(r2)\n" "cmpne r4, r3, r16\n"
		"ldw r3, 0x4(r2)\n" "cmpne r3, r3, r17\n" "slli r3, r3, 1\n" "or r4, r4, r3\n"
		"ldw r3, 0x8(r2)\n" "cmpne r3, r3, r18\n" "slli r3, r3, 2\n" "or r4, r4, r3\n"
		"ldw r3, 0xc(r2)\n" "cmpne r3, r3, r19\n" "slli r3, r3, 3\n" "or r4, r4, r3\n"
		"ldw r3, 0x10(r2)\n" "cmpne r3, r3, r20\n" "slli r3, r3, 4\n" "or r4, r4, r3\n"
		"ldw r3, 0x14(r2)\n" "cmpne r3, r3, r21\n" "slli r3, r3, 5\n" "or r4, r4, r3\n"
		"ldw r3, 0x18(r2)\n" "cmpne r3, r3, r22\n" "slli r3, r3, 6\n" "or r4, r4, r3\n"
		"ldw r3, 0x1c(r2)\n" "cmpne r3, r3, r23\n" "slli r3, r3, 7\n" "or r4, r4, r3\n"
		"ldw r3, 0x20(r2)\n" "cmpne r3, r3, sp\n" "slli r3, r3, 8\n" "or r4, r4, r3\n"
		"ldw r3, 0x24(r2)\n" "cmpne r3, r3, fp\n" "slli r3, r3, 9\n" "or r4, r4, r3\n"
		"movia r2, 0xff200000\n"	// Red LEDs
		"stwio r4, 0(r2)\n"
		);
	return;
}
