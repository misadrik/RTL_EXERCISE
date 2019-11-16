module cardinal_processor(
		input 							clk ,             // System Clock
		input 							reset,           // System Reset
		input 	[0:31]instruction,     // Instruction from Instruction Memory
		input [0:63]dataIn,          // Data from Data Memory
		output [0:31]pc,  // Program Counter
		output [0:63]dataOut,         // Write Data to Data Memory
		output [0:31]memAddr,         // Write Address for Data Memory 
		output memEn,           // Data Memory Enable
		output memWrEn                // Data Memory Write Enable
	);
	
	function [0:7]decode_PPP;
		input [0:2]PPP;
		begin
			case(PPP)
				3'b000: decode_PPP = 8'b1111_1111;
				3'b001: decode_PPP = 8'b1111_0000;
				3'b010: decode_PPP = 8'b0000_1111;
				3'b011: decode_PPP = 8'b1010_1010;
				3'b100: decode_PPP = 8'b0101_0101;
			endcase
		end
	endfunction
	
	wire stall;//
/*****************************************************************************************************************************
	WB STAGE
******************************************************************************************************************************/	
	wire [0:4]WB_rD;
	wire RegWrEn;
	wire [0:63]wdata;
	wire [0:7]WB_PPP;
	
/*****************************************************************************************************************************
	IF STAGE
******************************************************************************************************************************/
	reg [0:31]PC;//
	assign pc = PC;
	
/*****************************************************************************************************************************
	ID STAGE
******************************************************************************************************************************/	
	wire [0:31]ID_inst;
	wire flush;
	wire ID_flush;
	IF_ID_reg if_id(.IF_inst(instruction),.IF_flush(flush),.ID_inst(ID_inst),.ID_flush(ID_flush),.clk(clk),.rst(reset),.stall(stall));
	wire [0:4]rA;
	wire [0:4]rB;
	wire [0:4]rD;
	wire [0:63]dA;
	wire [0:63]dB;
	wire [0:15]EX_ctrl;
	wire [0:4]WB_ctrl;
	wire [0:15]IMM;
	wire beq;
	wire bneq;
	wire branch;
	wire zero;
	
	CONTROL_UNIT decoder(.instr(ID_inst),.if2id_flush(ID_flush),.cu_exalu_ctrl(EX_ctrl[2:15]),.cu_exmem_ctrl(EX_ctrl[0:1]),.id_br({beq,bneq}),
						.cu_wb_ctrl(WB_ctrl));
	
	assign branch = beq || bneq;
	assign rA = (branch || EX_ctrl[0]) ? ID_inst[6:10] : ID_inst[11:15];
	assign rB = ID_inst[16:20];
	assign rD = ID_inst[6:10];
	assign IMM = ID_inst[16:31];
	
	RegFile rf(.r0addr(rA),.r1addr(rB),.wdata(wdata),.waddr(WB_rD),.wena(RegWrEn),.sel(WB_PPP),.r0data(dA),.r1data(dB),.clk(clk),.rst(reset));
	
	wire ID_sel_dA;
	wire ID_sel_dB;
	wire [0:63]dA_true;
	wire [0:63]dB_true;
	
	assign ID_sel_dA = (rA == WB_rD) && RegWrEn;
	assign ID_sel_dB = (rB == WB_rD) && RegWrEn;
	assign dA_true = ID_sel_dA ? wdata : dA;
	assign dB_true = ID_sel_dB ? wdata : dB;
	assign zero = dA_true == 0;
	assign flush = (zero && beq) || (!zero && bneq);
	
/*****************************************************************************************************************************
	EX STAGE
******************************************************************************************************************************/
	wire [0:4]EX_rA;
	wire [0:4]EX_rB;
	wire [0:63]EX_dA;
	wire [0:63]EX_dB;
	wire [0:4]EX_rD;
	wire [0:15]EX_IMM;
	wire [0:15]EX_EX_ctrl;
	wire [0:4]EX_WB_ctrl;
	ID_EX_reg id_ex(.ID_rA(rA),.ID_rB(rB),.ID_dA(dA_true),.ID_dB(dB_true),.ID_rD(rD),.ID_IMM(IMM),.ID_EX_ctrl(EX_ctrl),.ID_WB_ctrl(WB_ctrl),
				.EX_rA(EX_rA),.EX_rB(EX_rB),.EX_dA(EX_dA),.EX_dB(EX_dB),.EX_rD(EX_rD),.EX_IMM(EX_IMM),
				.EX_EX_ctrl(EX_EX_ctrl),.EX_WB_ctrl(EX_WB_ctrl),.clk(clk),.rst(reset),.stall(stall));
	
	wire [0:4]shift_amount;
	wire [0:13]alu_op;
	wire [0:63]alu_out;//
	wire EX_alu_Regwr;
	wire EX_RegWrEn;
	wire EX_sel_dA;
	wire EX_sel_dB;
	wire [0:63]EX_dA_true;
	wire [0:63]EX_dB_true;
	
	assign EX_sel_dA = (EX_rA == WB_rD) && RegWrEn;
	assign EX_sel_dB = (EX_rB == WB_rD) && RegWrEn;
	assign EX_dA_true = EX_sel_dA ? wdata : EX_dA;
	assign EX_dB_true = EX_sel_dB ? wdata : EX_dB;
	
	assign shift_amount = EX_rB;
	assign dataOut = EX_dA_true;
	assign memAddr = EX_IMM;
	assign memEn = EX_EX_ctrl[1] || EX_EX_ctrl[0];
	assign memWrEn = EX_EX_ctrl[0];
	assign alu_op = EX_EX_ctrl[2:15];
//	assign EX_RegWrEn = EX_WB_ctrl[0];

	ALU alu(.ra(EX_dA_true),.rb(EX_dB_true),.ex_alu_ctrl(alu_op),.ex2alu_regwrite(EX_WB_ctrl[0]),.alu_imme(EX_rB),.alu_out(alu_out),.alu2wb_regwirte(EX_alu_Regwr));

	assign EX_RegWrEn = EX_alu_Regwr || EX_EX_ctrl[1];
	assign stall = branch && (EX_rD == rD) && EX_RegWrEn;
	
	wire [0:7]EX_PPP;
	assign EX_PPP = decode_PPP(EX_WB_ctrl[2:4]);
	
/*****************************************************************************************************************************
	WB STAGE
******************************************************************************************************************************/	
	wire [0:63]WB_alu_out;
	wire [0:1]WB_WB_ctrl;
	EX_WB_reg ex_wb(.EX_alu_out(alu_out),.EX_rD(EX_rD),.EX_WB_ctrl({EX_RegWrEn,EX_WB_ctrl[1]}),.EX_PPP(EX_PPP),
				.WB_alu_out(WB_alu_out),.WB_rD(WB_rD),.WB_WB_ctrl(WB_WB_ctrl),.WB_PPP(WB_PPP),.clk(clk),.rst(reset));
	
	wire mem2Reg;
	
	assign RegWrEn = WB_WB_ctrl[0];
	assign mem2Reg = WB_WB_ctrl[1];
	assign wdata = mem2Reg ? dataIn : WB_alu_out;

	always @(posedge clk)
	begin
		if(reset)
		begin
			PC <= 0;
		end
		else
		begin
			if(!stall)
			begin
				if(flush)
				begin
					PC <= {16'h0000,IMM};
				end
				else
				begin
					PC <= PC + 4;
					if(PC[0:8] == 9'b111111111)
						PC <= 0;
				end
			end
		end
	end
	
	
	
endmodule