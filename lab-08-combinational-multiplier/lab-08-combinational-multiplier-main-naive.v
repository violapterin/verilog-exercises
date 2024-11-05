// Lab 8: Multiplier
// Tzuyu Jeng, Oct 27

`timescale 1ns / 1ps

module multiplication_combinational(
   input clock, input reset,
   input [3:0] alpha, input [3:0] beta,
   output [3:0] anode, output [6:0] cathode
);
   wire [7:0] product;
   multiplier_combinational the_multiplier_combinational(
      .alpha(alpha),
      .beta(beta),
      .product(product)
   );
   seven_segment_display the_display(
      .clock(clock),
      .reset(reset),
      .digit_1(alpha),
      .digit_2(beta),
      .digit_3(product[7:4]),
      .digit_4(product[3:0]),
      .anode(anode),
      .cathode(cathode)
   );
endmodule: multiplication_combinational

