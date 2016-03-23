// ---------------------------------------------------------------------
// Copyright (c) 2007 by University of Toronto ECE 243 development team 
// ---------------------------------------------------------------------
//	   	 	  											 	  	   	 		
// Major Functions:	a simple processor which operates basic mathematical
//					operations as follow:
//					(1)loading, (2)storing, (3)adding, (4)subtracting,
//					(5)shifting, (6)oring, (7)branch if zero,
//					(8)branch if not zero, (9)branch if positive zero
//					 
// Input(s):		1. KEY0(reset): clear all values from registers,
//									reset flags condition, and reset
//									control FSM
//					2. KEY1(clock): manual clock controls FSM and all
//									synchronous components at every
//									positive clock edge
//
//
// Output(s):		1. HEX Display: display registers value r3 to r0
//									in hexadecimal format
//
//					** For more details, please refer to the document
//					   provided with this implementation
//
// ---------------------------------------------------------------------

module multicycle
(
SW, KEY, HEX0, HEX1, HEX2, HEX3,
HEX4, HEX5, LEDR
);

// ------------------------ PORT declaration ------------------------ //
input	[1:0] KEY;
input [3:0] SW;
output	[6:0] HEX0, HEX1, HEX2, HEX3;
output	[6:0] HEX4, HEX5;
output reg	[9:0] LEDR;

// ------------------------- Registers/Wires ------------------------ //
wire	clock, reset;
wire	IRLoad, MDRLoad, MemRead, MemWrite, PCWrite, RegIn, AddrSel, MemDirSel;
wire	ALU1, ALUOutWrite, FlagWrite, OpABLoad, OpASel, RFWrite;
wire	[7:0] OpBwire, PCwire, OpAwire, RFout1wire, RFout2wire, MemDirWire;
wire	[7:0] ALU1wire, ALU2wire, ALUwire, ALUOut, MDRwire, MEMwire;
wire	[7:0] IR, SE4wire, ZE5wire, ZE3wire, AddrWire, RegWire;
wire	[7:0] reg0, reg1, reg2, reg3;
wire	[7:0] constant;
wire	[2:0] ALUOp, ALU2;
wire	[1:0] OpA_in;
wire	Nwire, Zwire;
reg		N, Z;

// ------------------------ Input Assignment ------------------------ //
assign	clock = KEY[1];
assign	reset =  ~KEY[0]; // KEY is active high

FSM		Control(
	.reset(reset),.clock(clock),.N(N),.Z(Z),.instr(IR[3:0]),
	.PCwrite(PCWrite),.AddrSel(AddrSel),.MemRead(MemRead),.MemWrite(MemWrite),
	.IRload(IRLoad),.OpASel(OpASel),.MDRload(MDRLoad),.OpABLoad(OpABLoad),
	.ALU1(ALU1),.ALUOutWrite(ALUOutWrite),.RFWrite(RFWrite),.RegIn(RegIn),
	.FlagWrite(FlagWrite),.ALU2(ALU2),.ALUop(ALUOp),.MemDirSel(MemDirSel)
);

memory	DataMem(
	.MemRead(MemRead),.wren(MemWrite),.clock(clock),
	.address(AddrWire),.data(OpAwire),.q(MEMwire)
);

ALU		ALU(
	.in1(ALU1wire),.in2(ALU2wire),.out(ALUwire),
	.ALUOp(ALUOp),.N(Nwire),.Z(Zwire)
);

RF		RF_block(
	.clock(clock),.reset(reset),.RFWrite(RFWrite),
	.dataw(RegWire),.reg1(OpA_in),.reg2(IR[5:4]),
	.regw(OpA_in),.data1(RFout1wire),.data2(RFout2wire),
	.r0(reg0),.r1(reg1),.r2(reg2),.r3(reg3)
);

register_8bit	IR_reg(
	.clock(clock),.aclr(reset),.enable(IRLoad),
	.data(MEMwire),.q(IR)
);

register_8bit	MDR_reg(
	.clock(clock),.aclr(reset),.enable(MDRLoad),
	.data(MEMwire),.q(MDRwire)
);

register_8bit	PC(
	.clock(clock),.aclr(reset),.enable(PCWrite),
	.data(ALUwire),.q(PCwire)
);

