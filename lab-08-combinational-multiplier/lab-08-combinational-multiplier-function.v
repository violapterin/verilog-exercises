// Lab 8: Multiplier
// Tzuyu Jeng, Oct 27

`timescale 1ns / 1ps

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
endmodule: multiplier_combinational

// // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // //

module multiplier_array(
   input [3:0] alpha,
   input [3:0] beta,
   output [7:0] product
);
   wire s_0_0, s_0_1, s_0_2, s_0_3;
   wire s_1_0, s_1_1, s_1_2, s_1_3;
   wire s_2_0, s_2_1, s_2_2, s_2_3;
   wire s_3_0, s_3_1, s_3_2, s_3_3;
   wire s_4_0, s_4_1, s_4_2;
   wire c_0_0, c_0_1, c_0_2, c_0_3;
   wire c_1_0, c_1_1, c_1_2, c_1_3;
   wire c_2_0, c_2_1, c_2_2, c_2_3;
   wire c_3_0, c_3_1, c_3_2, c_3_3;
   wire c_4_0, c_4_1, c_4_2;

   block_0_0 block(alpha[0], beta[0],     0,     0, s_0_0, c_0_0);
   block_0_1 block(alpha[1], beta[0],     0,     0, s_0_1, c_0_1);
   block_0_2 block(alpha[2], beta[0],     0,     0, s_0_2, c_0_2);
   block_0_3 block(alpha[3], beta[0],     0,     0, s_0_3, c_0_3);

   block_1_0 block(alpha[0], beta[1], s_0_1, c_0_0, s_1_0, c_1_0);
   block_1_1 block(alpha[1], beta[1], s_0_2, c_0_1, s_1_1, c_1_1);
   block_1_2 block(alpha[2], beta[1], s_0_3, c_0_2, s_1_2, c_1_2);
   block_1_3 block(alpha[3], beta[1],     0, c_0_3, s_1_3, c_1_3);

   block_2_0 block(alpha[0], beta[2], s_1_1, c_1_0, s_2_0, c_2_0);
   block_2_1 block(alpha[1], beta[2], s_1_2, c_1_1, s_2_1, c_2_1);
   block_2_2 block(alpha[2], beta[2], s_1_3, c_1_2, s_2_2, c_2_2);
   block_2_3 block(alpha[3], beta[2],     0, c_1_3, s_2_3, c_2_3);

   block_3_0 block(alpha[0], beta[3], s_2_1, c_2_0, s_3_0, c_3_0);
   block_3_1 block(alpha[1], beta[3], s_2_2, c_2_1, s_3_1, c_3_1);
   block_3_2 block(alpha[2], beta[3], s_2_3, c_2_2, s_3_2, c_3_2);
   block_3_3 block(alpha[3], beta[3],     0, c_2_3, s_3_3, c_3_3);

   full_4_1 full_adder(s_3_1, c_3_0,     0, s_4_0, c_4_0);
   full_4_2 full_adder(s_3_2, c_3_1, c_4_0, s_4_1, c_4_1);
   full_4_3 full_adder(s_3_3, c_3_2, c_4_1, s_4_2, c_4_2);

   assign product[0] = s_0_0;
   assign product[1] = s_1_0;
   assign product[2] = s_2_0;
   assign product[3] = s_3_0;
   assign product[4] = s_4_0;
   assign product[5] = s_4_1;
   assign product[6] = s_4_2;
   assign product[7] = c_4_2;
endmodule: multiplier_array

module block(
   input phi, input chi,
   input sum_in, input carry_in,
   output sum_out, output carry_out
);
   and(beta, phi, chi);
   full_adder the_full_adder(
      sum_in, beta, carry_in, carry_out, sum_out
   );
endmodule: block

// // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // //

// legacy code
module multiplier_booth(
   input [3:0] A,
   input [3:0] B,
   output [7:0] P
);
   wire signed [9:0] x1, x2, x3;
   wire signed [9:0] P1, P2, P3;
      
   boothEncode b1({B[1:0], 1'b0}, A, x1);
   boothEncode b2(B[3:1], A, x2);
   boothEncode b3({2'b0, B[3]}, A, x3);

   assign P1 = x1;
   assign P2 = (P1>>>2) + x2;
   assign P3 = (P2>>>2) + x3;
   assign P = P3[7:0];
endmodule: multiplier_booth

module encode_booth(
    input [2:0] bits,
    input [3:0] A,
    output [9:0] y
    );
   
   wire [5:0] A1 = {2'b0, A};
   reg [5:0] x;
   assign y = {x, 4'b0};
   
   always @(bits or A1) begin
      case(bits)
         0: x = 0;
         1: x = A1;
         2: x = A1;
         3: x = A1<<1;
         4: x = ~(A1<<1) + 1;
         5: x = ~A1 + 1;
         6: x = ~A1 + 1;
         7: x = 0;
         default: x = 0;
      endcase
   end
endmodule: encode_booth

// // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // //

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

// // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // //

module seven_segment_display(
   input clock, input reset,
   input [3:0] digit_1, input [3:0] digit_2,
   input [3:0] digit_3, input [3:0] digit_4,
   output [3:0] anode, output [6:0] cathode
);
   wire enable;
   wire [1:0] choice;
   wire [3:0] decision;
   clock_enable the_clock_enable(
      .mode(2'b01),
      .clock(clock),
      .reset(reset),
      .enable(enable)
   );
   anode_driver the_anode_driver(
      .enable(enable),
      .reset(reset),
      .choice(choice),
      .anode(anode)
   );
   multiplexer the_multiplexer(
      .digit_1(digit_1),
      .digit_2(digit_2),
      .digit_3(digit_3),
      .digit_4(digit_4),
      .choice(choice),
      .decision(decision)
   );
   decoder the_decoder(
      .decision(decision),
      .cathode(cathode)
   );
endmodule: seven_segment_display

module decoder(
   input [3:0] decision,
   output reg [6:0] cathode
);
   always @(*) begin
      case (decision)
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

module multiplexer(
   input [3:0] digit_1, input [3:0] digit_2,
   input [3:0] digit_3, input [3:0] digit_4,
   input [1:0] choice,
   output reg [3:0] decision
);
   always @(*) begin
      case (choice)
         4'b00: decision = digit_1;
         4'b01: decision = digit_2;
         4'b10: decision = digit_3;
         4'b11: decision = digit_4;
      endcase
   end
endmodule: multiplexer

module anode_driver(
   input enable, input reset,
   output reg [1:0] choice, output reg [3:0] anode
);
   always @(posedge enable or posedge reset) begin
      if (reset == 1) begin
         choice <= 0;
      end
      else if (enable == 1) begin
         choice <= choice + 1;
      end
   end
   always @(*) begin
      case (choice)
         4'b00: anode = 4'b0111;
         4'b01: anode = 4'b1011;
         4'b10: anode = 4'b1101;
         4'b11: anode = 4'b1110;
      endcase
   end
endmodule: anode_driver

module clock_enable(
   input [1:0] mode, input clock, input reset,
   output reg enable
);
   parameter mode_fast = 2'b00;
   parameter mode_moderate = 2'b01;
   parameter mode_slow = 2'b10;
   parameter ratio_fast = 28'h0000400;
   parameter ratio_moderate = 28'h0040000;
   parameter ratio_slow = 28'h4000000;
   reg [28:0] count;
   reg [28:0] ratio;

   always @(*) begin
      case (mode)    
         mode_fast: ratio = ratio_fast;
         mode_moderate: ratio = ratio_moderate;
         mode_slow: ratio = ratio_slow;
      endcase
   end

   always @(posedge clock or posedge reset) begin
      if (reset) begin
         count  <= 28'h0000000;
         enable <= 0;
      end
      else if (count == ratio - 28'h0000001) begin
         count  <= 28'h0000000;
         enable <= 1;
      end
      else begin
         count  <= count + 28'h0000001;
         enable <= 0;
      end
   end
endmodule: clock_enable

