﻿// Lab 7: Multibit adders
// Tzuyu Jeng, Oct 19, 2022

`timescale 1ns / 1ps

module adder_ahead(
   input [3:0] alpha, input [3:0] beta,
   output [7:0] sum
);
   wire [3:0] gamma;
   wire [3:0] phi, chi;
   assign phi = alpha ^ beta;
   assign chi = alpha & beta;

   wire theta_1_1;
   wire theta_2_1, theta_2_2;
   wire theta_3_1, theta_3_2, theta_3_3;
   assign theta_1_1 = phi[1] && chi[0];
   assign theta_2_1 = phi[2] && chi[1];
   assign theta_2_2 = phi[2] && phi[1] && chi[0];
   assign theta_3_1 = phi[3] && chi[2];
   assign theta_3_2 = phi[3] && phi[2] && chi[1];
   assign theta_3_3 = phi[3] && phi[2] && phi[1] && chi[0];

   assign gamma[0] = chi[0];
   assign gamma[1] = chi[1] || theta_1_1;
   assign gamma[2] = chi[2] || theta_2_1 || theta_2_2;
   assign gamma[3] = chi[3] || theta_3_1 || theta_3_2 || theta_3_3;
   assign sum[3:0] = phi ^ {gamma[2:0], 1'b0};
   assign sum[7:4] = {3'b000, gamma[3]};
endmodule
 
module adder_ripple(
   input [3:0] alpha, input [3:0] beta,
   output [7:0] sum
);
   wire [3:0] gamma;
   half_adder adder_1(alpha[0], beta[0], gamma[0], sum[0]);
   full_adder adder_2(alpha[1], beta[1], gamma[0], gamma[1], sum[1]);
   full_adder adder_3(alpha[2], beta[2], gamma[1], gamma[2], sum[2]);
   full_adder adder_4(alpha[3], beta[3], gamma[2], gamma[3], sum[3]);
   assign sum[7:4] = {3'b000, gamma[3]};
endmodule

module full_adder(
   input alpha, input beta, input carry_in,
   output carry_out, output sum 
);
   wire phi, chi, psi;
   half_adder adder_1(alpha, beta, phi, psi);
   half_adder adder_2(carry_in, psi, chi, sum);
   or(carry_out, phi, chi);
endmodule

module half_adder(
   input alpha, input beta,
   output carry, output sum
);
   xor(sum, alpha, beta);
   and(carry, alpha, beta);
endmodule

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

