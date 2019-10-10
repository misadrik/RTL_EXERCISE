`timescale 1ns/1ns
module optimal_place#(
    parameter COL_NUM = 8,
    parameter LIN_NUM = 8)
    (
    input CLK,
    input RST_n
    );

    reg[1:0] matrix[0:63];
    integer fp;
    integer fin;
    reg [1:0] file_in;
    reg [6:0] in_cnt;
    reg bfs_start;

    initial begin
      fin = $fopen("example.ckt", "r");
    end
    
    always@(posedge CLK or negedge RST_n) begin
      if(!RST_n) begin
        in_cnt <= 6'b0;
      end
      else if(!bfs_start) begin
        fp = $fscanf(fin,"%d",file_in);
        matrix[in_cnt[5:0]] <= file_in;
        //$display("%d %d", file_in, matrix[in_cnt[5:0]-1]);
        in_cnt <= in_cnt + 1;
      end
    end

    always@(posedge CLK or negedge RST_n) begin
      if(!RST_n) begin
        bfs_start <= 0;
      end
      else if(in_cnt == 7'd64) begin
        bfs_start <= 1;
      end
    end

  

endmodule