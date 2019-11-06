module sync_fifo#(
    parameter DATA_WIDTH = 16,
    parameter FIFO_DEPTH = 5)(
    input RST_n,
    input CLK,
    input[DATA_WIDTH-1:0] DIN,
    input WEN,
    input REN,
    output [DATA_WIDTH-1:0] DOUT,
    output full,
    output empty
    );

    reg[FIFO_DEPTH:0] wrptr;
    reg[FIFO_DEPTH:0] rdptr;
    reg[DATA_WIDTH-1:0] fifo_mem[0:2**FIFO_DEPTH -1];
    wire wen_q;
    wire ren_q;
  
    assign empty = ((wrptr - rdptr) == {(FIFO_DEPTH+1){1'b0}}) ? 1'b1:1'b0;
    assign full  = ((wrptr - rdptr) == {1'b1,{FIFO_DEPTH{1'b0}}}) ? 1'b1:1'b0;

    assign wen_q = (!full) & WEN;
    assign ren_q = (!empty)& REN;

    always@(posedge CLK or negedge RST_n) begin
      if(!RST_n) begin
        wrptr <= 0;
      end
      else if(wen_q) begin
         wrptr <=  wrptr + 1;
      end
    end

    always@(posedge CLK) begin
      if(wen_q) begin
        fifo_mem[wrptr[FIFO_DEPTH-1 :0]] <= DIN;
      end
    end

    always@(posedge CLK or negedge RST_n) begin
      if(!RST_n) begin
        rdptr <= 0;
      end
      else if(ren_q) begin
         rdptr <=  rdptr + 1;
      end
    end
    
    assign DOUT = fifo_mem[rdptr[FIFO_DEPTH-1 :0]];

endmodule : sync_fifo