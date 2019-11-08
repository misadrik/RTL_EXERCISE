module async_fifo#(
    parameter DATA_WIDTH = 16,
    parameter FIFO_DEPTH = 5)(
    input rst_n,
    input clk_w,
    input clk_r,
    input[DATA_WIDTH-1:0] din,
    input wen,
    input ren,
    output [DATA_WIDTH-1:0] dout,
    output full,
    output empty
    );

    reg[FIFO_DEPTH:0] wrptr;
    reg[FIFO_DEPTH:0] rdptr;
    reg[DATA_WIDTH-1:0] fifo_mem[0:2**FIFO_DEPTH -1];


    wire wenq;
    wire renq;

    assign wenq = wen &(~full);
    assign renq = ren &(~empty);

    assign empty  = (wrptr_gray_ss == rdptr_gray) ? 1'b1:1'b0;
    assign full   = ((wrptr_gray[PTR_WIDTH:PTR_WIDTH-1] == (~rdptr_gray_ss[PTR_WIDTH:PTR_WIDTH-1])) && (wrptr_gray[PTR_WIDTH-2:0] == rdptr_gray_ss[PTR_WIDTH-2:0])) ? 1'b1:1'b0;


    always@(posedge clk_w or negedge rst_n) begin
        if(~rst_n) begin
            wrptr <= {FIFO_DEPTH{1'b0}};
        end
        else if(wenq) begin
            wrptr <= wrptr + 1'b1;
            fifo_mem[wrptr[FIFO_DEPTH-1 :0]] <= DIN;
        end
    end

    assign wrptr_next = wrptr + 1'b1;

    always@(posedge clk_w or negedge rst_n) begin
        if(~rst_n) begin
            wrptr_gray <= {FIFO_DEPTH{1'b0}};
        end
        else
            wrptr_gray <= wrptr_next ^ {1'b0, wrptr_next[FIFO_DEPTH:1]};
    end

    always@(posedge clk_r or negedge rst_n) begin
        if(~rst_n) begin
            wrptr_gray_1d <= {FIFO_DEPTH{1'b0}};
            wrptr_gray_2d <= {FIFO_DEPTH{1'b0}};
        end
        else begin
            wrptr_gray_1d <= wrptr_gray;
            wrptr_gray_2d <= wrptr_gray_1d;            
        end
    end


    always@(posedge clk_r or negedge rst_n) begin
        if(~rst_n) begin
            rdptr <= {FIFO_DEPTH{1'b0}};
        end
        else if(renq) begin
            rdptr <= rdptr + 1'b1;
        end
    end

    assign rdptr_next = rdptr + 1'b1;

    always @(posedge clk_r or negedge rst_n) begin
        if(~rst_n) begin
            rdptr_gray <= {FIFO_DEPTH{1'b0}};
        end
        else
            rdptr_gray <= rdptr_next ^ {1'b0, rdptr_next[FIFO_DEPTH:1]};
    end

    always@(posedge clk_w or negedge rst_n) begin
        if(~rst_n) begin
            rdptr_gray_1d <= {FIFO_DEPTH{1'b0}};
            rdptr_gray_2d <= {FIFO_DEPTH{1'b0}};
        end
        else begin
            rdptr_gray_1d <= rdptr_gray;
            rdptr_gray_2d <= rdptr_gray_1d;            
        end
    end


endmodule : async_fifo