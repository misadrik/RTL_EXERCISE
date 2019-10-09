`timescale  1ns/1ns
module tb ();
    reg         CLK;
    reg         RST_n;
    reg[3:0]    seed;
    wire[3:0]   random_gen;
    reg         load;

    parameter DUTY = 1;

    always #DUTY CLK = ~CLK;

    initial begin
        CLK = 1;
        RST_n = 0;
        load  = 0;
        #10
        RST_n = 1;
        load = 1;
        seed = 4'b0110;
        #2
        load = 0;
        #30
        load = 1;
        seed = 4'b1111;
        #2
        load = 0;
        #10
        RST_n = 1;

    end

    random_gen U_random_gen(.clk(CLK),.rst_n(RST_n),.seed(seed),.load(load), .random_gen(random_gen));


endmodule