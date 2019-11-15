`timescale 1ns/1ns
module gold_ring_tb();
    reg       [3:0]               send_en;
    reg                           clk;
    reg                           reset;
    reg       [1:0]               curr_node;

    wire                          node0_pesi;
    wire      [63:0]              node0_pedi;
    wire                          node0_peri;
    wire                          node0_polarity;

    wire                          node1_pesi;
    wire      [63:0]              node1_pedi;
    wire                          node1_peri;
    wire                          node1_polarity;

    wire                          node2_pesi;
    wire      [63:0]              node2_pedi;
    wire                          node2_peri;
    wire                          node2_polarity;

    wire                          node3_pesi;
    wire      [63:0]              node3_pedi;
    wire                          node3_peri;
    wire                          node3_polarity;

    wire                          node0_peso;
    reg                           node0_pero;
    wire [63:0]                   node0_pedo;

    reg                           node1_pero;
    wire                          node1_peso;
    wire [63:0]                   node1_pedo;

    reg                           node2_pero;
    wire                          node2_peso;
    wire [63:0]                   node2_pedo;

    reg                           node3_pero;    
    wire                          node3_peso;
    wire [63:0]                   node3_pedo;


always #2 clk = ~clk;

integer fp0,fp1,fp2,fp3,fpse;

initial begin
    fp0 = $fopen("./gather_phase0.out","w");
    fp1 = $fopen("./gather_phase1.out","w");
    fp2 = $fopen("./gather_phase2.out","w");
    fp3 = $fopen("./gather_phase3.out","w");
    fpse = $fopen("./start_end_time.out","w");

    reset = 1;
    clk = 1;
    curr_node = 0;
    node0_pero = 1'b1;
    node1_pero = 1'b1;
    node2_pero = 1'b1;
    node3_pero = 1'b1;    
    #10;
    reset = 0;
    curr_node = 2'b0;
    send_en   = 4'b1110;
    #10;
    send_en   = 4'b0000; 
    curr_node = 2'b01;
    #28;// wait for output
    send_en  = 4'b1101;// send another
    #8;
    send_en   = 4'b0000; 
    curr_node = 2'b10;
    #28;// wait for output
    send_en  = 4'b1011;// send another
    #8;
    send_en   = 4'b0000; 
    curr_node = 2'b11;
    #28;// wait for output
    send_en  = 4'b0111;
    #8;
    curr_node = 2'b00;
    send_en = 4'b0000;
    #30;
    $fclose(fp0);
    $fclose(fp1);
    $fclose(fp2);
    $fclose(fp3);
    $fclose(fpse);
    $stop;
end

always@(posedge clk) begin
    if(node0_peso == 1'b1) begin
        $fdisplay(fp0,"Phase=0, Time=%0t, Destination=%h, Source=%h, PacketValue=%h",$time,node0_pedo[1:0],node0_pedo[47:32],node0_pedo[31:0]);
    end
    if(node1_peso == 1'b1) begin
        $fdisplay(fp1,"Phase=1, Time=%0t, Destination=%h, Source=%h, PacketValue=%h",$time,node1_pedo[1:0],node1_pedo[47:32],node1_pedo[31:0]);
    end
    if(node2_peso == 1'b1) begin
        $fdisplay(fp2,"Phase=2, Time=%0t, Destination=%h, Source=%h, PacketValue=%h",$time,node2_pedo[1:0],node2_pedo[47:32],node2_pedo[31:0]);
    end
    if(node3_peso == 1'b1) begin
        $fdisplay(fp3,"Phase=3, Time=%0t, Destination=%h, Source=%h, PacketValue=%h",$time,node3_pedo[1:0],node3_pedo[47:32],node3_pedo[31:0]);
    end
end

reg start_flag;
reg end_flag;
reg[1:0] cnt;

always@(posedge clk) begin
    if(reset) begin
        start_flag <= 1'b0;
    end
    else if((node0_pesi||node1_pesi||node2_pesi||node3_pesi)&&(start_flag==1'b0)) begin
        $fdisplay(fpse,"Phase = %d, Start Time = %0t", curr_node, $time-4);
        start_flag <= 1'b1;
    end
    else if(send_en == 4'b0000) 
        start_flag <= 1'b0;
end

always@(posedge clk) begin
    if(reset) begin
        end_flag <= 1'b0;
        cnt = 2'b0;
    end
    if((cnt == 2'b10) &&(node0_peso||node1_peso||node2_peso||node3_peso)&&(end_flag == 1'b0)) begin
        end_flag <= 1'b1;
        $fdisplay(fpse,"Phase = %d, Completion Time = %0t", curr_node-1'b1, $time-4);
        cnt <= 2'b0;
    end
    else if((node0_peso||node1_peso||node2_peso||node3_peso)&&(end_flag==1'b0)) begin
        cnt <= cnt + 1'b1;
    end
    else if(send_en != 4'b0000) 
        end_flag <= 1'b0;
end
    SEND_PKT U_SEND_PKT(.send_en(send_en), .clk(clk), .reset(reset), .curr_node(curr_node),
 .node0_pesi(node0_pesi), .node0_pedi(node0_pedi), .node0_peri(node0_peri), .node0_polarity(node0_polarity),
 .node1_pesi(node1_pesi), .node1_pedi(node1_pedi), .node1_peri(node1_peri), .node1_polarity(node1_polarity),
 .node2_pesi(node2_pesi), .node2_pedi(node2_pedi), .node2_peri(node2_peri), .node2_polarity(node2_polarity),
 .node3_pesi(node3_pesi), .node3_pedi(node3_pedi), .node3_peri(node3_peri), .node3_polarity(node3_polarity));


gold_ring U_GOLD_RING(.clk(clk), .reset(reset), 
.node0_pesi(node0_pesi), .node0_pedi(node0_pedi), .node0_peri(node0_peri), .node0_pero(node0_pero), .node0_peso(node0_peso), .node0_pedo(node0_pedo), .node0_polarity(node0_polarity), 
.node1_pesi(node1_pesi), .node1_pedi(node1_pedi), .node1_peri(node1_peri), .node1_pero(node1_pero), .node1_peso(node1_peso), .node1_pedo(node1_pedo), .node1_polarity(node1_polarity), 
.node2_pesi(node2_pesi), .node2_pedi(node2_pedi), .node2_peri(node2_peri), .node2_pero(node2_pero), .node2_peso(node2_peso), .node2_pedo(node2_pedo), .node2_polarity(node2_polarity), 
.node3_pesi(node3_pesi), .node3_pedi(node3_pedi), .node3_peri(node3_peri), .node3_pero(node3_pero), .node3_peso(node3_peso), .node3_pedo(node3_pedo), .node3_polarity(node3_polarity));

endmodule