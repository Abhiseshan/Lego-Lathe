// ---------------------------------------------------------------------
// Copyright (c) 2007 by University of Toronto ECE 243 development team 
// ---------------------------------------------------------------------
//	   	 	  											 	  	   	 		
// Major Functions:	Mathematical Operator which calculates two inputs.
//					This operator performs five operations:	i) addition,
//					ii) subtraction, iii) oring, iv) nand, v) shift
// 
// Input(s):		1. in1: first eight-bit input data to be operated
//					2. in2: second eight-bit input data to be operated
//					3. ALUOp: select signal indicates operation to be
//							  performed
//
// Output(s):		1. out:	output value after performing mathematical
//							operation
//					2. N: a single bit indicates whether an output is
//						  negative or non-negative
//					3. Z: a single bit indicates whether an output is
//						  zero or non-zero
//
// ---------------------------------------------------------------------

module ALU (in1, in2, out, ALUOp, N, Z);

// ------------------------ PORT declaration ------------------------ //
input [7:0] in1, in2;
input [2:0] ALUOp;
output [7:0] out;
output N, Z;

// ------------------------- Registers/Wires ------------------------ //
reg [7:0] tmp_out;

// -------------------------- ALU Operation ------------------------- //
// ALUOp encoding:													  //
//  000 = addition, 001 = subtraction, 010 = OR,					  //
//  011 = NAND, and 100 = Shift										  //
// ------------------------------------------------------------------ //
always @(*)
begin
	if (ALUOp == 0) begin
		tmp_out = in1 + in2;
	end	else if (ALUOp == 1) begin
		tmp_out = in1 - in2;
	end	else if (ALUOp == 2) begin
		tmp_out = in1 | in2;
	end	else if (ALUOp == 3) begin
		tmp_out = ~(in1 & in2);
	end	else if (ALUOp == 4) begin
		if (in2[2] == 1)
			tmp_out = in1 << in2[1:0];
		else
			tmp_out = in1 >> in2[1:0];
	end	else begin
		tmp_out = 0;
	end
end

// Assign output and condition flags
assign out = tmp_out;
assign N = out[7];
assign Z = (out == 8'b0);

endmodule 			 	 		           	 		 			 	  
                   
