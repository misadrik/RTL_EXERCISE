`timescale 1ns/1ns
module tb();
    reg CLK;
    reg RST;
    wire    [2:0]     x_min;
    wire    [2:0]     y_min;
    wire    [15:0]    cost_mini;
    wire              output_vld;

    parameter DUTY = 1;

    always #1 CLK = ~CLK;

    initial begin
        CLK = 1;
        RST = 0;
        #10
        RST = 1;
    end

    always @(posedge CLK or negedge RST) begin : proc_output_vld
        if(output_vld == 1'b1) begin
            $display("x = %d, y= %d, total_cost = %d",x_min, y_min, cost_mini);
            $display("At_time: %t",$time);
            $stop;
        end
    end

    optimal_place U_OPTIMAL_PLACE(.CLK(CLK), .RST_n(RST),.x_min(x_min),.y_min(y_min),.cost_mini(cost_mini),.output_vld(output_vld));
    
endmodule