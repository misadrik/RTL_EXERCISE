module CRC(D_IN, CLK, RST, D_OUT, CRC_RDY);
    input CLK, RST;
    input [31:0] D_IN;
    output[35:0] D_OUT;
    output       CRC_RDY;

    reg[5:0]    cnt;
    reg[35:0]   D_OUT;
    reg         CRC_RDY;
    reg[35:0]   D_IN_temp;
    reg[3:0]    CRC_val;
    reg[35:0]  D_IN_temp_comb;

    always @(posedge CLK or negedge RST) begin
        if(RST) begin
            cnt <= 6'b0;
        end
        else if(cnt == 6'd33) begin
            cnt <= 5'b0;
        end
        else begin
            cnt <= cnt + 1;
        end
    end

    always @(*) begin
        D_IN_temp_comb = D_IN_temp;

        if(D_IN_temp[35] == 1'b1)
            D_IN_temp_comb[35:31] = D_IN_temp[35:31] ^ 5'b10011;

        D_IN_temp_comb = D_IN_temp_comb << 1;
    end

    always @(posedge CLK or negedge RST) begin
        if(RST) begin
            D_IN_temp <= 0;
        end
        else if(cnt == 6'b0) begin
            D_IN_temp <= {D_IN,4'b0};
        end
        else
            D_IN_temp <= D_IN_temp_comb;
    end

    always@(posedge CLK or negedge RST) begin
        if(RST) begin
            CRC_RDY <= 1'b0;
            D_OUT   <= 1'b0;
        end
        else if(cnt == 6'b0) begin
            CRC_RDY <= 1'b0;
            D_OUT   <= 1'b0;
        end
        else if(cnt == 6'd32) begin
            D_OUT   <= {D_IN, D_IN_temp_comb[35:32]};
            CRC_RDY <= 1'b1;
        end
        else begin
            CRC_RDY <= 1'b0;
            D_OUT   <= 1'b0;
        end
    end
endmodule