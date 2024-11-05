`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Candace Walden
// 
// Create Date:   21:48:48 06/14/2016 
// Design Name:   boothMult
// Project Name:  lab8
//
// Booth multiplier without using a loop
//
//////////////////////////////////////////////////////////////////////////////////
module boothMult(
    input [3:0] A,
    input [3:0] B,
    output [7:0] P
    );
	 
	wire signed [9:0] x1, x2, x3;
	wire signed [9:0] P1, P2, P3;
	 
	boothEncode b1({B[1:0], 1'b0}, A, x1);
	boothEncode b2(B[3:1], A, x2);
	boothEncode b3({2'b0, B[3]}, A, x3);

	assign P1 = x1;
	assign P2 = (P1>>>2) + x2;
	assign P3 = (P2>>>2) + x3;
	
	assign P = P3[7:0];

endmodule
