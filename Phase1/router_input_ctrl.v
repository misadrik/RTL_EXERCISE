module ROUTER_INPUT_CTRL (
    input                   clk,    // Clock
    input                   rst,
    input                   polarity,
    input[63:0]             ch2in_din,
    input                   ch2in_vld,
    output                  in2ch_rdy,
    output                  in2cw_req,
    output                  in2ccw_req,
    input                   cw2in_gnt,
    input                   ccw2in_gnt,
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
        if(rst) begin
            in_buffer[0] = 64'b0;
            in_buffer[1] = 64'b0;
        end
        else if(polarity && in_buffer_en[1] && in2ch_rdy && ch2in_vld && ch2in_din[63]) begin
            in_buffer[1] <= ch2in_din;
        end
        else if((~polarity) && in_buffer_en[0] && in2ch_rdy && ch2in_vld && (~ch2in_din[63])) begin
            in_buffer[0] <= ch2in_din;
        end
    end

    assign in2cw_req_even   = (polarity && (~in_buffer_empty[0]) && (~in_buffer[0][62]));
    assign in2cw_req_odd    = ((~polarity) && (~in_buffer_empty[1]) && (~in_buffer[1][62]));
    assign in2cw_req        = in2cw_req_even || in2cw_req_odd;

    assign in2ccw_req_even  = (polarity && (~in_buffer_empty[0]) && (in_buffer[0][62])) ;
    assign in2ccw_req_odd   = ((~polarity) && (~in_buffer_empty[1]) && (in_buffer[1][62]));
    assign in2ccw_req       = in2ccw_req_even || in2ccw_req_odd;

    always@(*) begin
        in_buffer_will_empty = 2'b00;
        if(ccw2in_gnt) begin
            in_buffer_will_empty = {in2ccw_req_odd,in2ccw_req_even};
        end
        else if(cw2in_gnt) begin
            in_buffer_will_empty = {in2cw_req_odd,in2cw_req_even};
        end
    end

    assign gnt_ind = cw2in_gnt || ccw2in_gnt;

    assign in2out_dout = (gnt_ind && (~polarity)) ? in_buffer[1] : 
                         (gnt_ind &&  polarity)   ? in_buffer[0] : 64'b0;

endmodule