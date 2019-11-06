module ROUTER_NODE(
    input                   clk,
    input                   reset,
    output reg              polarity, 
// 1  virtual channel being forwarded externally for any clk cycle
    input                   cwsi,
    input  [63:0]           cwdi,
    output                  cwri,
    input                   cwro,
    output                  cwso,
    output [63:0]           cwdo,

    input                   ccwsi,
    input  [63:0]           ccwdi,
    output                  ccwri,
    input                   ccwro,
    output                  ccwso,
    output [63:0]           ccwdo,

    input                   pesi,
    input  [63:0]           pedi,
    output                  peri,
    input                   pero,
    output                  peso,
    output [63:0]           pedo);

    wire rst;

assign rst = reset;

always @(posedge clk) begin
    if(rst)
        polarity <= 1'b0;
    else
        polarity <= ~polarity;
end

wire                            pe2cw_req;
wire                            pe2ccw_req;
wire                            cw2cw_req;
wire                            ccw2ccw_req;
wire                            cw2pe_req;
wire                            ccw2pe_req;
wire                            cw2pe_gnt;
wire                            ccw2pe_gnt;
wire                            cw2cw_gnt;
wire                            ccw2ccw_gnt;
wire                            pe2cw_gnt;
wire                            pe2ccw_gnt;
wire[63:0]                      pe_dout;
wire[63:0]                      cw_dout;
wire[63:0]                      ccw_dout;
wire[63:0]                      pe_out_buf_in;
wire[63:0]                      cw_out_buf_in;
wire[63:0]                      ccw_out_buf_in;



ROUTER_INPUT_CTRL U_PE_IN_CTRL(.clk(clk), .rst(rst),.polarity(polarity),.ch2in_din(pedi),.ch2in_vld(pesi),.in2ch_rdy(peri),
    .in2cw_req(pe2cw_req),.in2ccw_req(pe2ccw_req),.cw2in_gnt(cw2pe_gnt),.ccw2in_gnt(ccw2pe_gnt),.in2out_dout(pe_dout));

PATH_INPUT_CTRL U_CW_IN_CTRL(.clk(clk), .rst(rst),.polarity(polarity),.ch2in_din(cwdi),.ch2in_vld(cwsi),.in2ch_rdy(cwri),.in2path_req(cw2cw_req),
    .in2pe_req(cw2pe_req),.path2in_gnt(cw2cw_gnt),.pe2in_gnt(pe2cw_gnt),.in2out_dout(cw_dout));

PATH_INPUT_CTRL U_CCW_IN_CTRL(.clk(clk), .rst(rst),.polarity(polarity),.ch2in_din(ccwdi),.ch2in_vld(ccwsi),.in2ch_rdy(ccwri),.in2path_req(ccw2ccw_req),
    .in2pe_req(ccw2pe_req),.path2in_gnt(ccw2ccw_gnt),.pe2in_gnt(pe2ccw_gnt),.in2out_dout(ccw_dout));

assign pe_out_buf_in = (pe2cw_gnt == 1'b1) ? cw_dout:
                        (pe2ccw_gnt == 1'b1) ? ccw_dout: 64'b0;

OUTPUT_CTRL U_PE_OUT_CTRL(.clk(clk),.rst(rst),.polarity(polarity),.path_rdy(pero),.din(pe_out_buf_in),
    .req_0(cw2pe_req),.req_1(ccw2pe_req),.gnt_0(pe2cw_gnt),.gnt_1(pe2ccw_gnt),.dout(pedo),.dout_vld(peso));

assign cw_out_buf_in = (cw2cw_gnt == 1'b1) ? cw_dout:
                        (cw2pe_gnt == 1'b1) ? pe_dout: 64'b0;

OUTPUT_CTRL U_CW_OUT_CTRL(.clk(clk),.rst(rst),.polarity(polarity),.path_rdy(cwro),.din(cw_out_buf_in),
    .req_0(cw2cw_req),.req_1(pe2cw_req),.gnt_0(cw2cw_gnt),.gnt_1(cw2pe_gnt),.dout(cwdo),.dout_vld(cwso));

assign ccw_out_buf_in = (ccw2ccw_gnt == 1'b1) ? ccw_dout :
                        (ccw2pe_gnt == 1'b1) ? pe_dout : 64'b0;

OUTPUT_CTRL U_CCW_OUT_CTRL(.clk(clk),.rst(rst),.polarity(polarity),.path_rdy(cwro),.din(ccw_out_buf_in),
    .req_0(ccw2ccw_req),.req_1(pe2ccw_req),.gnt_0(ccw2ccw_gnt),.gnt_1(ccw2pe_gnt),.dout(ccwdo),.dout_vld(ccwso));

endmodule : ROUTER_NODE