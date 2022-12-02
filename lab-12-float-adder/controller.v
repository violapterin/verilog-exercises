`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2021 01:36:08 PM
// Design Name: 
// Module Name: controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module controller(
    input clk, clr, we_move, 
    input wire start,
    output reg start_bit, norman, valid
    );
    reg [1:0] state, next_state;
    
    parameter start_s = 3'd0, norman_s = 3'b1, valid_s = 3'd2;
    
    always @(negedge clk or posedge clr) begin
        if (clr) state = start_s;
        else begin
            //$display("State before: %d", state);
            state = next_state;
            //$display("State after: %d", state);
        end
    end
    
    always @(start or state or we_move or valid) begin
        case(state)
            start_s: begin
                if (start == 0) next_state = start_s; 
                else if (start == 1) next_state = norman_s;
                else next_state = start_s;
            end
            norman_s: next_state = valid_s;
            valid_s: begin
                 if (start) next_state = start_s; 
                 else next_state = valid_s; 
            end
            default: next_state = start_s;
        endcase
    end
    
    always @(state) begin
        case(state)
            start_s: begin
                start_bit = 1;
                norman = 0;
                valid = 0;
            end
            norman_s: begin
                start_bit = 0;
                norman = 1;
                valid = 0;
            end
            valid_s: begin
                start_bit = 0;
                norman = 0;
                valid = 1;
            end
        endcase
    end
endmodule
