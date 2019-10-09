`timescale 1ns/1ns
module tb();
    reg[3:0] req;
    wire[3:0] grant;
    reg RST;
    reg enable;
    reg CLK;
    integer i;
    parameter DUTY = 1;

    always #DUTY CLK = ~CLK;

    initial begin

        CLK = 1;
        RST = 1;
        enable = 0;
        req = 4'b0;
        //repeat(5)  @(posedge CLK)
        #4
        RST = 0;
        //@(posedge CLK)
        enable = 1;
        req = 4'd15;
        #20
        req = $urandom % 4'hf;
        #16
        req = $urandom % 4'hf;
        #16
        req = $urandom % 4'hf;
        #12
        enable = 0;
        req = $urandom % 4'hf;
        #2
        enable = 1;
        #12
        $stop;
    end

    arbiter_LRU4 u_arbiter_LRU4(.grant_vector(grant), .req_vector(req), .enable(enable), .CLK(CLK), .RST(RST));

    always@(posedge CLK) begin
        for(i=0; i<4; i=i+1) begin
            if(grant[i] == 1'b1)
                req[i] = 1'b0;
        end
    end



endmodule