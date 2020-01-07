module slave_if(
    input clk,
    input rst_n,
    //read addr
    input [2:0]             ARID,
    input [2:0]             ARADDR,
    input                   ARVLD,
    output                  ARRDY,
    //read data
    output [2:0]            RID,
    output [7:0]            RDATA,
    output                  RVLD,
    input                   RRDY,
    //write addr
    input [2:0]             AWID,
    input [2:0]             AWADDR,
    input                   AWVLD,
    output                  AWRDY,
    //write data
    input [2:0]             WID,
    input [7:0]             WDATA,
    input                   WVLD,
    output                  WRDY,
    //write resp
    output[2:0]             BID,
    output                  BRESP,
    output                  BVLD,
    input                   BRDY,

    //to master_if
    output[31:0]            sif_s2m_fifo_dout,
    input                   sif_s2m_fifo_ren,
    output                  s2m_fifo_empty,

    input                   mif2sif_wen,
    input[31:0]             mif2sif_din,
    output                  sif_m2s_fifo_full);

reg[31:0]           pkt;
reg                 pkt_vld;

reg [31:0]          rbuff[0:7];

reg [3:0]           rbuff_wrptr;
reg [3:0]           rbuff_rdptr;
reg [2:0]           rd_cnt;
reg                 rd_resp_vld;
reg [31:0]          rd_pkt;

wire                s2m_fifo_afull;
wire                s2m_fifo_full;


reg [2:0]           wr_cnt;
reg [2:0]           wr_cnt_1d;

reg [8:0]           wbuff[0:7];
reg [3:0]           wbuff_wrptr;
reg [3:0]           wbuff_rdptr;
reg                 wr_resp_vld;

integer i;
// assign AWRDY = 
// assign WRDY = 
assign ARRDY = ((rbuff_wrptr - rbuff_rdptr) != {1'b1,3'b0}) && (pkt_vld ?  !(s2m_fifo_afull): (!s2m_fifo_full));
assign AWRDY = ((wbuff_wrptr - wbuff_rdptr) != {1'b1,3'b0}) && (pkt_vld ?  !(s2m_fifo_afull): (!s2m_fifo_full));
assign WRDY = ((wbuff_wrptr - wbuff_rdptr) != {1'b1,3'b0}) && (pkt_vld ?  !(s2m_fifo_afull): (!s2m_fifo_full));

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rbuff_wrptr <= 4'b0;
        for(i = 0; i< 8; i = i + 1) begin
            rbuff[i][0] <= 1'b0;
        end
    end
    else if (ARVLD && ARRDY) begin
        rbuff[rbuff_wrptr[2:0]][0] <= 1'b1;
        rbuff[rbuff_wrptr[2:0]][3:1] <= ARID;
        rbuff[rbuff_wrptr[2:0]][6:4] <= rd_cnt;
        rbuff_wrptr<= rbuff_wrptr + 1'b1;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rd_cnt <= 3'b0;
    end
    else if (ARVLD && ARRDY) begin
        rd_cnt <= rd_cnt + 1'b1;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wr_cnt <= 3'b0;
        wr_cnt_1d <= 3'b0;  
    end
    else if(AWVLD && AWRDY) begin
        wr_cnt_1d <= wr_cnt;
        wr_cnt <= wr_cnt + 1'b1;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wbuff_wrptr <= 4'b0;

        for(i = 0; i< 8; i = i + 1) begin
            wbuff[i][0] <= 1'b0;
        end
    end
    else if(AWVLD && AWRDY) begin
        wbuff[wbuff_wrptr[2:0]][0]   <= 1'b1;
        wbuff[wbuff_wrptr[2:0]][3:1] <= AWID;
        wbuff[wbuff_wrptr[2:0]][6:4] <= wr_cnt;
        wbuff_wrptr <= wbuff_wrptr + 1'b1;        
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        pkt_vld <= 1'b0;
        pkt <= 'b0;
    end
    else if (ARVLD && ARRDY) begin
        pkt[2:0]    <= ARID;
        pkt[5:3]    <= rd_cnt;
        pkt[8:6]    <= 3'b000;
        pkt[11:9]   <= ARADDR;
        pkt[31:12]  <= 'b0;
        pkt_vld     <= 1'b1;
    end
    else if(AWVLD && AWRDY) begin
        pkt[2:0]    <= AWID;
        pkt[5:3]    <= wr_cnt;
        pkt[8:6]    <= 3'b001;
        pkt[11:9]   <= AWADDR;
        pkt[31:12]  <= 'b0;
        pkt_vld     <= 1'b1;
    end
    else if(WVLD && WRDY) begin
        pkt[2:0]    <= WID;
        pkt[5:3]    <= wr_cnt_1d;
        pkt[8:6]    <= 3'b010;
        pkt[31:24]  <= WDATA;
        pkt[23:9]   <= 'b0;
        pkt_vld     <= 1'b1;
    end
    else begin
        pkt_vld <= 'b0;
    end
