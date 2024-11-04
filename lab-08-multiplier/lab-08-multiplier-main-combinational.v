// Lab 8: Multiplier
// Tzuyu Jeng, Oct 27

`timescale 1ns / 1ps

module multiplication_combinational(
   input clock, input [3:0] alpha, input [3:0] beta,
   output [3:0] anode, output [6:0] cathode
);
   wire [7:0] product;
   multiplier_combinational the_multiplier_combinational(
      .alpha(alpha),
      .beta(beta),
      .product(product)
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
endmodule: multiplication_combinational

module multiplication_array(
   input clock, input [3:0] alpha, input [3:0] beta,
   output [3:0] anode, output [6:0] cathode
);
   wire [7:0] product;
   multiplier_array the_multiplier_array(
      .alpha(alpha),
      .beta(beta),
      .product(product)
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
endmodule: multiplication_array


module multiplier_array(
   input [3:0] a,
   input [3:0] b,
   output [7:0] p
);
   wire w_1_1, w_1_2, w_1_3, w_1_4;
   wire w_2_1, w_2_2, w_2_3, w_2_4;
   wire w_3_1, w_3_2, w_3_3, w_3_4;
   wire w_4_1, w_4_2, w_4_3, w_4_4;


module multiplier_combinational(
   input [3:0] a,
   input [3:0] b,
   output [7:0] p
);
   wire c_1_1, c_1_2, c_1_3, c_1_4;
   wire c_2_1, c_2_2, c_2_3, c_2_4;
   wire c_3_1, c_3_2, c_3_3, c_3_4;
   wire c_4_1, c_4_2, c_4_3, c_4_4;

   wire s_1_1, s_1_2, s_1_3, s_1_4;
   wire s_2_1, s_2_2, s_2_3, s_2_4;
   wire s_3_1, s_3_2, s_3_3, s_3_4;
   wire s_4_1, s_4_2, s_4_3, s_4_4;

   half_adder half_1_1(a[0]&b[1], a[1]&b[0], c_1_1, s_1_1);
   half_adder half_1_2(a[0]&b[2], a[1]&b[1], c_1_2, s_1_2);
   half_adder half_1_3(a[0]&b[3], a[1]&b[2], c_1_3, s_1_3);
   full_adder full_1_4(a[1]&b[3], a[2]&b[2], c_1_3, c_1_4, s_1_4);

   full_adder full_2_1(s_1_2, a[2]&b[0], c_1_1, c_2_1, s_2_1);
   full_adder full_2_2(s_1_3, a[2]&b[1], c_1_2, c_2_2, s_2_2);
   full_adder full_2_3(s_1_4, a[3]&b[1], c_2_2, c_2_3, s_2_3);
   full_adder full_2_4(a[2]&b[3], a[3]&b[2], c_1_4, c_2_4, s_2_4);

   full_adder full_3_1(s_2_2, a[3]&b[0], c_2_1, c_3_1, s_3_1);
   half_adder half_3_2(c_3_1, s_2_3, c_3_2, s_3_2);
   full_adder full_3_3(c_2_3, s_2_4, c_3_2, c_3_3, s_3_3);
   full_adder full_3_4(c_2_4, a[3]&b[3], c_3_3, c_3_4, s_3_4);

   and(p[0], a[0], b[0]);
   assign p[1] = s_1_1;
   assign p[2] = s_2_1;
   assign p[3] = s_3_1;
   assign p[4] = s_3_2;
   assign p[5] = s_3_3;
   assign p[6] = s_3_4;
   assign p[7] = c_3_4;
endmodule: multiplier
 
module ripple_adder(
   input [3:0] a,
   input [3:0] b,
   output [3:0] c,
   output [3:0] s
);
   half_adder add_1(a[0], b[0], c[0], s[0]);
   full_adder add_2(a[1], b[1], c[0], c[1], s[1]);
   full_adder add_3(a[2], b[2], c[1], c[2], s[2]);
   full_adder add_4(a[3], b[3], c[2], c[3], s[3]);
endmodule: ripple_adder

module full_adder(
   input a,
   input b,
   input c_i,
   output c_o,
   output s
);
   wire c_1, c_2, t;
   half_adder add_1(a, b, c_1, t);
   half_adder add_2(c_i, t, c_2, s);
   or(c_o, c_1, c_2);
endmodule

module half_adder(
   input a,
   input b,
   output c,
   output s
);
   xor(s, a, b);
   and(c, a, b);
endmodule

module display(
   input clock,
   input [3:0] digit_1,
   input [3:0] digit_2,
   input [3:0] digit_3,
   input [3:0] digit_4,
   output [3:0] anode,
   output [6:0] cathode
);
   wire enable;
   wire [1:0] choice;
   wire [3:0] decision;
   clock_enable the_clock_moderate(1, clock, enable);
   anode_driver the_anode_driver(enable, choice, anode);
   multiplexer the_multiplexer(
      .digit_1(digit_1),
      .digit_2(digit_2),
      .digit_3(digit_3),
      .digit_4(digit_4),
      .choice(choice),
      .decision(decision)
   );
   decoder the_decoder(decision, cathode);
endmodule: display

module clock_enable(
   input [1:0] mode,
   input clock,
   input reset,
   output reg enable
);
   parameter mode_fast = 2'b00;
   parameter mode_moderate = 2'b01;
   parameter mode_slow = 2'b10;
   parameter ratio_fast = 16;
   parameter ratio_moderate = 2048;
   parameter ratio_slow = 524288;
   reg [16:0] count;
   wire [19:0] ratio;

   case (mode)    
      mode_fast:
         ratio = ratio_fast;
      mode_moderate:
         ratio = ratio_moderate;
      mode_slow:
         ratio = ratio_slow;
   endcase
   always @(posedge clock or posedge reset) begin
      if (reset) begin
         count  <= 1'b0;
         enable <= 1'b0;
      end
      else if (count == ratio - 1) begin
         count  <= 1'b0;
         enable <= 1'b1;
      end
      else begin
         count  <= count + 1'b1;
         enable <= 1'b0;
      end
   end
endmodule: clock_enable

module multiplexer(
   input [3:0] digit_1,
   input [3:0] digit_2,
   input [3:0] digit_3,
   input [3:0] digit_4,
   input [1:0] choice,
   output reg [3:0] decision
);
   always @(*) begin
     case(choice)
       2'b00: decision = digit_1;
       2'b01: decision = digit_2;
       2'b10: decision = digit_3;
       2'b11: decision = digit_4;
     endcase
   end
endmodule: multiplexer

module anode_driver(
   input enable,
   output reg [1:0] choice,
   output reg [3:0] anode
);
   always @(posedge enable) begin
     choice <= choice + 1;
     case(choice)
       4'b00: anode <= 4'b0111;
       4'b01: anode <= 4'b1011;
       4'b10: anode <= 4'b1101;
       4'b11: anode <= 4'b1110;
     endcase
   end
endmodule: anode_driver

module decoder(
   input [3:0] decision,
   output reg [6:0] cathode
);
   always @(*) begin
     case(decision)
       4'b0000: cathode = 7'b0000001;
       4'b0001: cathode = 7'b1001111;
       4'b0010: cathode = 7'b0010010;
       4'b0011: cathode = 7'b0000110;

       4'b0100: cathode = 7'b1001100;
       4'b0101: cathode = 7'b0100100;
       4'b0110: cathode = 7'b0100000;
       4'b0111: cathode = 7'b0001111;  

       4'b1000: cathode = 7'b0000000;
       4'b1001: cathode = 7'b0000100;
       4'b1010: cathode = 7'b0001000;
       4'b1011: cathode = 7'b1100000;

       4'b1100: cathode = 7'b0110001;
       4'b1101: cathode = 7'b1000010;
       4'b1110: cathode = 7'b0110000;
       4'b1111: cathode = 7'b0111000;
     endcase
   end
endmodule: decoder
