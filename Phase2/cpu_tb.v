/////////////////////////////////////////////////////////////////////
// Project      : EE577B Fall2018 Gold CMP
// Filename     : cpu_tb.v
// Description  : Gold Processor Simulation Testbench 
// Author       : Aditya Deshpande
// Date Created : 09/24/2018
// Version      : ver1
// Last Modified by : Aditya 
// Update Log   : 
//
/////////////////////////////////////////////////////////////////////

// Testbench for the Processor RTL Verification 
`timescale 1ns/10ps

// Define Clock cycle, using 250MHz.
`define CYCLE_TIME 4

// Include Files

// Memory Files
`include "./include/dmem.v"
`include "./include/imem.v"

// CPU Files 
// Include all your proces design files here 
`include "./design/cpu.v"


module cpu_tb;
	reg CLK, RESET;
	wire [0:31] ProgramCounter;  // PC output from processor
	wire [0:31] Instruction;     // Instruction from IMEM to processor
	wire [0:63] DataIn;          // Data into the processor from DMEM
	wire [0:63] DataOut;         // Data write to DMEM
	wire  MemEn, MemWrEn;        // DMEM control signals
	wire [0:31] MemAddr;         // DMEM read/write address
	integer CycleNum;            // Counter to count number of cycles for program exec.	
	
	integer i;
	integer dmem_dump_file;
	
	// Instruction Memory Instance
	imem IM (
		.memAddr (ProgramCounter[21:29]),  // Memory Read Address (9-bit)
		.dataOut (Instruction)	           // Memory READ Output data
	);
	
	// Data Memory Instance
	dmem DM (
		.clk      (CLK),               // System Clock
		.memEn    (MemEn),             // Memory Enable
		.memWrEn  (MemWrEn),           // Memory Write Enable
		.memAddr  (MemAddr[23:31]),    // Memory Address (9-bit)
		.dataIn   (DataOut),           // Memory WRITE Data  (input to data-memory)
		.dataOut  (DataIn)             // Memory READ Data (output from data-memory)
	);

	// Processor Instance
	cardinal_processor cpu (
		.clk          (CLK),             // System Clock
		.reset        (RESET),           // System Reset
		.instruction  (Instruction),     // Instruction from Instruction Memory
		.dataIn       (DataIn),          // Data from Data Memory
		.pc           (ProgramCounter),  // Program Counter
		.dataOut      (DataOut),         // Write Data to Data Memory
		.memAddr      (MemAddr),         // Write Address for Data Memory 
		.memEn        (MemEn),           // Data Memory Enable
		.memWrEn      (MemWrEn)          // Data Memory Write Enable
	);

	// Clock Generation
	always #(`CYCLE_TIME /2) CLK <= ~CLK;

	// Cycle Counter
	always @(posedge CLK) begin
		if(RESET) 
			CycleNum <= 'd0;
		else 
			CycleNum <= CycleNum + 'd1;
	end
	
	// Initial
	initial begin
		$readmemh("imem.fill", IM.MEM);    // Loading Instruction Memory
		$readmemh("dmem.fill", DM.MEM);    // Loading Data Memory
		CLK <= 0;                          // Initialize Clock
		CycleNum <= 0;                     // Initialize				
		RESET <= 1'b1;                     // Reset the CPU
		repeat (5) @(negedge CLK);         // Wait for CPU
		RESET <= 1'b0;                     // de-activate reset signal
		
		// Convention for LAST INSTRUCTION
		// We would have a last Instruction NOP  => 32'h00000000
		wait(Instruction == 32'h00000000);
		//Let us see how many cycles your program took
		$display ("The Program Completed in %d cycles", CycleNum);
		
		// Let us now flush the pipeline
		repeat(5) @(negedge CLK);
		
		// Open file to copy contents of data-memory
		dmem_dump_file = $fopen("dmem.dump");
		
		// Dump all locations of data-memory to output file
		for (i=0; i<512;i=i+1) begin
			$fdisplay(dmem_dump_file, "Memory Location #%3d: %h" , i, DM.MEM[i]);
		end
		$fclose(dmem_dump_file);
		$stop;
		
	end	// initial block ends here

endmodule
