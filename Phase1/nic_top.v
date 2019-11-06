module NIC_TOP(
    //interface to the processor
    input                   clk,
    input                   rst,
    input [1:0]             addr,
    input [63:0]            d_in,
    input                   nicEN,
    input                   nicWrEn,
    output  [63:0]          d_out,
    //interface to the router
    input [63:0]            cwdi,
    input                   cwsi,
    output                  cwri,
            
    output [63:0]           cwdo,
    output                  cwso,
    input                   cwro,   
    
    input [63:0]            ccwdi,
    input                   ccwsi,
    output                  ccwri,
            
    output [63:0]           ccwdo,
    output                  ccwso,
    input                   ccwro);

    wire                    net_so;
    wire                    net_ro;
    wire[63:0]              net_do;
    wire                    polarity;
    wire                    net_si;
    wire                    net_ri;
    wire  [63:0]            net_di;


NIC U_NIC(
    //interface to the processor
    .clk(clk),
    .reset(rst),
    .addr(addr),
    .d_in(d_in),
    .nicEN(nicEN),
    .nicWrEn(nicWrEn),
    .d_out(d_out),
    //interface to the router
    .net_so(net_so),
    .net_ro(net_ro),
    .net_do(net_do),
    .net_polarity(polarity),
    .net_si(net_si),
    .net_ri(net_ri),
    .net_di(net_di));

ROUTER_NODE U_ROUTER_NODE(    
    .cwdi(cwdi),
    .cwsi(cwsi),
    .cwri(cwri),
            
    .cwdo(cwdo),
    .cwso(cwso),
    .cwro(cwro),   
    
    .ccwdi(ccwdi),
    .ccwsi(ccwsi),
    .ccwri(ccwri),
            
    .ccwdo(ccwdo),
    .ccwso(ccwso),
    .ccwro(ccwro),
    
    .pedi(net_do), 
    .pesi(net_so),
    .peri(net_ro),
    
    .pedo(net_di),
    .peso(net_si),
    .pero(net_ri),
    
    .clk(clk),
    .reset(rst),
    .polarity(polarity));

endmodule : NIC_TOP