`timescale 1ns/1ns

module tb();
    reg D_IN;
    reg RST;
    reg CLK;
    wire MATCH;
    integer fd_in;
    integer fd_out;
    integer test;
    integer fp;

    parameter DUTY = 1;

    always #DUTY CLK = ~CLK;

    initial begin
        fd_out = $fopen("./seq.out", "w");
        fd_in = $fopen("./pattern.in", "r");
        $fmonitor(fd_out, "At time %t ns, CLK=%d, RST=%d, D_IN=%d, MATCH=%d", $time, CLK, RST, D_IN, MATCH);
        
        RST = 1;
        CLK = 1;

        #8 
        RST = 0;
        #1000
        $fclose(fd_out);
    end

    always @(posedge CLK) begin
        
        fp = $fscanf(fd_in, "%1b", D_IN);
    end

    seq_detect U_SEQ_DETECT(D_IN, CLK, RST, MATCH);

endmodule