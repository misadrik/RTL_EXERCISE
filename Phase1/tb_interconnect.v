`timescale 1ns/1ns
module tb_interconnect();
    reg                     clk;
    reg                     rst;
    reg [1:0]               addr_0;
    reg [63:0]              d_in_0;
    reg                     nicEN_0;
    reg                     nicWrEn_0;
    wire [63:0]             d_out_0;

    reg [1:0]               addr_1;
    reg [63:0]              d_in_1;
    reg                     nicEN_1;
    reg                     nicWrEn_1;
    wire [63:0]             d_out_1;

    reg [1:0]               addr_2;
    reg [63:0]              d_in_2;
    reg                     nicEN_2;
    reg                     nicWrEn_2;
    wire [63:0]             d_out_2;

    reg [1:0]               addr_3;
    reg [63:0]              d_in_3;
    reg                     nicEN_3;
    reg                     nicWrEn_3;
    wire [63:0]             d_out_3;

    always #1 clk = ~clk;

initial begin
    clk = 1;
    rst = 1;
    #9;
    rst = 0;
end

initial begin
    #10
    addr_0 = 2'b10;
    addr_1 = 2'b10;
    addr_2 = 2'b10;
    addr_3 = 2'b10;

    nicEN_0 = 1'b1;
    nicEN_1 = 1'b1;
    nicEN_2 = 1'b1;
    nicEN_3 = 1'b1;

    nicWrEn_0 = 1'b1;
    nicWrEn_1 = 1'b1;
    nicWrEn_2 = 1'b1;
    nicWrEn_3 = 1'b1;

    d_in_0 = {1'b0,1'b0,6'b0,8'hff,16'b0,32'hffff_fff0};
    d_in_1 = {1'b0,1'b1,6'b0,8'hff,16'b0,32'hffff_fff1};
    d_in_2 = {1'b1,1'b0,6'b0,8'hff,16'b0,32'hffff_fff2};
    d_in_3 = {1'b1,1'b1,6'b0,8'hff,16'b0,32'hffff_fff3};

    #4
    d_in_0 = {1'b0,1'b0,6'b0,8'hff,16'b0,32'hffff_0000};
    d_in_1 = {1'b0,1'b1,6'b0,8'hff,16'b0,32'hffff_0001};
    d_in_2 = {1'b1,1'b0,6'b0,8'hff,16'b0,32'hffff_0002};
    d_in_3 = {1'b1,1'b1,6'b0,8'hff,16'b0,32'hffff_0003};    

    #4
    d_in_0 = {1'b0,1'b0,6'b0,8'h1f,16'b0,32'hffff_aaa3};
    d_in_1 = {1'b0,1'b1,6'b0,8'h3f,16'b0,32'hffff_aaa3};
    d_in_2 = {1'b1,1'b0,6'b0,8'h7f,16'b0,32'hffff_aaa3};
    d_in_3 = {1'b1,1'b1,6'b0,8'hff,16'b0,32'hffff_aaa3}; 
    #4
    d_in_0 = {1'b0,1'b0,6'b0,8'h1f,16'b0,32'hffff_bbb3};
    d_in_1 = {1'b0,1'b1,6'b0,8'h3f,16'b0,32'hffff_bbb3};
    d_in_2 = {1'b1,1'b0,6'b0,8'h7f,16'b0,32'hffff_bbb1};
    d_in_3 = {1'b1,1'b1,6'b0,8'hff,16'b0,32'hffff_bbb3};       
    #5
    nicWrEn_0 = 1'b0;
    nicWrEn_1 = 1'b0;
    nicWrEn_2 = 1'b0;
    nicWrEn_3 = 1'b0;

    addr_0 = 2'b00;
    addr_1 = 2'b00;
    addr_2 = 2'b00;
    addr_3 = 2'b00;
end


INTERCONNECT_TOP U_INTERCONNECT_TOP(
    .clk(clk),
    .rst(rst),
    .addr_0(addr_0),
    .d_in_0(d_in_0),
    .nicEN_0(nicEN_0),
    .nicWrEn_0(nicWrEn_0),
    .d_out_0(d_out_0),

    .addr_1(addr_1),
    .d_in_1(d_in_1),
    .nicEN_1(nicEN_1),
    .nicWrEn_1(nicWrEn_1),
    .d_out_1(d_out_1),

    .addr_2(addr_2),
    .d_in_2(d_in_2),
    .nicEN_2(nicEN_2),
    .nicWrEn_2(nicWrEn_2),
    .d_out_2(d_out_2),

    .addr_3(addr_3),
    .d_in_3(d_in_3),
    .nicEN_3(nicEN_3),
    .nicWrEn_3(nicWrEn_3),
    .d_out_3(d_out_3));

endmodule