module divider (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low
    input [31:0] dividend,
    input [31:0] divisor,
    output reg [31:0] quotient
);

    wire[31:0] quotient_internal;
    wire[31:0] dividend_internal;
    wire[31:0] divisor_internal;
    wire       quotient_neg;

    assign quotient_neg = dividend[31] ^ divisor[31];

    assign dividend_internal = abs_out(dividend);
    assign divisor_internal  = abs_out(divisor);

    assign quotient_internal = quotient_out(dividend_internal, divisor_internal);

    always @(posedge clk or negedge rst_n) begin : proc_quotient
        if(~rst_n) begin
            quotient <= 32'h0;
        end else begin
            // $display("dividend: %d", dividend);
            quotient <= quotient_neg ? (~quotient_internal + 1): quotient_internal;
        end
    end


    function  [31:0] quotient_out;
    input [31:0] dividend;
    input [31:0] divisor;

    reg quotient_neg;
    reg[31:0] quotient_internal;
    reg[31:0] internal_val;
    integer i;


    begin
        if(divisor == 32'b0)
            quotient_out = 32'h7fff_ffff;
        else if(dividend[31] == 1'b1) // since all value pass in this function should be all positive, overflow is considered
            quotient_out = 32'h7fff_ffff;
        else begin
            quotient_internal = 32'b0;
            internal_val      = 32'b0;
            for(i = 0; i < 32; i =  i +1) begin
                    internal_val = internal_val<<1;
                    internal_val = internal_val + dividend[31-i];
                    quotient_internal = quotient_internal << 1;

                    if(internal_val > divisor) begin
                        internal_val = internal_val - divisor;
                        quotient_internal = quotient_internal + 1;
                    end
            end
            quotient_out = quotient_internal;
        end
    end
    endfunction

    function [31:0] abs_out;
        input [31:0] data_in;

        begin
            assign abs_out = data_in[31] ? (~data_in + 1) : data_in;
        end
    endfunction

endmodule