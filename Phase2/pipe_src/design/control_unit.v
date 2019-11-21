module CONTROL_UNIT(
    input [0:31]        instr,
    input               if2id_flush,
    output [0:13]       cu_exalu_ctrl,
    output [0:1]        cu_exmem_ctrl,
    output[0:1]         id_br,            
    output[0:4]         cu_wb_ctrl);

    
    wire[0:5]           cu_opcode;
    wire[0:2]           cu_wb_ppp;
    wire[0:1]           cu_ex_ww;
    wire[0:5]           cu_ex_func;

    reg[0:1]            cu_br;
    reg                 cu_memread;
    reg                 cu_regwrite;
    reg                 cu_memwrite;
    reg                 cu_memtoreg;

//id ctrl
    assign id_br = cu_br;
//ex alu ctrl
    assign cu_exalu_ctrl = {cu_opcode,cu_ex_ww, cu_ex_func};
    assign cu_opcode = instr[0:5];    
    assign cu_ex_ww = instr[24:25];
    assign cu_ex_func = instr[26:31];
//ex mem ctrl
    assign cu_exmem_ctrl = {cu_memwrite,cu_memread};

//wb ctrl
    assign cu_wb_ctrl = {cu_regwrite,cu_memtoreg,cu_wb_ppp};
    assign cu_wb_ppp = instr[21:23];

    always@(*) begin
        if(if2id_flush == 1'b1) begin
            cu_br = 2'b00;
            cu_regwrite = 1'b0;
            cu_memread = 1'b0;
            cu_memwrite = 1'b0;
            cu_memtoreg = 1'b0; // alu_out to rf 
        end
        else begin       
            case(cu_opcode)
                6'b101010: //Rtype
                begin
                    cu_br = 2'b00;
                    cu_regwrite = 1'b1;
                    cu_memread = 1'b0;
                    cu_memwrite = 1'b0;
                    cu_memtoreg = 1'b0; // alu_out to rf
                end
                6'b100000: //load reg from mem
                //EA<- 16'b0, imme
                //rd<= mem[ea] 
                begin
                    cu_br = 2'b00;
                    cu_regwrite = 1'b1;
                    cu_memread = 1'b1;
                    cu_memwrite = 1'b0;
                    cu_memtoreg = 1'b1; // alu_out to rf
                    
                end
                6'b100001: //sw
                begin
                    cu_br = 2'b00;
                    cu_regwrite = 1'b0;
                    cu_memread = 1'b0;
                    cu_memwrite = 1'b1;
                    cu_memtoreg = 1'b1; // alu_out to rf
                end
                6'b100010: //beq
                begin
                    cu_br = 2'b01;
                    cu_regwrite = 1'b0;
                    cu_memread = 1'b0;
                    cu_memwrite = 1'b0;
                    cu_memtoreg = 1'b1; // alu_out to rf
                end
                6'b100011: //bne
                begin
                    cu_br = 2'b10;
                    cu_regwrite = 1'b0;
                    cu_memread = 1'b0;
                    cu_memwrite = 1'b0;
                    cu_memtoreg = 1'b0; // alu_out to rf
                end
                6'b111100: //nop
                begin
                    cu_br = 2'b00;
                    cu_regwrite = 1'b0;
                    cu_memread = 1'b0;
                    cu_memwrite = 1'b0;
                    cu_memtoreg = 1'b0; // alu_out to rf                    
                end
                default:
                begin
                    cu_br = 2'b00;
                    cu_regwrite = 1'b0;
                    cu_memread = 1'b0;
                    cu_memwrite = 1'b0;
                    cu_memtoreg = 1'b0; // alu_out to rf
                end
            endcase
        end
    end



endmodule