`timescale 1ns / 100ps
////////////////////////////////////
// File: multicycle_tb.v
// Multicycle processor testbench
// R.Willenberg
// Oct 5, 2012
////////////////////////////////////


module multicycle_tb;

	wire	[6:0] HEX0, HEX1, HEX2, HEX3;
	wire	[6:0] HEX4, HEX5;
	wire	[9:0] LEDR;

	wire	[1:0] KEY;
	reg	[3:0] SW;
	
	reg reset; // active-low
	reg clock;

	multicycle DUT(
					SW, KEY, HEX0, HEX1, HEX2, HEX3,
					HEX4, HEX5, LEDR
					);
	
	initial begin
		clock = 1'b0;
		reset = 1'b1; 
		SW = 4'h0;
		#41
		reset = 1'b0; 
	end
	
	always #10 clock = ~clock;

	assign	KEY[1] = clock;
	assign	KEY[0] =  ~reset; // KEY is active high

endmodule
