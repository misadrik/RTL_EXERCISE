module CRC(D_IN, CLK, RST, D_OUT);
    input CLK, RST;
    input [31:0] D_IN;
    output[35:0] D_OUT;

    wire[3:0]  crc_out;
    reg[31:0]  D_IN_1d;
    reg[3:0]   lfsr_c;
    reg[3:0]   lfsr_q;
    reg crc_en;

    always @(*) begin
        lfsr_c[0] = lfsr_q[2] ^ D_IN[0] ^ D_IN[3] ^ D_IN[4] ^ D_IN[6] ^ D_IN[8] ^ D_IN[9] ^ D_IN[10] ^ D_IN[11] ^ D_IN[15] ^ D_IN[18] ^ D_IN[19] ^ D_IN[21] ^ D_IN[23] ^ D_IN[24] ^ D_IN[25] ^ D_IN[26] ^ D_IN[30];
        lfsr_c[1] = lfsr_q[2] ^ lfsr_q[3] ^ D_IN[0] ^ D_IN[1] ^ D_IN[3] ^ D_IN[5] ^ D_IN[6] ^ D_IN[7] ^ D_IN[8] ^ D_IN[12] ^ D_IN[15] ^ D_IN[16] ^ D_IN[18] ^ D_IN[20] ^ D_IN[21] ^ D_IN[22] ^ D_IN[23] ^ D_IN[27] ^ D_IN[30] ^ D_IN[31];
        lfsr_c[2] = lfsr_q[0] ^ lfsr_q[3] ^ D_IN[1] ^ D_IN[2] ^ D_IN[4] ^ D_IN[6] ^ D_IN[7] ^ D_IN[8] ^ D_IN[9] ^ D_IN[13] ^ D_IN[16] ^ D_IN[17] ^ D_IN[19] ^ D_IN[21] ^ D_IN[22] ^ D_IN[23] ^ D_IN[24] ^ D_IN[28] ^ D_IN[31];
        lfsr_c[3] = lfsr_q[1] ^ D_IN[2] ^ D_IN[3] ^ D_IN[5] ^ D_IN[7] ^ D_IN[8] ^ D_IN[9] ^ D_IN[10] ^ D_IN[14] ^ D_IN[17] ^ D_IN[18] ^ D_IN[20] ^ D_IN[22] ^ D_IN[23] ^ D_IN[24] ^ D_IN[25] ^ D_IN[29];

    end 

    always@(posedge CLK) begin
        if(RST) begin
           //lfsr_q <= 4'b1111; 
           lfsr_q <= 4'b0000;
        end
        else if(crc_en == 1'b1) begin
           lfsr_q <= lfsr_c;
        end
        else 
            lfsr_q <= lfsr_q;
    end

    always@(posedge CLK) begin
        if(RST) begin
            crc_en  <= 1'b0;
        end
        else begin
            crc_en <= 1'b1;
        end
    end   

    assign crc_out = crc_en ? lfsr_q: 4'b0;

    always@(posedge CLK) begin
        if(RST) begin
            D_IN_1d <= 32'b0;
        end
        else begin
            D_IN_1d <= D_IN;
        end
    end

    assign D_OUT = {D_IN_1d, crc_out};


endmodule
