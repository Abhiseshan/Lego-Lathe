// ---------------------------------------------------------------------
// Copyright (c) 2007 by University of Toronto ECE 243 development team 
// ---------------------------------------------------------------------
//
// Major Functions:	Two modules included: HEX, HEXs
//
//					HEX:	decode a four-bit input value into
//							7-segment HEX display signals (0 to F)
//					HEXs:	decode three 8-bit inputs to six 7-segment
//							HEX display signals
//
// Input(s):		HEX
//						 in: 4-bit input (HEX: 0 to F)
//					HEXs
//						 in0 - in2: four 8-bit input (HEX: 00 to FF)
//
// Output(s):		HEX/HEXs
//						 out: seven-segment display decoded value(s) 
//
// ---------------------------------------------------------------------


module HEXs
(
input [7:0] in0, in1, in2,
output [6:0] out0, out1, out2, out3, out4, out5
);

HEX hex0 ( in0[7:4], out1 );
HEX hex1 ( in0[3:0], out0 );
HEX hex2 ( in1[7:4], out3 );
HEX hex3 ( in1[3:0], out2 );
HEX hex4 ( in2[7:4], out5 );
HEX hex5 ( in2[3:0], out4 );

endmodule

module HEX (in, out);
input 	[3:0] in;
output 	[6:0] out;

reg [6:0] out;

always @(in)
begin
	case (in)
		0: out = 7'b1000000;
		1: out = 7'b1111001;
		2: out = 7'b0100100;
		3: out = 7'b0110000;
		4: out = 7'b0011001;
		5: out = 7'b0010010;
		6: out = 7'b0000010;
		7: out = 7'b1111000;
		8: out = 7'b0000000;
		9: out = 7'b0010000;
		10: out = 7'b0001000;
		11: out = 7'b0000011;
		12: out = 7'b1000110;
		13: out = 7'b0100001;
		14: out = 7'b0000110;
		15: out = 7'b0001110;
	endcase
end

endmodule
