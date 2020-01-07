module axi_top(
    input                    clk,
    input                    rst_n,

    output [2:0]             slave_ARID,
    output [2:0]             slave_ARADDR,
    output                   slave_ARVLD,
    input                    slave_ARRDY,
    //read data
    input   [2:0]            slave_RID,
    input   [7:0]            slave_RDATA,
    input                    slave_RVLD,
    output                   slave_RRDY,
    //write addr
    output [2:0]             slave_AWID,
    output [2:0]             slave_AWADDR,
    output                    slave_AWVLD,
    input                   slave_AWRDY,
    //write data
    output [2:0]             slave_WID,
    output [7:0]             slave_WDATA,
    output                   slave_WVLD,
    input                    slave_WRDY,
    //write resp
    input [2:0]              slave_BID,
    input                    slave_BRESP,
    input                    slave_BVLD,
    output                   slave_BRDY, 
    //read addr

    input [2:0]              master_ARID,
    input [2:0]              master_ARADDR,
    input                    master_ARVLD,
    output                   master_ARRDY,
    //read data
    output [2:0]             master_RID,
    output [7:0]             master_RDATA,
    output                   master_RVLD,
    input                    master_RRDY,
    //write addr
    input [2:0]              master_AWID,
    input [2:0]              master_AWADDR,
    input                    master_AWVLD,
    output                   master_AWRDY,
    //write data
    input [2:0]              master_WID,
    input [7:0]              master_WDATA,
    input                    master_WVLD,
    output                   master_WRDY,
    //write resp
    output[2:0]              master_BID,
    output                   master_BRESP,
    output                   master_BVLD,
    input                    master_BRDY);

wire                  sif2mif_fifo_empty;
wire[31:0]            sif_s2m_fifo_dout;
wire                  s2m_fifo_full;
wire                  s2m_fifo_empty;
wire                  mif_m2s_fifo_empty;
wire[31:0]            mif_m2s_fifo_dout;
wire                  sif_m2s_fifo_full;


master_if U_master_if(.clk(clk),.rst_n(rst_n),
    //read addr
.ARID(slave_ARID),.ARADDR(slave_ARADDR),.ARVLD(slave_ARVLD),.ARRDY(slave_ARRDY),
    //read data
.RID(slave_RID),.RDATA(slave_RDATA),.RVLD(slave_RVLD),.RRDY(slave_RRDY),
    //write addr
.AWID(slave_AWID),.AWADDR(slave_AWADDR),.AWVLD(slave_AWVLD),.AWRDY(slave_AWRDY),
    //write data
.WID(slave_WID),.WDATA(slave_WDATA),.WVLD(slave_WVLD),.WRDY(slave_WRDY),
    //write resp
.BID(slave_BID),.BRESP(slave_BRESP),.BVLD(slave_BVLD),.BRDY(slave_BRDY),

    //to master_if
.mif_m2s_fifo_empty(mif_m2s_fifo_empty),.mif_m2s_fifo_dout(mif_m2s_fifo_dout),.mif_m2s_fifo_ren(!sif_m2s_fifo_full),
.s2m_fifo_wen(!s2m_fifo_empty),.sif2mif_din(sif_s2m_fifo_dout),.s2m_fifo_full(s2m_fifo_full));


slave_if U_slave_if(.clk(clk),.rst_n(rst_n),
    //read addr
.ARID(master_ARID),.ARADDR(master_ARADDR),.ARVLD(master_ARVLD),.ARRDY(master_ARRDY),
    //read data
.RID(master_RID),.RDATA(master_RDATA),.RVLD(master_RVLD),.RRDY(master_RRDY),
    //write addr
.AWID(master_AWID),.AWADDR(master_AWADDR),.AWVLD(master_AWVLD),.AWRDY(master_AWRDY),
    //write data
.WID(master_WID),.WDATA(master_WDATA),.WVLD(master_WVLD),.WRDY(master_WRDY),
    //write resp
.BID(master_BID),.BRESP(master_BRESP),.BVLD(master_BVLD),.BRDY(master_BRDY),

    //to master_if
.sif_s2m_fifo_dout(sif_s2m_fifo_dout),.sif_s2m_fifo_ren(!s2m_fifo_full),.s2m_fifo_empty(s2m_fifo_empty),
.mif2sif_wen(!mif_m2s_fifo_empty),.mif2sif_din(mif_m2s_fifo_dout),.sif_m2s_fifo_full(sif_m2s_fifo_full));


endmodule