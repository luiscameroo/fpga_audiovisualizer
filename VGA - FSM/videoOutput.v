`timescale 1ns/1ns

module visualOutput(
	clk,
	resetn,
	start,
	inAmpFreq,
	VGA_CLK,   						//	VGA Clock
	VGA_HS,							//	VGA H_SYNC
	VGA_VS,							//	VGA V_SYNC
	VGA_BLANK_N,						//	VGA BLANK
	VGA_SYNC_N,						//	VGA SYNC
	VGA_R,   						//	VGA Red[9:0]
	VGA_G,	 						//	VGA Green[9:0]
	VGA_B  
	);
	
	input [23:0]inAmpFreq;
	input start,
			resetn,
			clk;

	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	
	
	wire [2:0]color;
	wire [7:0]VGA_X;
	wire [6:0]VGA_Y;
	wire set_clear,
		  resetnextcount,
		  ld_values, 
		  draw_clear, 
		  draw,
		  plot, 
		  draw_freq1, 
		  draw_freq2, 
		  draw_freq3, 
		  draw_freq4,
		  draw_freq5, 
		  draw_freq6, 
		  draw_freq7, 
		  draw_freq8,
		  start, 
		  done, 
		  doneload, 
		  donedraw, 
		  clearready, 
		  cleardone;
		  
	assign plot  = draw | draw_clear; 
	
		
	control VGAoutputControl(
		.start(start),
		.resetn(resetn), 
		.clk(clk),
		.set_clear(set_clear),
		.resetnextcount(resetnextcount),
		.ld_values(ld_values), 
		.draw_clear(draw_clear), 
		.draw(draw),
		.draw_freq1(draw_freq1), 
		.draw_freq2(draw_freq2), 
		.draw_freq3(draw_freq3), 
		.draw_freq4(draw_freq4),
		.draw_freq5(draw_freq5), 
		.draw_freq6(draw_freq6), 
		.draw_freq7(draw_freq7), 
		.draw_freq8(draw_freq8),
		.done(done),
		.doneload(doneload),
		.donedraw(donedraw),
		.clearready(clearready),
		.cleardone(cleardone)
		);
	
	datapath VGAoutputDatapath(
		.start(start), 
		.resetn(resetn), 
		.clk(clk), 
		.ld_values(ld_values), 
		.draw_clear(draw_clear), 
		.set_clear(set_clear), 
		.resetnextcount(resetnextcount),
		.draw(draw),
		.draw_freq1(draw_freq1), 
		.draw_freq2(draw_freq2), 
		.draw_freq3(draw_freq3), 
		.draw_freq4(draw_freq4),
		.draw_freq5(draw_freq5), 
		.draw_freq6(draw_freq6), 
		.draw_freq7(draw_freq7), 
		.draw_freq8(draw_freq8), 
		.inputfreqamp(inAmpFreq),
		.VGA_X(VGA_X), 
		.VGA_Y(VGA_Y), 
		.color(color),
		.done(done),
		.doneload(doneload),
		.donedraw(donedraw),
		.clearready(clearready),
		.cleardone(cleardone)
		);
	
	
	
	vga_adapter VGA(
			.resetn(resetn),
			.clock(clk),
			.colour(color),
			.x(VGA_X),
			.y(VGA_Y),
			.plot(plot),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
	

endmodule

module control(
	start, 
	resetn, 
	clk, 
	set_clear,
	ld_values, 
	draw_clear,
	draw,
	draw_freq1, 
	draw_freq2,
	draw_freq3,
	draw_freq4,
	draw_freq5,
	draw_freq6, 
	draw_freq7, 
	draw_freq8,
	resetnextcount,
	done, 
	doneload, 
	donedraw, 
	clearready,
	cleardone
	);
	
	input start, 
			resetn, 
			clk,
			done,
			doneload,
			donedraw,
			clearready, 
			cleardone;
	output reg ld_values, 
				  draw_clear, 
				  draw, 
				  set_clear, 
		        draw_freq1, 
				  draw_freq2, 
				  draw_freq3, 
				  draw_freq4,
		        draw_freq5, 
				  draw_freq6, 
				  draw_freq7, 
				  draw_freq8,
				  resetnextcount; 
	
	reg [5:0] current_state, next_state;
	reg next, clearwait, resetclearwait; 
		 
		
	localparam    S_LOADVALUES        = 5'd0,
					  S_FREQ1             = 5'd1,
					  S_FREQ2             = 5'd2,
					  S_FREQ3             = 5'd3,
					  S_FREQ4             = 5'd4,
					  S_FREQ5             = 5'd5,
					  S_FREQ6             = 5'd6,
					  S_FREQ7             = 5'd7,
					  S_FREQ8             = 5'd8,
					  S_HOLD              = 5'd9,
					  S_REFRESH           = 5'd10,
					  S_READY             = 5'd11,
					  S_FHOLD1            = 5'd12,
					  S_FHOLD2            = 5'd13,
					  S_FHOLD3            = 5'd14,
					  S_FHOLD4            = 5'd15,
					  S_FHOLD5            = 5'd16,
					  S_FHOLD6            = 5'd17,
					  S_FHOLD7            = 5'd18,
					  S_FHOLD0            = 5'd19,
					  S_BHOLD             = 5'd20,
					  S_PREREFRESH        = 5'd21,
					  S_CLEARWAIT         = 5'd22;
	
	always@(*)
	begin:state_table
		case (current_state)
			S_READY : next_state = start ? S_LOADVALUES : S_READY;
			S_LOADVALUES : next_state = doneload ? S_FHOLD0 : S_LOADVALUES;
			S_FHOLD0 : next_state = done ? S_FREQ1 : S_FHOLD0;
			S_FREQ1 : next_state = donedraw ? S_FHOLD1 : S_FREQ1;
			S_FHOLD1 : next_state = done ? S_FREQ2 : S_FHOLD1;
			S_FREQ2 : next_state = donedraw ? S_FHOLD2 : S_FREQ2;
			S_FHOLD2 : next_state = done ? S_FREQ3 : S_FHOLD2;
			S_FREQ3 : next_state = donedraw ? S_FHOLD3 : S_FREQ3;
			S_FHOLD3 : next_state = done ? S_FREQ4 : S_FHOLD3;
			S_FREQ4 : next_state = donedraw ? S_FHOLD4 : S_FREQ4;
			S_FHOLD4 : next_state = done ? S_FREQ5 : S_FHOLD4;
			S_FREQ5 : next_state = donedraw ? S_FHOLD5 : S_FREQ5;
			S_FHOLD5 : next_state = done ? S_FREQ6 : S_FHOLD5;
			S_FREQ6 : next_state = donedraw ? S_FHOLD6 : S_FREQ6;
			S_FHOLD6 : next_state = done ? S_FREQ7 : S_FHOLD6;
			S_FREQ7 : next_state = donedraw ? S_FHOLD7 : S_FREQ7;
			S_FHOLD7 : next_state = done ? S_FREQ8 : S_FHOLD7;
			S_FREQ8 : next_state = donedraw ? S_BHOLD : S_FREQ8;
			S_BHOLD : next_state = done ? S_HOLD : S_BHOLD;
			S_HOLD : next_state = next ? S_PREREFRESH : S_HOLD;
			S_PREREFRESH : next_state = clearready ? S_REFRESH : S_PREREFRESH;
			S_REFRESH : next_state = cleardone ? S_CLEARWAIT : S_REFRESH;
			S_CLEARWAIT: next_state = clearwait ?  S_LOADVALUES: S_CLEARWAIT;
			default : next_state = S_READY; 
		endcase
	end	  
		  
	
	always@(*)
	begin:enable_signals
		draw = 1'b0; 
		set_clear = 1'b0; 
		ld_values = 1'b0;
		draw_freq1 = 1'b0;
		draw_freq2 = 1'b0; 
		draw_freq3 = 1'b0;
		draw_freq4 = 1'b0;
		draw_freq5 = 1'b0;
		draw_freq6 = 1'b0;
		draw_freq7 = 1'b0;
		draw_freq8 = 1'b0;
		draw_clear = 1'b0;
		resetnextcount = 1'b0;
		resetclearwait = 1'b0; 
		case (current_state)
			S_READY:begin
				end
			S_LOADVALUES: begin
				ld_values = 1'b1;
				end
			S_FREQ1 : begin
				draw = 1'b1; 
				end
			S_FREQ2 : begin
				draw = 1'b1;
				end
			S_FREQ3 : begin
				draw = 1'b1;
				end
			S_FREQ4 : begin
				draw = 1'b1;
				end
			S_FREQ5 : begin
				draw = 1'b1;
				end
			S_FREQ6 : begin
				draw = 1'b1;
				end
			S_FREQ7 : begin
				draw = 1'b1;
				end
			S_FREQ8 : begin
				draw = 1'b1; 
				end
			S_FHOLD0 : begin
				draw_freq1 = 1'b1;
				end
			S_FHOLD1 : begin
				draw_freq2 = 1'b1;
				end
			S_FHOLD2 : begin
				draw_freq3 = 1'b1;
				end
			S_FHOLD3 : begin
				draw_freq4 = 1'b1;
				end
			S_FHOLD4 : begin
				draw_freq5 = 1'b1;	
				end
			S_FHOLD5 : begin
				draw_freq6 = 1'b1;
				end
			S_FHOLD6 : begin
				draw_freq7 = 1'b1;	
				end
			S_FHOLD7 : begin
				draw_freq8 = 1'b1;	
				end
			S_BHOLD : begin
				resetnextcount = 1'b1;
				end
			S_HOLD : begin
				end
			S_PREREFRESH : begin
				set_clear = 1'b1;
				end
			S_REFRESH : begin
				draw_clear = 1'b1;
				resetclearwait = 1'b1;
				end
			S_CLEARWAIT : begin
				end
			
		endcase
	end
	
	always@(posedge clk)
	begin : state_FFs
		if(!resetn)			
			current_state <= S_READY;
		else
			current_state <= next_state;
	end
	

	
	reg[27:0]countnext;
	reg[19:0]countclear;
	reg[3:0]count15;
	reg clock60;
		
	always@(posedge clk)
	begin
		if(!resetn)
			begin
			countnext <= 21'b0; 
			next <= 1'b0;
			end
		else if(resetnextcount)
			begin
			countnext <= 21'b0; 
			next <= 1'b0; 
			end
		else if(countnext == 28'b00000101111101011110000100000)//2hz: 28'b0001111111111111100001000000)//60hz : 28'b0000000011001011011100110101)//4hz :28'b00000101111101011110000100000)//1hz: 28'b0010111110101111000010000000)
			begin
			next <= 1'b1;
			countnext <= 21'b0;
			end
		else 
			countnext <= countnext + 1; 
	end
	
	always@(posedge clk)
	begin
		if(!resetn)
			begin
			countclear <= 0; 
			clearwait <= 0; 
			end
		else if(resetclearwait)
			begin
			countclear <= 0; 
			clearwait <= 0; 
			end
		else if(countclear == 20'b00000000000000000001)
			begin
			countclear <= 0; 
			clearwait <= 1;
			end
		else
			countclear <= countclear + 1;
	end
	
endmodule 

module datapath(
			start, 
			resetn, 
			clk, 
			ld_values, 
			draw_clear, 
			set_clear,
			resetnextcount,	
			draw,
		   draw_freq1, 
			draw_freq2, 
			draw_freq3, 
			draw_freq4,
		   draw_freq5, 
			draw_freq6, 
			draw_freq7, 
			draw_freq8, 
			inputfreqamp,
			VGA_X, 
			VGA_Y, 
			color, 
			done, 
			doneload, 
			donedraw, 
			clearready, 
			cleardone
			);
			 
	input start, 
			resetn, 
			clk, 
			ld_values,
			draw_clear,
			set_clear,
			resetnextcount, 
			draw,
		   draw_freq1, 
			draw_freq2, 
			draw_freq3, 
			draw_freq4,
		   draw_freq5,
			draw_freq6, 
			draw_freq7,
			draw_freq8;
	input [23:0]inputfreqamp;
	
	
	output reg [7:0]VGA_X;
	output reg [6:0]VGA_Y;
	output reg [2:0]color;
	output reg done, doneload, donedraw, clearready, cleardone;
	//output reg [2:0]VGA_color;
	reg [2:0]freqamp [7:0];
	reg [7:0]X;
	reg [6:0]Y;
	reg [7:0]incrementX; 
	reg [6:0]incrementY;
	reg [6:0]boundY;
	//reg [2:0]color; 
	
	
	always@(posedge clk)
	begin 
		if(ld_values)
			begin 
			freqamp[0] <= inputfreqamp[2:0];
			freqamp[1] <= inputfreqamp[5:3];
			freqamp[2] <= inputfreqamp[8:6];
			freqamp[3] <= inputfreqamp[11:9];
			freqamp[4] <= inputfreqamp[14:12];
			freqamp[5] <= inputfreqamp[17:15];
			freqamp[6] <= inputfreqamp[20:18];
			freqamp[7] <= inputfreqamp[23:21];
			doneload <= 1;
			done <= 0; 
			donedraw <= 0;
			clearready <= 0;
			cleardone <= 0; 
			end
		else if(draw_freq1)
			begin
			X <= 8'b00000010;
			Y <= (7'b1111111 - (7'b0010000*freqamp[0]+7'b0001111));
			incrementX <= 0; 
			incrementY <= 0;
			boundY <= 7'b0010000*freqamp[0] + 7'b0001111;
			color <= 3'b001;
			done <= 1; 
			donedraw <= 0;
			doneload <= 0; 

			end
		else if(draw_freq2)
			begin
			X <= 8'b00010110;
			Y <= (7'b1111111 - (7'b0010000*freqamp[1]+7'b0001111));
			incrementX <= 0; 
			incrementY <= 0; 
			boundY <= 7'b0010000*freqamp[1] + 7'b0001111;
			color <= 3'b001;
			done <= 1;
			donedraw <= 0;
			doneload <= 0; 

			end
		else if(draw_freq3)
			begin
			X <= 8'b00101010;
			Y <= (7'b1111111 - (7'b0010000*freqamp[2]+7'b0001111));
			incrementX <= 0; 
			incrementY <= 0; 
			boundY <= 7'b0010000*freqamp[2] + 7'b0001111;
			color <= 3'b010;
			done <= 1;
			donedraw <= 0;
			doneload <= 0; 

			end
		else if(draw_freq4)
			begin
			X <= 8'b00111110;
			Y <= (7'b1111111 - (7'b0010000*freqamp[3]+7'b0001111));
			incrementX <= 0; 
			incrementY <= 0; 
			boundY <= 7'b0010000*freqamp[3] + 7'b0001111;
			color <= 3'b010;
			done <= 1;
			donedraw <= 0;
			doneload <= 0; 

			end
		else if(draw_freq5)	
			begin
			X <= 8'b01010010;
			Y <= (7'b1111111 - (7'b0010000*freqamp[4]+7'b0001111));
			incrementX <= 0; 
			incrementY <= 0; 
			boundY <= 7'b0010000*freqamp[4] + 7'b0001111;
			color <= 3'b110;
			done <= 1;
			donedraw <= 0;
			doneload <= 0; 
	
			end
		else if(draw_freq6)
			begin
			X <= 8'b01100110;
			Y <= (7'b1111111 - (7'b0010000*freqamp[5]+7'b0001111));
			incrementX <= 0; 
			incrementY <= 0; 
			boundY <= 7'b0010000*freqamp[5] + 7'b0001111;
			color <= 3'b110;
			done <= 1;
			donedraw <= 0;
			doneload <= 0; 

			end
		else if(draw_freq7)
			begin
			X <= 8'b01111010;
			Y <= (7'b1111111 - (7'b0010000*freqamp[6]+7'b0001111));
			incrementX <= 0; 
			incrementY <= 0; 
			boundY <= 7'b0010000*freqamp[6] + 7'b0001111;
			color <= 3'b100;
			done <= 1;
			donedraw <= 0;
			doneload <= 0; 

			end
		else if(draw_freq8)
			begin
			X <= 8'b10001110;
			Y <= (7'b1111111 - (7'b0010000*freqamp[7]+7'b0001111));
			incrementX <= 0; 
			incrementY <= 0; 
			boundY <= 7'b0010000*freqamp[7] + 7'b0001111;
			color <= 3'b100;
			done <= 1;
			donedraw <= 0;
			doneload <= 0; 

			end
		else if(draw) 
			begin
			done <=0;
			if(incrementX == 7'b0001111)
				begin
				if(incrementY == boundY)
					begin
					incrementY <= 0;
					donedraw <= 1;
					end
				else
					begin
					incrementX <= 0;
					incrementY <= incrementY + 1;
					end
				end
			else 
				incrementX <= incrementX + 1; 
			end
		else if(set_clear)
			begin
			X <= 0;
			Y <= 0; 
			incrementX <= 0; 
			incrementY <= 0;
			color <= 3'b000; 
			donedraw <= 0;
			cleardone <= 0; 
			clearready <= 1; 
			end
		else if(draw_clear)
			begin
			clearready <= 0; 
			if(incrementX == 8'b10011111)
				begin
				if(incrementY == 7'b1111111)
					begin
					incrementY <= 0;
					cleardone <= 1;
					end
				else 
					begin
					incrementX <= 0; 
					incrementY <= incrementY + 1;
					end
				end
			else
				incrementX <= incrementX + 1; 
			end
			
		else if(resetnextcount)
			done <= 1; 
			
		else if(!resetn)
			begin
			X <= 0; 
			Y <= 0; 
			incrementX <= 0;
			incrementY <= 0;
			doneload <= 0;
			done <= 0;
			donedraw <= 0;
			clearready <= 0; 
			cleardone <= 0; 
			end
			
		VGA_X <= X + incrementX;
		VGA_Y <= Y + incrementY;
		end
						
endmodule


