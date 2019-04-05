// Hex decoder to display the value of the card/scored shown in a decimal format, up to 34
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

module hex_display(IN, OUT);
    input [3:0] IN;
	 output reg [6:0] OUT;
	 
	 always @(*)
	 begin
		case(IN[3:0])
			4'b0000: OUT = 7'b1000000; // 0
			4'b0001: OUT = 7'b1111001; // 1
			4'b0010: OUT = 7'b0100100; // 2
			4'b0011: OUT = 7'b0110000; // 3
			4'b0100: OUT = 7'b0011001; // 4
			4'b0101: OUT = 7'b0010010; // 5
			4'b0110: OUT = 7'b0000010; // 6
			4'b0111: OUT = 7'b1111000; // 7
			4'b1000: OUT = 7'b0000000; // 8
			4'b1001: OUT = 7'b0011000; // 9
			4'b1010: OUT = 7'b0001000; // A
			4'b1011: OUT = 7'b0000011; // B
			4'b1100: OUT = 7'b1000110; // C
			4'b1101: OUT = 7'b0100001; // D
			4'b1110: OUT = 7'b0000110; // E
			4'b1111: OUT = 7'b0001110; // F
			
			default: OUT = 7'b0111111;
		endcase

	end
endmodule