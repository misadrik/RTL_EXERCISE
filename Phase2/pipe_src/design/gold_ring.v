module gold_ring (
    input                   clk,
    input                   reset,

    input                   node0_pesi,
    input  [63:0]           node0_pedi,
    output                  node0_peri,
    input                   node0_pero,
    output                  node0_peso,
    output [63:0]           node0_pedo,
    output                  node0_polarity,

    input                   node1_pesi,
    input  [63:0]           node1_pedi,
    output                  node1_peri,
    input                   node1_pero,
    output                  node1_peso,
    output [63:0]           node1_pedo,
    output                  node1_polarity,

    input                   node2_pesi,
    input  [63:0]           node2_pedi,
    output                  node2_peri,
    input                   node2_pero,
    output                  node2_peso,
    output [63:0]           node2_pedo,
    output                  node2_polarity,

    input                   node3_pesi,
    input  [63:0]           node3_pedi,
    output                  node3_peri,
    input                   node3_pero,
    output                  node3_peso,
    output [63:0]           node3_pedo,
    output                  node3_polarity);

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

ROUTER_NODE NODE0(.clk(clk),.reset(reset), .polarity(node0_polarity),
                    .cwdi(cwd_3_0),.cwsi(cws_3_0),.cwri(cwr_0_3),
                    .cwdo(cwd_0_1),.cwso(cws_0_1),.cwro(cwr_1_0),   
                    .ccwdi(ccwd_1_0),.ccwsi(ccws_1_0),.ccwri(ccwr_0_1),
                    .ccwdo(ccwd_0_3),.ccwso(ccws_0_3),.ccwro(ccwr_3_0),
                    .pesi(node0_pesi),.pedi(node0_pedi),.peri(node0_peri),
                    .pero(node0_pero),.peso(node0_peso),.pedo(node0_pedo));
    

ROUTER_NODE NODE1(.clk(clk),.reset(reset),.polarity(node1_polarity),
                    .cwdi(cwd_0_1),.cwsi(cws_0_1),.cwri(cwr_1_0),
                    .cwdo(cwd_1_2),.cwso(cws_1_2),.cwro(cwr_2_1),   
                    .ccwdi(ccwd_2_1),.ccwsi(ccws_2_1),.ccwri(ccwr_1_2),
                    .ccwdo(ccwd_1_0),.ccwso(ccws_1_0),.ccwro(ccwr_0_1),
                    .pesi(node1_pesi),.pedi(node1_pedi),.peri(node1_peri),
                    .pero(node1_pero),.peso(node1_peso),.pedo(node1_pedo));
 
ROUTER_NODE NODE2(.clk(clk),.reset(reset),.polarity(node2_polarity),
                    .cwdi(cwd_1_2),.cwsi(cws_1_2),.cwri(cwr_2_1),
                    .cwdo(cwd_2_3),.cwso(cws_2_3),.cwro(cwr_3_2),   
                    .ccwdi(ccwd_3_2),.ccwsi(ccws_3_2),.ccwri(ccwr_2_3),
                    .ccwdo(ccwd_2_1),.ccwso(ccws_2_1),.ccwro(ccwr_1_2),
                    .pesi(node2_pesi),.pedi(node2_pedi),.peri(node2_peri),
                    .pero(node2_pero),.peso(node2_peso),.pedo(node2_pedo));

ROUTER_NODE NODE3(.clk(clk),.reset(reset),.polarity(node3_polarity),
                    .cwdi(cwd_2_3),.cwsi(cws_2_3),.cwri(cwr_3_2),
                    .cwdo(cwd_3_0),.cwso(cws_3_0),.cwro(cwr_0_3),   
                    .ccwdi(ccwd_0_3),.ccwsi(ccws_0_3),.ccwri(ccwr_3_0),
                    .ccwdo(ccwd_3_2),.ccwso(ccws_3_2),.ccwro(ccwr_2_3),
                    .pesi(node3_pesi),.pedi(node3_pedi),.peri(node3_peri),
                    .pero(node3_pero),.peso(node3_peso),.pedo(node3_pedo));
endmodule