end

assign RDATA = rbuff[rbuff_rdptr[2:0]][15:8];
assign RID   = rbuff[rbuff_rdptr[2:0]][2:0];

//reorder read resp
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i< 8; i= i+1) begin
            rbuff[i][7] <= 1'b0;
        end
    end
    else if(rd_resp_vld) begin
        if(rbuff[0][6:4] == rd_pkt[5:3]) begin
            rbuff[0][15:8] <= rd_pkt[31:24];
            rbuff[0][7] <= 1'b1;
        end
        else if(rbuff[1][6:4] == rd_pkt[5:3]) begin
            rbuff[1][15:8] <= rd_pkt[31:24];
            rbuff[1][7] <= 1'b1;
        end
        else if(rbuff[2][6:4] == rd_pkt[5:3]) begin
            rbuff[2][15:8] <= rd_pkt[31:24];
            rbuff[2][7] <= 1'b1;
        end
        else if(rbuff[3][6:4] == rd_pkt[5:3]) begin
            rbuff[3][15:8] <= rd_pkt[31:24];
            rbuff[3][7] <= 1'b1;
        end
        else if(rbuff[3][6:4] == rd_pkt[5:3]) begin
            rbuff[3][15:8] <= rd_pkt[31:24];
            rbuff[3][7] <= 1'b1;
        end
        else if(rbuff[4][6:4] == rd_pkt[5:3]) begin
            rbuff[4][15:8] <= rd_pkt[31:24];
            rbuff[4][7] <= 1'b1;
        end
        else if(rbuff[5][6:4] == rd_pkt[5:3]) begin
            rbuff[5][15:8] <= rd_pkt[31:24];
            rbuff[5][7] <= 1'b1;
        end
        else if(rbuff[6][6:4] == rd_pkt[5:3]) begin
            rbuff[6][15:8] <= rd_pkt[31:24];
            rbuff[6][7] <= 1'b1;
        end
        else if(rbuff[7][6:4] == rd_pkt[5:3]) begin
            rbuff[7][15:8] <= rd_pkt[31:24];
            rbuff[7][7] <= 1'b1;
        end
    end
end

assign BRESP = wbuff[wbuff_rdptr[2:0]][8];
assign BID   = wbuff[wbuff_rdptr[2:0]][2:0];

