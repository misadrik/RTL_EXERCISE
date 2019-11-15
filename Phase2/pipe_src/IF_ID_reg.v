module IF_ID_reg(input [31:0]IF_inst,
				input IF_flush,
				output reg [31:0]ID_inst,
				output reg ID_flush,
				input clk,
				input rst,
				input stall);
	
	always @(posedge clk)
	begin
		if(rst)
		begin
			ID_inst <= 0;
			ID_flush <= 0;
		end
		else if(!stall)
		begin
			ID_inst <= IF_inst;
			ID_flush <= IF_flush;
		end
	end
	
endmodule
