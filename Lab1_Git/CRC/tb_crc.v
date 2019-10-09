`timescale 1ns/100ps
module tb();
    reg RST;
    reg CLK;
    reg [31:0] D_IN;
    wire [35:0] D_OUT;
    integer fp;
    integer i;

    parameter DUTY = 2;
    always #DUTY CLK = ~CLK;

    initial begin
        CLK = 1;
        RST = 1;
        #8
        RST = 0;
    end

    initial begin
        fp = $fopen("./crc.out","w");
        $fmonitor(fp, "At time", $time, " ns, rst = %h, in = %h, out = %h", RST, D_IN, D_OUT);
        $monitor("At time", $time, " ns, rst = %h, in = %h, out = %h", RST, D_IN, D_OUT);
        #1000
        $fclose(fp);
        $stop;
    end

    always @(posedge CLK) begin
        if(RST)
            D_IN <= 32'b0;
        else
            for(i = 0; i <20; i = i + 1)
                 D_IN <= $urandom % 32'hffff_ffff;

    end

    CRC U_CRC(.D_IN(D_IN), .CLK(CLK), .RST(RST), .D_OUT(D_OUT));


endmodule