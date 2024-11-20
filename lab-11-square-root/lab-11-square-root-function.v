// Lab 11: Square root finder
// Tzuyu Jeng, Nov 4

`timescale 1ns / 1ps

// (moore machine)
module path_control(
   input clock,
   input reset,
   input start,
   input flag_greater,
   output reg action_load,
   output reg action_add,
   output reg action_half
);
   parameter state_idle = 2'b00;
   parameter state_load = 2'b01;
   parameter state_add = 2'b10;
   parameter state_half = 2'b11;
   reg [1:0] state, state_next;
   reg action_load_next, action_add_next, action_half_next;


   always @(*) begin
      case (state)
         state_idle: begin
            if (start)
               state_next = state_load;
            else
               state_next = state_idle;
         end
         state_load: begin
            action_load_next = 1;
            if (flag_greater)
               state_next = state_half;
            else
               state_next = state_add;
         end
         state_add: begin
            action_add_next = 1;
            state_next = state_load;
         end
         state_half: begin
            action_half_next = 1;
            state_next = state_idle;
         end
         default: begin
            state_next = state_idle;
         end
      endcase
   end

   always @(negedge clock or posedge reset) begin
      if (reset) begin
         state <= state_idle;
         action_load <= 0;
         action_add <= 0;
         action_half <= 0;
      end
      else begin
         state <= state_next;
         action_load <= action_load_next;
         action_add <= action_add_next;
         action_half <= action_half_next;
      end
   end
endmodule: path_control

module path_data(
   input clock,
   input reset,
   input [7:0] alpha,
   input action_load,
   input action_add,
   input action_half,
   output reg flag_greater,
   output reg [7:0] root
);
   reg [7:0] delta, delta_next;
   reg [7:0] square, square_next;

   always @(posedge clock or posedge reset) begin
      if (reset) begin
         delta <= 3;
         square <= 1;
         root <= 0;
      end
      else if (action_load) begin
         square_next <= square + delta;
         delta_next <= delta + 2;
      end
      else if (action_add) begin
         square <= square_next;
         delta <= delta_next;
      end
      else if (action_half) begin
         root <= (delta >> 1) - 1;
      end
   end
   
   always @(*) begin
      flag_greater = (square > alpha);
   end
endmodule: path_data

// // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // //

module convert_base(
   input [7:0] hexadecimal,
   output [11:0] decimal
);
   reg shift_1, shift_2, shift_3;
   reg remain_1, remain_2, remain_3;
   always @(*) begin
      shift_1 = hexadecimal / 10;
      shift_2 = hexadecimal / 100;
      shift_3 = hexadecimal / 1000;
   end

   always @(*) begin
      remain_1 = hexadecimal - 10 * shift_1;
      remain_2 = shift_1 - 10 * shift_2;
      remain_3 = shift_2 - 10 * shift_3;
   end

   assign decimal = {remain_3, remain_2, remain_1};
endmodule: convert_base

module show_result(
   input reset,
   input show,
   input [11:0] alpha,
   input [11:0] root,
   output reg [11:0] result
);
   always @(posedge reset or posedge show) begin
      if (reset) begin
         result <= alpha;
      end
      else if (show) begin
         result <= root;
      end
   end
endmodule: show_result

// // // // // // // // // // // // // // // // // //
// // // // // // // // // // // // // // // // // //

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

