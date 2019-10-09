module random_gen(
    input [3:0]  seed,
    input clk, 
    input rst_n,
    input load,
    output reg [3:0] random_gen);

    reg[3:0]  random_reg;
    reg[3:0]  random_reg_comb;

always @(*)
begin
    if(load) begin
        random_reg_comb[0] = seed[1];
        random_reg_comb[1] = seed[2];
        random_reg_comb[2] = seed[3];
        random_reg_comb[3] = seed[0] ^ seed[3];
    end
    else begin
        random_reg_comb[0] = random_reg[1];
        random_reg_comb[1] = random_reg[2];
        random_reg_comb[2] = random_reg[3];
        random_reg_comb[3] = random_reg[0] ^ random_reg[3] ;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        random_reg <= 4'b0000;
    else begin
        random_reg <= random_reg_comb;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        random_gen <= 4'b0000;
    else begin
        random_gen <= random_reg_comb;
    end
end

endmodule : random_gen