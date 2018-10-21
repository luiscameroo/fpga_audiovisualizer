`timescale 1ns/1ns

module filterInput(
	clk,
	clkFreq,
	outAmpFreq,
	selectTone, 
	resetn, 
	start,
	newSample
	);
	

	input start, 
		  resetn,
		  clk;
	input [3:0]selectTone; 
	
	
	
	output [63:0]outAmpFreq;
	output [15:0]newSample;
	


	
	reg hold; 
	output reg clkFreq;
	reg [15:0]countFreq;
	reg [15:0]address; 
	
	
	RAMaccess RAM_inst(
		.clk(clk),
		.clkFreq(clkFreq),
		.address(address[13:0]),
		.selectTone(selectTone),
		.newSample(newSample)
		);
	
	accessFIR FIR_inst(
		.clk(clk),
		.clkFreq(clkFreq),
		.resetn(resetn),
		.start(start),
		.newSample(newSample), 
		.outAmpFreq(outAmpFreq)
		);
	
	always@(posedge clk)
	begin
		if(!resetn)
			hold <= 1;
		else if(start)
			hold <= 0; 
		else 
			hold <= hold; 
	end
			
	always@(posedge clk) 
	begin
		if(!resetn || hold)
		begin
			countFreq <= 0;
			clkFreq <= 0;
		end
		else if(countFreq == 16'b0000110000110101)// 5khz = 16'b0010011100010000)
		begin
			countFreq <= 0; 
			clkFreq <= 1; 
		end
		else 
		begin
			countFreq <= countFreq + 1; 
			clkFreq <= 0; 
		end
	end
	
	always@(posedge clkFreq)
	begin
		if(!resetn || hold)
			begin
			address <= 0; 
			end
		else if(address == 16'b0011111010000000)
			begin
			address <= 0;
			end
		else 	
			address <= address + 1;
	end
	


endmodule 


module firController(
	clk,
	resetn,
	ld_values,
	loaddone,
	shift,
	shiftdone,
	multiply,
	multiplydone, 
	send, 
	sentdone,
	rsignals, 
	rsignalsdone,
	ld_newsample,
	newsampleloaded, 
	start
	);
	
	input loaddone,
			shiftdone,
			multiplydone,
			sentdone,
			rsignalsdone,
			newsampleloaded, 
			start,
			clk,
			resetn;
	
	output reg multiply,
				  send, 
				  ld_values,
				  shift,
				  rsignals,
				  ld_newsample;
			
	reg [5:0] current_state, next_state; 
	localparam S_READY       = 5'd1,
				  S_SHIFT       = 5'd2,
				  S_MULTIPLY    = 5'd3,
				  S_SEND        = 5'd4,
				  S_RSIGNALS    = 5'd5,
				  S_WAIT        = 5'd6;
	
	always@(*)
	begin: state_table
		case(current_state)
			S_READY: next_state = (start && loaddone) ? S_SHIFT : S_READY;
			S_SHIFT: next_state = shiftdone ? S_RSIGNALS : S_SHIFT;
			S_RSIGNALS: next_state = rsignalsdone ? S_MULTIPLY : S_RSIGNALS; 
			S_MULTIPLY: next_state = multiplydone ? S_SEND : S_MULTIPLY;
			S_SEND : next_state = sentdone ?  S_WAIT : S_SEND;
		   S_WAIT : next_state = newsampleloaded ? S_SHIFT : S_WAIT;
			default : next_state = S_READY; 
		endcase
	end
	
	always@(*)
	begin: enable_signals
		multiply = 1'b0;
		send = 1'b0;
		ld_values = 1'b0;
		shift = 1'b0;
		rsignals = 1'b0;
		ld_newsample = 1'b0;
		case(current_state)
			S_READY: begin
				ld_values = 1'b1;
			end
			S_SHIFT: begin
				shift = 1'b1; 
			end
			S_MULTIPLY: begin
				multiply = 1'b1; 
			end
			S_SEND: begin
				send = 1'b1; 
			end
			S_RSIGNALS: begin
				rsignals = 1'b1; 
			end
			S_WAIT: begin
				ld_newsample = 1'b1;
			end
		endcase
	end
	
	always@(posedge clk)
	begin: state_FFs
		if(!resetn)
			current_state <= S_READY;
		else
			current_state <= next_state;
	end
	
endmodule

module firFilter(
	clk,
	clkFreq, 
	resetn,
	shift,
	shiftdone, 
	multiply,
	multiplydone,
	send,
	sentdone,
	ld_values,
	loaddone,
	rsignals,
	rsignalsdone,
	ld_newsample, 
	newsampleloaded, 
	newSample,
	outputReg
	);

	input clk, 
			clkFreq, 
			resetn,
			multiply,
			send,
			ld_values,
			shift,
			rsignals,
			ld_newsample;
	
	input [15:0]newSample; 
	
	output reg [63:0]outputReg;
	output reg multiplydone,
				  rsignalsdone,
				  newsampleloaded, 
				  shiftdone,
				  sentdone,
				  loaddone; 
				  
	
	reg [15:0]sampleReg[31:0];
	reg [15:0]coeff[31:0];
   reg [15:0]inputSample; 
	reg [63:0]accumulate;
	reg [5:0]countMultiply;
	
	parameter coeff0 = 16'b0;
	parameter coeff1 = 16'b0;
	parameter coeff2 = 16'b0;
	parameter coeff3 = 16'b0;
	parameter coeff4 = 16'b0;
	parameter coeff5 = 16'b0;
	parameter coeff6 = 16'b0;
	parameter coeff7 = 16'b0;
	parameter coeff8 = 16'b0;
	parameter coeff9 = 16'b0;
	parameter coeff10 = 16'b0;
	parameter coeff11 = 16'b0;
	parameter coeff12 = 16'b0;
	parameter coeff13 = 16'b0;
	parameter coeff14 = 16'b0;
	parameter coeff15 = 16'b0;
	parameter coeff16 = 16'b0;
	parameter coeff17 = 16'b0;
	parameter coeff18 = 16'b0;
	parameter coeff19 = 16'b0;
	parameter coeff20 = 16'b0;
	parameter coeff21 = 16'b0;
	parameter coeff22 = 16'b0;
	parameter coeff23 = 16'b0;
	parameter coeff24 = 16'b0;
	parameter coeff25 = 16'b0;
	parameter coeff26 = 16'b0;
	parameter coeff27 = 16'b0;
	parameter coeff28 = 16'b0;
	parameter coeff29 = 16'b0;
	parameter coeff30 = 16'b0;
	parameter coeff31 = 16'b0;
		
	
	
	always@(posedge clk)
	begin	
		if(!resetn)
		begin
			sampleReg[31] <= 16'b0;
			sampleReg[30] <= 16'b0;
			sampleReg[29] <= 16'b0;
			sampleReg[28] <= 16'b0;
			sampleReg[27] <= 16'b0;
			sampleReg[26] <= 16'b0;
			sampleReg[25] <= 16'b0;
			sampleReg[24] <= 16'b0;
			sampleReg[23] <= 16'b0;
			sampleReg[22] <= 16'b0;
			sampleReg[21] <= 16'b0;
			sampleReg[20] <= 16'b0;
			sampleReg[19] <= 16'b0;
			sampleReg[18] <= 16'b0;
			sampleReg[17] <= 16'b0;
			sampleReg[16] <= 16'b0;
			sampleReg[15] <= 16'b0;
			sampleReg[14] <= 16'b0;
			sampleReg[13] <= 16'b0;
			sampleReg[12] <= 16'b0;
			sampleReg[11] <= 16'b0;
			sampleReg[10] <= 16'b0;
			sampleReg[9] <= 16'b0;
			sampleReg[8] <= 16'b0;
			sampleReg[7] <= 16'b0;
			sampleReg[6] <= 16'b0;
			sampleReg[5] <= 16'b0;
			sampleReg[4] <= 16'b0;
			sampleReg[3] <= 16'b0;
			sampleReg[2] <= 16'b0;
			sampleReg[1] <= 16'b0;
			sampleReg[0] <= 16'b0;
			outputReg <= 64'b0;
			countMultiply <= 0;
			multiplydone <= 0;
			sentdone <= 0;
			accumulate <= 0;
			shiftdone <= 0;
			newsampleloaded <= 0;
			rsignalsdone <= 0;
		end
		else if(rsignals)
			begin
			countMultiply <= 0;
			multiplydone <= 0;
			sentdone <= 0;
			accumulate <= 0;
			shiftdone <= 0;
			loaddone <= 0; 
			newsampleloaded <= 0;
			rsignalsdone <= 1; 
			end
		else if(ld_values)
		begin
			coeff[0] <= coeff0;
			coeff[1] <= coeff1;
			coeff[2] <= coeff2;
			coeff[3] <= coeff3;
			coeff[4] <= coeff4;
			coeff[5] <= coeff5;
			coeff[6] <= coeff6;
			coeff[7] <= coeff7;
			coeff[8] <= coeff8;
			coeff[9] <= coeff9;
			coeff[10] <= coeff10;
			coeff[11] <= coeff11;
			coeff[12] <= coeff12;
			coeff[13] <= coeff13;
			coeff[14] <= coeff14;
			coeff[15] <= coeff15;
			coeff[16] <= coeff16;
			coeff[17] <= coeff17;
			coeff[18] <= coeff18;
			coeff[19] <= coeff19;
			coeff[20] <= coeff20;
			coeff[21] <= coeff21;
			coeff[22] <= coeff22;
			coeff[23] <= coeff23;
			coeff[24] <= coeff24;
			coeff[25] <= coeff25;
			coeff[26] <= coeff26;
			coeff[27] <= coeff27;
			coeff[28] <= coeff28;
			coeff[29] <= coeff29;
			coeff[30] <= coeff30;
			coeff[31] <= coeff31;
			outputReg <= 64'b0; 
			loaddone <= 1;
			countMultiply <= 0;
			multiplydone <= 0;
			sentdone <= 0;
			accumulate <= 0;
			shiftdone <= 0;
			rsignalsdone <= 0; 
			newsampleloaded <= 0;

		end
		
		else if(ld_newsample && clkFreq)
		begin
			newsampleloaded <= 1;
			inputSample <= newSample; 
		end 
		
		else if(multiply)
		begin	
			case({coeff[countMultiply][15], sampleReg[countMultiply][15]})
				2'b00:begin
					accumulate <= accumulate + {32'b0, (coeff[countMultiply] * sampleReg[countMultiply])};
				end			
	
				2'b01:begin
					if(~(|coeff[countMultiply]))
						accumulate <= accumulate; 
					else
					accumulate <= accumulate + {32'b11111111111111111111111111111111, (~(coeff[countMultiply] *((~sampleReg[countMultiply])+1))+1)};
				end
	
				2'b10:begin
					if(~(|sampleReg[countMultiply]))
						accumulate <= accumulate;
					else
					accumulate <= accumulate + {32'b11111111111111111111111111111111,(~(((~coeff[countMultiply])+1) * sampleReg[countMultiply])+1)};			
				end
	
				2'b11:begin
					accumulate <= accumulate + {32'b0, (((~coeff[countMultiply])+1)*((~sampleReg[countMultiply])+1))};
				end
			endcase 
			
			if(countMultiply == 6'b011111)
				multiplydone <= 1; 
			else
				countMultiply <= countMultiply + 1; 
		end
		
		else if(send)
		begin
			outputReg <= accumulate[63] ? (~(accumulate)+1) : accumulate;
			sentdone <= 1;
		end
		
		else if(shift) 
		begin
			sampleReg[31] <= sampleReg[30];
			sampleReg[30] <= sampleReg[29];
			sampleReg[29] <= sampleReg[28];
			sampleReg[28] <= sampleReg[27];
			sampleReg[27] <= sampleReg[26];
			sampleReg[26] <= sampleReg[25];
			sampleReg[25] <= sampleReg[24];
			sampleReg[24] <= sampleReg[23];
			sampleReg[23] <= sampleReg[22];
			sampleReg[22] <= sampleReg[21];
			sampleReg[21] <= sampleReg[20];
			sampleReg[20] <= sampleReg[19];
			sampleReg[19] <= sampleReg[18];
			sampleReg[18] <= sampleReg[17];
			sampleReg[17] <= sampleReg[16];
			sampleReg[16] <= sampleReg[15];
			sampleReg[15] <= sampleReg[14];
			sampleReg[14] <= sampleReg[13];
			sampleReg[13] <= sampleReg[12];
			sampleReg[12] <= sampleReg[11];
			sampleReg[11] <= sampleReg[10];
			sampleReg[10] <= sampleReg[9];
			sampleReg[9] <= sampleReg[8];
			sampleReg[8] <= sampleReg[7];
			sampleReg[7] <= sampleReg[6];
			sampleReg[6] <= sampleReg[5];
			sampleReg[5] <= sampleReg[4];
			sampleReg[4] <= sampleReg[3];
			sampleReg[3] <= sampleReg[2];
			sampleReg[2] <= sampleReg[1];
			sampleReg[1] <= sampleReg[0];
			sampleReg[0] <= inputSample; 
			shiftdone <= 1; 
			rsignalsdone <= 0;
		end
		
		else
		begin 
			sampleReg[31] <= sampleReg[31];
			sampleReg[30] <= sampleReg[30];
			sampleReg[29] <= sampleReg[29];
			sampleReg[28] <= sampleReg[28];
			sampleReg[27] <= sampleReg[27];
			sampleReg[26] <= sampleReg[26];
			sampleReg[25] <= sampleReg[25];
			sampleReg[24] <= sampleReg[24];
			sampleReg[23] <= sampleReg[23];
			sampleReg[22] <= sampleReg[22];
			sampleReg[21] <= sampleReg[21];
			sampleReg[20] <= sampleReg[20];
			sampleReg[19] <= sampleReg[19];
			sampleReg[18] <= sampleReg[18];
			sampleReg[17] <= sampleReg[17];
			sampleReg[16] <= sampleReg[16];
			sampleReg[15] <= sampleReg[15];
			sampleReg[14] <= sampleReg[14];
			sampleReg[13] <= sampleReg[13];
			sampleReg[12] <= sampleReg[12];
			sampleReg[11] <= sampleReg[11];
			sampleReg[10] <= sampleReg[10];
			sampleReg[9] <= sampleReg[9];
			sampleReg[8] <= sampleReg[8];
			sampleReg[7] <= sampleReg[7];
			sampleReg[6] <= sampleReg[6];
			sampleReg[5] <= sampleReg[5];
			sampleReg[4] <= sampleReg[4];
			sampleReg[3] <= sampleReg[3];
			sampleReg[2] <= sampleReg[2];
			sampleReg[1] <= sampleReg[1];
			sampleReg[0] <= sampleReg[0];	
			outputReg <= outputReg;
		end	
	end
endmodule	

module RAMaccess(
	clk,
	clkFreq,
	address,
	selectTone,
	newSample
	);
	
	input clk, clkFreq;
	input [3:0]selectTone;
	input [13:0]address;

	output reg [15:0]newSample; 
	
	localparam s_tone1 = 4'b0001,
				  s_tone2 = 4'b0010,
				  s_tone3 = 4'b0011,
				  s_tone4 = 4'b0100,
				  s_tone5 = 4'b0101,
				  s_tone6 = 4'b0110,
				  s_tone7 = 4'b0111,
				  s_tone8 = 4'b1000; 
				  
	wire [15:0]tone1;
	wire [15:0]tone2;
	wire [15:0]tone3;
	wire [15:0]tone4;
	wire [15:0]tone5;
	wire [15:0]tone6;
	wire [15:0]tone7;
	wire [15:0]tone8;
	
	always@(posedge clk)
	begin
		case(selectTone)
			s_tone1: begin
				newSample <= tone1;
			end
			s_tone2: begin
				newSample <= tone2;
			end
			s_tone3: begin
				newSample <= tone3;
			end
			s_tone4: begin
				newSample <= tone4;
			end
			s_tone5: begin
				newSample <= tone5;
			end
			s_tone6: begin
				newSample <= tone6;
			end
			s_tone7: begin
				newSample <= tone7;
			end
			s_tone8: begin
				newSample <= tone8;
			end
			default: begin
				newSample <= 16'b0;
			end
		endcase
	end
	
	Tone10RAM Tone1(
			.address(address),
			.clock(clkFreq),
			.data (16'b0),
			.wren ( 1'b0),
			.q (tone1)
			);
	
	Tone400RAM Tone2(
			.address(address),
			.clock(clkFreq),
			.data (16'b0),
			.wren ( 1'b0),
			.q (tone2)
			);	
			
	Tone800RAM Tone3(
			.address(address),
			.clock(clkFreq),
			.data (16'b0),
			.wren ( 1'b0),
			.q (tone3)
			);
			
	Tone1200RAM Tone4(
			.address(address),
			.clock(clkFreq),
			.data (16'b0),
			.wren ( 1'b0),
			.q (tone4)
			);
			
	Tone1600RAM Tone5(
			.address(address),
			.clock(clkFreq),
			.data (16'b0),
			.wren ( 1'b0),
			.q (tone5)
			);
			
	Tone2000RAM Tone6(
			.address(address),
			.clock(clkFreq),
			.data (16'b0),
			.wren ( 1'b0),
			.q (tone6)
			);
			
	Tone2400RAM Tone7(
			.address(address),
			.clock(clkFreq),
			.data (16'b0),
			.wren ( 1'b0),
			.q (tone7)
			);
			
	Tone3000RAM Tone8(
			.address(address),
			.clock(clkFreq),
			.data (16'b0),
			.wren ( 1'b0),
			.q (tone8)
			);
	
	
	
	
	
endmodule

module accessFIR(
	clk,
	clkFreq,
	resetn,
	start,
	newSample, 
	outAmpFreq,
	firOutWire1,
	firOutWire2,
	firOutWire3,
	firOutWire4,
	firOutWire5,
	firOutWire6,
	firOutWire7,
	firOutWire8,
	avg1,
	avg2, 
	avg3,
	avg4, 
	avg5, 
	avg6, 
	avg7, 
	avg8
	);
	
	input clk, 
			clkFreq,
			resetn,
			start;
			
	input [15:0]newSample;
	output reg[23:0]outAmpFreq;
	
	 
	wire [16:0]loaddone;
	wire [16:0]shiftdone; 
	wire [16:0]multiplydone;
	wire [16:0]sentdone; 
	wire [16:0]rsignalsdone;
	wire [16:0]newsampleloaded; 
		
	wire ld_values, 
		  shift, 
		  multiply, 
		  send,  
		  rsignals,
		  ld_newsample; 
		  
	/////////////////////////	 
	output  [63:0]firOutWire1;
	output  [63:0]firOutWire2;
	output  [63:0]firOutWire3;
	output  [63:0]firOutWire4;
	output  [63:0]firOutWire5;
	output  [63:0]firOutWire6;
	output  [63:0]firOutWire7;
	output  [63:0]firOutWire8;

	output [63:0]avg1;
	output [63:0]avg2;
	output [63:0]avg3;
	output [63:0]avg4;
	output [63:0]avg5;
	output [63:0]avg6;
	output [63:0]avg7;
	output [63:0]avg8;	
	//////////////////////////	  
//
//	wire  [63:0]firOutWire1;
//	wire  [63:0]firOutWire2;
//	wire  [63:0]firOutWire3;
//	wire  [63:0]firOutWire4;
//	wire  [63:0]firOutWire5;
//	wire  [63:0]firOutWire6;
//	wire  [63:0]firOutWire7;
//	wire  [63:0]firOutWire8;
//	
//	wire [63:0]avg1;
//	wire [63:0]avg2;
//	wire [63:0]avg3;
//	wire [63:0]avg4;
//	wire [63:0]avg5;
//	wire [63:0]avg6;
//	wire [63:0]avg7;
//	wire [63:0]avg8;	
		 
	assign loaddone[0] = &loaddone[16:1];
	assign shiftdone[0] = &shiftdone[16:1];
	assign multiplydone[0] = &multiplydone[16:1];
	assign sentdone[0] = &sentdone[16:1];
	assign rsignalsdone[0] = &rsignalsdone[16:1];
	assign newsampleloaded[0] = &newsampleloaded[16:1];

	
	firController controller(
	.clk(clk),
	.resetn(resetn),
	.ld_values(ld_values),
	.loaddone(loaddone[0]),
	.shift(shift),
	.shiftdone(shiftdone[0]),
	.multiply(multiply),
	.multiplydone(multiplydone[0]), 
	.send(send), 
	.sentdone(sentdone[0]),
	.rsignals(rsignals),
	.rsignalsdone(rsignalsdone[0]),
	.ld_newsample(ld_newsample),
	.newsampleloaded(newsampleloaded[0]),
	.start(start) 
	);
	
	
	firFilter FIR1(
	.clk(clk),
	.clkFreq(clkFreq),
	.resetn(resetn),
	.shift(shift),
	.shiftdone(shiftdone[1]), 
	.multiply(multiply),
	.multiplydone(multiplydone[1]),
	.send(send),
	.sentdone(sentdone[1]),
	.ld_values(ld_values),
	.loaddone(loaddone[1]),
	.rsignals(rsignals),
	.rsignalsdone(rsignalsdone[1]),
	.ld_newsample(ld_newsample),
	.newsampleloaded(newsampleloaded[1]),
	.newSample(newSample),
	.outputReg(firOutWire1)
	);
	defparam FIR1.coeff0 = 16'b0000000111011011;
	defparam FIR1.coeff1 = 16'b0000001000010011;
	defparam FIR1.coeff2 = 16'b0000001010111000;
	defparam FIR1.coeff3 = 16'b0000001111000101;
	defparam FIR1.coeff4 = 16'b0000010100101101;
	defparam FIR1.coeff5 = 16'b0000011011100011;
	defparam FIR1.coeff6 = 16'b0000100011010100;
	defparam FIR1.coeff7 = 16'b0000101011101100;
	defparam FIR1.coeff8 = 16'b0000110100010110;
	defparam FIR1.coeff9 = 16'b0000111100111001;
	defparam FIR1.coeff10 = 16'b0001000101000001;
	defparam FIR1.coeff11 = 16'b0001001100010111;
	defparam FIR1.coeff12 = 16'b0001010010101001;
	defparam FIR1.coeff13 = 16'b0001010111100110;
	defparam FIR1.coeff14 = 16'b0001011011000000;
	defparam FIR1.coeff15 = 16'b0001011100110000;
	defparam FIR1.coeff16 = 16'b0001011100110000;
	defparam FIR1.coeff17 = 16'b0001011011000000;
	defparam FIR1.coeff18 = 16'b0001010111100110;
	defparam FIR1.coeff19 = 16'b0001010010101001;
	defparam FIR1.coeff20 = 16'b0001001100010111;
	defparam FIR1.coeff21 = 16'b0001000101000001;
	defparam FIR1.coeff22 = 16'b0000111100111001;
	defparam FIR1.coeff23 = 16'b0000110100010110;
	defparam FIR1.coeff24 = 16'b0000101011101100;
	defparam FIR1.coeff25 = 16'b0000100011010100;
	defparam FIR1.coeff26 = 16'b0000011011100011;
	defparam FIR1.coeff27 = 16'b0000010100101101;
	defparam FIR1.coeff28 = 16'b0000001111000101;
	defparam FIR1.coeff29 = 16'b0000001010111000;
	defparam FIR1.coeff30 = 16'b0000001000010011;
	defparam FIR1.coeff31 = 16'b0000000111011011;
	
//	defparam FIR1.coeff0 = 16'b0000000101111110;
//	defparam FIR1.coeff1 = 16'b0000000110111001;
//	defparam FIR1.coeff2 = 16'b0000001001010101;
//	defparam FIR1.coeff3 = 16'b0000001101010100;
//	defparam FIR1.coeff4 = 16'b0000010010110001;
//	defparam FIR1.coeff5 = 16'b0000011001100011;
//	defparam FIR1.coeff6 = 16'b0000100001011101;
//	defparam FIR1.coeff7 = 16'b0000101010001100;
//	defparam FIR1.coeff8 = 16'b0000110011011000;
//	defparam FIR1.coeff9 = 16'b0000111100101010;
//	defparam FIR1.coeff10 = 16'b0001000101100111;
//	defparam FIR1.coeff11 = 16'b0001001101110100;
//	defparam FIR1.coeff12 = 16'b0001010100111010;
//	defparam FIR1.coeff13 = 16'b0001011010100010;
//	defparam FIR1.coeff14 = 16'b0001011110011101;
//	defparam FIR1.coeff15 = 16'b0001100000011101;
//	defparam FIR1.coeff16 = 16'b0001100000011101;
//	defparam FIR1.coeff17 = 16'b0001011110011101;
//	defparam FIR1.coeff18 = 16'b0001011010100010;
//	defparam FIR1.coeff19 = 16'b0001010100111010;
//	defparam FIR1.coeff20 = 16'b0001001101110100;
//	defparam FIR1.coeff21 = 16'b0001000101100111;
//	defparam FIR1.coeff22 = 16'b0000111100101010;
//	defparam FIR1.coeff23 = 16'b0000110011011000;
//	defparam FIR1.coeff24 = 16'b0000101010001100;
//	defparam FIR1.coeff25 = 16'b0000100001011101;
//	defparam FIR1.coeff26 = 16'b0000011001100011;
//	defparam FIR1.coeff27 = 16'b0000010010110001;
//	defparam FIR1.coeff28 = 16'b0000001101010100;
//	defparam FIR1.coeff29 = 16'b0000001001010101;
//	defparam FIR1.coeff30 = 16'b0000000110111001;
//	defparam FIR1.coeff31 = 16'b0000000101111110;
	//Max FIR1: 0010 0101 1111 0010 0000 1100 1110 0000; 636,620,000	
	movingAverage average1(
	.clk(clk),
	.clkFreq(clkFreq),
	.resetn(resetn),
	.shift(shift),
	.shiftdone(shiftdone[9]), 
	.multiply(multiply),
	.multiplydone(multiplydone[9]),
	.send(send),
	.sentdone(sentdone[9]),
	.ld_values(ld_values),
	.loaddone(loaddone[9]),
	.rsignals(rsignals),
	.rsignalsdone(rsignalsdone[9]),
	.ld_newsample(ld_newsample),
	.newsampleloaded(newsampleloaded[9]),
	.newSample(firOutWire1),
	.outputReg(avg1)
	);
	
	firFilter FIR2(
	.clk(clk),
	.clkFreq(clkFreq),
	.resetn(resetn),
	.shift(shift),
	.shiftdone(shiftdone[2]), 
	.multiply(multiply),
	.multiplydone(multiplydone[2]),
	.send(send),
	.sentdone(sentdone[2]),
	.ld_values(ld_values),
	.loaddone(loaddone[2]),
	.rsignals(rsignals),
	.rsignalsdone(rsignalsdone[2]),
	.ld_newsample(ld_newsample),
	.newsampleloaded(newsampleloaded[2]),
	.newSample(newSample),
	.outputReg(firOutWire2)
	);
	defparam FIR2.coeff0 = 16'b1111110101101100;
	defparam FIR2.coeff1 = 16'b1111110110001010;
	defparam FIR2.coeff2 = 16'b1111110101100111;
	defparam FIR2.coeff3 = 16'b1111110101011101;
	defparam FIR2.coeff4 = 16'b1111110111001011;
	defparam FIR2.coeff5 = 16'b1111111100000011;
	defparam FIR2.coeff6 = 16'b0000000101000100;
	defparam FIR2.coeff7 = 16'b0000010010101001;
	defparam FIR2.coeff8 = 16'b0000100100100111;
	defparam FIR2.coeff9 = 16'b0000111010001010;
	defparam FIR2.coeff10 = 16'b0001010001111011;
	defparam FIR2.coeff11 = 16'b0001101010001000;
	defparam FIR2.coeff12 = 16'b0010000000110010;
	defparam FIR2.coeff13 = 16'b0010010011111001;
	defparam FIR2.coeff14 = 16'b0010100001101110;
	defparam FIR2.coeff15 = 16'b0010100001101110;
	defparam FIR2.coeff16 = 16'b0010101000111111;
	defparam FIR2.coeff17 = 16'b0010100001101110;
	defparam FIR2.coeff18 = 16'b0010010011111001;
	defparam FIR2.coeff19 = 16'b0010000000110010;
	defparam FIR2.coeff20 = 16'b0001101010001000;
	defparam FIR2.coeff21 = 16'b0001010001111011;
	defparam FIR2.coeff22 = 16'b0000111010001010;
	defparam FIR2.coeff23 = 16'b0000100100100111;
	defparam FIR2.coeff24 = 16'b0000010010101001;
	defparam FIR2.coeff25 = 16'b0000000101000100;
	defparam FIR2.coeff26 = 16'b1111111100000011;
	defparam FIR2.coeff27 = 16'b1111110111001011;
	defparam FIR2.coeff28 = 16'b1111110101011101;
	defparam FIR2.coeff29 = 16'b1111110101100111;
	defparam FIR2.coeff30 = 16'b1111110110001010;
	defparam FIR2.coeff31 = 16'b1111110101101100;
	
	
//	defparam FIR2.coeff0 = 16'b1111110111111001;
//	defparam FIR2.coeff1 = 16'b1111111000000000;
//	defparam FIR2.coeff2 = 16'b1111110111010010;
//	defparam FIR2.coeff3 = 16'b1111110110111010;
//	defparam FIR2.coeff4 = 16'b1111111000001011;
//	defparam FIR2.coeff5 = 16'b1111111100011011;
//	defparam FIR2.coeff6 = 16'b0000000100101100;
//	defparam FIR2.coeff7 = 16'b0000010001100110;
//	defparam FIR2.coeff8 = 16'b0000100011001001;
//	defparam FIR2.coeff9 = 16'b0000111000101001;
//	defparam FIR2.coeff10 = 16'b0001010000110010;
//	defparam FIR2.coeff11 = 16'b0001101001110000;
//	defparam FIR2.coeff12 = 16'b0010000001011000;
//	defparam FIR2.coeff13 = 16'b0010010101011111;
//	defparam FIR2.coeff14 = 16'b0010100100001001;
//	defparam FIR2.coeff15 = 16'b0010101011110111;
//	defparam FIR2.coeff16 = 16'b0010101011110111;
//	defparam FIR2.coeff17 = 16'b0010100100001001;
//	defparam FIR2.coeff18 = 16'b0010010101011111;
//	defparam FIR2.coeff19 = 16'b0010000001011000;
//	defparam FIR2.coeff20 = 16'b0001101001110000;
//	defparam FIR2.coeff21 = 16'b0001010000110010;
//	defparam FIR2.coeff22 = 16'b0000111000101001;
//	defparam FIR2.coeff23 = 16'b0000100011001001;
//	defparam FIR2.coeff24 = 16'b0000010001100110;
//	defparam FIR2.coeff25 = 16'b0000000100101100;
//	defparam FIR2.coeff26 = 16'b1111111100011011;
//	defparam FIR2.coeff27 = 16'b1111111000001011;
//	defparam FIR2.coeff28 = 16'b1111110110111010;
//	defparam FIR2.coeff29 = 16'b1111110111010010;
//	defparam FIR2.coeff30 = 16'b1111111000000000;
//	defparam FIR2.coeff31 = 16'b1111110111111001;
	//Max Fir2 = 32'b 0010 1010 0100 0011 0011 1110 1001 0000
	movingAverage average2(
	.clk(clk),
	.clkFreq(clkFreq),
	.resetn(resetn),
	.shift(shift),
	.shiftdone(shiftdone[10]), 
	.multiply(multiply),
	.multiplydone(multiplydone[10]),
	.send(send),
	.sentdone(sentdone[10]),
	.ld_values(ld_values),
	.loaddone(loaddone[10]),
	.rsignals(rsignals),
	.rsignalsdone(rsignalsdone[10]),
	.ld_newsample(ld_newsample),
	.newsampleloaded(newsampleloaded[10]),
	.newSample(firOutWire2),
	.outputReg(avg2)
	);
	
	
	firFilter FIR3(
	.clk(clk),
	.clkFreq(clkFreq),
	.resetn(resetn),
	.shift(shift),
	.shiftdone(shiftdone[3]), 
	.multiply(multiply),
	.multiplydone(multiplydone[3]),
	.send(send),
	.sentdone(sentdone[3]),
	.ld_values(ld_values),
	.loaddone(loaddone[3]),
	.rsignals(rsignals),
	.rsignalsdone(rsignalsdone[3]),
	.ld_newsample(ld_newsample),
	.newsampleloaded(newsampleloaded[3]),
	.newSample(newSample),
	.outputReg(firOutWire3)
	);
	defparam FIR3.coeff0 = 16'b0000000010010101;
	defparam FIR3.coeff1 = 16'b1111111101011001;
	defparam FIR3.coeff2 = 16'b1111110110000100;
	defparam FIR3.coeff3 = 16'b1111101010100100;
	defparam FIR3.coeff4 = 16'b1111011010111001;
	defparam FIR3.coeff5 = 16'b1111001001010010;
	defparam FIR3.coeff6 = 16'b1110111001110110;
	defparam FIR3.coeff7 = 16'b1110110001101101;
	defparam FIR3.coeff8 = 16'b1110110101100100;
	defparam FIR3.coeff9 = 16'b1111001000011010;
	defparam FIR3.coeff10 = 16'b1111101010010010;
	defparam FIR3.coeff11 = 16'b0000011000000010;
	defparam FIR3.coeff12 = 16'b0001001011011101;
	defparam FIR3.coeff13 = 16'b0001111100100100;
	defparam FIR3.coeff14 = 16'b0010100011000101;
	defparam FIR3.coeff15 = 16'b0010111000001111;
	defparam FIR3.coeff16 = 16'b0010111000001111;
	defparam FIR3.coeff17 = 16'b0010100011000101;
	defparam FIR3.coeff18 = 16'b0001111100100100;
	defparam FIR3.coeff19 = 16'b0001001011011101;
	defparam FIR3.coeff20 = 16'b0000011000000010;
	defparam FIR3.coeff21 = 16'b1111101010010010;
	defparam FIR3.coeff22 = 16'b1111001000011010;
	defparam FIR3.coeff23 = 16'b1110110101100100;
	defparam FIR3.coeff24 = 16'b1110110001101101;
	defparam FIR3.coeff25 = 16'b1110111001110110;
	defparam FIR3.coeff26 = 16'b1111001001010010;
	defparam FIR3.coeff27 = 16'b1111011010111001;
	defparam FIR3.coeff28 = 16'b1111101010100100;
	defparam FIR3.coeff29 = 16'b1111110110000100;
	defparam FIR3.coeff30 = 16'b1111111101011001;
	defparam FIR3.coeff31 = 16'b0000000010010101;	
	
//	defparam FIR3.coeff0 = 16'b0000000001111000;
//	defparam FIR3.coeff1 = 16'b1111111101110101;
//	defparam FIR3.coeff2 = 16'b1111110111011111;
//	defparam FIR3.coeff3 = 16'b1111101101000101;
//	defparam FIR3.coeff4 = 16'b1111011110011001;
//	defparam FIR3.coeff5 = 16'b1111001101010000;
//	defparam FIR3.coeff6 = 16'b1110111101100011;
//	defparam FIR3.coeff7 = 16'b1110110100011011;
//	defparam FIR3.coeff8 = 16'b1110110110111100;
//	defparam FIR3.coeff9 = 16'b1111001000101000;
//	defparam FIR3.coeff10 = 16'b1111101010000111;
//	defparam FIR3.coeff11 = 16'b0000011000011111;
//	defparam FIR3.coeff12 = 16'b0001001101100001;
//	defparam FIR3.coeff13 = 16'b0010000000110000;
//	defparam FIR3.coeff14 = 16'b0010101001010000;
//	defparam FIR3.coeff15 = 16'b0010111111100110;
//	defparam FIR3.coeff16 = 16'b0010111111100110;
//	defparam FIR3.coeff17 = 16'b0010101001010000;
//	defparam FIR3.coeff18 = 16'b0010000000110000;
//	defparam FIR3.coeff19 = 16'b0001001101100001;
//	defparam FIR3.coeff20 = 16'b0000011000011111;
//	defparam FIR3.coeff21 = 16'b1111101010000111;
//	defparam FIR3.coeff22 = 16'b1111001000101000;
//	defparam FIR3.coeff23 = 16'b1110110110111100;
//	defparam FIR3.coeff24 = 16'b1110110100011011;
//	defparam FIR3.coeff25 = 16'b1110111101100011;
//	defparam FIR3.coeff26 = 16'b1111001101010000;
//	defparam FIR3.coeff27 = 16'b1111011110011001;
//	defparam FIR3.coeff28 = 16'b1111101101000101;
//	defparam FIR3.coeff29 = 16'b1111110111011111;
//	defparam FIR3.coeff30 = 16'b1111111101110101;
//	defparam FIR3.coeff31 = 16'b0000000001111000;
	//Max Fir3 = 32'b0000 1001 0001 0110 0101 1010 1110 0000; 152,460,000
	movingAverage average3(
	.clk(clk),
	.clkFreq(clkFreq),
	.resetn(resetn),
	.shift(shift),
	.shiftdone(shiftdone[11]), 
	.multiply(multiply),
	.multiplydone(multiplydone[11]),
	.send(send),
	.sentdone(sentdone[11]),
	.ld_values(ld_values),
	.loaddone(loaddone[11]),
	.rsignals(rsignals),
	.rsignalsdone(rsignalsdone[11]),
	.ld_newsample(ld_newsample),
	.newsampleloaded(newsampleloaded[11]),
	.newSample(firOutWire3),
	.outputReg(avg3)
	);
	
	
	firFilter FIR4(
	.clk(clk),
	.clkFreq(clkFreq),
	.resetn(resetn),
	.shift(shift),
	.shiftdone(shiftdone[4]), 
	.multiply(multiply),
	.multiplydone(multiplydone[4]),
	.send(send),
	.sentdone(sentdone[4]),
	.ld_values(ld_values),
	.loaddone(loaddone[4]),
	.rsignals(rsignals),
	.rsignalsdone(rsignalsdone[4]),
	.ld_newsample(ld_newsample),
	.newsampleloaded(newsampleloaded[4]),
	.newSample(newSample),
	.outputReg(firOutWire4)
	);
	defparam FIR4.coeff0 = 16'b0000000111101110;
	defparam FIR4.coeff1 = 16'b0000001110000110;
	defparam FIR4.coeff2 = 16'b0000010101100111;
	defparam FIR4.coeff3 = 16'b0000011011110000;
	defparam FIR4.coeff4 = 16'b0000011010110011;
	defparam FIR4.coeff5 = 16'b0000001100110100;
	defparam FIR4.coeff6 = 16'b1111101111100101;
	defparam FIR4.coeff7 = 16'b1111000111011110;
	defparam FIR4.coeff8 = 16'b1110011111101011;
	defparam FIR4.coeff9 = 16'b1110000111000101;
	defparam FIR4.coeff10 = 16'b1110001010110010;
	defparam FIR4.coeff11 = 16'b1110110000100001;
	defparam FIR4.coeff12 = 16'b1111110011000101;
	defparam FIR4.coeff13 = 16'b0001000010110001;
	defparam FIR4.coeff14 = 16'b0010001001110110;
	defparam FIR4.coeff15 = 16'b0010110011101001;
	defparam FIR4.coeff16 = 16'b0010110011101001;
	defparam FIR4.coeff17 = 16'b0010001001110110;
	defparam FIR4.coeff18 = 16'b0001000010110001;
	defparam FIR4.coeff19 = 16'b1111110011000101;
	defparam FIR4.coeff20 = 16'b1110110000100001;
	defparam FIR4.coeff21 = 16'b1110001010110010;
	defparam FIR4.coeff22 = 16'b1110000111000101;
	defparam FIR4.coeff23 = 16'b1110011111101011;
	defparam FIR4.coeff24 = 16'b1111000111011110;
	defparam FIR4.coeff25 = 16'b1111101111100101;
	defparam FIR4.coeff26 = 16'b0000001100110100;
	defparam FIR4.coeff27 = 16'b0000011010110011;
	defparam FIR4.coeff28 = 16'b0000011011110000;
	defparam FIR4.coeff29 = 16'b0000010101100111;
	defparam FIR4.coeff30 = 16'b0000001110000110;
	defparam FIR4.coeff31 = 16'b0000000111101110;
	
//	defparam FIR4.coeff0 = 16'b0000000110001110;
//	defparam FIR4.coeff1 = 16'b0000001011101110;
//	defparam FIR4.coeff2 = 16'b0000010010100011;
//	defparam FIR4.coeff3 = 16'b0000011000100001;
//	defparam FIR4.coeff4 = 16'b0000011000010011;
//	defparam FIR4.coeff5 = 16'b0000001011111001;
//	defparam FIR4.coeff6 = 16'b1111110000011011;
//	defparam FIR4.coeff7 = 16'b1111001001011000;
//	defparam FIR4.coeff8 = 16'b1110100001010110;
//	defparam FIR4.coeff9 = 16'b1110000111011010;
//	defparam FIR4.coeff10 = 16'b1110001001101010;
//	defparam FIR4.coeff11 = 16'b1110101110111011;
//	defparam FIR4.coeff12 = 16'b1111110010101110;
//	defparam FIR4.coeff13 = 16'b0001000101000110;
//	defparam FIR4.coeff14 = 16'b0010001111001110;
//	defparam FIR4.coeff15 = 16'b0010111011000010;
//	defparam FIR4.coeff16 = 16'b0010111011000010;
//	defparam FIR4.coeff17 = 16'b0010001111001110;
//	defparam FIR4.coeff18 = 16'b0001000101000110;
//	defparam FIR4.coeff19 = 16'b1111110010101110;
//	defparam FIR4.coeff20 = 16'b1110101110111011;
//	defparam FIR4.coeff21 = 16'b1110001001101010;
//	defparam FIR4.coeff22 = 16'b1110000111011010;
//	defparam FIR4.coeff23 = 16'b1110100001010110;
//	defparam FIR4.coeff24 = 16'b1111001001011000;
//	defparam FIR4.coeff25 = 16'b1111110000011011;
//	defparam FIR4.coeff26 = 16'b0000001011111001;
//	defparam FIR4.coeff27 = 16'b0000011000010011;
//	defparam FIR4.coeff28 = 16'b0000011000100001;
//	defparam FIR4.coeff29 = 16'b0000010010100011;
//	defparam FIR4.coeff30 = 16'b0000001011101110;
//	defparam FIR4.coeff31 = 16'b0000000110001110;
	//Max Fir3: 1111 1111 1111 0100 0000 1111 1111 0000, -1,314,800
	movingAverage average4(
	.clk(clk),
	.clkFreq(clkFreq),
	.resetn(resetn),
	.shift(shift),
	.shiftdone(shiftdone[12]), 
	.multiply(multiply),
	.multiplydone(multiplydone[12]),
	.send(send),
	.sentdone(sentdone[12]),
	.ld_values(ld_values),
	.loaddone(loaddone[12]),
	.rsignals(rsignals),
	.rsignalsdone(rsignalsdone[12]),
	.ld_newsample(ld_newsample),
	.newsampleloaded(newsampleloaded[12]),
	.newSample(firOutWire4),
	.outputReg(avg4)
	);
	
	firFilter FIR5(
	.clk(clk),
	.clkFreq(clkFreq),
	.resetn(resetn),
	.shift(shift),
	.shiftdone(shiftdone[5]), 
	.multiply(multiply),
	.multiplydone(multiplydone[5]),
	.send(send),
	.sentdone(sentdone[5]),
	.ld_values(ld_values),
	.loaddone(loaddone[5]),
	.rsignals(rsignals),
	.rsignalsdone(rsignalsdone[5]),
	.ld_newsample(ld_newsample),
	.newsampleloaded(newsampleloaded[5]),
	.newSample(newSample),
	.outputReg(firOutWire5)
	);
	defparam FIR5.coeff0 = 16'b1111110001111111;
	defparam FIR5.coeff1 = 16'b1111110000010110;
	defparam FIR5.coeff2 = 16'b1111110011010011;
	defparam FIR5.coeff3 = 16'b0000000000000000;
	defparam FIR5.coeff4 = 16'b0000011000001011;
	defparam FIR5.coeff5 = 16'b0000110100000001;
	defparam FIR5.coeff6 = 16'b0001000010101100;
	defparam FIR5.coeff7 = 16'b0000110010111111;
	defparam FIR5.coeff8 = 16'b0000000000000000;
	defparam FIR5.coeff9 = 16'b1110111000111100;
	defparam FIR5.coeff10 = 16'b1101111101101100;
	defparam FIR5.coeff11 = 16'b1101101111110100;
	defparam FIR5.coeff12 = 16'b1110011111100100;
	defparam FIR5.coeff13 = 16'b0000000000000000;
	defparam FIR5.coeff14 = 16'b0001101010001101;
	defparam FIR5.coeff15 = 16'b0010101111001000;
	defparam FIR5.coeff16 = 16'b0010101111001000;
	defparam FIR5.coeff17 = 16'b0001101010001101;
	defparam FIR5.coeff18 = 16'b0000000000000000;
	defparam FIR5.coeff19 = 16'b1110011111100100;
	defparam FIR5.coeff20 = 16'b1101101111110100;
	defparam FIR5.coeff21 = 16'b1101111101101100;
	defparam FIR5.coeff22 = 16'b1110111000111100;
	defparam FIR5.coeff23 = 16'b0000000000000000;
	defparam FIR5.coeff24 = 16'b0000110010111111;
	defparam FIR5.coeff25 = 16'b0001000010101100;
	defparam FIR5.coeff26 = 16'b0000110100000001;
	defparam FIR5.coeff27 = 16'b0000011000001011;
	defparam FIR5.coeff28 = 16'b0000000000000000;
	defparam FIR5.coeff29 = 16'b1111110011010011;
	defparam FIR5.coeff30 = 16'b1111110000010110;
	defparam FIR5.coeff31 = 16'b1111110001111111;
	
//	defparam FIR5.coeff0 = 16'b1111110100101110;
//	defparam FIR5.coeff1 = 16'b1111110010111101;
//	defparam FIR5.coeff2 = 16'b1111110101000110;
//	defparam FIR5.coeff3 = 16'b0000000000000000;
//	defparam FIR5.coeff4 = 16'b0000010101111100;
//	defparam FIR5.coeff5 = 16'b0000110000010101;
//	defparam FIR5.coeff6 = 16'b0000111111010010;
//	defparam FIR5.coeff7 = 16'b0000110001010100;
//	defparam FIR5.coeff8 = 16'b0000000000000000;
//	defparam FIR5.coeff9 = 16'b1110111001000101;
//	defparam FIR5.coeff10 = 16'b1101111100010101;
//	defparam FIR5.coeff11 = 16'b1101101100110100;
//	defparam FIR5.coeff12 = 16'b1110011100110000;
//	defparam FIR5.coeff13 = 16'b0000000000000000;
//	defparam FIR5.coeff14 = 16'b0001101110011011;
//	defparam FIR5.coeff15 = 16'b0010110110011110;
//	defparam FIR5.coeff16 = 16'b0010110110011110;
//	defparam FIR5.coeff17 = 16'b0001101110011011;
//	defparam FIR5.coeff18 = 16'b0000000000000000;
//	defparam FIR5.coeff19 = 16'b1110011100110000;
//	defparam FIR5.coeff20 = 16'b1101101100110100;
//	defparam FIR5.coeff21 = 16'b1101111100010101;
//	defparam FIR5.coeff22 = 16'b1110111001000101;
//	defparam FIR5.coeff23 = 16'b0000000000000000;
//	defparam FIR5.coeff24 = 16'b0000110001010100;
//	defparam FIR5.coeff25 = 16'b0000111111010010;
//	defparam FIR5.coeff26 = 16'b0000110000010101;
//	defparam FIR5.coeff27 = 16'b0000010101111100;
//	defparam FIR5.coeff28 = 16'b0000000000000000;
//	defparam FIR5.coeff29 = 16'b1111110101000110;
//	defparam FIR5.coeff30 = 16'b1111110010111101;
//	defparam FIR5.coeff31 = 16'b1111110100101110;
	//Max Fir4: 1111 1111 1110 1001 1101 1100 0000 0000; -6,937,600
	movingAverage average5(
	.clk(clk),
	.clkFreq(clkFreq),
	.resetn(resetn),
	.shift(shift),
	.shiftdone(shiftdone[13]), 
	.multiply(multiply),
	.multiplydone(multiplydone[13]),
	.send(send),
	.sentdone(sentdone[13]),
	.ld_values(ld_values),
	.loaddone(loaddone[13]),
	.rsignals(rsignals),
	.rsignalsdone(rsignalsdone[13]),
	.ld_newsample(ld_newsample),
	.newsampleloaded(newsampleloaded[13]),
	.newSample(firOutWire5),
	.outputReg(avg5)
	);
	
	firFilter FIR6(
	.clk(clk),
	.clkFreq(clkFreq),
	.resetn(resetn),
	.shift(shift),
	.shiftdone(shiftdone[6]), 
	.multiply(multiply),
	.multiplydone(multiplydone[6]),
	.send(send),
	.sentdone(sentdone[6]),
	.ld_values(ld_values),
	.loaddone(loaddone[6]),
	.rsignals(rsignals),
	.rsignalsdone(rsignalsdone[6]),
	.ld_newsample(ld_newsample),
	.newsampleloaded(newsampleloaded[6]),
	.newSample(newSample),
	.outputReg(firOutWire6)
	);
	defparam FIR6.coeff0 = 16'b0000001101101101;
	defparam FIR6.coeff1 = 16'b0000000110010110;
	defparam FIR6.coeff2 = 16'b1111110111101011;
	defparam FIR6.coeff3 = 16'b1111100100001010;
	defparam FIR6.coeff4 = 16'b1111011001110001;
	defparam FIR6.coeff5 = 16'b1111011001110001;
	defparam FIR6.coeff6 = 16'b0000011011000001;
	defparam FIR6.coeff7 = 16'b0001010000101011;
	defparam FIR6.coeff8 = 16'b0001100000101001;
	defparam FIR6.coeff9 = 16'b0000101110100101;
	defparam FIR6.coeff10 = 16'b1111001011001110;
	defparam FIR6.coeff11 = 16'b1101110011000001;
	defparam FIR6.coeff12 = 16'b1101100111011011;
	defparam FIR6.coeff13 = 16'b1110111101000001;
	defparam FIR6.coeff14 = 16'b0001000101100110;
	defparam FIR6.coeff15 = 16'b0010101011010000;
	defparam FIR6.coeff16 = 16'b0010101011010000;
	defparam FIR6.coeff17 = 16'b0001000101100110;
	defparam FIR6.coeff18 = 16'b1110111101000001;
	defparam FIR6.coeff19 = 16'b1101100111011011;
	defparam FIR6.coeff20 = 16'b1101110011000001;
	defparam FIR6.coeff21 = 16'b1111001011001110;
	defparam FIR6.coeff22 = 16'b0000101110100101;
	defparam FIR6.coeff23 = 16'b0001100000101001;
	defparam FIR6.coeff24 = 16'b0001010000101011;
	defparam FIR6.coeff25 = 16'b0000011011000001;
	defparam FIR6.coeff26 = 16'b1111101010111100;
	defparam FIR6.coeff27 = 16'b1111011001110001;
	defparam FIR6.coeff28 = 16'b1111100100001010;
	defparam FIR6.coeff29 = 16'b1111110111101011;
	defparam FIR6.coeff30 = 16'b0000000110010110;
	defparam FIR6.coeff31 = 16'b0000001101101101;
	
//	defparam FIR6.coeff0 = 16'b0000001011000001;
//	defparam FIR6.coeff1 = 16'b0000000101010010;
//	defparam FIR6.coeff2 = 16'b1111111000110111;
//	defparam FIR6.coeff3 = 16'b1111100111011011;
//	defparam FIR6.coeff4 = 16'b1111011101010110;
//	defparam FIR6.coeff5 = 16'b1111101100011101;
//	defparam FIR6.coeff6 = 16'b0000011001100110;
//	defparam FIR6.coeff7 = 16'b0001001101111011;
//	defparam FIR6.coeff8 = 16'b0001011110111011;
//	defparam FIR6.coeff9 = 16'b0000101110011011;
//	defparam FIR6.coeff10 = 16'b1111001010101111;
//	defparam FIR6.coeff11 = 16'b1101110000010001;
//	defparam FIR6.coeff12 = 16'b1101100011001010;
//	defparam FIR6.coeff13 = 16'b1110111010101110;
//	defparam FIR6.coeff14 = 16'b0001001000010001;
//	defparam FIR6.coeff15 = 16'b0010110010001100;
//	defparam FIR6.coeff16 = 16'b0010110010001100;
//	defparam FIR6.coeff17 = 16'b0001001000010001;
//	defparam FIR6.coeff18 = 16'b1110111010101110;
//	defparam FIR6.coeff19 = 16'b1101100011001010;
//	defparam FIR6.coeff20 = 16'b1101110000010001;
//	defparam FIR6.coeff21 = 16'b1111001010101111;
//	defparam FIR6.coeff22 = 16'b0000101110011011;
//	defparam FIR6.coeff23 = 16'b0001011110111011;
//	defparam FIR6.coeff24 = 16'b0001001101111011;
//	defparam FIR6.coeff25 = 16'b0000011001100110;
//	defparam FIR6.coeff26 = 16'b1111101100011101;
//	defparam FIR6.coeff27 = 16'b1111011101010110;
//	defparam FIR6.coeff28 = 16'b1111100111011011;
//	defparam FIR6.coeff29 = 16'b1111111000110111;
//	defparam FIR6.coeff30 = 16'b0000000101010010;
//	defparam FIR6.coeff31 = 16'b0000001011000001;
	//Max FIR6: 0000 0000 0001 1111 1111 0111 1001 1000; 2,095,000	
	movingAverage average6(
	.clk(clk),
	.clkFreq(clkFreq),
	.resetn(resetn),
	.shift(shift),
	.shiftdone(shiftdone[14]), 
	.multiply(multiply),
	.multiplydone(multiplydone[14]),
	.send(send),
	.sentdone(sentdone[14]),
	.ld_values(ld_values),
	.loaddone(loaddone[14]),
	.rsignals(rsignals),
	.rsignalsdone(rsignalsdone[14]),
	.ld_newsample(ld_newsample),
	.newsampleloaded(newsampleloaded[14]),
	.newSample(firOutWire6),
	.outputReg(avg6)
	);
	
	firFilter FIR7(
	.clk(clk),
	.clkFreq(clkFreq),
	.resetn(resetn),
	.shift(shift),
	.shiftdone(shiftdone[7]), 
	.multiply(multiply),
	.multiplydone(multiplydone[7]),
	.send(send),
	.sentdone(sentdone[7]),
	.ld_values(ld_values),
	.loaddone(loaddone[7]),
	.rsignals(rsignals),
	.rsignalsdone(rsignalsdone[7]),
	.ld_newsample(ld_newsample),
	.newsampleloaded(newsampleloaded[7]),
	.newSample(newSample),
	.outputReg(firOutWire7)
	);
	defparam FIR7.coeff0 = 16'b1111111001001111;
	defparam FIR7.coeff1 = 16'b0000000111100100;
	defparam FIR7.coeff2 = 16'b0000010101100111;
	defparam FIR7.coeff3 = 16'b0000010101011100;
	defparam FIR7.coeff4 = 16'b1111111001011111;
	defparam FIR7.coeff5 = 16'b1111001110101010;
	defparam FIR7.coeff6 = 16'b1111000000110000;
	defparam FIR7.coeff7 = 16'b1111110010010001;
	defparam FIR7.coeff8 = 16'b0001001010011001;
	defparam FIR7.coeff9 = 16'b0001111000111001;
	defparam FIR7.coeff10 = 16'b0000111110111110;
	defparam FIR7.coeff11 = 16'b1110111010010100;
	defparam FIR7.coeff12 = 16'b1101011011111100;
	defparam FIR7.coeff13 = 16'b1110000011100001;
	defparam FIR7.coeff14 = 16'b0000011100100111;
	defparam FIR7.coeff15 = 16'b0010100110000110;
	defparam FIR7.coeff16 = 16'b0010100110000110;
	defparam FIR7.coeff17 = 16'b0000011100100111;
	defparam FIR7.coeff18 = 16'b1110000011100001;
	defparam FIR7.coeff19 = 16'b1101011011111100;
	defparam FIR7.coeff20 = 16'b1110111010010100;
	defparam FIR7.coeff21 = 16'b0000111110111110;
	defparam FIR7.coeff22 = 16'b0001111000111001;
	defparam FIR7.coeff23 = 16'b0001001010011001;
	defparam FIR7.coeff24 = 16'b1111110010010001;
	defparam FIR7.coeff25 = 16'b1111000000110000;
	defparam FIR7.coeff26 = 16'b1111001110101010;
	defparam FIR7.coeff27 = 16'b1111111001011111;
	defparam FIR7.coeff28 = 16'b0000010101011100;
	defparam FIR7.coeff29 = 16'b0000010101100111;
	defparam FIR7.coeff30 = 16'b0000000111100100;
	defparam FIR7.coeff31 = 16'b1111111001001111;
//	defparam FIR7.coeff0 = 16'b1111111010100100;
//	defparam FIR7.coeff1 = 16'b0000000110010010;
//	defparam FIR7.coeff2 = 16'b0000010010100001;
//	defparam FIR7.coeff3 = 16'b0000010010111001;
//	defparam FIR7.coeff4 = 16'b1111111010000111;
//	defparam FIR7.coeff5 = 16'b1111010010010010;
//	defparam FIR7.coeff6 = 16'b1111000100001000;
//	defparam FIR7.coeff7 = 16'b1111110010110000;
//	defparam FIR7.coeff8 = 16'b0001001000111110;
//	defparam FIR7.coeff9 = 16'b0001111000010101;
//	defparam FIR7.coeff10 = 16'b0000111111011110;
//	defparam FIR7.coeff11 = 16'b1110111001000011;
//	defparam FIR7.coeff12 = 16'b1101010111100101;
//	defparam FIR7.coeff13 = 16'b1101111111011011;
//	defparam FIR7.coeff14 = 16'b0000011101101011;
//	defparam FIR7.coeff15 = 16'b0010101100101000;
//	defparam FIR7.coeff16 = 16'b0010101100101000;
//	defparam FIR7.coeff17 = 16'b0000011101101011;
//	defparam FIR7.coeff18 = 16'b1101111111011011;
//	defparam FIR7.coeff19 = 16'b1101010111100101;
//	defparam FIR7.coeff20 = 16'b1110111001000011;
//	defparam FIR7.coeff21 = 16'b0000111111011110;
//	defparam FIR7.coeff22 = 16'b0001111000010101;
//	defparam FIR7.coeff23 = 16'b0001001000111110;
//	defparam FIR7.coeff24 = 16'b1111110010110000;
//	defparam FIR7.coeff25 = 16'b1111000100001000;
//	defparam FIR7.coeff26 = 16'b1111010010010010;
//	defparam FIR7.coeff27 = 16'b1111111010000111;
//	defparam FIR7.coeff28 = 16'b0000010010111001;
//	defparam FIR7.coeff29 = 16'b0000010010100001;
//	defparam FIR7.coeff30 = 16'b0000000110010010;
//	defparam FIR7.coeff31 = 16'b1111111010100100;
	//Max FIR7: 0000 0011 0010 0011 0110 1011 0000; 3,290,800			
	movingAverage average7(
	.clk(clk),
	.clkFreq(clkFreq),
	.resetn(resetn),
	.shift(shift),
	.shiftdone(shiftdone[15]), 
	.multiply(multiply),
	.multiplydone(multiplydone[15]),
	.send(send),
	.sentdone(sentdone[15]),
	.ld_values(ld_values),
	.loaddone(loaddone[15]),
	.rsignals(rsignals),
	.rsignalsdone(rsignalsdone[15]),
	.ld_newsample(ld_newsample),
	.newsampleloaded(newsampleloaded[15]),
	.newSample(firOutWire7),
	.outputReg(avg7)
	);
	
	firFilter FIR8(
	.clk(clk),
	.clkFreq(clkFreq),
	.resetn(resetn),
	.shift(shift),
	.shiftdone(shiftdone[8]), 
	.multiply(multiply),
	.multiplydone(multiplydone[8]),
	.send(send),
	.sentdone(sentdone[8]),
	.ld_values(ld_values),
	.loaddone(loaddone[8]),
	.rsignals(rsignals),
	.rsignalsdone(rsignalsdone[8]),
	.ld_newsample(ld_newsample),
	.newsampleloaded(newsampleloaded[8]),
	.newSample(newSample),
	.outputReg(firOutWire8)
	);
	
   defparam FIR8.coeff0 = 16'b0000001100010101;
	defparam FIR8.coeff1 = 16'b1111111100110001;
	defparam FIR8.coeff2 = 16'b1111101010101010;
	defparam FIR8.coeff3 = 16'b1111101111010000;
	defparam FIR8.coeff4 = 16'b0000010111000000;
	defparam FIR8.coeff5 = 16'b0000110110000001;
	defparam FIR8.coeff6 = 16'b0000001101110001;
	defparam FIR8.coeff7 = 16'b1110110111011000;
	defparam FIR8.coeff8 = 16'b1110101001000001;
	defparam FIR8.coeff9 = 16'b0000010111110000;
	defparam FIR8.coeff10 = 16'b0010000111010100;
	defparam FIR8.coeff11 = 16'b0001010100110100;
	defparam FIR8.coeff12 = 16'b1110100100001110;
	defparam FIR8.coeff13 = 16'b1101010100010010;
	defparam FIR8.coeff14 = 16'b1111011100100001;
	defparam FIR8.coeff15 = 16'b0010011010001010;
	defparam FIR8.coeff16 = 16'b0010011010001010;
	defparam FIR8.coeff17 = 16'b1111011100100001;
	defparam FIR8.coeff18 = 16'b1101010100010010;
	defparam FIR8.coeff19 = 16'b1110100100001110;
	defparam FIR8.coeff20 = 16'b0001010100110100;
	defparam FIR8.coeff21 = 16'b0010000111010100;
	defparam FIR8.coeff22 = 16'b0000010111110000;
	defparam FIR8.coeff23 = 16'b1110101001000001;
	defparam FIR8.coeff24 = 16'b1110110111011000;
	defparam FIR8.coeff25 = 16'b0000001101110001;
	defparam FIR8.coeff26 = 16'b0000110110000001;
	defparam FIR8.coeff27 = 16'b0000010111000000;
	defparam FIR8.coeff28 = 16'b1111101111010000;
	defparam FIR8.coeff29 = 16'b1111101010101010;
	defparam FIR8.coeff30 = 16'b1111111100110001;
	defparam FIR8.coeff31 = 16'b0000001100010101;
//	defparam FIR8.coeff0 = 16'b1111111110011011;
//	defparam FIR8.coeff1 = 16'b1111111011001110;
//	defparam FIR8.coeff2 = 16'b1111111110111101;
//	defparam FIR8.coeff3 = 16'b0000000011011101;
//	defparam FIR8.coeff4 = 16'b0000000000010010;
//	defparam FIR8.coeff5 = 16'b0000000011110000;
//	defparam FIR8.coeff6 = 16'b0000010100010101;
//	defparam FIR8.coeff7 = 16'b0000000000110100;
//	defparam FIR8.coeff8 = 16'b1110111110001100;
//	defparam FIR8.coeff9 = 16'b1111001000111000;
//	defparam FIR8.coeff10 = 16'b0001011100111101;
//	defparam FIR8.coeff11 = 16'b0010100001001000;
//	defparam FIR8.coeff12 = 16'b1111011001111110;
//	defparam FIR8.coeff13 = 16'b1100001000111111;
//	defparam FIR8.coeff14 = 16'b1110011101000011;
//	defparam FIR8.coeff15 = 16'b0011100010010011;
//	defparam FIR8.coeff16 = 16'b0011100010010011;
//	defparam FIR8.coeff17 = 16'b1110011101000011;
//	defparam FIR8.coeff18 = 16'b1100001000111111;
//	defparam FIR8.coeff19 = 16'b1111011001111110;
//	defparam FIR8.coeff20 = 16'b0010100001001000;
//	defparam FIR8.coeff21 = 16'b0001011100111101;
//	defparam FIR8.coeff22 = 16'b1111001000111000;
//	defparam FIR8.coeff23 = 16'b1110111110001100;
//	defparam FIR8.coeff24 = 16'b0000000000110100;
//	defparam FIR8.coeff25 = 16'b0000010100010101;
//	defparam FIR8.coeff26 = 16'b0000000011110000;
//	defparam FIR8.coeff27 = 16'b0000000000010010;
//	defparam FIR8.coeff28 = 16'b0000000011011101;
//	defparam FIR8.coeff29 = 16'b1111111110111101;
//	defparam FIR8.coeff30 = 16'b1111111011001110;
//	defparam FIR8.coeff31 = 16'b1111111110011011;
	//Max FIR8:  -2.7338e+06	
	movingAverage average8(
	.clk(clk),
	.clkFreq(clkFreq),
	.resetn(resetn),
	.shift(shift),
	.shiftdone(shiftdone[16]), 
	.multiply(multiply),
	.multiplydone(multiplydone[16]),
	.send(send),
	.sentdone(sentdone[16]),
	.ld_values(ld_values),
	.loaddone(loaddone[16]),
	.rsignals(rsignals),
	.rsignalsdone(rsignalsdone[16]),
	.ld_newsample(ld_newsample),
	.newsampleloaded(newsampleloaded[16]),
	.newSample(firOutWire8),
	.outputReg(avg8)
	);
	
	always @(posedge clk)
	begin
	if(ld_newsample)
		begin
		outAmpFreq <= {avg8[29:27],
							avg7[30:28],
							avg6[30:28],
							avg5[29:27],
							avg4[30:28],
							avg3[29:27],
							avg2[31:29],
							avg1[32:30]};
		end
	end	  
endmodule


	
	

