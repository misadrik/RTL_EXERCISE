/*
addr NIC_internal regs
00      in ch buffer
01      in ch status reg
10      out ch buffer
11      out ch status reg
*/
module NIC(
    //interface to the processor
    input               clk,
    input               reset,
    input [1:0]         addr,
    input [63:0]        d_in,
    input               nicEN,
    input               nicWrEn,
    output reg [63:0]   d_out,
    //interface to the router
    output reg          net_so,
    input               net_ro,
    output reg[63:0]    net_do,
    input               net_polarity,
    input               net_si,
    output reg          net_ri,
    input  [63:0]       net_di);

   reg [63:0]  net_in_ch_buf;
   reg net_in_ch_status;
   reg [63:0]  net_out_ch_buf;
   reg net_out_ch_status;

   wire rst;
   assign rst = reset;
   /******************************** Interface with processor *******************/ 

   always@(posedge clk) begin
    if(rst) begin
        net_out_ch_buf <= 64'b0;
    end
    else if((nicEN == 1'b1) && (nicWrEn == 1'b1) &&(addr== 2'b10) && (net_out_ch_status == 1'b0)) begin
        net_out_ch_buf <= d_in;
    end
   end

   always@(posedge clk) begin
    if(rst) begin
        d_out <= 64'b0;
    end
    else if((nicEN == 1'b1) && (nicWrEn == 1'b0) &&(addr== 2'b00)) begin
        d_out <= net_in_ch_buf;
    end
    else if((nicEN == 1'b1) && (nicWrEn == 1'b0) &&(addr== 2'b01)) begin
        d_out <= {net_in_ch_status, 63'b0};
    end
    else if((nicEN == 1'b1) && (nicWrEn == 1'b0) &&(addr== 2'b11)) begin
        d_out <= {net_out_ch_status, 63'b0};
    end
    else if(nicEN == 1'b0)begin
        d_out <= 64'b0;
    end
   end

   always@(posedge clk) begin
    if(rst) begin
        net_out_ch_status <= 1'b0;
    end
    else if((nicEN == 1'b1) && (nicWrEn == 1'b1) && (addr== 2'b10) && (net_out_ch_status == 1'b0)) begin
        net_out_ch_status <= 1'b1;
    end
    else if((net_ro == 1'b1) && (net_polarity == net_out_ch_buf[63]) && (net_out_ch_status == 1'b1)) begin
        net_out_ch_status <= 1'b0;
    end
   end

   always@(*) begin
    
    net_so = 1'b0;
    net_do = 64'b0;
    if((net_ro == 1'b1) && (net_polarity == net_out_ch_buf[63]) && (net_out_ch_status == 1'b1)) begin
        net_so = 1'b1;
        net_do = net_out_ch_buf;
    end
    else begin
        net_so = 1'b0;
        net_do = 64'b0;
    end
   end

   /******************************** Interface with router *******************/ 

   always@(posedge clk) begin
    if(rst) begin
        net_ri <= 1'b1;
    end
    else if((net_in_ch_status == 1'b1) || ((net_in_ch_status == 1'b0) && (net_si == 1'b1))) begin
        net_ri <= 1'b0;
    end
    else if(net_in_ch_status == 1'b0) begin
        net_ri <= 1'b1;
    end
   end

   always@(posedge clk) begin
    if(rst) begin
        net_in_ch_status <= 1'b0;
    end
    else if((net_ri == 1'b1)&&(net_si == 1'b1) && (net_in_ch_status == 1'b0)) begin
        net_in_ch_status <= 1'b1;
    end
    else if((nicEN == 1'b1) && (nicWrEn == 1'b0) &&(addr== 2'b00) && (net_in_ch_status == 1'b1)) begin
        net_in_ch_status <= 1'b0;
    end
   end

   always@(posedge clk) begin
    if(rst) begin
        net_in_ch_buf <= 64'b0;
    end
    else if((net_ri == 1'b1)&&(net_si == 1'b1)&&(net_in_ch_status == 1'b0)) begin
        net_in_ch_buf <= net_di;
    end
   end


endmodule