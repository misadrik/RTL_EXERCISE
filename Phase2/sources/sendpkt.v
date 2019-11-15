module SEND_PKT(
    input   [3:0]                   send_en,
    input                           clk,
    input                           reset,
    input   [1:0]                   curr_node,

    output reg                      node0_pesi,
    output reg  [63:0]              node0_pedi,
    input                           node0_peri,
    input                           node0_polarity,

    output reg                      node1_pesi,
    output reg  [63:0]              node1_pedi,
    input                           node1_peri,
    input                           node1_polarity,

    output reg                      node2_pesi,
    output reg  [63:0]              node2_pedi,
    input                           node2_peri,
    input                           node2_polarity,

    output reg                      node3_pesi,
    output reg  [63:0]              node3_pedi,
    input                           node3_peri,
    input                           node3_polarity);

    wire                            vc_0;
    wire                            dir_0;
    wire[1:0]                       hop_0;
    wire[15:0]                      src_0;
    wire[1:0]                       dst_0;

    //node0
    assign vc_0  = 1'b0;
    assign dir_0 = (curr_node == 2'b11) ? 1'b1:1'b0;
    assign hop_0 = (curr_node == 2'b10) ? 2'b11:2'b01;
    assign src_0 = 16'b0;
    assign dst_0 = curr_node;

    always@(posedge clk) begin
        if(reset) begin
            node0_pesi <= 1'b0;
            node0_pedi <= 64'b0;
        end
        else if(~send_en[0]) begin
            node0_pesi <= 1'b0;
            node0_pedi <= 64'b0;
        end
        else if(send_en[0] && node0_peri && (node0_polarity != vc_0)) begin
            node0_pesi <= 1'b1;
            node0_pedi <= {vc_0, dir_0, 12'b0, hop_0, src_0, 30'b0, dst_0};
        end
        else begin
            node0_pesi <= 1'b0;
            node0_pedi <= 64'b0;           
        end
    end

    //node1
    wire                            vc_1;
    wire                            dir_1;
    wire[1:0]                       hop_1;
    wire[15:0]                      src_1;
    wire[1:0]                       dst_1;

    assign vc_1  = 1'b0;
    assign dir_1 = (curr_node == 2'b00) ? 1'b1:1'b0;
    assign hop_1 = (curr_node == 2'b11) ? 2'b11:2'b01;
    assign src_1 = 16'b1;
    assign dst_1 = curr_node;

    always@(posedge clk) begin
        if(reset) begin
            node1_pesi <= 1'b0;
            node1_pedi <= 64'b0;
        end
        else if(~send_en[1]) begin
            node1_pesi <= 1'b0;
            node1_pedi <= 64'b0;
        end
        else if(send_en[1] && node1_peri && (node1_polarity != vc_1)) begin
            node1_pesi <= 1'b1;
            node1_pedi <= {vc_1, dir_1, 12'b0, hop_1, src_1, 30'b0, dst_1};
        end
        else begin
            node1_pesi <= 1'b0;
            node1_pedi <= 64'b0;           
        end
    end

    //node2
    wire                            vc_2;
    wire                            dir_2;
    wire[1:0]                       hop_2;
    wire[15:0]                      src_2;
    wire[1:0]                       dst_2;

    assign vc_2  = 1'b1;
    assign dir_2 = (curr_node == 2'b01) ? 1'b1:1'b0;
    assign hop_2 = (curr_node == 2'b00) ? 2'b10:2'b01;
    assign src_2 = 16'b10;
    assign dst_2 = curr_node;

    always@(posedge clk) begin
        if(reset) begin
            node2_pesi <= 1'b0;
            node2_pedi <= 64'b0;
        end
        else if(~send_en[2]) begin
            node2_pesi <= 1'b0;
            node2_pedi <= 64'b0;
        end
        else if(send_en[2] && node2_peri && (node2_polarity != vc_2)) begin
            node2_pesi <= 1'b1;
            node2_pedi <= {vc_2, dir_2, 12'b0, hop_2, src_2, 30'b0, dst_2};
        end
        else begin
            node2_pesi <= 1'b0;
            node2_pedi <= 64'b0;           
        end
    end

    //node3
    wire                            vc_3;
    wire                            dir_3;
    wire[1:0]                       hop_3;
    wire[15:0]                      src_3;
    wire[1:0]                       dst_3;

    assign vc_3  = 1'b1;
    assign dir_3 = (curr_node == 2'b10) ? 1'b1:1'b0;
    assign hop_3 = (curr_node == 2'b01) ? 2'b11:2'b01;
    assign src_3 = 16'b11;
    assign dst_3 = curr_node;

    always@(posedge clk) begin
        if(reset) begin
            node3_pesi <= 1'b0;
            node3_pedi <= 64'b0;
        end
        else if(~send_en[3]) begin
            node3_pesi <= 1'b0;
            node3_pedi <= 64'b0;
        end
        else if(send_en[3] && node3_peri && (node3_polarity != vc_3)) begin
            node3_pesi <= 1'b1;
            node3_pedi <= {vc_3, dir_3, 12'b0, hop_3, src_3, 30'b0, dst_3};
        end
        else begin
            node3_pesi <= 1'b0;
            node3_pedi <= 64'b0;           
        end
    end


endmodule : SEND_PKT
