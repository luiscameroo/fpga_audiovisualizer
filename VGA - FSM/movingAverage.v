`timescale 1ns/1ns

module movingAverage(
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
	countMultiply, 
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
	
	localparam shiftNum = 5;
	
	input [63:0]newSample; 
	
	output reg [63:0]outputReg;
	output reg multiplydone,
				  rsignalsdone,
				  newsampleloaded, 
				  shiftdone,
				  sentdone,
				  loaddone; 
				  
	
	reg [63:0]sampleReg[31:0];
   reg [63:0]inputSample; 
	reg [63:0]accumulate;
	output reg [5:0]countMultiply;
	
		
	
	
	always@(posedge clk)
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
		loaddone <= loaddone;
		countMultiply <= countMultiply;
		multiplydone <= multiplydone;
		sentdone <= sentdone;
		accumulate <= accumulate;
		shiftdone <= shiftdone;
		rsignalsdone <= rsignalsdone; 
		newsampleloaded <= newsampleloaded;
		inputSample <= inputSample;
			
		if(!resetn)
		begin
			sampleReg[31] <= 64'b0;
			sampleReg[30] <= 64'b0;
			sampleReg[29] <= 64'b0;
			sampleReg[28] <= 64'b0;
			sampleReg[27] <= 64'b0;
			sampleReg[26] <= 64'b0;
			sampleReg[25] <= 64'b0;
			sampleReg[24] <= 64'b0;
			sampleReg[23] <= 64'b0;
			sampleReg[22] <= 64'b0;
			sampleReg[21] <= 64'b0;
			sampleReg[20] <= 64'b0;
			sampleReg[19] <= 64'b0;
			sampleReg[18] <= 64'b0;
			sampleReg[17] <= 64'b0;
			sampleReg[16] <= 64'b0;
			sampleReg[15] <= 64'b0;
			sampleReg[14] <= 64'b0;
			sampleReg[13] <= 64'b0;
			sampleReg[12] <= 64'b0;
			sampleReg[11] <= 64'b0;
			sampleReg[10] <= 64'b0;
			sampleReg[9] <= 64'b0;
			sampleReg[8] <= 64'b0;
			sampleReg[7] <= 64'b0;
			sampleReg[6] <= 64'b0;
			sampleReg[5] <= 64'b0;
			sampleReg[4] <= 64'b0;
			sampleReg[3] <= 64'b0;
			sampleReg[2] <= 64'b0;
			sampleReg[1] <= 64'b0;
			sampleReg[0] <= 64'b0;
			outputReg <= 64'b0;
			countMultiply <= 0;
			multiplydone <= 0;
			sentdone <= 0;
			accumulate <= 64'b0;
			shiftdone <= 0;
			newsampleloaded <= 0;
			rsignalsdone <= 0;
			inputSample <= 0;
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
			outputReg <= outputReg; 
			end
		else if(ld_values)
		begin
			sampleReg[31] <= 64'b0;
			sampleReg[30] <= 64'b0;
			sampleReg[29] <= 64'b0;
			sampleReg[28] <= 64'b0;
			sampleReg[27] <= 64'b0;
			sampleReg[26] <= 64'b0;
			sampleReg[25] <= 64'b0;
			sampleReg[24] <= 64'b0;
			sampleReg[23] <= 64'b0;
			sampleReg[22] <= 64'b0;
			sampleReg[21] <= 64'b0;
			sampleReg[20] <= 64'b0;
			sampleReg[19] <= 64'b0;
			sampleReg[18] <= 64'b0;
			sampleReg[17] <= 64'b0;
			sampleReg[16] <= 64'b0;
			sampleReg[15] <= 64'b0;
			sampleReg[14] <= 64'b0;
			sampleReg[13] <= 64'b0;
			sampleReg[12] <= 64'b0;
			sampleReg[11] <= 64'b0;
			sampleReg[10] <= 64'b0;
			sampleReg[9] <= 64'b0;
			sampleReg[8] <= 64'b0;
			sampleReg[7] <= 64'b0;
			sampleReg[6] <= 64'b0;
			sampleReg[5] <= 64'b0;
			sampleReg[4] <= 64'b0;
			sampleReg[3] <= 64'b0;
			sampleReg[2] <= 64'b0;
			sampleReg[1] <= 64'b0;
			sampleReg[0] <= 64'b0;
			outputReg <= 64'b0; 
			loaddone <= 1;
			countMultiply <= 0;
			multiplydone <= 0;
			sentdone <= 0;
			accumulate <= 64'b0;
			shiftdone <= 0;
			rsignalsdone <= 0; 
			newsampleloaded <= 0;
			inputSample <= 0;
		end
		
		else if(ld_newsample && clkFreq)
		begin
			inputSample <= newSample; 
			newsampleloaded <= 1;
		end 
		
		else if(multiply)
		begin	
			accumulate <= accumulate + (sampleReg[countMultiply]>>5);			
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
			accumulate<= accumulate; 
		end	
	end
endmodule	