`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Candace Walden
// 
// Create Date:   21:48:48 06/14/2016 
// Design Name:   booth_mult2
// Project Name:  lab8
//
// Booth multiplier using a for loop
//
//////////////////////////////////////////////////////////////////////////////////
module booth_mult2(
    input [3:0] a,
    input [3:0] b,
    output [7:0] p
    );
	 
	 reg [4:0] contrib;
	 reg [5:0] x;
	 reg signed [9:0] prod;		//big enough to handle overflow and signed bit
	 integer i;
	 
	 assign p = prod[7:0];		//only care about unsigned product
	 
	 always @(a or b)
	 begin
		contrib = {b,1'b0};		//add 0 as first bit to start
		prod = 0;
		for(i = 0; i < 3; i = i + 1)	//4-bit unsigned numbers need 3 contributions
		begin
			prod = prod >>> 2;	//arthemetic shift right for "Add and Shift"
			case(contrib[2:0])
				0: x = 0;
				1: x = {2'b0,a};
				2: x = {2'b0,a};
				3: x = {1'b0,a}<<1;			//multiply by 2 using shift
				4: x = ~({1'b0,a}<<1) + 1;	//multiply then 2's complement
				5: x = ~{2'b0,a} + 1;		//2's complement (1's complement + 1)
				6: x = ~{2'b0,a} + 1;		//2's complement
				7: x = 0;
			endcase
			prod = prod + {x,4'b0};		//add to most signficant bits of prod
			contrib = contrib >> 2;		//shift to next contribution
		end
	 end


endmodule
