// sequential multiplier

module multiplier_sequential(
   input clock,
   input clear,
   input start,
   input [3:0] alpha,
   input [3:0] beta,
   output [3:0] product,
);
   path_data(
      .clock(clock),
      .clear(clear),
      .alpha(alpha),
      .beta(beta),
      .flag_data(flag_data),
      .product(product),
      .flag_control(flag_control)
   );
   path_control(
      .clock(clock),
      .clear(clear),
      .start(start),
      .alpha(alpha),
      .beta(beta),
      .flag_control(flag_control)
      .flag_data(flag_data),
   );
endmodule: multiplier_sequential

// (moore machine)
module path_control(
   input clock,
   input reset,
   input start,
   input flag_zero_beta,
   input flag_least_bit_beta,
   output reg action_load_alpha,
   output reg action_load_beta,
   output reg action_shift_phi,
   output reg action_shift_chi,
   output reg action_load_product,
   output reg action_add_product
);
   parameter state_idle = 2'b00;
   parameter state_add = 2'b01;
   parameter state_load = 2'b10;
   parameter state_shift = 2'b11;
   reg [1:0] state;
   reg [1:0] state_next;
   reg action_load_alpha_next;
   reg action_load_beta_next;
   reg action_shift_phi_next;
   reg action_shift_chi_next;
   reg action_load_product_next;
   reg action_add_next;

   always @(*) begin
      case (state)
         state_idle: begin
            if (start)
               state_next = state_load;
            else
               state_next = state_idle;
         end
         state_load: begin
            action_load_alpha_next = 1;
            action_load_beta_next = 1;
            action_load_product_next = 1;
            if (flag_zero)
               state_next = state_idle;
            else if (flag_add)
               state_next = state_add;
            else
               state_next = state_shift;
         end
         state_add: begin
            action_add = 1;
            next = state_shift;
         end
         state_shift: begin
            action_shift_phi = 1;
            action_shift_chi = 1;
            if (flag_zero)
               state_next = state_idle;
            else if (flag_add)
               state_next = state_add;
            else
               state_next = state_shift;
         end
         default:
            next = state_idle;
      endcase
   end

   always @(negedge clock or posedge reset) begin
      if (reset) begin
         state <= state_idle;
         action_load_alpha <= 0;
         action_load_beta <= 0;
         action_shift_phi <= 0;
         action_shift_chi <= 0;
         action_load_product <= 0;
         action_add_product <= 0;
      end
      else begin
         state <= state_next;
         action_load_alpha <= action_load_alpha_next;
         action_load_beta <= action_load_beta_next;
         action_shift_phi <= action_shift_phi_next;
         action_shift_chi <= action_shift_chi_next;
         action_load_product <= action_load_product_next;
         action_add_product <= action_add_product_next;
      end
   end
endmodule: path_control

module path_data(
   input clock,
   input reset,
   input [3:0] alpha,
   input [3:0] beta,
   input action_load_alpha,
   input action_load_beta,
   input action_shift_phi,
   input action_shift_chi,
   input action_load_product,
   input action_add,
   output reg flag_zero,
   output reg flag_add,
   output [7:0] product,
);
   reg [7:0] phi; // alpha padded with zero
   reg [3:0] chi; // beta shifted

   always @ (posedge clock) begin
      if (action_load_alpha) begin
         phi <= {alpha, 4b'0000};
      end
      else if (action_load_beta) begin
         chi <= beta;
      end
      if (action_shift_phi) begin
         phi <= (phi << 1);
      end
      if (action_shift_chi) begin
         chi <= (chi >> 1);
      end
      else if (action_load_product) begin
         product <= 8b'00000000;
      end
      else if (action_add) begin
         product <= product + phi;
      end
   end

   always @(*) begin
      flag_zero = (chi == 0);
   end

   always @(*) begin
      flag_add = chi[0];
   end
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


