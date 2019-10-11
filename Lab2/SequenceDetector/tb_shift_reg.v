`timescale 1ns/1ns
module tb();
    reg CLK;
    reg RST; 
    reg SHIFT; 
    reg LOAD; 
    reg DIR; 
    reg[7:0] DATA; 
    reg SER_IN;
    wire[7:0] Q;
 
    parameter DUTY = 1;

    always #DUTY CLK = ~CLK;
    
    initial begin
        CLK     = 0;
        RST     = 1;
        LOAD    = 0;
        SHIFT   = 0;
        DIR     = 0;
        SER_IN  = 0;
        #10;
        RST     = 0;
        LOAD    = 1;
        SHIFT   = 0;
        DATA    = 8'b1010_1010;
        DIR     = 0;
    end

    always @(posedge CLK) begin
        if(RST) begin
            SHIFT <= 1'b0;
            DIR   <= 1'b0;
            LOAD  <= 1'b0;
        end
        else begin
            DIR     <= $random() % 2;
            SHIFT   <= $random() % 2;
            LOAD    <= $random() % 2;
            SER_IN  <= $random() % 2;
        end
    end

 shift_reg U_SHIFT_REG(
    .CLK(CLK),
    .RST(RST), 
    .SHIFT(SHIFT), 
    .LOAD(LOAD), 
    .DIR(DIR), 
    .DATA(DATA), 
    .SER_IN(SER_IN),
    .Q(Q));

endmodule : tb