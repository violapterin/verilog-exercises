`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Create Date:   20:39:02 06/21/2016
// Design Name:   booth_mult2
// Project Name:  lab8
//
// Verilog Test Fixture created by ISE for module: booth_mult2
// 
////////////////////////////////////////////////////////////////////////////////

module booth_mult2_TB;

	// Inputs
	reg [3:0] a;
	reg [3:0] b;

	// Outputs
	wire [7:0] p;

	// Instantiate the Unit Under Test (UUT)
	booth_mult2 uut (
		.a(a), 
		.b(b), 
		.p(p)
	);

	integer i;
	initial begin
		// Initialize Inputs
		a = 0;
		b = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		for(i = 0; i < 256; i = i + 1)
			#10 {a,b} = i;

	end
      
endmodule

