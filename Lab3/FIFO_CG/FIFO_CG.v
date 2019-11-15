//empty and fulll signal is low active
// active high reset
module FIFO_CG#(
    parameter DATA_WIDTH = 16,
    parameter FIFO_DEPTH = 8
)(
    input                           rclk,
    input                           wclk,
    input                           reset,
    input                           put,
    input                           get,
    input[DATA_WIDTH - 1:0]         data_in,
    output                          empty_bar,
    output                          full_bar,
    output[DATA_WIDTH -1:0]         data_out);
    
    localparam PTR_WIDTH = $clog2(FIFO_DEPTH);
    
    reg [DATA_WIDTH-1:0]                    fifo_mem[0:FIFO_DEPTH-1];
    
    reg [PTR_WIDTH:0]                       wrptr_bin;
    wire[PTR_WIDTH:0]                       wrptr_bin_ss;
    wire[PTR_WIDTH:0]                       wrptr_bin_next;
    reg [PTR_WIDTH:0]                       wrptr_gray;
    reg [PTR_WIDTH:0]                       wrptr_gray_s;
    reg [PTR_WIDTH:0]                       wrptr_gray_ss;

    reg [PTR_WIDTH:0]                       rdptr_bin;
    wire[PTR_WIDTH:0]                       rdptr_bin_ss;
    wire[PTR_WIDTH:0]                       rdptr_bin_next;
    reg [PTR_WIDTH:0]                       rdptr_gray;      
    reg [PTR_WIDTH:0]                       rdptr_gray_s;      
    reg [PTR_WIDTH:0]                       rdptr_gray_ss;  
    
    wire                                    full;
    wire                                    empty;
    wire                                    wen_q;
    wire                                    ren_q;

    wire                                     WCLK_G;
    wire                                     RCLK_G;

    assign WCLK_G = ~((~wclk) & put);
    assign RCLK_G = ~((~rclk) & get);

    assign full_bar   = !full;
    assign empty_bar  = !empty;
    
    assign empty      = (wrptr_gray_ss == rdptr_gray) ? 1'b1:1'b0;
    assign full       = ((wrptr_gray[PTR_WIDTH:PTR_WIDTH-1] == (~rdptr_gray_ss[PTR_WIDTH:PTR_WIDTH-1])) && (wrptr_gray[PTR_WIDTH-2:0] == rdptr_gray_ss[PTR_WIDTH-2:0])) ? 1'b1:1'b0;

    assign wen_q = (!full)  && put;
    assign ren_q = (!empty) && get;

    always @(posedge WCLK_G) begin
        if(wen_q) begin
             fifo_mem[wrptr_bin[PTR_WIDTH-1:0]] <= data_in;
        end
    end  

    always @(posedge WCLK_G or posedge reset) begin
        if(reset) begin
             wrptr_bin <= {PTR_WIDTH+1{1'b0}};
        end 
        else if(wen_q) begin
             wrptr_bin <= wrptr_bin + 1;
        end
    end  

    assign wrptr_bin_next = wrptr_bin + 1;

    always @(posedge WCLK_G or posedge reset) begin
        if(reset) begin
            wrptr_gray <= {PTR_WIDTH+1{1'b0}};
        end
        else if(wen_q) begin
            wrptr_gray <= {1'b0,wrptr_bin_next[PTR_WIDTH:1]} ^ wrptr_bin_next;
        end
    end
//double sync wptr
    always @(posedge rclk or posedge reset) begin
        if(reset) begin
            wrptr_gray_s    <= {PTR_WIDTH+1{1'b0}};
            wrptr_gray_ss   <= {PTR_WIDTH+1{1'b0}};
        end
        else begin
            wrptr_gray_s    <= wrptr_gray;
            wrptr_gray_ss   <= wrptr_gray_s;
        end
    end

    assign data_out = fifo_mem[rdptr_bin[PTR_WIDTH-1:0]];

    always@(posedge RCLK_G or posedge reset) begin
        if(reset) begin
            rdptr_bin <= {PTR_WIDTH+1{1'b0}};
        end
        else if(ren_q) begin
            rdptr_bin <= rdptr_bin + 1'b1;
        end
    end

    assign rdptr_bin_next = rdptr_bin + 1'b1;

    always @(posedge RCLK_G or posedge reset) begin
        if(reset) begin
            rdptr_gray <= {PTR_WIDTH+1{1'b0}};
        end
        else if(ren_q) begin
            rdptr_gray <= {1'b0,rdptr_bin_next[PTR_WIDTH:1]} ^ rdptr_bin_next;
        end
    end
//double sync rdptr
    always @(posedge wclk or posedge reset) begin
        if(reset) begin
            rdptr_gray_s    <= {PTR_WIDTH+1{1'b0}};
            rdptr_gray_ss   <= {PTR_WIDTH+1{1'b0}};
        end
        else begin
            rdptr_gray_s    <= rdptr_gray;
            rdptr_gray_ss   <= rdptr_gray_s;
        end
    end


endmodule