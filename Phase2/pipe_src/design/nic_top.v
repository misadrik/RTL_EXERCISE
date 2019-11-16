module nic_top(
    input                   clk,
    input                   reset,

    input  [1:0]            node0_addr,
    input  [63:0]           node0_nicdi,
    output [63:0]           node0_nicdo,
    output                  node0_nicWrEn,
    output                  node0_nicEN,

    input  [1:0]            node1_addr,
    input  [63:0]           node1_nicdi,
    output [63:0]           node1_nicdo,
    output                  node1_nicWrEn,
    output                  node1_nicEN,

    input  [1:0]            node2_addr,
    input  [63:0]           node2_nicdi,
    output [63:0]           node2_nicdo,
    output                  node2_nicWrEn,
    output                  node2_nicEN,

    input  [1:0]            node3_addr,
    input  [63:0]           node3_nicdi,
    output [63:0]           node3_nicdo,
    output                  node3_nicWrEn,
    output                  node3_nicEN);

NIC NIC_0(
.clk(clk),.reset(reset),.addr(node0_addr),.d_in(node0_nicdi),.nicEN(node0_nicEN),.nicWrEn(node0_nicWrEn),.d_out(node0_nicdo),
.net_so(node0_peso),.net_ro(node0_pero),.net_do(node0_pedo),.net_polarity(node0_polarity),.net_si(node0_pesi),.net_ri(node0_peri),.net_di(node0_pedi));

NIC NIC_1(
.clk(clk),.reset(reset),.addr(node1_addr),.d_in(node1_nicdi),.nicEN(node1_nicEN),.nicWrEn(node1_nicWrEn),.d_out(node1_nicdo),
.net_so(node1_peso),.net_ro(node1_pero),.net_do(node1_pedo),.net_polarity(node1_polarity),.net_si(node1_pesi),.net_ri(node1_peri),.net_di(node1_pedi));

NIC NIC_2(
.clk(clk),.reset(reset),.addr(node2_addr),.d_in(node2_nicdi),.nicEN(node2_nicEN),.nicWrEn(node2_nicWrEn),.d_out(node2_nicdo),
.net_so(node2_peso),.net_ro(node2_pero),.net_do(node2_pedo),.net_polarity(node2_polarity),.net_si(node2_pesi),.net_ri(node2_peri),.net_di(node2_pedi));

NIC NIC_3(
.clk(clk),.reset(reset),.addr(node3_addr),.d_in(node3_nicdi),.nicEN(node3_nicEN),.nicWrEn(node3_nicWrEn),.d_out(node3_nicdo),
.net_so(node3_peso),.net_ro(node3_pero),.net_do(node3_pedo),.net_polarity(node3_polarity),.net_si(node3_pesi),.net_ri(node3_peri),.net_di(node3_pedi));

gold_ring U_gold_ring(.clk(clk), .reset(reset), 
.node0_pesi(node0_peso), .node0_pedi(node0_pedo), .node0_peri(node0_pero), .node0_pero(node0_peri), .node0_peso(node0_pesi), .node0_pedo(node0_pedi), .node0_polarity(node0_polarity), 
.node1_pesi(node1_peso), .node1_pedi(node1_pedo), .node1_peri(node1_pero), .node1_pero(node1_peri), .node1_peso(node1_pesi), .node1_pedo(node1_pedi), .node1_polarity(node1_polarity), 
.node2_pesi(node2_peso), .node2_pedi(node2_pedo), .node2_peri(node2_pero), .node2_pero(node2_peri), .node2_peso(node2_pesi), .node2_pedo(node2_pedi), .node2_polarity(node2_polarity), 
.node3_pesi(node3_peso), .node3_pedi(node3_pedo), .node3_peri(node3_pero), .node3_pero(node3_peri), .node3_peso(node3_pesi), .node3_pedo(node3_pedi), .node3_polarity(node3_polarity));

endmodule