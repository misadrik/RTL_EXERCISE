module shift_reg(
    input CLK,
    input RST, 
    input SHIFT, 
    input LOAD, 
    input DIR, 
    input [7:0] DATA, 
    input SER_IN,
    output reg[7:0] Q);

    always@(posedge CLK or posedge RST) begin
        if(RST)
            Q <= 8'b0;
        else if(LOAD)
            Q <= DATA;
        else if(SHIFT) 
            Q <= DIR ?{Q[6:0], SER_IN}:{SER_IN, Q[7:1]};
        else
            ;
    end

endmodule