`timescale 1ns/1ns
module optimal_place#(
    parameter COL_NUM = 8,
    parameter LIN_NUM = 8)
    (
    input CLK,
    input RST_n,
    output reg    [2:0]     x_min,
    output reg    [2:0]     y_min,
    output reg    [15:0]    cost_mini,
    output reg              output_vld
    );

    reg   [1:0]     matrix[0:63];
    integer         fp;
    integer         fin;
    reg   [1:0]     file_in;
    reg   [6:0]     in_cnt;
    reg   [6:0]     matrix_index;
    reg             bfs_start;
    wire             matrix_index_en;
    wire  [15:0]    start_node;
    // reg   [15:0]    cost_mini;
    reg   [7:0]     reg_num_in_matrix;
    reg   [2:0]     x;
    // reg   [2:0]     x_min;
    reg   [2:0]     y;
    // reg   [2:0]     y_min;
    wire  [15:0]    bfs2matrix_rd_node;
    wire  [1:0]     node_matrix_val;
    wire            load_start_node_comb;
    reg             load_start_node;
    wire            matrix_index_vld;
    wire  [15:0]    start_node_comb;
    wire            total_cost_vld;
    wire  [15:0]    total_cost;
    wire  [6:0]     total_reg;
    reg             load_start_node_flag;
    reg             bfs_start_1d;
    reg             bfs_start_2d;
    reg             total_cost_vld_1d; // due to modelsim


    initial begin
      fin = $fopen("input.txt", "r");
    end
    
    always@(posedge CLK or negedge RST_n) begin
      if(!RST_n) begin
        in_cnt <= 6'b0;
        reg_num_in_matrix <= 8'b0;
      end
      else if(!bfs_start) begin
        fp = $fscanf(fin,"%1d",file_in);
        matrix[in_cnt[5:0]] <= file_in;
        //$display("%d %d", file_in, matrix[in_cnt[5:0]-1]);
          if(file_in == 1)
            reg_num_in_matrix <= reg_num_in_matrix + 1'b1;
        in_cnt <= in_cnt + 1;
      end
    end

    always@(posedge CLK or negedge RST_n) begin
      if(!RST_n) begin
        bfs_start <= 0;
      end
      else if(in_cnt == 7'd63) begin
        bfs_start <= 1;
      end
    end

    assign node_matrix_val = matrix[{bfs2matrix_rd_node[10:8],bfs2matrix_rd_node[2:0]}];//due to limited mem space 3bit x, 3 bit y

    always@(posedge CLK or negedge RST_n) begin
      if(!RST_n) begin
        matrix_index <= 7'b0;
      end
      else if((load_start_node == 1'b1) && (matrix_index != 7'd63))
        matrix_index <= matrix_index + 1'b1;
      //else if((bfs_start == 1'b1) && (matrix_index_en == 1'b1)) 
      else if(matrix_index_en == 1'b1)
        matrix_index <= matrix_index + 1'b1;
    end

    assign matrix_index_en = ((matrix[matrix_index[5:0]] == 2'b00)|| matrix_index == 7'd63) ? 1'b0:1'b1;

    assign matrix_index_vld = (matrix[matrix_index[5:0]] == 2'b00) ? 1'b1:1'b0;// matrix[index] is 0

    always@(posedge CLK or negedge RST_n) begin
      if(!RST_n) begin
        load_start_node <= 1'b0;
      end
      else if(load_start_node_flag == 1'b1) begin
        load_start_node <= bfs_start_1d &(~bfs_start_2d);  //due to modelsim
        load_start_node_flag <= 1'b0;
        //load_start_node <= bfs_start_ &(~bfs_start_1d);  //due to modelsim
      end
      else  begin
        total_cost_vld_1d <= total_cost_vld; // due to modelsim
        load_start_node <= total_cost_vld;
      end
    end

    assign start_node = {5'b0, matrix_index[5:3], 5'b0, matrix_index[2:0]};

    always @(posedge CLK or negedge RST_n) begin
      if(~RST_n) begin
          load_start_node_flag <= 0;
          bfs_start_1d <= 1'b0;
          bfs_start_2d <= 1'b0;
      end else if((bfs_start == 1'b1) && (bfs_start_2d == 1'b0))begin
          load_start_node_flag <= 1'b1;
          bfs_start_1d <= bfs_start;
          bfs_start_2d <= bfs_start_1d; //due to modelsim
      end
    end
    
    always@(posedge CLK or negedge RST_n) begin
      if(!RST_n) begin
        cost_mini <= 16'hffff;
        x_min     <= 3'b0;
        y_min     <= 3'b0;
      end
      else if((total_cost_vld == 1'b1) && (total_cost < cost_mini) && (reg_num_in_matrix == total_reg)) begin
        cost_mini <= total_cost;
        x_min     <= x;
        y_min     <= y;
      end
    end

    always @(posedge CLK or negedge RST_n) begin
      if(~RST_n) begin
        x <= 3'b0;
        y <= 3'b0;
      end else if(load_start_node == 1'b1) begin
        x <= start_node[10:8];
        y <= start_node[2:0];
      end
    end

    // always@(posedge CLK or negedge RST_n) begin
    //   if(total_cost_vld)
    //     $display("x = %d, y= %d, total_cost = %d, %d",x, y, cost_mini, total_reg);
    // end
    always@(posedge CLK or negedge RST_n) begin
      if(!RST_n)
        output_vld <= 1'b0;
      else if((matrix_index == 7'd63) && (total_cost_vld_1d == 1'b1)) begin
        // $display("x = %d, y= %d, total_cost = %d, %d",x_min, y_min, cost_mini, total_reg);
        output_vld <= 1'b1;
      end
      else 
        output_vld <= 1'b0;
    end    
    bfs_search U_BFS_SEARCH (.CLK(CLK),.RST_n(RST_n),.load_start_node(load_start_node), .start_node(start_node),
                              .node_matrix_val(node_matrix_val),.total_cost_vld(total_cost_vld),.total_cost(total_cost),.total_reg(total_reg),
                              .bfs2matrix_rd_node(bfs2matrix_rd_node));


endmodule