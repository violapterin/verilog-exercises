// Lab 7: Multibit adders
// Tzuyu Jeng, Oct 19, 2022

`timescale 1ns / 1ps

// look ahead carry adder
module addition_ahead(
   input clock, input reset,
   input [3:0] alpha, input [3:0] beta,
   output [3:0] anode, output [6:0] display
);
   wire enable;
   wire [1:0] choice;
   wire [6:0] decision;
   wire [3:0] carry, sum;
   clock_enable the_clock_enable(
      .clock(clock),
      .enable(enable)
   );
   anode_driver the_anode_driver(
      .enable(enable),
      .choice(choice),
      .anode(anode)
   );
   adder_ahead the_adder_ahead(
      .alpha(alpha),
      .beta(beta),
      .carry(carry),
      .sum(sum)
   );
   multiplexer the_multiplexer(
      .alpha(alpha),
      .beta(beta),
      .carry(carry),
      .sum(sum),
      .choice(choice),
      .decision(decision)
   );
   decoder the_decoder(
      .decision(decision),
      .display(display)
   );
endmodule: addition_ahead
