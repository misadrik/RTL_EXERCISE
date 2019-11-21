module cmp(
    input                       CLK,
    input                       RESET,
    input[0:31]                 node0_inst_in,
    input[0:63]                 node0_d_in,
    output[0:31]                node0_pc_out,
    output[0:63]                node0_d_out,
    output[0:31]                node0_addr_out,
    output                      node0_memWrEn,
    output                      node0_memEn,

    input[0:31]                 node1_inst_in,
    input[0:63]                 node1_d_in,
    output[0:31]                node1_pc_out,
    output[0:63]                node1_d_out,
    output[0:31]                node1_addr_out,
    output                      node1_memWrEn,
    output                      node1_memEn,

    input[0:31]                 node2_inst_in,
    input[0:63]                 node2_d_in,
    output[0:31]                node2_pc_out,
    output[0:63]                node2_d_out,
    output[0:31]                node2_addr_out,
    output                      node2_memWrEn,
    output                      node2_memEn,

    input[0:31]                 node3_inst_in,
    input[0:63]                 node3_d_in,
    output[0:31]                node3_pc_out,
    output[0:63]                node3_d_out,
    output[0:31]                node3_addr_out,
    output                      node3_memWrEn,
    output                      node3_memEn);


    wire [0:63]                 node0_nicdo;
    wire [0:63]                 node1_nicdo;
    wire [0:63]                 node2_nicdo;
    wire [0:63]                 node3_nicdo;

    reg [0:31]                 node0_addr_out_1d;
    reg [0:31]                 node1_addr_out_1d;
    reg [0:31]                 node2_addr_out_1d;
    reg [0:31]                 node3_addr_out_1d;
    
    wire [0:63]                node0_dataIn;
    wire [0:63]                node1_dataIn;
    wire [0:63]                node2_dataIn;
    wire [0:63]                node3_dataIn;

    reg                        node0_memEn_1d;
    reg                        node1_memEn_1d;
    reg                        node2_memEn_1d;
    reg                        node3_memEn_1d;

    reg                        node0_nicEN_1d;
    reg                        node1_nicEN_1d;
    reg                        node2_nicEN_1d;
    reg                        node3_nicEN_1d;


assign node0_nicEN = node0_memEn && (node0_addr_out[16:17] == 2'b11);
assign node1_nicEN = node1_memEn && (node1_addr_out[16:17] == 2'b11);
assign node2_nicEN = node2_memEn && (node2_addr_out[16:17] == 2'b11);
assign node3_nicEN = node3_memEn && (node3_addr_out[16:17] == 2'b11);

assign node0_nicWrEn = node0_memWrEn && (node0_addr_out[16:17] == 2'b11);
assign node1_nicWrEn = node1_memWrEn && (node1_addr_out[16:17] == 2'b11);
assign node2_nicWrEn = node2_memWrEn && (node2_addr_out[16:17] == 2'b11);
assign node3_nicWrEn = node3_memWrEn && (node3_addr_out[16:17] == 2'b11);

assign node0_dataIn = (node0_nicEN_1d == 1'b0) ? node0_d_in:node0_nicdo; 
assign node1_dataIn = (node1_nicEN_1d == 1'b0) ? node1_d_in:node1_nicdo; 
assign node2_dataIn = (node2_nicEN_1d == 1'b0) ? node2_d_in:node2_nicdo; 
assign node3_dataIn = (node3_nicEN_1d == 1'b0) ? node3_d_in:node3_nicdo; 

cardinal_processor p0(.clk(CLK), .reset(RESET), .instruction(node0_inst_in), .dataIn(node0_dataIn), .pc(node0_pc_out), .dataOut(node0_d_out), .memAddr(node0_addr_out), .memEn(node0_memEn), .memWrEn(node0_memWrEn));
cardinal_processor p1(.clk(CLK), .reset(RESET), .instruction(node1_inst_in), .dataIn(node1_dataIn), .pc(node1_pc_out), .dataOut(node1_d_out), .memAddr(node1_addr_out), .memEn(node1_memEn), .memWrEn(node1_memWrEn));
cardinal_processor p2(.clk(CLK), .reset(RESET), .instruction(node2_inst_in), .dataIn(node2_dataIn), .pc(node2_pc_out), .dataOut(node2_d_out), .memAddr(node2_addr_out), .memEn(node2_memEn), .memWrEn(node2_memWrEn));
cardinal_processor p3(.clk(CLK), .reset(RESET), .instruction(node3_inst_in), .dataIn(node3_dataIn), .pc(node3_pc_out), .dataOut(node3_d_out), .memAddr(node3_addr_out), .memEn(node3_memEn), .memWrEn(node3_memWrEn));

always@(posedge CLK) begin
    node0_nicEN_1d <= node0_nicEN;
    node1_nicEN_1d <= node1_nicEN;
    node2_nicEN_1d <= node2_nicEN;
    node3_nicEN_1d <= node3_nicEN;
    node0_memEn_1d   <= node0_memEn;
    node1_memEn_1d   <= node1_memEn;
    node2_memEn_1d   <= node2_memEn;
    node3_memEn_1d   <= node3_memEn;
end

nic_top NIC(.clk(CLK),.reset(RESET),
.node0_addr(node0_addr_out[30:31]),.node0_nicdi(node0_d_out),.node0_nicdo(node0_nicdo),.node0_nicWrEn(node0_nicWrEn),.node0_nicEN(node0_nicEN),
.node1_addr(node1_addr_out[30:31]),.node1_nicdi(node1_d_out),.node1_nicdo(node1_nicdo),.node1_nicWrEn(node1_nicWrEn),.node1_nicEN(node1_nicEN),
.node2_addr(node2_addr_out[30:31]),.node2_nicdi(node2_d_out),.node2_nicdo(node2_nicdo),.node2_nicWrEn(node2_nicWrEn),.node2_nicEN(node2_nicEN),
.node3_addr(node3_addr_out[30:31]),.node3_nicdi(node3_d_out),.node3_nicdo(node3_nicdo),.node3_nicWrEn(node3_nicWrEn),.node3_nicEN(node3_nicEN));


endmodule