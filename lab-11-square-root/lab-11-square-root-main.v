// Lab 11: Square root finder
// Tzuyu Jeng, Nov 4


`timescale 1ns / 1ps

module square_root(
   input clock, input reset,
   input [3:0] alpha,
   output [3:0] anode,  
   output [6:0] cathode,
);
   wire [5:0] control;
   
   module path_control(
      .clock(clock),
      .reset(reset),
      .start(start),
      .control(control),
      .valid(valid)
   );
   module path_data(
      .clock(clock),
      .reset(reset),
      .alpha(alpha),
      .control(control),
      .square_root(square_root),
   );
   seven_segment_display the_display(
      .clock(clock),
      .reset(reset),
      .digit_1(square_root),
      .digit_2(alpha),
      .digit_3(4'b0000),
      .digit_4(4'b0000),
      .anode(anode),
      .cathode(cathode)
   );
endmodule: square_root

