`timescale 1ns/1ns

module FIRFilter(
	CLOCK_50,
	KEY, 
	outputReg,
	SW
	);
	
	input [1:0]SW;
	input CLOCK_50;
	input [3:0]KEY;
	
	output [63:0]outputReg;
	
	wire ld_values, 
		  loaddone, 
		  shift, 
		  shiftdone, 
		  multiply, 
		  multiplydone, 
		  send, 
		  sentdone, 
		  rsignals, 
		  rsignalsdone, 
		  start, 
		  resetn,
		  clk; 
		  
	wire[63:0]accumulate; 
	
	reg clk5khz;
	reg [15:0]count5khz;
	reg [15:0]newSample;
	
	assign resetn = KEY[0];
	assign start  = ~KEY[1];
	assign clk    = SW[0]; //CLOCK_50;
	
	
	always@(posedge sentdone or negedge resetn)
	begin
		if(!resetn)
			newSample <= 0; 
		else
			newSample <= newSample + 1; 
	end
	
	firController controller(
	.clk(clk),
	.resetn(resetn),
	.ld_values(ld_values),
	.loaddone(loaddone),
	.shift(shift),
	.shiftdone(shiftdone),
	.multiply(multiply),
	.multiplydone(multiplydone), 
	.send(send), 
	.sentdone(sentdone),
	.rsignals(rsignals),
	.rsignalsdone(rsignalsdone),
	.start(start) 
	);

	firFilter5khz FIR1(
	.clk(clk),
	.clk5khz(clk5khz),
	.resetn(resetn),
	.shift(shift),
	.shiftdone(shiftdone), 
	.multiply(multiply),
	.multiplydone(multiplydone),
	.send(send),
	.sentdone(sentdone),
	.ld_values(ld_values),
	.loaddone(loaddone),
	.rsignals(rsignals),
	.rsignalsdone(rsignalsdone),
	.newSample(newSample),
	.outputReg(outputReg),
	.accumulate(accumulate)
	);
	defparam FIR1.coeff0 = 16'b0000000000000001;
	defparam FIR1.coeff1 = 16'b0000000000000010;
	defparam FIR1.coeff2 = 16'b0000000000000011;
	defparam FIR1.coeff3 = 16'b0000000000000100;
	defparam FIR1.coeff4 = 16'b0000000000000101;
	defparam FIR1.coeff5 = 16'b0000000000000110;
	defparam FIR1.coeff6 = 16'b0000000000000111;
	defparam FIR1.coeff7 = 16'b0000000000001000;
	defparam FIR1.coeff8 = 16'b0000000000001001;
	defparam FIR1.coeff9 = 16'b0000000000001010;
	defparam FIR1.coeff10 = 16'b0000000000001011;
	defparam FIR1.coeff11 = 16'b0000000000001100;
	defparam FIR1.coeff12 = 16'b0000000000001101;
	defparam FIR1.coeff13 = 16'b0000000000001110;
	defparam FIR1.coeff14 = 16'b0000000000001111;
	defparam FIR1.coeff15 = 16'b0000000000010000;
	defparam FIR1.coeff16 = 16'b0000000000010001;
	defparam FIR1.coeff17 = 16'b0000000000010010;
	defparam FIR1.coeff18 = 16'b0000000000010011;
	defparam FIR1.coeff19 = 16'b0000000000010100;
	defparam FIR1.coeff20 = 16'b0000000000010101;
	defparam FIR1.coeff21 = 16'b0000000000010110;
	defparam FIR1.coeff22 = 16'b0000000000010111;
	defparam FIR1.coeff23 = 16'b0000000000011000;
	defparam FIR1.coeff24 = 16'b0000000000011001;
	defparam FIR1.coeff25 = 16'b0000000000011010;
	defparam FIR1.coeff26 = 16'b0000000000011011;
	defparam FIR1.coeff27 = 16'b0000000000011100;
	defparam FIR1.coeff28 = 16'b0000000000011101;
	defparam FIR1.coeff29 = 16'b0000000000011110;
	defparam FIR1.coeff30 = 16'b0000000000011111;
	defparam FIR1.coeff31 = 16'b0000000000100000;
	
	always@(posedge clk) 
	begin
		if(!resetn)
		begin
			count5khz <= 0;
			clk5khz <= 0;
		end
		else if(count5khz == 6'b110010)// 5khz = 16'b0010011100010000)
		begin
			count5khz <= 0; 
			clk5khz <= 1; 
		end
		else 
		begin
			count5khz <= count5khz + 1; 
			clk5khz <= 0; 
		end
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
	start
	);
	
	input loaddone,
			shiftdone,
			multiplydone,
			sentdone,
			rsignalsdone, 
			start,
			clk,
			resetn;
	
	output reg multiply,
				  send, 
				  ld_values,
				  shift,
				  rsignals;
			
	reg [5:0] current_state, next_state; 
	localparam S_READY       = 5'd1,
				  S_SHIFT       = 5'd2,
				  S_MULTIPLY    = 5'd3,
				  S_SEND        = 5'd4,
				  S_RSIGNALS    = 5'd5; 
	
	always@(*)
	begin: state_table
		case(current_state)
			S_READY: next_state = (start & loaddone) ? S_SHIFT : S_READY;
			S_SHIFT: next_state = shiftdone ? S_RSIGNALS : S_SHIFT;
			S_RSIGNALS: next_state = rsignalsdone ? S_MULTIPLY : S_RSIGNALS; 
			S_MULTIPLY: next_state = multiplydone ? S_SEND : S_MULTIPLY;
			S_SEND : next_state = sentdone ?  S_SHIFT : S_SEND; 
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

module firFilter5khz(
	clk,
	clk5khz, 
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
	//inputSample,
	newSample,
	outputReg,
	accumulate
	);

	input clk, 
			clk5khz, 
			resetn,
			multiply,
			send,
			ld_values,
			shift,
			rsignals;
	
	input [15:0]newSample; 
//	input [15:0]inputSample;
	
	output reg [63:0]outputReg;
	output reg multiplydone,
				  rsignalsdone,
				  shiftdone,
				  sentdone,
				  loaddone; 
				  
	
	reg [15:0]sampleReg[31:0];
	reg [15:0]coeff[31:0];
//	reg [15:0]newSample; 
	output reg [64:0]accumulate;
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
			countMultiply <= 0;
			multiplydone <= 0;
			sentdone <= 0;
			accumulate <= 0;
			shiftdone <= 0;
		end
		else if(rsignals)
			begin
			countMultiply <= 0;
			multiplydone <= 0;
			sentdone <= 0;
			accumulate <= 0;
			shiftdone <= 0;
			loaddone <= 0; 
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
			loaddone <= 1;
			countMultiply <= 0;
			multiplydone <= 0;
			sentdone <= 0;
			accumulate <= 0;
			shiftdone <= 0;
			rsignalsdone <= 0; 

		end
		
//		else if(waitfornew && clk5khz)
//		begin
//			newsampleloaded <= 1; 
//		end 
		
		else if(multiply)
		begin	
			accumulate <=  accumulate + (coeff[countMultiply] * sampleReg[countMultiply]);
			if(countMultiply == 6'b011111)
				multiplydone <= 1; 
			else
				countMultiply <= countMultiply + 1; 
		end
		
		else if(send)
		begin
			outputReg <= accumulate;
			sentdone <= 1;
		end
		
		else if(shift && clk5khz)
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
			sampleReg[0] <= newSample; 
			shiftdone <= 1; 
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
		end	
	end
	

	
endmodule	