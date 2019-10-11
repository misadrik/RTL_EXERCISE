module seq_detect (D_IN, CLK, RST, MATCH);
     input  CLK, RST, D_IN;
     output MATCH;

     wire[7:0] Q;

     wire MATCH_comb;
     reg MATCH_1d;

     //assign MATCH = (({Q[6:0],D_IN} == 8'b1010_1010) ||(Q == 8'b1010_1010)) ? 1'b1: 1'b0;
     //assign MATCH_comb = (Q == 8'b1010_1010) ? 1'b1: 1'b0;
    assign MATCH = (Q == 8'b1010_1010) ? 1'b1: 1'b0;
/*
     always @(posedge CLK or posedge RST) begin
         if(RST) begin
            MATCH_1d <= 0;
         end else begin
            MATCH_1d <= MATCH_comb;
         end
     end

     assign MATCH = MATCH_comb || MATCH_1d;
*/
 shift_reg U_SHIFT_REG(
    .CLK(CLK),
    .RST(RST), 
    .SHIFT(1'b1), // shift on every clock
    .LOAD(1'b0), // always no load
    .DIR(1'b1),     //always shift left
    .DATA(8'b0000_0000), 
    .SER_IN(D_IN),
    .Q(Q));

endmodule