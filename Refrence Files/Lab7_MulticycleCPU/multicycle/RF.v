// ---------------------------------------------------------------------
// Copyright (c) 2007 by University of Toronto ECE 243 development team 
// ---------------------------------------------------------------------
//
// Major Functions:	Registers memory stores four 8-bits data
//					 
// Input(s):		1. reset: 	clear registers value to zero
//					2. clock: 	data written at positive clock edge
//					3. reg1:	indicate which register will be 
//					   			output through (output)data1
//					4. reg2:	indicate which register will be 
//								output through (output)data2
//					5. regw:	indicate which register will be 
//								overwritten with the data from
//								(input)dataw
//					6. dataw:	input data to be written into register
//					7. RFWrite:	write enable single, allow the data to
//								be written at the positive edge
//
// Output(s):		1. data1:	data output of the register (input)reg1
//					2. data2:	data output of the register (input)reg2
//					3. r0-r3:	data stored by register0 to register3
//
// ---------------------------------------------------------------------

module RF
(
clock, reg1, reg2, regw,
dataw, RFWrite, data1, data2,
r0, r1, r2, r3, reset
);

// ------------------------ PORT declaration ------------------------ //
input clock;
input [1:0] reg1, reg2, regw;
input [7:0] dataw;
input RFWrite;
input reset;
output [7:0] data1, data2;
output [7:0] r0, r1, r2, r3;

// ------------------------- Registers/Wires ------------------------ //
reg [7:0] r0, r1, r2, r3;
reg [7:0] data1_tmp, data2_tmp;

// Asynchronously read data from two registers
always @(*)
begin
	case (reg1)
		0: data1_tmp = r0;
		1: data1_tmp = r1;
		2: data1_tmp = r2;
		3: data1_tmp = r3;
	endcase
	case (reg2)
		0: data2_tmp = r0;
		1: data2_tmp = r1;
		2: data2_tmp = r2;
		3: data2_tmp = r3;
	endcase
end

// Synchronously write data to the register file;
// also supports an asynchronous reset, which clears all registers
always @(posedge clock or posedge reset)
begin
	if (reset) begin
		r0 = 0;
		r1 = 0;
		r2 = 0;
		r3 = 0;
	end	else begin
		if (RFWrite) begin
			case (regw)
				0: r0 = dataw;
				1: r1 = dataw;
				2: r2 = dataw;
				3: r3 = dataw;
			endcase
		end
	end
end

// Assign temporary values to the outputs
assign data1 = data1_tmp;
assign data2 = data2_tmp;

endmodule
