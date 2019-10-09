module top_counter #(
    parameter TIMER_NUM = 5)(
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low
    input[(TIMER_NUM*10-1):0] load_value,
    output [4:0] time_out
);

reg[9:0] cnt;

always @(posedge clk or negedge rst_n) begin : proc_cnt
    if(~rst_n) begin
        cnt <= 0;
    end else begin
        cnt <= cnt + 1;
    end
end


generate
    genvar i;
    for(i = 0; i<TIMER_NUM; i = i+1) begin : timer
        counter U_COUNTER(.CLK(clk), .rst_n(rst_n), .load_value(load_value[10*i+:10]), .global_cnt(cnt), .timer_expired_out(time_out[i])) ;
    end 
endgenerate

endmodule