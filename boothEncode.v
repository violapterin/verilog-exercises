`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Candace Walden
// 
// Create Date:   21:48:48 06/14/2016 
// Design Name:   boothEncode
// Project Name:  lab8
//
// Module that does 2-bit booth encoding and padding
//
//////////////////////////////////////////////////////////////////////////////////
module boothEncode(
    input [2:0] bits,
    input [3:0] A,
    output [9:0] y
    );
	 
	 wire [5:0] A1 = {2'b0, A};
	 reg [5:0] x;
	 assign y = {x, 4'b0};
	 
	 always @(bits or A1)
		case(bits)
			0: x = 0;
			1: x = A1;
			2: x = A1;
			3: x = A1<<1;
			4: x = ~(A1<<1) + 1;
			5: x = ~A1 + 1;
			6: x = ~A1 + 1;
			7: x = 0;
			default: x = 0;
		endcase


endmodule
