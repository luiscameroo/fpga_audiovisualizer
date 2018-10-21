`timescale 1ns/1ns

module testSource(
	SW,
	KEY,
//	newSample,
//	outAmpFreq,
//	firOutWire1,
//	firOutWire2,
//	firOutWire3,
//	firOutWire4,
//	firOutWire5,
//	firOutWire6,
//	firOutWire7,
//	firOutWire8,
	avg1,
//	avg2, 
//	avg3,
//	avg4, 
//	avg5, 
//	avg6, 
//	avg7, 
//	avg8
	);
	
	wire [3:0]selectTone; 
	wire clk,
		  start,
		  resetn;
	//reg clkFreq;
	wire clkFreq; 	
	wire [5:0]countMultiply; 
	
//	output[15:0] newSample;
//	output[23:0] outAmpFreq;
	output[63:0] avg1;
//	output[63:0] firOutWire1;
//	output[63:0] avg2; 
//	output[63:0] firOutWire2;
//	output[63:0] avg3; 
//	output[63:0] firOutWire3;
//	output[63:0] avg4; 
//	output[63:0] firOutWire4;
//	output[63:0] avg5; 
//	output[63:0] firOutWire5;
//	output[63:0] avg6; 
//	output[63:0] firOutWire6;
//	output[63:0] avg7; 
//	output[63:0] firOutWire7;
//	output[63:0] avg8; 
//	output[63:0] firOutWire8;
	
	
	
	input [9:0]SW;
	input [3:0]KEY;
	
	assign clk = KEY[0];
	assign clkFreq = KEY[1];
	assign resetn = KEY[2];
	assign start = KEY[3];
	
//	assign selectTone = SW[3:0]; 
	
//	reg [13:0]address;
//	reg [15:0]countFreq;
//	
//	always@(posedge clk) 
//	begin
//		if(!resetn)
//		begin
//			countFreq <= 0;
//			clkFreq <= 0;
//		end
//		else if(countFreq == 16'b0000110000110101)
//		begin
//			countFreq <= 0; 
//			clkFreq <= 1; 
//		end
//		else 
//		begin
//			countFreq <= countFreq + 1; 
//			clkFreq <= 0; 
//		end
//	end
	
//	always@(posedge clkFreq)
//	begin
//		if(!resetn)
//			address <= 0; 
//		else 
//			address <= address + 1; 
//	end
	
//	RAMaccess RAM_inst(
//		.clk(clk),
//		.clkFreq(clkFreq),
//		.address(address),
//		.selectTone(selectTone),
//		.newSample(newSample)
//		);
		
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
		  ld_newsample, 
		  newsampleloaded; 
	
	
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
	.ld_newsample(ld_newsample),
	.newsampleloaded(newsampleloaded),
	.start(start) 
	);
	
	movingAverage average1(
	.clk(clk),
	.clkFreq(clkFreq),
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
	.ld_newsample(ld_newsample),
	.newsampleloaded(newsampleloaded),
	.newSample(64'b00000000000000001111111111111111),
	.countMultiply(countMultiply),
	.outputReg(avg1)
	);
	
//	accessFIR FIR_inst(
//		.clk(clk),
//		.clkFreq(clkFreq),
//		.resetn(resetn),
//		.start(start),
//		.newSample(newSample), 
//		.outAmpFreq(outAmpFreq),
//		.firOutWire1(firOutWire1),
//		.firOutWire2(firOutWire2),
//		.firOutWire3(firOutWire3),
//		.firOutWire4(firOutWire4),
//		.firOutWire5(firOutWire5),
//		.firOutWire6(firOutWire6),
//		.firOutWire7(firOutWire7),
//		.firOutWire8(firOutWire8),
//		.avg1(avg1),
//		.avg2(avg2),
//		.avg3(avg3),
//		.avg4(avg4),
//		.avg5(avg5),
//		.avg6(avg6),
//		.avg7(avg7),
//		.avg8(avg8)
//		);
//	
//	filterInput Source(
//		.clk(KEY[0]),
//		.clkFreq(KEY[1]),
//		.outAmpFreq(outAmpFreq),
//		.selectTone(SW[3:0]), 
//		.resetn(KEY[2]), 
//		.start(KEY[3]),
//		.newSample(newSample)
//		);

endmodule 