`timescale 1ns/10ps
`include "./include/gscl45nm.v"
module fifo_tb();
    parameter DATA_WIDTH = 16;
    parameter FIFO_DEPTH = 8;

    reg                           rclk;
    reg                           wclk;
    reg                           reset;
    reg                           put;
    reg                           get;
    reg [DATA_WIDTH - 1:0]        data_in;
    wire                          empty_bar;
    wire                          full_bar;
    wire[DATA_WIDTH -1:0]         data_out;

    reg[DATA_WIDTH-1:0]           cnt;
    reg                           rd_en;

    integer                       wrfp;
    integer                       rdfp;

    always #10 wclk = ~wclk;
    always #25 rclk = ~rclk;
    // always #25 wclk = ~wclk;
    // always #10 rclk = ~rclk;

    initial begin
        $sdf_annotate("./fifo.sdf", U_ASYNC_FIFO,"sdf.log","MAXIMUM","1.0:1.0:1.0", "FROM_MAXIMUM");
        $enable_warnings;
        $log("ncsim.log");
    end

    initial begin
        wrfp = $fopen("number_send.txt","w");
        rdfp = $fopen("number_receive.txt","w");
        wclk = 1;
        rclk = 1;
        reset = 1;
        put = 1'b0;
        get = 1'b0;
        rd_en = 1'b0;
        #100 reset = 0;
        #100
        rd_en = 1'b1;
        #4000;
        $fclose(wrfp);
        $fclose(rdfp);
        $stop;

    end

    always@(posedge wclk or posedge reset) begin
        if(reset) begin
            put <= 1'b0;
            cnt <= 16'b1;
        end
        else if(full_bar&&(cnt<=200)) begin
            put <= 1'b1;
            cnt <= cnt + 1'b1;
            data_in <= cnt;
            $fdisplay(wrfp,"%d",cnt);
        end
        else begin
            put <= 1'b0;
        end
    end

    always@(posedge rclk or posedge reset) begin
        if(reset) begin
            get <= 1'b0;
        end
        else if(empty_bar&&rd_en && (get== 1'b0)) begin
            get <= 1'b1;
            $fdisplay(rdfp,"%d",data_out);
        end
        else if(!empty_bar) begin
            get <= 1'b0;
        end
    end

    always@(posedge rclk) begin
     if(rd_en && (get== 1'b1)) begin
            $fdisplay(rdfp,"%d",data_out);
        end
    end
fifo U_ASYNC_FIFO(
    .rclk(rclk),
    .wclk(wclk),
    .reset(reset),
    .put(put),
    .get(get),
    .data_in(data_in),
    .empty_bar(empty_bar),
    .full_bar(full_bar),
    .data_out(data_out));
endmodule