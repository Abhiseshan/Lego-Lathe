// ---------------------------------------------------------------------
// Copyright (c) 2007 by University of Toronto ECE 243 development team 
// ---------------------------------------------------------------------
//
// Major Functions:	Two modules included: zExtend, sExtend
//						zExtend: extends input to eight bits with zero's
//								 (zero extended)
//						sExtend: extends input to eight bits with the
//								 first bit of the input (sign extended)
// 
// Input(s):		zExtend/sExtend
//						in: modifiable input size of any value under
//							eight bits
//
// Output(s):		zExtend
//						out: an eight-bit output which extends the input
//							 value with zero's (zero extended)
//					sExtend
//						out: an eight-bit output which entends the input
//							 value with either one's or zero's based on
//							 the first bit input (sign extended)
//
// Parameter(s):	zExtend/sExtend
//						n: modifiable variable which changes input
//						   data size
//
// ---------------------------------------------------------------------

module zExtend(in, out);
	parameter n = 3; // a parameter which detemines input size
	input [n-1:0] in;
	output [7:0] out;
	
	assign out[7:n] = 0;
	assign out[n-1:0] = in;
endmodule

module sExtend(in, out);
	parameter n = 3; // a parameter which detemines input size
	input [n-1:0] in;
	output [7:0] out;

	assign out = {{(8-n){in[n-1]}},in};
endmodule