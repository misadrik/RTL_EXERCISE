module EX_WB_reg(input [63:0]EX_alu_out,
				input [4:0]EX_rD,
				input [1:0]EX_WB_ctrl,
				input [7:0]EX_PPP,
				output reg [63:0]WB_alu_out,
				output reg [4:0]WB_rD,
				output reg [1:0]WB_WB_ctrl,
				output reg [7:0]WB_PPP,
				input clk,
				input rst);

	always @(posedge clk)
	begin
		if(rst)
		begin
			WB_WB_ctrl <= 0;
		end
		else
		begin
			WB_alu_out <= EX_alu_out;
			WB_rD <= EX_rD;
			WB_WB_ctrl <= EX_WB_ctrl;
			WB_PPP <= EX_PPP;
		end
	end
	
endmodule
