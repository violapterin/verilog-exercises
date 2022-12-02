// Lab 11: Square root finder
// Tzuyu Jeng, Nov 4


`timescale 1ns / 1ps

module float_adder(
   input clock,
   input clear,
   input [3:0] alpha,
   input [3:0] beta,
   output [7:0] result,
   output [3:0] anode,  
   output [6:0] cathode,
);
   wire start_bit, normal;
   path_control the_path_control(
      .clock(clock),
      .clear(clear),
      .start(start),
      .start_bit(start_bit),
      .normal(normal),
      .valid(valid)
   );
   path_data the_path_data(
      .a(a),
      .b(b),
      .clock(clock),
      .clear(clear),
      .start_bit(start_bit),
      .normal(normal),
      .result(result)
   );
   display the_display(
      .clock(clock),
      .digit_1(alpha),
      .digit_2(beta),
      .digit_3(result[7:4]),
      .digit_4(result[3:0]),
      .anode(anode),
      .cathode(cathode)
   );
endmodule



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
      .greater(greater)
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

module path_control(
    input clock, clear,
    input start,
    output reg start_bit, normal, valid
    );
    reg [1:0] state, next;
    
    parameter start_s = 3'd0, normal_s = 3'b1, valid_s = 3'd2;
    
    always @(negedge clock or posedge clear) begin
        if (clear) state = start_s;
        else begin
            state = next;
        end
    end
    
    always @(*) begin
        case(state)
            start_s: begin
               if (start == 0)
                  next = start_s; 
               else if (start == 1)
                  next = normal_s;
            end
            normal_s: next = valid_s;
            valid_s: begin
                 if (start) next = start_s; 
                 else next = valid_s; 
            end
            default: next = start_s;
        endcase
    end
    
    always @(*) begin
        case(state)
            start_s: begin
                start_bit = 1;
                normal = 0;
                valid = 0;
            end
            normal_s: begin
                start_bit = 0;
                normal = 1;
                valid = 0;
            end
            valid_s: begin
                start_bit = 0;
                normal = 0;
                valid = 1;
            end
        endcase
    end
endmodule: path_control

module path_data(
    input [7:0] a, b,
    input clock, clear, start_bit, normal, 
    output reg [7:0] result
    );
    integer a_int, b_int, sign_gt, sign_lt, mant_gt, mant_lt, exp_gt, exp_lt, sign_ans, exp_ans, mant_ans, hold;
    
    always @(posedge clock or posedge clear) begin
      if (start_bit || clear) begin
         result = 8'b0;
         if (a[6:3] > b [6:3]) begin // same sign, alpha exponent bigger
            sign_gt = a[7];
            exp_gt = a[6:3];
            mant_gt = a[2:0] + 8;
            sign_lt = b[7];
            exp_lt = b[6:3];
            mant_lt = b[2:0] + 8;
         end
         else if (a[6:3] < b [6:3]) begin // same sign, beta exponent bigger
            sign_gt = b[7];
            exp_gt = b[6:3];
            mant_gt = b[2:0] + 8;
            sign_lt = a[7];
            exp_lt = a[6:3];
            mant_lt = a[2:0] + 8;
         end
         else if (a[2:0] > b [2:0]) begin // same exponent, alpha mantissa bigger
               sign_gt = a[7];
               exp_gt = a[6:3];
               mant_gt = a[2:0] + 8;
               sign_lt = b[7];
               exp_lt = b[6:3];
               mant_lt = b[2:0] + 8;
         end
         else if (a[2:0] < b [2:0]) begin // same exponent, beta mantissa bigger
               sign_gt = b[7];
               exp_gt = b[6:3];
               mant_gt = b[2:0] + 8;
               sign_lt = a[7];
               exp_lt = a[6:3];
               mant_lt = a[2:0] + 8;
         end
         exp_ans = exp_gt;
         sign_ans = sign_gt;
         mant_lt = mant_lt >> (exp_gt - exp_lt);
         //perform operation
         mant_ans = (
            (sign_gt == sign_lt) ?
            (mant_gt + mant_lt) :
            (mant_gt - mant_lt)
         );
      end
      else if (normal) begin
         if (mant_ans[4] == 1) begin
               while (mant_ans[4] == 1) begin
                  hold = mant_ans[0];
                  mant_ans = mant_ans >> 1;
                  if (hold) mant_ans = mant_ans + 1; //round
                  exp_ans = exp_ans +1;
               end
         end
         else if (mant_ans[4] == 0 && mant_ans[3] == 0) begin
               while (mant_ans[4] == 0 && mant_ans[3] == 0) begin
                  hold = mant_ans[0];
                  mant_ans = mant_ans << 1;
                  //if (hold) mant_ans = mant_ans + 1; //round
                  exp_ans = exp_ans -1;
               end
         end
         result[7] = sign_ans;
         result[6:3] = exp_ans;
         result[2:0] = mant_ans[2:0];    
      end
    end
endmodule: path_data



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
