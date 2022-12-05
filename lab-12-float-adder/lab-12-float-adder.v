// Lab 11: Square root finder
// Tzuyu Jeng, Nov 4


`timescale 1ns / 1ps

module main(
   input clock,
   input clear,
   input [3:0] alpha,
   input [3:0] beta,
   output [7:0] result,
   output [3:0] anode,  
   output [6:0] cathode,
);
   float_adder(
      input clock,
      input clear,
      input [3:0] alpha,
      input [3:0] beta,
      input [7:0] result,
      output [3:0] anode,  
      output [6:0] cathode,
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
endmodule: main

module float_adder(
   input clock,
   input clear,
   input [3:0] alpha,
   input [3:0] beta,
   input [7:0] result,
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
endmodule: float_adder

module path_control(
   input clock,
   input clear,
   input [5:0] flag_control,
   output [6:0] flag_data,
);
   parameter state_idle = 3'b000;
   parameter state_load = 3'b001;
   parameter state_adjust = 3'b010;
   parameter state_add = 3'b011;
   parameter state_exception = 3'b100;
   parameter state_result = 3'b101;
   reg [2: 0] state;
   reg [2: 0] next;

   wire flag_alpha_abnormal = flag_control[0];
   wire flag_beta_abnormal = flag_control[1];
   wire flag_alpha_exponent_bigger = flag_control[2];
   wire flag_beta_exponent_bigger = flag_control[3];
   wire flag_overflow = flag_control[4];
   wire flag_gamma_abnormal = flag_control[5];

   reg flag_normalize_alpha = flag_data[0];
   reg flag_normalize_beta = flag_data[1];
   reg flag_shift_alpha = flag_data[2];
   reg flag_shift_beta = flag_data[3];
   reg flag_add = flag_data[4];
   reg flag_exception = flag_data[5];
   reg flag_normalize_gamma = flag_data[6];

   always @ (posedge clock or posedge clear) begin
      if (clear)
         state <= state_idle;
      else
         state <= next;
   end

   always @(*) begin
      flag_normalize_alpha = 0;
      flag_normalize_beta = 0;
      flag_shift_alpha = 0;
      flag_shift_beta = 0;
      flag_add = 0;
      flag_exception = 0;
      flag_normalize_gamma  = 0;
      next = state_load;

      case (state) begin
         state_idle:
            next = state_load;
         state_load:
            flag_load = 1;
            if (flag_alpha_abnormal):
               flag_normalize_alpha = 1;
            else if (flag_beta_abnormal):
               flag_normalize_beta = 1;
            else
               next = state_adjust;
         state_adjust:
            if (flag_alpha_exponent_bigger)
               flag_shift_alpha = 1;
            if (flag_beta_exponent_bigger)
               flag_shift_beta = 1;
            else
               next = state_add;
         state_add:
            flag_add = 1;
            if (flag_overflow)
               next = state_exception;
            else
               next = state_result;
         state_exception:
            flag_exception = 1;
            next = state_output;
         state_result:
            if (flag_gamma_abnormal)
               flag_normalize_gamma = 1;
            else
               next = state_idle;
      endcase
   end
endmodule: path_control

module path_data(
   input clock,
   input clear,
   input [7:0] number_one,
   input [7:0] number_two,
   input [6:0] flag_data,
   output [7:0] result
   output [5:0] flag_control,
);
   wire sign_one = number_one[7];
   wire sign_two = number_two[7];
   wire [3:0] exponent_one = number_one[6:3];
   wire [3:0] exponent_two = number_two[6:3];
   wire [2:0] fraction_one = number_one[2:0];
   wire [2:0] fraction_two = number_two[2:0];

   reg [3:0] exponent_alpha;
   reg [3:0] exponent_beta;
   reg [3:0] exponent_gamma;
   reg [4:0] mantissa_alpha;
   reg [4:0] mantissa_beta;
   reg [4:0] mantissa_gamma;
   reg overflow;

   wire flag_normalize_alpha = flag_data[0];
   wire flag_normalize_beta = flag_data[1];
   wire flag_shift_alpha = flag_data[2];
   wire flag_shift_beta = flag_data[3];
   wire flag_add = flag_data[4];
   wire flag_exception = flag_data[5];
   wire flag_normalize_gamma = flag_data[6];

   reg flag_alpha_abnormal = flag_control[0];
   reg flag_beta_abnormal = flag_control[1];
   reg flag_alpha_exponent_bigger = flag_control[2];
   reg flag_beta_exponent_bigger = flag_control[3];
   reg flag_overflow = flag_control[4];
   reg flag_gamma_abnormal = flag_control[5];

   always @(*) begin
      if (flag_load) begin
         exponent_alpha = exponent_one;
         mantissa_alpha[4] = sign_one;
         mantissa_alpha[3] = 1;
         mantissa_alpha[2:0] = number_one[2:0];
         exponent_beta = exponent_two;
         mantissa_beta[4] = sign_two;
         mantissa_beta[3] = 1;
         mantissa_beta[2:0] = number_two[2:0];
      end

      if (flag_normalize_alpha) begin
         exponent_alpha = exponent_alpha + 1;
         mantissa_alpha[3] = 0;
      end
      if (flag_normalize_beta) begin
         exponent_beta = exponent_beta + 1;
         mantissa_beta[3] = 0;
      end

      if (flag_shift_alpha) begin
         exponent_alpha = exponent_alpha + 1;
         mantissa_alpha = (mantissa_alpha >> 1);
      end
      if (flag_shift_beta) begin
         exponent_beta = exponent_beta + 1;
         mantissa_beta = (mantissa_beta >> 1);

      if (flag_add)
         exponent_gamma = exponent_alpha;
         {overflow, mantissa_gamma} = {0, mantissa_alpha} + {0, mantissa_beta};
      if (flag_exception)
         exponent_gamma = 15;
         mantissa_gamma = 0;
      if (flag_normalize_gamma) begin
         exponent_result = exponent_result + 1;
         mantissa_result[3] = 0;
      end
   end

   flag_alpha_exponent_bigger = (exponent_alpha > exponent_beta);
   flag_beta_exponent_bigger = (exponent_beta > exponent_alpha);
   flag_alpha_abnormal = (exponent_alpha == 0);
   flag_beta_abnormal = (exponent_beta == 0);
   flag_gamma_abnormal = (exponent_gamma == 0);
   flag_overflow = overflow;

   always @(posedge clock or posedge clear) begin
      if (clear) begin
         sign_one <= 0;
         sign_two <= 0;
         exponent_one <= 0;
         exponent_two <= 0;
         fraction_one <= 0;
         fraction_two <= 0;
         exponent_alpha <= 0;
         exponent_beta <= 0;
         exponent_gamma <= 0;
         mantissa_alpha <= 0;
         mantissa_beta <= 0;
         mantissa_gamma <= 0;
         overflow <= 0;
      end
      else begin
         result <= {mantissa_gamma[3], exponent_gamma, mantissa_gamma[2:0]};
      end
   end
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
   input clear,
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
   always @(posedge clock or posedge clear) begin
      if (clear) begin
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