//reorder write resp
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i< 8; i= i+1) begin
            wbuff[i][7] <= 1'b0;
        end
    end
    else if(wr_resp_vld) begin
        if(wbuff[0][6:4] == rd_pkt[5:3]) begin
            wbuff[0][8] <= rd_pkt[31];
            wbuff[0][7] <= 1'b1;
        end
        else if(wbuff[1][6:4] == rd_pkt[5:3]) begin
            wbuff[1][8] <= rd_pkt[31];
            wbuff[1][7] <= 1'b1;
        end
        else if(wbuff[2][6:4] == rd_pkt[5:3]) begin
            wbuff[2][8] <= rd_pkt[31];
            wbuff[2][7] <= 1'b1;
        end
        else if(wbuff[3][6:4] == rd_pkt[5:3]) begin
            wbuff[3][8] <= rd_pkt[31];
            wbuff[3][7] <= 1'b1;
        end
        else if(wbuff[3][6:4] == rd_pkt[5:3]) begin
            wbuff[3][8] <= rd_pkt[31];
            wbuff[3][7] <= 1'b1;
        end
        else if(wbuff[4][6:4] == rd_pkt[5:3]) begin
            wbuff[4][8] <= rd_pkt[31];
            wbuff[4][7] <= 1'b1;
        end
        else if(wbuff[5][6:4] == rd_pkt[5:3]) begin
            wbuff[5][8] <= rd_pkt[31];
            wbuff[5][7] <= 1'b1;
        end
        else if(wbuff[6][6:4] == rd_pkt[5:3]) begin
            wbuff[6][8] <= rd_pkt[31];
            wbuff[6][7] <= 1'b1;
        end
        else if(wbuff[7][6:4] == rd_pkt[5:3]) begin
            wbuff[7][8] <= rd_pkt[31];
            wbuff[7][7] <= 1'b1;
        end
    end
end
assign RVLD = rbuff[rbuff_rdptr[2:0]][7] && rbuff[rbuff_rdptr[2:0]][0];

assign BVLD = wbuff[wbuff_rdptr[2:0]][7] && wbuff[wbuff_rdptr[2:0]][0]; //write resp vld

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rbuff_rdptr <= 3'b000;
    end
    else if(RVLD && RRDY) begin
        rbuff[rbuff_rdptr[2:0]][7] <= 1'b0;
        rbuff[rbuff_rdptr[2:0]][0] <= 1'b0;
        rbuff_rdptr <= rbuff_rdptr + 1'b1;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wbuff_rdptr <= 3'b000;
    end
    else if(BVLD && BRDY) begin
        wbuff[wbuff_rdptr[2:0]][7] <= 1'b0;
        wbuff[wbuff_rdptr[2:0]][0] <= 1'b0;
        wbuff_rdptr <= wbuff_rdptr + 1'b1;
    end
end


wire s2m_fifo_wen;

assign s2m_fifo_wen = pkt_vld && (!s2m_fifo_full);

sync_fifo #(.DATA_WIDTH(32), .FIFO_DEPTH(32),.THREASHOLD(31)) sif_s2m_fifo(
.rst_n(rst_n),.clk(clk),.DIN(pkt),.WEN(s2m_fifo_wen),.REN(sif_s2m_fifo_ren),.DOUT(sif_s2m_fifo_dout),.almost_full(s2m_fifo_afull),.full(s2m_fifo_full),.empty(s2m_fifo_empty));

wire m2s_fifo_empty;
wire[31:0]  mif2sif_dout;
wire[2:0]    trans_type;

assign m2s_fifo_ren = !(m2s_fifo_empty);
assign trans_type = mif2sif_dout[8:6];

sync_fifo #(.DATA_WIDTH(32), .FIFO_DEPTH(32),.THREASHOLD(31)) sif_m2s_fifo(
.rst_n(rst_n),.clk(clk),.DIN(mif2sif_din),.WEN(mif2sif_wen),.REN(m2s_fifo_ren),.DOUT(mif2sif_dout),.almost_full(),.full(sif_m2s_fifo_full),.empty(m2s_fifo_empty));

//unpacket
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rd_resp_vld <= 1'b0;
    end
    else if(m2s_fifo_ren) begin
        if(trans_type == 3'b011) begin
            rd_pkt <= mif2sif_dout;
            rd_resp_vld <= 1'b1;
        end
        else if(trans_type == 3'b100) begin
            wr_resp_vld <= 1'b1;
            rd_pkt <= mif2sif_dout;
        end
        else begin
            rd_resp_vld <= 1'b0;
            wr_resp_vld <= 1'b0;
        end
    end
end

endmodule