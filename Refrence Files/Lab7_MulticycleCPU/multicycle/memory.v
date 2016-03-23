// Copyright (C) 1991-2007 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.

module memory(
	wren,
	clock,
	MemRead,
	address,
	data,
	q
);

input	wren;
input	clock;
input	MemRead;
input	[7:0] address;
input	[7:0] data;
output	[7:0] q;

wire	SYNTHESIZED_WIRE_0;
wire	[0:7] SYNTHESIZED_WIRE_1;
wire	[7:0] SYNTHESIZED_WIRE_2;

assign	SYNTHESIZED_WIRE_1 = 0;




DataMemory	b2v_inst(.wren(wren),
.clock(SYNTHESIZED_WIRE_0),.address(address),.data(data),.q(SYNTHESIZED_WIRE_2));
assign	SYNTHESIZED_WIRE_0 =  ~clock;

mux2to1_8bit	b2v_inst3(.sel(MemRead),
.data0x(SYNTHESIZED_WIRE_1),.data1x(SYNTHESIZED_WIRE_2),.result(q));


endmodule
