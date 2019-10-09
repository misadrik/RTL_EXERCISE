module arbiter_LRU4(grant_vector, req_vector, enable, CLK, RST);
    input[3:0] req_vector;
    input CLK;
    input RST;
    input enable;
    output[3:0] grant_vector;

    reg [1:0] lru[3:0];
    reg [3:0] grant_vector;
    reg [3:0] grant_vector_1d;
    reg [3:0] grant_vector_pre;
    reg [1:0] equal_sloc;
    reg [3:0] update_sloc;
    wire  grant_ind;
    reg cnt;
    integer i;
// initialize lru
    always@(posedge CLK) begin
        if(RST) begin
            lru[0] <= 2'd0;
            lru[1] <= 2'd1;
            lru[2] <= 2'd2;
            lru[3] <= 2'd3;
            grant_vector <= 4'b0;
            // for(i=0; i<4; i=i+1) begin
            //     lru[i]          <= i;
            //     grant_vector[i] <= 1'b0;
            // end
        end
        // update lru
        else if((enable == 1'b1) &&(cnt == 1'b1)) begin
            if(equal_sloc == 2'b0) begin
                lru[3] <= lru[0];
                lru[2] <= lru[3];
                lru[1] <= lru[2];
                lru[0] <= lru[1];
            end
            else if(equal_sloc == 2'b1) begin
                lru[3] <= lru[1];
                lru[2] <= lru[3];
                lru[1] <= lru[2];
            end
            else if(equal_sloc == 2'b10) begin
                lru[3] <= lru[2];
                lru[2] <= lru[3];
            end
        end
    end
// determin which block in lru is recently used
    always @(*) begin
        for(i = 0; i <4; i = i+1)begin
            if(grant_vector[lru[i]] == 1'b1) begin
                equal_sloc = i;
            end
        end
    
    end

//give grant
    always@(*) begin
        if(RST)
            grant_vector_pre = 4'b0;
        else if(!enable)
            grant_vector_pre = 4'b0;
        else if(cnt == 1'b1) // neglect in the second clk of a grant since grant last for two clk
            grant_vector_pre = 4'b0;
        else if(req_vector[lru[0]])
            grant_vector_pre[lru[0]] = req_vector[lru[0]];
        else if(req_vector[lru[1]])
            grant_vector_pre[lru[1]] = req_vector[lru[1]];
        else if(req_vector[lru[2]])
            grant_vector_pre[lru[2]] = req_vector[lru[2]];
        else if(req_vector[lru[3]])
            grant_vector_pre[lru[3]] = req_vector[lru[3]];
        else
            grant_vector_pre = 4'b0;
    end

    always@(posedge CLK) begin
        if(RST)
            grant_vector_1d <= 4'b0;
        else if(!enable)
            grant_vector_1d <= 4'b0;
        else
            grant_vector_1d <= grant_vector_pre;
    end

    always@(*) begin
        grant_vector = grant_vector_1d | grant_vector_pre;
    end

    assign grant_ind = |grant_vector;

    always@(posedge CLK) begin
        if(RST)
            cnt <= 1'b0;
        else if(grant_ind)
            cnt <= cnt +1;
    end
    
endmodule