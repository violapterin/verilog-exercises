`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2021 12:44:34 PM
// Design Name: 
// Module Name: datapath
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


module datapath(
    input [7:0] a, b,
    input clk, clr, start_bit, norman, 
    output reg we_move,
    output reg [7:0] result
    );
    integer a_int, b_int, sign_gt, sign_lt, mant_gt, mant_lt, exp_gt, exp_lt, sign_ans, exp_ans, mant_ans, temp;
    
    always @(posedge clk or posedge clr) begin
        if (start_bit || clr) begin
            we_move = 0;
            result = 8'b0;
            if (a[6:3] > b [6:3]) begin //both are same sign and a exponent is bigger
                 $display("In 3");
                sign_gt = a[7];
                exp_gt = a[6:3];
                mant_gt = a[2:0] + 8;
                sign_lt = b[7];
                exp_lt = b[6:3];
                $display("so what u doing: b[2:0] is: %b, result is: %b",b[2:0], b[2:0]+ 8);
                mant_lt = b[2:0] + 8;
            end else if (a[6:3] < b [6:3]) begin //both are same sign and b exponent is bigger
                 $display("In 4");
                sign_gt = b[7];
                exp_gt = b[6:3];
                mant_gt = b[2:0] + 8;
                sign_lt = a[7];
                exp_lt = a[6:3];
                mant_lt = a[2:0] + 8;
            end else if (a[2:0] > b [2:0]) begin //both are same exponent and a mant is bigger
                $display("In 5");
                sign_gt = a[7];
                exp_gt = a[6:3];
                mant_gt = a[2:0] + 8;
                sign_lt = b[7];
                exp_lt = b[6:3];
                mant_lt = b[2:0] + 8;
            end else if (a[2:0] < b [2:0]) begin //both are same exp and b mant is bigger
                 $display("In 6");
                sign_gt = b[7];
                exp_gt = b[6:3];
                mant_gt = b[2:0] + 8;
                sign_lt = a[7];
                exp_lt = a[6:3];
                mant_lt = a[2:0] + 8;
            end
            //load in values for answer
            exp_ans = exp_gt;
            sign_ans = sign_gt;
            mant_lt = mant_lt >> (exp_gt - exp_lt);
            //perform operation
            $display("mant_gt is: %b, mant_lt is: %b", mant_gt, mant_lt);
            mant_ans = (sign_gt == sign_lt)? mant_gt + mant_lt :mant_gt - mant_lt;
            we_move = 1;
        end else if (norman) begin
            we_move = 0;
            $display("mantissa is (begin): %b", mant_ans);
            if (mant_ans[4] == 1) begin
                $display("first");
                while (mant_ans[4] == 1) begin
                    temp = mant_ans[0];
                    mant_ans = mant_ans >> 1;
                    if (temp) mant_ans = mant_ans + 1; //round
                    exp_ans = exp_ans +1;
                end
            end else if (mant_ans[4] == 0 && mant_ans[3] == 0) begin
                $display("second");
                while (mant_ans[4] == 0 && mant_ans[3] == 0) begin
                    temp = mant_ans[0];
                    $display("mantissa is (before shift): %b", mant_ans);
                    mant_ans = mant_ans << 1;
                    $display("mantissa is (after shift): %b", mant_ans);
                    //if (temp) mant_ans = mant_ans + 1; //round
                    exp_ans = exp_ans -1;
                end
            end
        result[7] = sign_ans;
        result[6:3] = exp_ans;
        $display("mantissa is (end): %b", mant_ans);
        result [2:0] = mant_ans[2:0];    
            
        end
        
    end
endmodule
