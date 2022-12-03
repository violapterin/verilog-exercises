// Lab 11: Square root finder
// Tzuyu Jeng, Nov 4


`timescale 1ns / 1ps

module square_root(
   input clock, 
   input clear,
   input [3:0] alpha,
   output [3:0] anode,  
   output [6:0] cathode,
);
   wire [5:0] control;
   
   module path_control(
      .clock(clock),
      .clear(clear),
      .start(start),
      .control(control),
      .valid(valid)
   );
   module path_data(
      .clock(clock),
      .clear(clear),
      .alpha(alpha),
      .control(control),
      .square_root(square_root),
   );
   display the_display(
      .clock(clock),
      .digit_1(square_root),
      .digit_2(alpha),
      .digit_3(4'b0000),
      .digit_4(4'b0000),
      .anode(anode),
      .cathode(cathode)
   );
endmodule: square_root

module path_control(
   input clock,
   input clear,
   input start,
   input greater,
   output reg [5:0] control,
   output valid
);
   parameter idle = 2'b11;
   parameter load = 2'b00;
   parameter add = 2'b01;
   parameter divide = 2'b10;

   reg [1:0] state;
   reg [1:0] next;
   
   always @(*) begin
      case(state)
         idle:
            if(start)
               next = load;
            else
               next = idle;
         load:
            if(greater)
               next = divide;
            else
               next = add;
         add:
            if(greater)
               next = divide;
            else
               next = add;
         divide:
            next = idle;
         default:
            next = idle;
      endcase;
   end
      
   always @(negedge clock or posedge clear)
      if(clear)
         state <= idle;
      else
         state <= next;
         
   always @(state)
      case(state)
         idle:
            control = 6'b100000;
         load:
            control = 6'b001110;
         add:
            control = 6'b001111;
         divide:
            control = 6'b010000;
         default:
            control = 6'b000000;
      endcase;
         
   assign flag_increment = control[0];
   assign flag_alpha = control[1];
   assign flag_square = control[2];
   assign flag_delta = control[3];
   assign flag_out = control[4];
   assign valid = control[5];
endmodule: path_control

module path_data(
   input clock,
   input clear,
   input [7:0] alpha,
   input [5:0] control,
   output reg [3:0] square_root,
);
    reg [8:0] square;
    reg [5:0] delta;
    reg [7:0] beta;
    
    always @(posedge clock or posedge clear)
      if(clear)
         beta <= 0;
      else if(flag_alpha)
         beta <= alpha;
         
    always @(posedge clock or posedge clear)
      if(clear)
         square <= 0;
      else if(flag_square)
         if(flag_increment)
            square <= square + delta;
         else
            square <= 1;
   
   always @(posedge clock or posedge clear)
      if(clear)
         delta <= 0;
      else if(flag_delta)
         if(flag_increment)
            delta <= delta + 2;
         else
            delta <= 3;
      
   always @(posedge clock or posedge clear)
      if(clear)
         square_root = 0;
      else if(flag_out)
         square_root = (delta >> 1) - 1;
         
   assign flag_increment = control[0];
   assign flag_alpha = control[1];
   assign flag_square = control[2];
   assign flag_delta = control[3];
   assign flag_out = control[4];
   assign valid = control[5];
endmodule: path_data

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
      digit_1,
      digit_2,
      digit_3,
      digit_4,
      choice,
      decision
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


// // // // // // // // // // // // // // // //


`timescale 1ns / 1ps


module vending_machine_test();
   reg clear = 0;
   reg clock;
   initial begin
        clock <= 0;
        forever begin
          #10 clock <= clock + 1;
        end
   end

   reg [2:0] button;
   initial begin
         button[0] <= 0;
         forever #30 button[0] <= button[0] + 1;
   end
   initial begin
         button[1] <= 0;
         forever #50 button[1] <= button[1] + 1;
   end
   initial begin
         button[2] <= 0;
         forever #190 button[2] <= button[2] + 1;
   end

   reg [3:0] switch;
   initial begin
         switch[0] <= 0;
         forever #20 switch[0] <= switch[0] + 1;
   end
   initial begin
         switch[1] <= 0;
         forever #70 switch[1] <= switch[1] + 1;
   end
   initial begin
         switch[2] <= 0;
         forever #230 switch[2] <= switch[2] + 1;
   end
   initial begin
         switch[3] <= 0;
         forever #310 switch[3] <= switch[3] + 1;
   end

   wire [3:0] anode;
   wire [6:0] cathode;
   wire [3:0] state, next;
   vending_machine the_vending_machine(
     clock, clear,
     button, switch,
     anode, cathode,
     state, next
   );
endmodule
