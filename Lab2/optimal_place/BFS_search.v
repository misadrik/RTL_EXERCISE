module bfs_search#(
    parameter COL_NUM = 8,
    parameter LIN_NUM = 8)(
    input               CLK,
    input               RST_n,
    input               load_start_node, // high for 1 clk to load start_node
    input       [15:0]  start_node,
    input       [1:0]   node_matrix_val,
    output reg          total_cost_vld,
    output reg  [15:0]  total_cost,
    output reg  [6:0]   total_reg,
    output      [15:0]  bfs2matrix_rd_node);

//breath first search queue;
    reg                     bfs_en;
    reg     [1:0]           DIR_CNT; 
    reg     [7:0]           cost[0:63];
    reg     [0:63]          cost_vld;
    reg                     cost_collect_en;
    reg     [6:0]           collect_cnt;
    wire    [15:0]          data2queue_push;
    wire    [15:0]          next_node_comb;
    wire                    queue_push;
    wire    [15:0]          current_node;
    wire    [5:0]           current_node_index;
    wire    [5:0]           next_node_index;
    wire                    queue_empty;
    wire                    queue_full;
    wire    [15:0]          collect_rd_node;
    wire    [5:0]           start_node_index;
    wire                    bfs_en_comb;

    sync_fifo U_SYNC_FIFO(.RST_n(RST_n),.CLK(CLK),.DIN(data2queue_push),.WEN(queue_wen),.REN(queue_ren),.DOUT(current_node),.full(queue_full),.empty(queue_empty));


    assign queue_wen = (load_start_node | queue_push) & (!queue_full) ;
    assign queue_ren = ((DIR_CNT == 2'b11) && (queue_empty == 1'b0))? 1'b1: 1'b0; //increment when all four sons are enumerated

    assign data2queue_push = load_start_node ? start_node : next_node_comb;

    initial begin
       // $monitor("x is %d y is %d",next_node_index[5:3],next_node_index[2:0]);
    end
    //load first node to queue
    always@(posedge CLK or negedge RST_n)begin
      if(!RST_n) begin
        bfs_en <= 1'b0;
      end
      else if(load_start_node) begin
        bfs_en <= 1'b1;
      end
      else if(queue_empty) begin
        bfs_en <= 1'b0;
        end
    end

    assign bfs_en_comb = (queue_empty ==1'b1) ? 1'b0: bfs_en;

    always@(posedge CLK or negedge RST_n) begin // cost collect en
        if(!RST_n) begin
            cost_collect_en <= 1'b0;
        end
        else if((!load_start_node) & queue_empty & bfs_en) begin
            cost_collect_en <= 1'b1;
        end
        else if(collect_cnt == 7'd63) begin
            cost_collect_en <= 1'b0;
        end
    end

    always@(posedge CLK or negedge RST_n)begin // make sure all four nodes are searched
      if(!RST_n) begin
        DIR_CNT <= 2'b0;
      end
      else if(load_start_node == 1'b1) begin
        DIR_CNT <=2'b0;
      end
      else if(bfs_en) begin
        DIR_CNT <= DIR_CNT + 1;
      end
    end

//walk
    assign next_node_comb = walk(current_node, DIR_CNT);
    assign bfs2matrix_rd_node = (cost_collect_en == 1'b1) ? collect_rd_node : next_node_comb;
    assign collect_rd_node = (cost_collect_en == 1'b1) ? {5'b0,collect_cnt[5:3],5'b0, collect_cnt[2:0]}:16'b0;

    assign next_node_index = {next_node_comb[10:8], next_node_comb[2:0]};
    assign current_node_index = {current_node[10:8], current_node[2:0]};
    assign start_node_index = (load_start_node == 1'b1) ? {start_node[10:8], start_node[2:0]} : 6'b0;

//judge and store the value
    always@(posedge CLK or negedge RST_n) begin
        if(!RST_n) begin
            cost_vld <= 64'b0;
        end
        else if(total_cost_vld == 1'b1) begin
            cost_vld <= 64'b0;
        end
        else if(load_start_node == 1'b1) begin //initial start node
            cost_vld[start_node_index] <= 1'b1;
            cost[start_node_index] <= 8'b0;
        end
        else begin
            if((cost_vld[next_node_index] == 1'b0) && (judge_range(next_node_comb, node_matrix_val) == 1'b1)) begin
                cost_vld[next_node_index] <= 1'b1; // calculate cost
                cost[next_node_index] <= cost[current_node_index] + 1;
            end
        end
    end

    // wire[7:0] cost_watcher;
    // assign cost_watcher = cost[current_node_index] + 1;
    assign queue_push = judge_type(next_node_comb, node_matrix_val) & bfs_en_comb &(!cost_vld[next_node_index]); // push nodes to queue

// after BFS done collect the results
    always@(posedge CLK or negedge RST_n) begin
        if(!RST_n) begin
            collect_cnt <= 7'b0;
        end
        else if(!cost_collect_en) begin
            collect_cnt <= 7'b0;
        end
        else
            collect_cnt <= collect_cnt + 1'b1;
    end

    always@(posedge CLK or negedge RST_n) begin
        if(!RST_n) begin
            total_cost <= 16'b0;
            total_reg <= 7'b0;
        end
        else if(!cost_collect_en) begin
            total_cost <= 16'b0;
            total_reg <= 7'b0;
        end
        else
            if((node_matrix_val == 2'b01) && (cost_vld[collect_cnt[5:0]] == 1'b1)) begin
                total_reg <= total_reg + 1'b1;
                total_cost <= total_cost + cost[collect_cnt[5:0]];
            end
    end

    always@(posedge CLK or negedge RST_n) begin
        if(!RST_n) begin
            total_cost_vld <= 1'b0;
        end
        else if(collect_cnt == 7'd63) begin
            total_cost_vld <= 1'b1;
        end
        else
            total_cost_vld <= 1'b0;
    end



function [15:0] walk;
    input[15:0] current_node; //15:8 x, 7:0 y;
    input[1:0] dir;

    begin
        if(dir == 2'b00)
            walk = {current_node[15:8], current_node[7:0] - 7'b1}; //x,y-1
        else if(dir == 2'b01)
            walk = {current_node[15:8], current_node[7:0] + 7'b1}; //x,y+1
        else if(dir == 2'b10)
            walk = {current_node[15:8] - 7'b1, current_node[7:0]}; //x-1,y
        else
            walk = {current_node[15:8] + 7'b1, current_node[7:0]}; //x+1,y
    end
endfunction

function judge_range;
    input[15:0] node;
    input[1:0] node_matrix_val;

    begin
        if(node[15:8] > (COL_NUM - 1)) judge_range = 1'b0;
        else if(node[7:0] > (LIN_NUM - 1)) judge_range = 1'b0;
        //else if(node_matrix_val == 2'b01) judge_range = 1'b0;
        else judge_range = 1'b1;
    end
endfunction

function judge_type;
    input[15:0] node;
    input[1:0] node_matrix_val;

    begin
        if(node[15:8] > (COL_NUM - 1)) judge_type = 1'b0;
        else if(node[7:0] > (LIN_NUM - 1)) judge_type = 1'b0;
        else if(node_matrix_val == 2'b10 || node_matrix_val == 2'b01) judge_type = 1'b0;
        else judge_type = 1'b1;
    end
endfunction
endmodule