module INTERCONNECT_TOP (
    input                   clk,
    input                   rst,
    input [1:0]             addr_0,
    input [63:0]            d_in_0,
    input                   nicEN_0,
    input                   nicWrEn_0,
    output  [63:0]          d_out_0,

    input [1:0]             addr_1,
    input [63:0]            d_in_1,
    input                   nicEN_1,
    input                   nicWrEn_1,
    output  [63:0]          d_out_1,

    input [1:0]             addr_2,
    input [63:0]            d_in_2,
    input                   nicEN_2,
    input                   nicWrEn_2,
    output [63:0]           d_out_2,

    input [1:0]             addr_3,
    input [63:0]            d_in_3,
    input                   nicEN_3,
    input                   nicWrEn_3,
    output  [63:0]          d_out_3);

    wire [63:0]             cwd_3_0;
    wire                    cws_3_0;
    wire                    cwr_0_3;
            
    wire [63:0]             cwd_0_1;
    wire                    cws_0_1;
    wire                    cwr_1_0;

    wire [63:0]             cwd_1_2;
    wire                    cws_1_2;
    wire                    cwr_2_1;
            
    wire [63:0]             cwd_2_3;
    wire                    cws_2_3;
    wire                    cwr_3_2;

    wire [63:0]             ccwd_1_0;
    wire                    ccws_1_0;
    wire                    ccwr_0_1;
            
    wire [63:0]             ccwd_0_3;
    wire                    ccws_0_3;
    wire                    ccwr_3_0;

    wire [63:0]             ccwd_3_2;
    wire                    ccws_3_2;
    wire                    ccwr_2_3;
            
    wire [63:0]             ccwd_2_1;
    wire                    ccws_2_1;
    wire                    ccwr_1_2;

NIC_TOP U0_NIC_TOP(.clk(clk),.rst(rst),.addr(addr_0),.d_in(d_in_0),.nicEN(nicEN_0),.nicWrEn(nicWrEn_0),.d_out(d_out_0),
                    .cwdi(cwd_3_0),.cwsi(cws_3_0),.cwri(cwr_0_3),
                    .cwdo(cwd_0_1),.cwso(cws_0_1),.cwro(cwr_1_0),   
                    .ccwdi(ccwd_1_0),.ccwsi(ccws_1_0),.ccwri(ccwr_0_1),
                    .ccwdo(ccwd_0_3),.ccwso(ccws_0_3),.ccwro(ccwr_3_0));
    

NIC_TOP U1_NIC_TOP(.clk(clk),.rst(rst),.addr(addr_1),.d_in(d_in_1),.nicEN(nicEN_1),.nicWrEn(nicWrEn_1),.d_out(d_out_1),
                    .cwdi(cwd_0_1),.cwsi(cws_0_1),.cwri(cwr_1_0),
                    .cwdo(cwd_1_2),.cwso(cws_1_2),.cwro(cwr_2_1),   
                    .ccwdi(ccwd_2_1),.ccwsi(ccws_2_1),.ccwri(ccwr_1_2),
                    .ccwdo(ccwd_1_0),.ccwso(ccws_1_0),.ccwro(ccwr_0_1));
 
NIC_TOP U2_NIC_TOP(.clk(clk),.rst(rst),.addr(addr_2),.d_in(d_in_2),.nicEN(nicEN_2),.nicWrEn(nicWrEn_2),.d_out(d_out_2),
                    .cwdi(cwd_1_2),.cwsi(cws_1_2),.cwri(cwr_2_1),
                    .cwdo(cwd_2_3),.cwso(cws_2_3),.cwro(cwr_3_2),   
                    .ccwdi(ccwd_3_2),.ccwsi(ccws_3_2),.ccwri(ccwr_2_3),
                    .ccwdo(ccwd_2_1),.ccwso(ccws_2_1),.ccwro(ccwr_1_2));

NIC_TOP U3_NIC_TOP(.clk(clk),.rst(rst),.addr(addr_3),.d_in(d_in_3),.nicEN(nicEN_3),.nicWrEn(nicWrEn_3),.d_out(d_out_3),
                    .cwdi(cwd_2_3),.cwsi(cws_2_3),.cwri(cwr_3_2),
                    .cwdo(cwd_3_0),.cwso(cws_3_0),.cwro(cwr_0_3),   
                    .ccwdi(ccwd_0_3),.ccwsi(ccws_0_3),.ccwri(ccwr_3_0),
                    .ccwdo(ccwd_3_2),.ccwso(ccws_3_2),.ccwro(ccwr_2_3));
endmodule