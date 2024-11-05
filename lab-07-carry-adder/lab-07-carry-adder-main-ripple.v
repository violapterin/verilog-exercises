// Lab 7: Multibit adders
// Tzuyu Jeng, Oct 19, 2022

`timescale 1ns / 1ps

// ripple carry adder
module addition_ripple(
   input clock, input reset,
   input [3:0] alpha, input [3:0] beta,
   output [3:0] anode, output [6:0] display
);
   wire enable;
   wire [1:0] choice;
   wire [6:0] decision;
   wire [3:0] carry, sum;
   clock_enable the_clock_enable(clock, enable);
   anode_driver the_anode_driver(enable, choice, anode);
   adder_ripple the_adder_ripple(alpha, beta, carry, sum);
   multiplexer the_multiplexer(alpha, beta, carry, sum, choice, decision);
   decoder the_decoder(decision, display);
endmodule: addition_ripple
