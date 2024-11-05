`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Create Date:   19:55:54 03/28/2016
// Design Name:   boothMult
// Project Name:  lab8 
//
// Verilog Test Fixture created by ISE for module: boothMult
//
////////////////////////////////////////////////////////////////////////////////

module boothTest;

	// Inputs
	reg [3:0] A;
	reg [3:0] B;

	// Outputs
	wire [7:0] P;

	// Instantiate the Unit Under Test (UUT)
	boothMult uut (
		.A(A), 
		.B(B), 
		.P(P)
	);

	integer i;
	initial begin
		// Initialize Inputs
		A = 0;
		B = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		for(i = 0; i < 256; i = i + 1)
			#10 {A,B} = i;
	end
      
endmodule