register_8bit	OpA(
	.clock(clock),.aclr(reset),.enable(OpABLoad),
	.data(RFout1wire),.q(OpAwire)
);

register_8bit	OpB(
	.clock(clock),.aclr(reset),.enable(OpABLoad),
	.data(RFout2wire),.q(OpBwire)
);

register_8bit	ALUOut_reg(
	.clock(clock),.aclr(reset),.enable(ALUOutWrite),
	.data(ALUwire),.q(ALUOut)
);

mux2to1_2bit		OpASel_mux(
	.data0x(IR[7:6]),.data1x(constant[1:0]),
	.sel(OpASel),.result(OpA_in)
);

mux2to1_8bit 		AddrSel_mux(
	.data0x(OpBwire),.data1x(PCwire),
	.sel(AddrSel),.result(MemDirWire)
);

mux2to1_8bit 		MemDirSel_mux(
	.data0x(MemDirWire),.data1x(MDRwire),
	.sel(MemDirSel),.result(AddrWire)
);

mux2to1_8bit 		RegMux(
	.data0x(ALUOut),.data1x(MDRwire),
	.sel(RegIn),.result(RegWire)
);

mux2to1_8bit 		ALU1_mux(
	.data0x(PCwire),.data1x(OpAwire),
	.sel(ALU1),.result(ALU1wire)
);

mux5to1_8bit 		ALU2_mux(
	.data0x(OpBwire),.data1x(constant),.data2x(SE4wire),
	.data3x(ZE5wire),.data4x(ZE3wire),.sel(ALU2),.result(ALU2wire)
);

sExtend		SE4(.in(IR[7:4]),.out(SE4wire));
zExtend		ZE3(.in(IR[5:3]),.out(ZE3wire));
zExtend		ZE5(.in(IR[7:3]),.out(ZE5wire));
// define parameter for the data size to be extended
defparam	SE4.n = 4;
defparam	ZE3.n = 3;
defparam	ZE5.n = 5;

always@(posedge clock or posedge reset)
begin
if (reset)
	begin
	N <= 0;
	Z <= 0;
	end
else
if (FlagWrite)
	begin
	N <= Nwire;
	Z <= Zwire;
	end
end

// ------------------------ Assign Constant 1 ----------------------- //
assign	constant = 1;

// ----------------- Debugging LEDs selected by SW[3:2] ------------- //
always @(*) begin
	LEDR = 10'h0;	// Avoid inferred latches.
	case (SW[3:2]) 
		2'h0: begin
			LEDR[9] = PCWrite;
			LEDR[8] = AddrSel;
			LEDR[7] = MemRead;
			LEDR[6] = MemWrite;
			LEDR[5] = IRLoad;
			LEDR[4] = OpASel;
			LEDR[3] = MDRLoad;
			LEDR[2] = OpABLoad;
			LEDR[1] = RFWrite;
			LEDR[0] = RegIn;		
		end
		2'h1: begin
			LEDR[1] = N;
			LEDR[0] = Z;
		end
		2'h2: begin		
			LEDR[9:7] = ALU2[2:0];
			LEDR[5] = ALU1;
			LEDR[4:2] = ALUOp[2:0];
			LEDR[1] = ALUOutWrite;
			LEDR[0] = FlagWrite;
		end
		default: ;
	endcase
end

// --------------- HEX displays selected by SW[1:0] ---------------- //
reg [7:0] DisplayVal0, DisplayVal1, DisplayVal2;
always @(*) begin
	{DisplayVal2, DisplayVal1, DisplayVal0} = 24'h0;	// Avoid inferred latches
	case (SW[1:0])
		2'h2: {DisplayVal2, DisplayVal1, DisplayVal0} = {ALU1wire, ALU2wire, ALUwire};
		2'h1: {DisplayVal2, DisplayVal1, DisplayVal0} = {PCwire, reg2, reg3};
		2'h0:	{DisplayVal2, DisplayVal1, DisplayVal0} = {PCwire, reg0, reg1};
		default: ;
	endcase
end

HEXs	HEX_display(
	.in0(DisplayVal0),.in1(DisplayVal1),.in2(DisplayVal2),
	.out0(HEX0),.out1(HEX1),.out2(HEX2),.out3(HEX3),
	.out4(HEX4),.out5(HEX5)
);

endmodule 			 	 		           	 		 			 	  
                   
