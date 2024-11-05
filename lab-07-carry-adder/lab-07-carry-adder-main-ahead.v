// Lab 7: Multibit adders
// Tzuyu Jeng, Oct 19, 2022

`timescale 1ns / 1ps

// look ahead carry adder
module addition_ahead(
   input clock, input reset,
   input [3:0] alpha, input [3:0] beta,
   output [3:0] anode, output [6:0] cathode
);
   wire [3:0] carry;
   wire [3:0] sum;
   adder_ahead the_adder(
      .alpha(alpha),
      .beta(beta),
      .carry(carry),
      .sum(sum)
   );
   seven_segment_display the_display(
      .clock(clock),
      .reset(reset),
      .digit_1(alpha),
      .digit_2(beta),
      .digit_3(carry),
      .digit_4(sum),
      .anode(anode),
      .cathode(cathode)
   );
endmodule: addition_ahead

