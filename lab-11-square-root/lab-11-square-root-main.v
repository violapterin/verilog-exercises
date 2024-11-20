// Lab 11: Square root finder
// Tzuyu Jeng, Nov 4


`timescale 1ns / 1ps

module square_root(
   input clock,
   input reset,
   input start,
   input show,
   input [7:0] alpha,
   output [3:0] anode,
   output [6:0] cathode
);
   wire action_load, action_add, action_half;
   wire flag_greater;
   wire [7:0] root_hexadecimal;
   wire [11:0] root_decimal;
   wire [11:0] result;

   path_control(
      .clock(clock),
      .reset(reset),
      .start(start),
      .flag_greater(flag_greater),
      .action_load(action_load),
      .action_add(action_add),
      .action_half(action_half)
   );
   path_data(
      .clock(clock),
      .reset(reset),
      .alpha(alpha),
      .action_load(action_load),
      .action_add(action_add),
      .action_half(action_half),
      .flag_greater(flag_greater),
      .root(root_hexadecimal)
   );
   convert_base(
      .hexadecimal(root_hexadecimal),
      .decimal(root_decimal)
   );
   show_result(
      .reset(reset),
      .show(show),
      .alpha({4'b0000, alpha}),
      .root(root_decimal),
      .result(result)
   );
   seven_segment_display the_display(
      .clock(clock),
      .reset(reset),
      .digit_1(4'b0000),
      .digit_2(result[11:8]),
      .digit_3(result[7:4]),
      .digit_4(result[3:0]),
      .anode(anode),
      .cathode(cathode)
   );
endmodule: square_root

