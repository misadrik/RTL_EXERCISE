module sync_fifo#(
    parameter DATA_WIDTH = 16,
    parameter FIFO_DEPTH = 32,
    parameter THREASHOLD = 30)(
    input                     rst_n,
    input                     clk,
    input[DATA_WIDTH-1:0]     DIN,
    input                     WEN,
    input                     REN,
    output [DATA_WIDTH-1:0]   DOUT,
    output                    almost_full,
    output                    full,
    output                    empty
    );

    localparam PTR_WIDTH = $clog2(FIFO_DEPTH);

    reg[PTR_WIDTH:0] wrptr;
    reg[PTR_WIDTH:0] rdptr;
    reg[DATA_WIDTH-1:0] fifo_mem[0:FIFO_DEPTH -1];
    
    wire wen_q;
    wire ren_q;
    
    assign empty = ((wrptr - rdptr) == {(PTR_WIDTH+1){1'b0}}) ? 1'b1:1'b0;
    assign full  = ((wrptr - rdptr) == {1'b1,{PTR_WIDTH{1'b0}}}) ? 1'b1:1'b0;

    assign almost_full = ((wrptr - rdptr) >= THREASHOLD);
    
    assign wen_q = (!full) & WEN;
    assign ren_q = (!empty)& REN;

    always@(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        wrptr <= 0;
      end
      else if(wen_q) begin
         wrptr <=  wrptr + 1;
      end
    end

    always@(posedge clk) begin
      if(wen_q) begin
        fifo_mem[wrptr[PTR_WIDTH-1 :0]] <= DIN;
      end
    end

    always@(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        rdptr <= 0;
      end
      else if(ren_q) begin
         rdptr <=  rdptr + 1;
      end
    end
    
    assign DOUT = fifo_mem[rdptr[PTR_WIDTH-1 :0]];

endmodule