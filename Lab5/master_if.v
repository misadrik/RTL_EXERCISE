module master_if(
    input clk,
    input rst_n,
    //read addr
    output reg [2:0]         ARID,
    output reg[2:0]          ARADDR,
    output                   ARVLD,
    input                    ARRDY,
    //read data
    input   [2:0]            RID,
    input   [7:0]            RDATA,
    input                    RVLD,
    output                   RRDY,
    //write addr
    output reg [2:0]         AWID,
    output reg [2:0]         AWADDR,
    output reg               AWVLD,
    input                    AWRDY,
    //write data
    output reg[2:0]          WID,
    output reg[7:0]          WDATA,
    output reg               WVLD,
    input                    WRDY,
    //write resp
    input [2:0]              BID,
    input                    BRESP,
    input                    BVLD,
    output                   BRDY,

    //to master_if
    output                   mif_m2s_fifo_empty,
    output[31:0]             mif_m2s_fifo_dout,
    input                    mif_m2s_fifo_ren, 

    input                    s2m_fifo_wen,
    input[31:0]              sif2mif_din, 
    output                   s2m_fifo_full);

    wire                     mif_s2m_fifo_ren;
    wire                     mif_s2m_fifo_empty;
    wire [31:0]              mif_s2m_fifo_dout;
    wire [31:0]              read_addr_fifo_dout;
    wire                     addr_fifo_full;

    reg[31:0]                mif_m2s_fifo_din;
    reg                      mif_m2s_fifo_wen;
    reg [2:0]                temp_CTR;
    reg                      read_addr_fifo_ren;

    wire                     mif_m2s_fifo_full;

    reg[15:0]                wreorder_buff[0:7]; 
    reg[2:0]                 reorder_rdptr;

    reg 				     write_req;

    wire[2:0]				 Trans_ID;
    wire[2:0]			     CNT;
    wire[2:0]				 Type_ID;
    wire[22:0]			     Transaction;
    wire                     write_cmd_ren;
    integer i;

assign  Trans_ID            = mif_s2m_fifo_dout[2:0];
assign  CNT                 = mif_s2m_fifo_dout[5:3];
assign  Type_ID             = mif_s2m_fifo_dout[8:6];
assign  Transaction         = mif_s2m_fifo_dout[31:9];

assign read_addr_ren = (Type_ID == 3'b000) && (!addr_fifo_full);
assign write_cmd_ren = (Type_ID == 3'b001) || (Type_ID ==3'b010);

assign mif_s2m_fifo_ren = read_addr_ren | write_cmd_ren;

sync_fifo #(.DATA_WIDTH(32), .FIFO_DEPTH(32),.THREASHOLD(31)) mif_s2m_fifo(
.rst_n(rst_n),.clk(clk),.DIN(sif2mif_din),.WEN(s2m_fifo_wen),.REN(mif_s2m_fifo_ren),.DOUT(mif_s2m_fifo_dout),.almost_full(),.full(s2m_fifo_full),.empty(s2m_fifo_empty));

sync_fifo #(.DATA_WIDTH(32), .FIFO_DEPTH(32),.THREASHOLD(31)) read_addr_fifo(
.rst_n(rst_n),.clk(clk),.DIN(mif_s2m_fifo_dout),.WEN(read_addr_ren),.REN(read_addr_fifo_ren),.DOUT(read_addr_fifo_dout),.almost_full(),.full(addr_fifo_full),.empty(mif_s2m_fifo_empty));

assign ARVLD = !mif_s2m_fifo_empty;
assign RRDY  = !mif_m2s_fifo_full;
assign BRDY  = !mif_m2s_fifo_full;

always@(*) begin
    read_addr_fifo_ren = 1'b0;
    if(ARVLD && ARRDY) begin
        read_addr_fifo_ren = 1'b1;
        ARID    = read_addr_fifo_dout[2:0];
        ARADDR  = read_addr_fifo_dout[11:9];
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        temp_CTR <= 3'b0;
    end 
    else if(ARRDY && ARVLD) begin 
        temp_CTR <= read_addr_fifo_dout[5:3];
    end
    else if(WVLD && WRDY) begin
        temp_CTR <= reorder_rdptr;
    end
end

always@(*) begin
    mif_m2s_fifo_din = 32'b0;
    mif_m2s_fifo_wen = 1'b0;
    if(RVLD && RRDY) begin
        mif_m2s_fifo_din[2:0]  = RID;
        mif_m2s_fifo_din[5:3]  = temp_CTR;
        mif_m2s_fifo_din[8:6]  = 3'b011;
        mif_m2s_fifo_din[31:24] = RDATA;
        mif_m2s_fifo_wen = 1'b1;
    end
    else if(BVLD && BRDY) begin
        mif_m2s_fifo_din[2:0]  = BID;
        mif_m2s_fifo_din[5:3]  = temp_CTR;
        mif_m2s_fifo_din[8:6]  = 3'b100;
        mif_m2s_fifo_din[31]   = BRESP;
        mif_m2s_fifo_wen = 1'b1;        
    end
end

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        for(i = 0; i< 8; i = i + 1) begin
            wreorder_buff[i][0] <= 1'b0;
            wreorder_buff[i][4] <= 1'b0;
        end
    end
    else if(Type_ID == 3'b001) begin //write addr
        wreorder_buff[CNT][3:1] <= Transaction[2:0];
        wreorder_buff[CNT][0] 	<= 1'b1;
    end
    else if(Type_ID == 3'b010) begin //write data
        wreorder_buff[CNT][15:8] <= Transaction[22:15];
        wreorder_buff[CNT][7:5]  <= Trans_ID;
        wreorder_buff[CNT][4]    <= 1'b1;
    end
end

always@(*) begin
    write_req = 0;
    if(wreorder_buff[reorder_rdptr[2:0]][0] && wreorder_buff[reorder_rdptr[2:0]][4]) begin
        write_req = 1'b1;
    end
end

always@(*) begin
    if(write_req)begin
        WID    = wreorder_buff[reorder_rdptr[2:0]][7:5];
        WDATA  = wreorder_buff[reorder_rdptr[2:0]][15:8];
        WVLD   = 1'b1;
        AWADDR = wreorder_buff[reorder_rdptr[2:0]][3:1];
        AWID   = wreorder_buff[reorder_rdptr[2:0]][7:5];
        AWVLD  = 1'b1;
	end
	else begin
        WID    = 3'b0;
        WDATA  = 8'b0;
        WVLD   = 1'b0;
        AWADDR = 3'b0;
        AWID   = 3'b0;
        AWVLD  = 1'b0;
	end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        reorder_rdptr <= 3'b0;
    end
    else if(WVLD && WRDY) begin
        reorder_rdptr <= reorder_rdptr + 1'b1;
        wreorder_buff[reorder_rdptr[2:0]][4] <= 1'b0;
        wreorder_buff[reorder_rdptr[2:0]][0] <= 1'b0;
    end
end

sync_fifo #(.DATA_WIDTH(32), .FIFO_DEPTH(32),.THREASHOLD(31)) mif_m2s_fifo(
.rst_n(rst_n),.clk(clk),.DIN(mif_m2s_fifo_din),.WEN(mif_m2s_fifo_wen),.REN(mif_m2s_fifo_ren),.DOUT(mif_m2s_fifo_dout),.almost_full(),.full(mif_m2s_fifo_full),.empty(mif_m2s_fifo_empty));

endmodule