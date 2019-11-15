/////////////////////////////////////////////////////////////////////
// Project      : EE577B Fall2018 Gold CMP
// Filename     : dmem.v
// Description  : Instruction Memory For Gold Processor  
// Author       : Aditya Deshpande
// Date Created : 09/24/2018
// Version      : ver1
// Last Modified by : Aditya 
// Update Log   : 
// ver1: Baseline
//
/////////////////////////////////////////////////////////////////////
`timescale 1ns/10ps

module imem (memAddr, dataOut);
	input  [0:8]    memAddr;    // Memory Read/Write Address (9-bits)
	output [0:31]   dataOut;    // Memory Read Output
	
	// Memory Declaration
	reg [0:31] MEM[0:511] ;		// 32-bit wide, 512-deep memory
	
	// Asynchronous READ Operation
	assign dataOut = MEM[memAddr];
	
endmodule
