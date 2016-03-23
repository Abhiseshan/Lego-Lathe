`timescale 1 ps / 1 ps

module mux2to1_2bit (
	data0x,
	data1x,
	sel,
	result);

	input	[1:0]  data0x;
	input	[1:0]  data1x;
	input	  sel;
	output	[1:0]  result;

	assign result = sel ? data1x : data0x;

endmodule

