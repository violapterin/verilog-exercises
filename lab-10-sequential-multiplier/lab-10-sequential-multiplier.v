// sequential multiplier
// adapted from Mano and Ciletti, 6e, p 516

module multiplication(
   input clock,
   input clear,
   input [3:0] alpha,
   input [3:0] beta,
   output [3:0] anode,
   output [6:0] cathode
);
   wire [7:0] result;
   wire ready;
   multiplier the_multiplier(
      .clock(clock),
      .clear(clear),
      .start(start),
      .number_one(number_one),
      .number_two(number_two),
      .result(result),
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
endmodule: multiplication

module multiplier(
   input clock,
   input clear,
   input start,
   input [3: 0] number_one,
   input [3: 0] number_two,
   output [3: 0] result,
);
   path_data(
      .clock(clock),
      .clear(clear),
      .number_one(number_one),
      .number_two(number_two),
      .flag_data(flag_data),
      .result(result),
      .flag_control(flag_control)
   );
   path_control(
      .clock(clock),
      .clear(clear),
      .start(start),
      .number_one(number_one),
      .number_two(number_two),
      .flag_control(flag_control)
      .flag_data(flag_data),
   );
endmodule: multiplier

module path_control(
   input clock,
   input clear,
   input start,
   input [1: 0] flag_control,
   output [3: 0] flag_data,
);
   parameter state_idle = 2'b01;
   parameter state_add = 2'b10;
   parameter state_shift = 2'b11;
   reg [2: 0] state;
   reg [2: 0] next;

   reg flag_load = flag_data[0];
   reg flag_decrease = flag_data[1];
   reg flag_add = flag_data[2];
   reg flag_shift = flag_data[3];
   wire flag_zero = flag_control[0];
   wire flag_onset = flag_control[1];

   always @ (posedge clock or posedge clear) begin
      if (clear)
         state <= state_idle;
      else
         state <= next;
   end

   always @(*) begin
      flag_load = 0;
      flag_decrease = 0;
      flag_add = 0;
      flag_shift = 0;
      next = state_idle;
      
      case (state)
         state_idle: begin
            if (start) begin
               flag_load = 1;
               next = state_add;
            end
         end
         state_add: begin
            flag_decrease = 1;
            if (flag_onset)
               flag_add = 1;
            next = state_shift;
         end
         state_shift: begin
            flag_shift = 1;
            if (flag_zero)
               next = state_idle;
            else
               next = state_add;
         end
         default:
            next = state_idle;
      endcase
   end
endmodule: path_control

module path_data(
   input clock,
   input clear,
   input number_one,
   input number_two,
   input [3: 0] flag_data,
   output result,
   output [1: 0] flag_control
);
   reg [3: 0] alpha;
   reg [3: 0] beta;
   reg [3: 0] gamma;
   reg carry;
   reg [2: 0] counter;

   reg flag_zero = flag_control[0];
   reg flag_onset = flag_control[1];
   wire flag_load = flag_data[0];
   wire flag_decrease = flag_data[1];
   wire flag_add = flag_data[2];
   wire flag_shift = flag_data[3];

   always @ (posedge clock) begin
      if (flag_load) begin
         alpha <= number_one;
         beta <= number_two;
         carry <= 0;
         gamma <= 0;
         counter <= width;
      end
      if (flag_add)
         {carry, gamma} <= gamma + alpha;
      if (flag_shift)
         {carry, gamma, beta} <= ({carry, gamma, beta} >> 1);
      if (flag_decrease)
         counter <= counter - 1;
   end

   flag_zero = (counter == 0);
   flag_onset = beta[0];

   always @(posedge clock or posedge clear) begin
      if(clear)
         alpha <= 0;
         beta <= 0;
         carry <= 0;
         gamma <= 0;
         counter <= 0;
         result <= 0;
      else
         result <= {gamma, beta};
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
