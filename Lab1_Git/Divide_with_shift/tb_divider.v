`timescale 1ns/1ns
module tb();
    reg clk;
    reg rst_n;
    reg  signed [31:0] dividend;
    reg  signed [31:0] divisor;
    wire signed [31:0] quotient;

    reg signed[31:0] dividend_1d;
    reg signed [31:0] divisor_1d;
    parameter DUTY = 1;

    always #DUTY clk = ~clk;

    initial begin
        clk = 1;
        rst_n = 0;
        #10
        rst_n = 1;
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
             dividend<= 0;
             divisor <= 0;
        end else begin
             dividend<= $urandom % 1000;
             divisor <= $urandom % 16;
        end
    end
    divider U_DIVIDER(.clk(clk), .rst_n(rst_n), .dividend(dividend), .divisor(divisor), .quotient(quotient));

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
             dividend_1d <= 0;
             divisor_1d  <= 0;
        end else begin
             dividend_1d <= dividend;
             divisor_1d  <= divisor;
        end
    end

    always @(*) begin
        if(dividend_1d/divisor_1d != quotient)
            $display("dividend: %h, divisor: %h, quotient: %h, quotient_gold: %h", dividend_1d, divisor_1d, quotient, dividend_1d/divisor_1d);
    end

endmodule : tb