// Lab 11: Square root finder
// Tzuyu Jeng, Nov 4

`timescale 1ns / 1ps

// (moore machine)
module path_control(
   input clock,
   input reset,
   input start,
   input flag_greater,
   output action_load,
   output action_add,
   output action_half
);
   parameter state_idle = 2'b00;
   parameter state_load = 2'b01;
   parameter state_add = 2'b10;
   parameter state_half = 2'b11;
   reg [1:0] state;
   reg [1:0] next;

   always @(*) begin
      flag_greater = 0;
      flag_load = 0;
      flag_add = 0;
      flag_half = 0;
      next = state_idle;
      
      case(state)
         state_idle: begin
            if (start)
               next = state_load;
            else
               next = state_idle;
         end
         state_load: begin
            action_half = 1;
            next = state_add;
         end
         state_add: begin
            action_half = 1;
            if (flag_greater)
               next = state_half;
            else
               next = state_add;
         end
         state_half: begin
            action_half = 1;
            next = state_idle;
         end
         default:
            next = state_idle;
      endcase
   end

   always @(negedge clock or posedge reset) begin
      if (reset)
         state <= idle;
      else
         state <= next;
   end
endmodule: path_control

module path_data(
   input clock,
   input reset,
   input [7:0] number,
   input action_load,
   input action_add,
   input action_half,
   output flag_greater,
   output result
);
   reg [7:0] alpha;
   reg [7:0] delta;
   reg [7:0] square;

   always @(posedge clock or posedge reset) begin
      if (reset) begin
         alpha <= 0;
         delta <= 3;
         square <= 1;
         result <= 0;
      end
      else if (flag_load) begin
         alpha <= number;
      end
      else if (flag_add) begin
         square <= square + delta;
         delta <= delta + 2;
      end
      else if (flag_half) begin
         result <= (delta >> 1) - 1;
      end
   end
   
   flag_greater = (square > alpha);
endmodule: path_data

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
   parameter ratio_fast = 18'h0080;
   parameter ratio_moderate = 18'h0800;
   parameter ratio_slow = 16'h8000;
   reg [16:0] count;
   reg [18:0] ratio;

   case (mode)    
      mode_fast: ratio = ratio_fast;
      mode_moderate: ratio = ratio_moderate;
      mode_slow: ratio = ratio_slow;
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
