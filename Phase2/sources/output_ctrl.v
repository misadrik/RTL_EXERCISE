module OUTPUT_CTRL(
    input                       clk,
    input                       rst,
    input                       polarity,
    input                       path_rdy,
    input[63:0]                 din,
    input                       req_0,
    input                       req_1,
    output reg                  gnt_0,
    output reg                  gnt_1,
    output[63:0]                dout,
    output reg                  dout_vld);

    reg[63:0]                   out_buffer[0:1];
    reg[1:0]                    out_buffer_empty;
    reg[1:0]                    out_buffer_will_empty;
    wire[1:0]                   out_buffer_en;

    reg                         prior;
    wire                        gnt_ind;

    assign out_buffer_en = out_buffer_empty | out_buffer_will_empty;

always@(posedge clk) begin
    if(gnt_ind && polarity) begin
        out_buffer[0] <= din;
    end
    else if(gnt_ind && (~polarity)) begin
        out_buffer[1] <= din;
    end
end

always@(posedge clk) begin
    if(rst) begin
        out_buffer_empty <= 2'b11;
    end
    else if(gnt_ind && polarity) begin
        out_buffer_empty[0] <= 1'b0;
        out_buffer_empty[1] <= out_buffer_will_empty[1]|out_buffer_empty[1];
    end
    else if(gnt_ind && (~polarity)) begin
        out_buffer_empty[1] <= 1'b0;
        out_buffer_empty[0] <= out_buffer_will_empty[0]|out_buffer_empty[0];
    end
    else begin
        out_buffer_empty <= out_buffer_empty|out_buffer_will_empty;
    end

end

always@(posedge clk) begin
    if(rst) begin
        prior <= 1'b0;
    end
    else if((prior && gnt_1) || ((~prior) && gnt_0)) begin
        prior <= ~prior;
    end
end

assign gnt_ind = gnt_0 || gnt_1;

always@(*) begin
    gnt_0 = 1'b0;
    gnt_1 = 1'b0;

    if(polarity && (~prior) && req_0 && out_buffer_en[0]) begin
        gnt_0 = 1'b1;
    end
    else if(polarity && (~prior) && req_1 && out_buffer_en[0]) begin
        gnt_1 = 1'b1;
    end
    else if(polarity && prior && req_1 && out_buffer_en[0]) begin
        gnt_1 = 1'b1;
    end
    else if(polarity && prior && req_0 && out_buffer_en[0]) begin
        gnt_0 = 1'b1;
    end
    else if((~polarity) && prior && req_1 && out_buffer_en[1]) begin
        gnt_1 = 1'b1;
    end
    else if((~polarity) && prior && req_0 && out_buffer_en[1]) begin
        gnt_0 = 1'b1;
    end
    else if((~polarity) && (~prior) && req_0 && out_buffer_en[1]) begin
        gnt_0 = 1'b1;
    end
    else if((~polarity) && (~prior) && req_1 && out_buffer_en[1]) begin
        gnt_1 = 1'b1;
    end
end

assign dout = (dout_vld && (~polarity)) ? out_buffer[0] :
                (dout_vld && polarity) ? out_buffer[1] : 64'b0;

always@(*) begin
   dout_vld = 1'b0;
   if(path_rdy && (~polarity) && (~out_buffer_empty[0])) begin
        dout_vld = 1'b1;
   end
   else if(path_rdy && (polarity) && (~out_buffer_empty[1])) begin
        dout_vld = 1'b1;
   end
end

always@(*) begin
    out_buffer_will_empty = 2'b00;
    if(dout_vld && (~polarity)) begin
        out_buffer_will_empty = 2'b01;
    end
    else if(dout_vld && polarity) begin
        out_buffer_will_empty = 2'b10;
    end
end

endmodule : OUTPUT_CTRL