module PATH_INPUT_CTRL (
    input                   clk, 
    input                   rst,
    input                   polarity,
    input[63:0]             ch2in_din,
    input                   ch2in_vld,
    output                  in2ch_rdy,
    output                  in2path_req,
    output                  in2pe_req,
    input                   path2in_gnt,
    input                   pe2in_gnt,
    output[63:0]            in2out_dout
);

    reg[63:0]               in_buffer[0:1];
    reg[1:0]                in_buffer_empty;
    reg[1:0]                in_buffer_will_empty;
    wire[1:0]               in_buffer_en;

    assign in_buffer_en = in_buffer_empty | in_buffer_will_empty;

    assign in2ch_rdy = ((~polarity) && in_buffer_en[0]) || (polarity && in_buffer_en[1]);

    always@(posedge clk) begin
        if(rst) begin
            in_buffer_empty <= 2'b11;
        end
        else if(polarity && in_buffer_en[1] && in2ch_rdy && ch2in_vld && ch2in_din[63]) begin
            in_buffer_empty[1] <= 1'b0;
            in_buffer_empty[0] <= in_buffer_will_empty[0]|in_buffer_empty[0];
        end
        else if((~polarity) && in_buffer_en[0] && in2ch_rdy && ch2in_vld && (~ch2in_din[63])) begin
            in_buffer_empty[0] <= 1'b0;
            in_buffer_empty[1] <= in_buffer_will_empty[1]|in_buffer_empty[1];
        end
        else begin
            in_buffer_empty <= in_buffer_empty|in_buffer_will_empty;
        end
    end

    always@(posedge clk) begin
        if(polarity && in_buffer_en[1] && in2ch_rdy && ch2in_vld && ch2in_din[63]) begin
            in_buffer[1] <= {ch2in_din[63:56],1'b0,ch2in_din[55:49],ch2in_din[47:0]}; //right shift hop value
        end
        else if((~polarity) && in_buffer_en[0] && in2ch_rdy && ch2in_vld && (~ch2in_din[63])) begin
            in_buffer[0] <= {ch2in_din[63:56],1'b0,ch2in_din[55:49],ch2in_din[47:0]};
        end
    end

    assign in2path_req_even   = (polarity && (~in_buffer_empty[0]) && (in_buffer[0][55:48] != 8'b0));
    assign in2path_req_odd    = ((~polarity) && (~in_buffer_empty[1]) && (in_buffer[1][55:48] != 8'b0));
    assign in2path_req        = in2path_req_even || in2path_req_odd;

    assign in2pe_req_even  = (polarity && (~in_buffer_empty[0]) && (in_buffer[0][55:48] == 8'b0));
    assign in2pe_req_odd   = ((~polarity) && (~in_buffer_empty[1]) && (in_buffer[1][55:48] == 8'b0));
    assign in2pe_req       = in2pe_req_even || in2pe_req_odd;

    always@(*) begin
        in_buffer_will_empty = 2'b00;
        if(path2in_gnt) begin
            in_buffer_will_empty = {in2path_req_odd, in2path_req_even};
        end
        else if(pe2in_gnt) begin
            in_buffer_will_empty = {in2pe_req_odd, in2pe_req_even};
        end
    end

    assign gnt_ind = pe2in_gnt || path2in_gnt;

    assign in2out_dout = (gnt_ind && (~polarity)) ? in_buffer[1] : 
                         (gnt_ind &&  polarity)   ? in_buffer[0] : 64'b0;

endmodule