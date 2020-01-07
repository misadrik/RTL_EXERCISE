`timescale 1ns/1ns
module axi_top_tb();
    reg                    clk;
    reg                    rst_n;

    wire [2:0]             slave_ARID;
    wire [2:0]             slave_ARADDR;
    wire                   slave_ARVLD;
    reg                    slave_ARRDY;
    //read data
    reg   [2:0]            slave_RID;
    reg   [7:0]            slave_RDATA;
    reg                    slave_RVLD;
    wire                   slave_RRDY;
    //write addr
    wire [2:0]             slave_AWID;
    wire [2:0]             slave_AWADDR;
    wire                   slave_AWVLD;
    reg                    slave_AWRDY;
    //write data 
    wire [2:0]             slave_WID;
    wire [7:0]             slave_WDATA;
    wire                   slave_WVLD;
    reg                    slave_WRDY;
    //write resp
    reg [2:0]              slave_BID;
    reg                    slave_BRESP;
    reg                    slave_BVLD;
    wire                   slave_BRDY; 
    //read addr

    reg [2:0]              master_ARID;
    reg [2:0]              master_ARADDR;
    reg                    master_ARVLD;
    wire                   master_ARRDY;
    //read data
    wire [2:0]             master_RID;
    wire [7:0]             master_RDATA;
    wire                   master_RVLD;
    reg                    master_RRDY;
    //write addr
    reg [2:0]              master_AWID;
    reg [2:0]              master_AWADDR;
    reg                    master_AWVLD;
    wire                   master_AWRDY;
    //write data
    reg [2:0]              master_WID;
    reg [7:0]              master_WDATA;
    reg                    master_WVLD;
    wire                   master_WRDY;
    //write resp
    wire[2:0]              master_BID;
    wire                   master_BRESP;
    wire                   master_BVLD;
    reg                    master_BRDY;

    reg                    write_start;
    reg                    addr_sent;
    reg                    send_end;
    always #1 clk = ~clk;

    reg[7:0] mem[0:7];

initial begin
    rst_n = 1'b0;
    send_end = 1'b0;
    #10;
    rst_n = 1'b1;
    clk = 1'b1;
    slave_ARRDY = 1'b1;
    master_ARID = 1'b1;
    master_RRDY = 1'b1;
    write_start = 1'b0;
    #100
    rst_n = 1'b0;
    slave_ARRDY = 1'b0;
    master_ARID = 1'b0;
    master_RRDY = 1'b0;
    send_end    = 1'b1;
    #10;
    rst_n = 1'b1;
    write_start = 1'b1;
    master_BRDY = 1'b1;
    master_AWID = 1'b1;
    master_WID  = 1'b1;
    slave_AWRDY = 1'b1;
    slave_WRDY  = 1'b1;
end

always@(posedge clk) begin
    if(master_ARRDY && (!send_end)) begin
        master_ARVLD = 1'b1; 
        master_ARADDR = $urandom_range(0,7);       
    end
    else begin
        master_ARVLD = 1'b0;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin 
        slave_RVLD  <= 1'b0;
        slave_RDATA <= 8'b0;
        slave_RID <= 3'b0;
    end
    else if(slave_ARVLD && slave_ARRDY) begin
        slave_RDATA <= $random %8'hff;
        slave_RVLD <= 1'b1;
        slave_RID  <= 1'b1;
    end
    else begin
        slave_RVLD  <= 1'b0;
        slave_RDATA <= 8'b0;
        slave_RID <= 3'b0;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        addr_sent <= 1'b0;
    end
    else if(master_AWRDY && (addr_sent == 1'b0) && (write_start == 1'b1)) begin
        addr_sent <= 1'b1;
    end
    else if(master_WRDY && (addr_sent == 1'b1) && (write_start == 1'b1)) begin
        addr_sent       <= 1'b0; //! warning change one reg val in two always block
    end
end

always@(*) begin
    if(master_AWRDY && (addr_sent == 1'b0) && (write_start == 1'b1)) begin
        master_AWVLD  = 1'b1;
        master_AWADDR = $urandom_range(0,7);
    end
    else begin
        master_AWVLD  = 1'b0;
        // master_AWADDR = 3'b0;
    end
end

always@(*) begin
if(master_WRDY && (addr_sent == 1'b1) && (write_start == 1'b1)) begin   
        master_WVLD     <= 1'b1;
        master_WDATA    <= $urandom % 8'hff;
    end
    else begin
        master_WVLD     <= 1'b0;
        master_WDATA    <= 8'h00;
    end
end

always@(posedge clk) begin
    slave_BID <=slave_AWID;
end

always@(posedge clk) begin
    if(slave_WRDY && (slave_WVLD)) begin
        slave_BVLD  = 1'b1;
        slave_BRESP = $urandom_range(0,1);
    end
    else begin
        slave_BVLD = 1'b0;
        slave_BRESP = 1'b0;
    end
end


    axi_top U_AXI_TOP(.clk(clk),.rst_n(rst_n),
.slave_ARID(slave_ARID),.slave_ARADDR(slave_ARADDR),.slave_ARVLD(slave_ARVLD),.slave_ARRDY(slave_ARRDY),
    //read data
.slave_RID(slave_RID),.slave_RDATA(slave_RDATA),.slave_RVLD(slave_RVLD),.slave_RRDY(slave_RRDY),
    //write addr
.slave_AWID(slave_AWID),.slave_AWADDR(slave_AWADDR),.slave_AWVLD(slave_AWVLD),.slave_AWRDY(slave_AWRDY),
    //write data
.slave_WID(slave_WID),.slave_WDATA(slave_WDATA),.slave_WVLD(slave_WVLD),.slave_WRDY(slave_WRDY),
    //write resp
.slave_BID(slave_BID),.slave_BRESP(slave_BRESP),.slave_BVLD(slave_BVLD),.slave_BRDY(slave_BRDY), 
    //read addr
.master_ARID(master_ARID),.master_ARADDR(master_ARADDR),.master_ARVLD(master_ARVLD),.master_ARRDY(master_ARRDY),
    //read data
.master_RID(master_RID),.master_RDATA(master_RDATA),.master_RVLD(master_RVLD),.master_RRDY(master_RRDY),
    //write addr
.master_AWID(master_AWID),.master_AWADDR(master_AWADDR),.master_AWVLD(master_AWVLD),.master_AWRDY(master_AWRDY),
    //write data
.master_WID(master_WID),.master_WDATA(master_WDATA),.master_WVLD(master_WVLD),.master_WRDY(master_WRDY),
    //write resp
.master_BID(master_BID),.master_BRESP(master_BRESP),.master_BVLD(master_BVLD),.master_BRDY(master_BRDY));

endmodule
