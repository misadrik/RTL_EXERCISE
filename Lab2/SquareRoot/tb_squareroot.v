`timescale 1ns/1ns

module tb_squareroot();
    reg[15:0] Din;
    reg CLK;
    reg RST;
    wire[7:0] Dout;
    reg[7:0] squareroot;

    parameter DUTY = 10;

    always #DUTY CLK = ~CLK;

    initial begin
        CLK = 1;
        RST = 0;
 //       Din = $urandom() % 65536;
        #1000;
        $stop;
    end
   
    always@(posedge CLK) begin
        Din <= $urandom() % 65536;
        squareroot = $sqrt(Din);
        $display("%d 's squareroot is %d, function output: %d", Din, Dout, squareroot);
    end 

    squareroot U_SQUAREROOT(
     .CLK(CLK),
     .RST(RST),
     .Din(Din),
     .Dout(Dout));
endmodule