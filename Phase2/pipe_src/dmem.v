/////////////////////////////////////////////////////////////////////
// Project      : EE577B Fall2018 Gold CMP 
// Filename     : dmem.v
// Description  : Data Memory For Gold Processor  
// Author       : Aditya Deshpande
// Date Created : 09/24/2018
// Version      : ver1
// Last Modified by : Aditya 
// Update Log   : 
// ver1: Baseline
//
/////////////////////////////////////////////////////////////////////
`timescale 1ns/10ps

module dmem (clk, memEn, memWrEn, memAddr, dataIn, dataOut);
	input          clk;       // System Clock
	input          memEn;     // Memory Enable
	input          memWrEn;   // Memory Write Enable
	input  [0:8]   memAddr;   // Memory Read/Write Address (9-bits)
	input  [0:63]  dataIn;    // Memory WRITE Data (64-bit)
	output [0:63]  dataOut;   // Memory Read Output (64-bit)
	
	// Memory Declaration
	reg [0:63] MEM[0:511]; 		// 64-bit wide, 512-deep memory
	
	// Registered Inputs
	reg       r_memEn;
	reg [0:8] r_memAddr;
	
	// READ Operation
	assign dataOut = r_memEn ? MEM[r_memAddr] : 64'd0;
	
	// Input Registers
	always @(posedge clk)
	begin
		r_memAddr <= memAddr;
		r_memEn   <= memEn;
	end
	
	// Synchronous WRITE Operation
	always @(posedge clk)
	begin
		if (memEn & memWrEn)
		begin
			MEM[memAddr] <= dataIn;
		end
	end
	
endmodule
	