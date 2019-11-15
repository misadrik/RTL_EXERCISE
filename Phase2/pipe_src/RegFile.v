`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:22:11 02/18/2019 
// Design Name: 
// Module Name:    RegFile 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module RegFile(
	input [4:0] r0addr,
    input [4:0] r1addr,
    input [63:0] wdata,
    input [4:0] waddr,
    input wena,
	input [7:0]sel,
    output [63:0] r0data,
    output [63:0] r1data,

	input clk,
	input rst);
	
	reg [63:0] DFF[0:31];
	
	assign r0data = DFF[r0addr];
	assign r1data = DFF[r1addr];
	
	task regrst;
		integer i;
		begin
			for(i = 0; i < 32; i = i+1)
				DFF[i] <= 0;
		end
	endtask

	always @(posedge clk)
	begin
		if(rst)
		begin
			regrst;
		end
		else
		begin
			if(wena)
			begin
				if(sel[0])
					DFF[waddr][7:0] <= wdata[7:0];
				if(sel[1])
					DFF[waddr][15:8] <= wdata[15:8];
				if(sel[2])
					DFF[waddr][23:16] <= wdata[23:16];
				if(sel[3])
					DFF[waddr][31:24] <= wdata[31:24];
				if(sel[4])
					DFF[waddr][39:32] <= wdata[39:32];
				if(sel[5])
					DFF[waddr][47:40] <= wdata[47:40];
				if(sel[6])
					DFF[waddr][55:48] <= wdata[55:48];
				if(sel[7])
					DFF[waddr][63:56] <= wdata[63:56];
				DFF[0] <= 0;
			end
		end
	end

endmodule

