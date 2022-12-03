// Lab 9: Vending machine
// Tzuyu Jeng, Nov 4


`timescale 1ns / 1ps

module vending_machine (
   input clock, 
   input clear,
   input [2:0] button, 
   input [3:0] switch,
   output [3:0] anode,  
   output [6:0] cathode
);
   wire [7:0] amount;
   wire [7:0] cost;
   wire [7:0] product;
   wire [3:0] state;
   wire [3:0] next;
   
   vendor the_vendor(
      .clock(clock),
      .clear(clear),
      .button(button),
      .switch(switch),
      .amount(amount),
      .cost(cost),
      .state(state),
      .next(next)
   );
   display the_display (
      .clock  (clock),
      .digit_1(amount[7:4]),
      .digit_2(amount[3:0]),
      .digit_3(cost[7:4]),
      .digit_4(cost[3:0]),
      .anode  (anode) 
      .cathode(cathode)
   );
endmodule: vending_machine

module vendor(
   input clock,
   input clear,
   input [2:0] button,
   input [3:0] switch,
   output reg [7:0] amount,
   output reg [7:0] cost
);
   
   parameter entered_00 = 4'b0000,
   parameter entered_05 = 4'b0001;
   parameter entered_10 = 4'b0010,
   parameter entered_15 = 4'b0011;
   parameter entered_20 = 4'b0100,
   parameter entered_25 = 4'b0101;
   parameter entered_30 = 4'b0110,
   parameter entered_35 = 4'b0111;

   parameter change_00  = 4'b1000,
   paramter  change_05  = 4'b1001;
   parameter change_10  = 4'b1010,
   parameter change_15  = 4'b1011;
   parameter change_20  = 4'b1100;

   parameter product_15 = 4'd8;
   parameter product_20 = 4'd4;
   parameter product_25 = 4'd2;
   parameter product_30 = 4'd1;

   parameter quarter    = 3'd4;
   parameter dime       = 3'd2;
   parameter nickel     = 3'd1;

   wire enable;
   wire [3:0] state;
   wire [3:0] next;

   clock_enable the_clock_slow(2, clock, enable);
   
   always @(*) begin
      case(state)
         entered_00: begin
            if (button == nickel)
               next = entered_05;
            else if (button == dime)
               next = entered_10;
            else if (button == quarter)
               next = entered_25;
            else
               next = entered_00;
         end

         entered_05: begin
            if (button == nickel)
               next = entered_10;
            else if (button == dime)
               next = entered_15;
            else if (button == quarter)
               next = entered_30;
            else
               next = entered_05;
         end

         entered_10: begin
            if (button == nickel)
               next = entered_15;
            else if (button == dime)
               next = entered_20;
            else if (button == quarter)
               next = entered_35;
            else
               next = entered_10;
         end

         entered_15: begin
            if (button == nickel)
               next = entered_20;
            else if (button == dime)
               next = entered_25;
            else if (button == quarter)
               next = entered_35;
            else if (switch == product_15)
               next = change_00;
            else
               next = entered_15;
         end

         entered_20: begin
            if (button == nickel)
               next = entered_25;
            else if (button == dime)
               next = entered_30;
            else if (button == quarter)
               next = entered_35;
            else if (switch == product_15)
               next = change_05;
            else if (switch == product_20)
               next = change_00;
            else
               next = entered_20;
         end

         entered_25: begin
            if (button == nickel)
               next = entered_30;
            else if (button == dime | button == quarter)
               next = entered_35;
            else if (switch == product_15)
               next = change_10;
            else if (switch == product_20)
               next = change_05;
            else if (switch == product_25)
               next = change_00;
            else
               next = entered_25;
         end

         entered_30: begin
            if (button == nickel | button == dime | button == quarter)
               next = entered_35;
            else if (switch == product_15)
               next = change_15;
            else if (switch == product_20)
               next = change_10;
            else if (switch == product_25)
               next = change_05;
            else if (switch == product_30)
               next = change_00;
            else
               next = entered_30;
         end

         entered_35: begin
            if (switch == product_15)
               next = change_20;
            else if (switch == product_20)
               next = change_15;
            else if (switch == product_25)
               next = change_10;
            else if (switch == product_30)
               next = change_05;
            else
               next = entered_35;
         end

         change_00: next = entered_00;
         change_05: next = entered_00;
         change_10: next = entered_00;
         change_15: next = entered_00;
         change_20: next = entered_00;

         default: next = entered_00;
      endcase
   end

   always @(posedge enable or posedge clear) begin
      if (clear)
         state <= entered_00;
      else
         state <= next;
   end
   
   always @(*) begin
      case(switch)
         product_15: cost = 8'd15;
         product_20: cost = 8'd20;
         product_25: cost = 8'd25;
         product_30: cost = 8'd30;
         default: cost = 8'h00;
      endcase
      
      case(state)
         entered_00: amount = 8'd00;
         entered_05: amount = 8'd05;
         entered_10: amount = 8'd10;
         entered_15: amount = 8'd15;
         entered_20: amount = 8'd20;
         entered_25: amount = 8'd25;
         entered_30: amount = 8'd30;
         entered_35: amount = 8'd35;
         change_00: amount = 8'd00;
         change_05: amount = 8'd05;
         change_10: amount = 8'd10;
         change_15: amount = 8'd15;
         change_20: amount = 8'd20;
         default: amount = 8'd00;
      endcase
   end
endmodule: vendor

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
   input [2:0] mode,
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
