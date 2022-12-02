`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2021 02:00:52 PM
// Design Name: 
// Module Name: fp_adder
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

module fp_adder(
    input [7:0] a, b,
    input clk, clr, start,
    output [7:0] result,
    output valid
    );
    wire we_move, start_bit, norman;
    controller c1(.clk(clk), .clr(clr), .we_move(we_move), .start(start), .start_bit(start_bit), .norman(norman), .valid(valid));
    datapath d1(.a(a), .b(b), .clk(clk), .clr(clr), .start_bit(start_bit), .norman(norman), .we_move(we_move), .result(result));
endmodule
