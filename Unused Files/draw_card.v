//LOOK INTO LINEAR FEEDBACK SHIFT REGISTER FOR RANDOM NUMBERS

module draw_card(in, card, clock, reset);
	input in, clock, reset;
	output reg [3:0] card;
	
	always @(posedge clock)
	begin
		if(reset == 1'b1)
			card <= 0;
		else if(in == 1'b1)
			card <= counterValue;
		else
			card <= 0;
	end
	
	wire [3:0] counterValue;
	
	counterUp counter(.num(counterValue), .clock(clock), .pause(in));
	
endmodule	

module counterUp(num, clock, pause);
	input pause, clock;
	output reg [3:0] num;
	
	always @(posedge clock)
	begin
		if (num == 4'b1010)
			num <= 4'b0001;
		else if(pause == 1'b1)
			num <= num + 1'b0;
		else
			num <= num + 1'b1;
	end
endmodule
