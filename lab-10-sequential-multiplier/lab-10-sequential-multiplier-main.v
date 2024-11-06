// sequential multiplier
// adapted from Mano and Ciletti, 6e, p 516

module multiplication_sequential(
   input clock,
   input clear,
   input [3:0] alpha,
   input [3:0] beta,
   output [3:0] anode,
   output [6:0] cathode
);
   wire [7:0] result;
   wire ready;
   multiplier the_multiplier(
      .clock(clock),
      .clear(clear),
      .start(start),
      .number_one(number_one),
      .number_two(number_two),
      .result(result),
   );
   display the_display(
      .clock(clock),
      .digit_1(alpha),
      .digit_2(beta),
      .digit_3(product[7:4]),
      .digit_4(product[3:0]),
      .anode(anode),
      .cathode(cathode)
   );
endmodule: multiplication_sequential

