`timescale 1ns/1ns
module TB_ROUTER_NODE();
    reg                   clk;
    reg                   reset;
    wire                  polarity; 
// 1  virtual channel being forwarded externally for any clk cycle
    reg                   cwsi;
    reg  [63:0]           cwdi;
    wire                  cwri;
    reg                   cwro;
    wire                  cwso;
    wire [63:0]           cwdo;

    reg                   ccwsi;
    reg  [63:0]           ccwdi;
    wire                  ccwri;
    reg                   ccwro;
    wire                  ccwso;
    wire [63:0]           ccwdo;

    reg                   pesi;
    reg  [63:0]           pedi;
    wire                  peri;
    reg                   pero;
    wire                  peso;
    wire [63:0]           pedo;


always #1 clk = ~clk;

initial begin
    clk = 1;
    reset = 1;
    cwro  = 1'b0;
    ccwro = 1'b0;
    pero = 1'b0;
    #5;
    reset = 0;
    #1;
    cwro  = 1'b1;
    ccwro  = 1'b1;
    #200;
    $stop;
end

reg dir;

reg[31:0] data;
always@(posedge clk)begin
    data <= $urandom % 32'hffff_ffff;
end


always@(posedge clk) begin
    if(reset) begin
        pesi <= 1'b0;
        pedi <= 64'b0;      
    end
    else if(peri) begin
        dir  = data[1];
        pesi <= 1'b1;
        pedi <= {~polarity,dir, 6'b0, 8'hff, 16'b0,data};
    end 
    else begin
        pesi <= 1'b0;
        pedi <= 64'b0;
    end
end

always@(posedge clk) begin
    if(reset) begin
        cwsi <= 1'b0;
        cwdi <= 64'b0;      
    end
    else if(cwri) begin
        cwsi <= 1'b1;
        cwdi <= {~polarity,1'b0, 6'b0, 8'h0f, 16'b0,data};
    end 
    else begin
        cwsi <= 1'b0;
        cwdi <= 64'b0;
    end
end

always@(posedge clk) begin
    if(reset) begin
        ccwsi <= 1'b0;
        ccwdi <= 64'b0;      
    end
    else if(ccwri) begin
        ccwsi <= 1'b1;
        ccwdi <= {~polarity,1'b1, 6'b0, 8'h03, 16'b0,data};
    end 
    else begin
        ccwsi <= 1'b0;
        ccwdi <= 64'b0;
    end
end
ROUTER_NODE U_ROUTER_NODE(.clk(clk),.reset(reset),.polarity(polarity), 
            .cwsi(cwsi),.cwdi(cwdi),.cwri(cwri),.cwro(cwro),.cwso(cwso),.cwdo(cwdo),
            .ccwsi(ccwsi),.ccwdi(ccwdi),.ccwri(ccwri),.ccwro(ccwro),.ccwso(ccwso),.ccwdo(ccwdo),
            .pesi(pesi),.pedi(pedi),.peri(peri),.pero(pero),.peso(peso),.pedo(pedo));

endmodule : TB_ROUTER_NODE