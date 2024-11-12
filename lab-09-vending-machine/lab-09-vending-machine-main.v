// Lab 9: Vending machine
// Tzuyu Jeng, Nov 4

`timescale 1ns / 1ps

module vending_machine (
   input clock, 
   input reset,
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
      .reset(reset),
      .button(button),
      .switch(switch),
      .amount(amount),
      .cost(cost)
   );
   seven_segment_display the_display(
      .clock(clock),
      .reset(reset),
      .digit_1(cost[7:4]),
      .digit_2(cost[3:0]),
      .digit_3(amount[7:4]),
      .digit_4(amount[3:0]),
      .anode(anode),
      .cathode(cathode)
   );
endmodule: vending_machine

