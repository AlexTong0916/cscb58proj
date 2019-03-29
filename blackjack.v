module blackjack(SW, KEY, CLOCK_50, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7);
    input [17:0] SW;
    input [3:0] KEY;
    input CLOCK_50;
    output [17:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;

    wire resetn;
    wire draw;
    wire outcome;
    wire hold;
    wire hold_d;
    wire ld_card_dealer;
    wire ld_card_player;
    wire go;
    
    wire [7:0] money;

    wire [7:0] player_total;
    wire [7:0] dealer_total;
    //wire [3:0] card_in;
    assign resetn = SW[4];
    assign hold = SW[17];
    assign go = SW[5];
    
    
    //draw_card draw( .in(draw),
	//	    .card(card_in),
	//	    .clock(CLOCK_50));

    hex_display H0(
        .IN(SW[16:13]), 
        .OUT(HEX0)
        );
        
    hex_display H1(
        .IN(SW[3:0]), 
        .OUT(HEX1)
        );
    hex_display_card H32(
        .IN(money[4:0]), 
        .tens(HEX3),
	.ones(HEX2)
        );
    hex_display_card H45(
        .IN(dealer_total[4:0]), 
        .tens(HEX5),
	.ones(HEX4)
        );
    hex_display_card H67(
        .IN(player_total[4:0]), 
        .tens(HEX7),
	.ones(HEX6)
        );
    control C0(
	.clk(CLOCK_50),
	.resetn(SW[4]),
	.hold(SW[17]),
	.hold_d(hold_d),
	.go(go),

	.outcome(outcome), 
	.ld_card_dealer(ld_card_dealer),
	.ld_card_player(ld_card_player),
	.win(win),
	.lose(lose)
    );
    datapath D0(
	.clk(CLOCK_50),
	.resetn(SW[4]),
	.go(go),
	.card_in(SW[16:13]),
	.bet(SW[3:0]),
	.ld_card_dealer(ld_card_dealer),
	.ld_card_player(ld_card_player),
	.win(win),
	.lose(lose),
	.money_out(money),
	.outcome(outcome),
	.dealer_total(dealer_total),
	.player_total(player_total),
	.hold_d(hold_d)
    );
endmodule
module control(
    input clk,
    input resetn,
    input hold,
    input hold_d,
    input outcome,
    input go,
    
    output reg ld_card_dealer,ld_card_player,win,lose
    //output draw
    );

    reg [5:0] current_state, next_state; 
    localparam  DEALER_DRAW_A   = 5'b00000,
		PLAYER_DRAW_A   = 5'b10000,
		PLAYER_DRAW_B   = 5'b10001,
		PLAYER_DECIDE = 5'b10011,
		PLAYER_DECIDE_WAIT = 5'b00011,
                PLAYER_HOLD    = 5'b00111,
		DEALER_DRAW_B   = 5'b01111,
		DEALER_DECIDE = 5'b11111,
		DEALER_DECIDE_WAIT = 5'b11110,
                DEALER_HOLD     =5'b11100,
					 EVAL		=5'b00110,
                WIN       = 5'b00100,
                LOSE       = 5'b01000;
    initial
    begin
    current_state = DEALER_DRAW_A;
    end
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
               DEALER_DRAW_A: next_state = PLAYER_DRAW_A;
					PLAYER_DRAW_A: next_state = PLAYER_DRAW_B;
					PLAYER_DRAW_B: next_state = PLAYER_DECIDE;
               PLAYER_DECIDE: next_state = go ? PLAYER_DECIDE_WAIT : PLAYER_DECIDE;
					PLAYER_DECIDE_WAIT: next_state = go ? PLAYER_DECIDE_WAIT : PLAYER_HOLD;
					PLAYER_HOLD: next_state  = hold ? DEALER_DRAW_B: PLAYER_DRAW_B;
					DEALER_DRAW_B: next_state = DEALER_DECIDE;
					DEALER_DECIDE: next_state = go ? DEALER_DECIDE_WAIT : DEALER_DECIDE;
					DEALER_DECIDE_WAIT: next_state = go ? DEALER_DECIDE_WAIT : DEALER_HOLD;
               DEALER_HOLD: next_state =  hold_d ? EVAL : DEALER_DRAW_B;
					EVAL: next_state =  outcome ? WIN : LOSE;
               WIN: next_state = DEALER_DRAW_A;
               LOSE: next_state = DEALER_DRAW_A;
            default:     next_state = DEALER_DRAW_A;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_card_player = 1'b0;
        ld_card_dealer = 1'b0;
	win = 1'b0;
	lose = 1'b0;
	//draw = 1'b0;
        case (current_state)
            DEALER_DRAW_A: begin
                ld_card_dealer = 1'b1;
		//draw = 1'b1;
                end
	    DEALER_DRAW_B: begin
                ld_card_dealer = 1'b1;
		//draw = 1'b1;
                end
            PLAYER_DRAW_A: begin
                ld_card_player = 1'b1;
		//draw = 1'b1;
                end
	    PLAYER_DRAW_B: begin
                ld_card_player = 1'b1;
		//draw = 1'b1;
                end
            WIN: begin
                win = 1'b1;
                end
            LOSE: begin
                lose = 1'b1;
                end
    
            
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= DEALER_DRAW_A;
        else
            current_state <= next_state;
    end // state_FFS
endmodule

module datapath(
    input clk,
    input resetn,
    input go,
    input [3:0] card_in,
    input [3:0] bet,
    input ld_card_dealer,ld_card_player,win,lose,
    output reg [7:0] dealer_total,
    output reg [7:0] player_total,
    output reg hold_d,
    output reg [7:0]money_out,
    output reg outcome
    );
    //initial
    //begin
    //outcome = 1'b0;
    //hold_d = 1'b0;
    //player_total = 8'b0;
    //dealer_total = 8'b0;
    //end
    reg [7:0]player_total_temp = 8'b0;
    reg [7:0]dealer_total_temp = 8'b0;
	 reg [7:0]money = 8'd5;
    always @(*)
    begin: Output_logic
	 if(!resetn) 
	 begin
		    outcome = 1'b0;
		    hold_d = 1'b0;
		end
		else
		begin
	    if(player_total > 8'd21)
		outcome = 1'b0;
	    else if(dealer_total_temp > 8'd21)
		outcome = 1'b1;
	    else if(player_total_temp > dealer_total_temp)
		outcome = 1'b1;
	    else
		outcome = 1'b0;
	   if(dealer_total_temp >= player_total_temp || player_total_temp > 8'd21)
		hold_d = 1'b1;
		else
		hold_d = 1'b0;
		if(win)
		begin
			outcome = 1'b0;
			hold_d = 1'b0;
			end
		if(lose)
		begin
			outcome = 1'b0;
			hold_d = 1'b0;
	   end
	    end
		
    end
    always @(posedge clk)
    begin : Operations
	 if(!resetn) 
	 begin
		    player_total_temp = 8'b0;
		    dealer_total_temp = 8'b0;
		end
	else
	begin
	    if(ld_card_player)
	    begin
		    if(card_in >= 8'd10)
			    player_total_temp = player_total_temp + 8'd10;
		    else
			    player_total_temp = player_total_temp + card_in;
	    end
	    else if(ld_card_dealer)
	    begin
		    if(card_in >= 8'd10)
			    dealer_total_temp = dealer_total_temp + 8'd10;
		    else 
			    dealer_total_temp = dealer_total_temp + card_in;
	    end
	    else if(win)
	   begin
			player_total_temp = 8'b0;
			dealer_total_temp = 8'b0;
			money = money + bet;
	   end
	    else if(lose)
		begin
			player_total_temp = 8'b0;
			dealer_total_temp = 8'b0;
			money = money - bet;
	   end 
	 end
	 player_total = player_total_temp;
	 dealer_total = dealer_total_temp;
	 money_out = money;
	 end
endmodule

module hex_display(IN, OUT);
    input [3:0] IN;
	 output reg [6:0] OUT;
	 
	 always @(*)
	 begin
		case(IN[3:0])
			4'b0000: OUT = 7'b1000000;
			4'b0001: OUT = 7'b1111001;
			4'b0010: OUT = 7'b0100100;
			4'b0011: OUT = 7'b0110000;
			4'b0100: OUT = 7'b0011001;
			4'b0101: OUT = 7'b0010010;
			4'b0110: OUT = 7'b0000010;
			4'b0111: OUT = 7'b1111000;
			4'b1000: OUT = 7'b0000000;
			4'b1001: OUT = 7'b0011000;
			4'b1010: OUT = 7'b0001000;
			4'b1011: OUT = 7'b0000011;
			4'b1100: OUT = 7'b1000110;
			4'b1101: OUT = 7'b0100001;
			4'b1110: OUT = 7'b0000110;
			4'b1111: OUT = 7'b0001110;
			
			default: OUT = 7'b0111111;
		endcase

	end
endmodule
module hex_display_card(IN, tens, ones);
    input [5:0] IN;
	 output reg [6:0] tens, ones;
	 
	 always @(*)
	 begin
		case(IN[5:0])
			// 01
			6'b000000: begin
							tens = 7'b1000000; // 0
							ones = 7'b1000000; // 1
						end
			// 01
			6'b000001: begin
							tens = 7'b1000000; // 0
							ones = 7'b1111001; // 1
						end
			// 02
			6'b000010: begin
							tens = 7'b1000000; // 0
							ones = 7'b0100100; // 2
						end
			// 03
			6'b000011: begin
							tens = 7'b1000000; // 0
							ones = 7'b0110000; // 3
						end
			// 04
			6'b000100: begin
							tens = 7'b1000000; // 0
							ones = 7'b0011001; // 4
						end
			// 05
			6'b000101: begin
							tens = 7'b1000000; // 0
							ones = 7'b0010010; // 5
						end
			// 06
			6'b000110: begin
							tens = 7'b1000000; // 0
							ones = 7'b0000010; // 6
						end
			// 07
			6'b000111: begin
							tens = 7'b1000000; // 0
							ones = 7'b1111000; // 7
						end
			// 08
			6'b001000: begin
							tens = 7'b1000000; // 0
							ones = 7'b0000000; // 8
						end
			// 09
			6'b001001: begin
							tens = 7'b1000000; // 0
							ones = 7'b0011000; // 9
						end
			// 10
			6'b001010: begin
							tens = 7'b1111001; // 1
							ones = 7'b1000000; // 0
						end
			// 11
			6'b001011: begin
							tens = 7'b1111001; // 1
							ones = 7'b1111001; // 1
						end
			// 12
			6'b001100: begin
							tens = 7'b1111001; // 1
							ones = 7'b0100100; // 2
						end
			// 13
			6'b001101: begin
							tens = 7'b1111001; // 1
							ones = 7'b0110000; // 3
						end
			// 14
			6'b001110: begin
							tens = 7'b1111001; // 1
							ones = 7'b0011001; // 4
						end
			// 15
			6'b001111: begin
							tens = 7'b1111001; // 1
							ones = 7'b0010010; // 5
						end
			// 16
			6'b010000: begin
							tens = 7'b1111001; // 1
							ones = 7'b0000010; // 6
						end
			// 17
			6'b010001: begin
							tens = 7'b1111001; // 1
							ones = 7'b1111000; // 7
						end
			// 18
			6'b010010: begin
							tens = 7'b1111001; // 1
							ones = 7'b0000000; // 8
						end
			// 19
			6'b010011: begin
							tens = 7'b1111001; // 1
							ones = 7'b0011000; // 9
						end
			// 20
			6'b010100: begin
							tens = 7'b0100100; // 2
							ones = 7'b1000000; // 0
						end
			// 21
			6'b010101: begin
							tens = 7'b0100100; // 2
							ones = 7'b1111001; // 1
						end
			// 22
			6'b010110: begin
							tens = 7'b0100100; // 2
							ones = 7'b0100100; // 2
						end
			// 23
			6'b010111: begin
							tens = 7'b0100100; // 2
							ones = 7'b0110000; // 3
						end
			// 24
			6'b011000: begin
							tens = 7'b0100100; // 2
							ones = 7'b0011001; // 4
						end
			// 25
			6'b011001: begin
							tens = 7'b0100100; // 2
							ones = 7'b0010010; // 5
						end
			// 26
			6'b011010: begin
							tens = 7'b0100100; // 2
							ones = 7'b0000010; // 6
						end
			// 27
			6'b011011: begin
							tens = 7'b0100100; // 2
							ones = 7'b1111000; // 7
						end
			// 28
			6'b011100: begin
							tens = 7'b0100100; // 2
							ones = 7'b0000000; // 8
						end
			// 29
			6'b011101: begin
							tens = 7'b0100100; // 2
							ones = 7'b0011000; // 9
						end
			// 30
			6'b011110: begin
							tens = 7'b0110000; // 3
							ones = 7'b1000000; // 0
						end
			// 31
			6'b011111: begin
							tens = 7'b0110000; // 3
							ones = 7'b1111001; // 1
						end
			// 32
			6'b100000: begin
							tens = 7'b0110000; // 3
							ones = 7'b0100100; // 2
						end
			// 33
			6'b100001: begin
							tens = 7'b0110000; // 3
							ones = 7'b0110000; // 3
						end
			// 34
			6'b100010: begin
							tens = 7'b0110000; // 3
							ones = 7'b0011001; // 4
						end
			
			// Set default to --
			default: begin
							tens = 7'b0111111; // 0
							ones = 7'b0111111; // 0
						end
		endcase
	end
endmodule