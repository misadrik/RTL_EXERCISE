`timescale 1ns/1ns
module tb();
    reg CLK;
    reg RST;

    parameter DUTY = 1;

    always #1 CLK = ~CLK;

    initial begin
        CLK = 1;
        RST = 0;
        #10
        RST = 1;
    end

    optimal_place U_OPTIMAL_PLACE(.CLK(CLK), .RST_n(RST));
    
endmodule