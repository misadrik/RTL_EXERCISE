module ID_EX_reg(input [4:0]ID_rA,
				input [4:0]ID_rB,
				input [63:0]ID_dA,
				input [63:0]ID_dB,
				input [4:0]ID_rD,
				input [15:0]ID_IMM,
				input [15:0]ID_EX_ctrl,
				input [4:0]ID_WB_ctrl,
				output reg [4:0]EX_rA,
				output reg [4:0]EX_rB,
				output reg [63:0]EX_dA,
				output reg [63:0]EX_dB,
				output reg [4:0]EX_rD,
				output reg [15:0]EX_IMM,
				output reg [15:0]EX_EX_ctrl,
				output reg [4:0]EX_WB_ctrl,
				input clk,
				input rst,
				input stall);
	
	always @(posedge clk)
	begin
		if(rst)
		begin
			EX_EX_ctrl <= 0;
			EX_WB_ctrl <= 0;
		end
		else if(stall)
		begin
			EX_EX_ctrl <= 0;
			EX_WB_ctrl <= 0;
		end
		else
		begin
			EX_rA <= ID_rA;
			EX_rB <= ID_rB;
			EX_dA <= ID_dA;
			EX_dB <= ID_dB;
			EX_rD <= ID_rD;
			EX_IMM <= ID_IMM;
			EX_EX_ctrl <= ID_EX_ctrl;
			EX_WB_ctrl <= ID_WB_ctrl;
		end
	end	
	
endmodule
