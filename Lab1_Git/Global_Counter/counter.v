 module counter( 
        input CLK, 
        input rst_n, 
        input[9:0] load_value,
        input[9:0] global_cnt, 
        output timer_expired_out);

reg [9:0] cnt_saved;

always @(posedge CLK or negedge rst_n) begin 
     if(~rst_n) begin
          cnt_saved <= global_cnt;
     end else if(timer_expired_out == 1'b1) begin
          cnt_saved <= global_cnt + load_value;
     end
end

 // always @(posedge CLK or negedge rst_n) begin
 //     if(~rst_n) begin
 //        timer_expired_out <= 1'b1;
 //     end else if(cnt_saved == global_cnt - 1)begin
 //        timer_expired_out <= 1'b1;
 //     end else begin
 //        timer_expired_out <= 1'b0;
 //     end
 // end

    assign timer_expired_out = (cnt_saved == global_cnt - 1)? 1'b1 : 1'b0;


endmodule : counter