`timescale 1ns/1ns
module tb();
    reg clk;
    reg rst_n;
    integer i;

    parameter DUTY = 1;
    parameter TIMER_NUM = 5;
    reg [(TIMER_NUM*10-1):0] load_value;
    wire[4:0] time_out;

    always #DUTY clk = ~clk;

    initial begin
        clk = 1;
        rst_n = 0;
        #6
        rst_n = 1;
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
             load_value <= 'b0;
        end else begin
             for(i = 0; i < TIMER_NUM; i = i+1) begin
                if(time_out[i] == 1'b1) begin
                    load_value[i*10+:10] <= $urandom % 10'hf;
                end
             end
        end
    end
    top_counter #(.TIMER_NUM(5)) U_TOP_COUNTER (.clk(clk),.rst_n(rst_n),.load_value(load_value),.time_out(time_out));

endmodule : tb