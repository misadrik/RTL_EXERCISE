module CONTROL_UNIT(
    input [31:0]        instr,
    input               if2id_flush,
    output [13:0]       cu_exalu_ctrl,
    output [1:0]        cu_exmem_ctrl,
    output[1:0]         id_br,            
    output[4:0]         cu_wb_ctrl,
    output [11:0]       cu_imme);

    
    wire[5:0]           cu_opcode;
    wire[2:0]           cu_wb_ppp;
    wire[1:0]           cu_ex_ww;
    wire[5:0]           cu_ex_func;

    reg[1:0]            cu_br;
    reg                 cu_memread;
    reg                 cu_regwrite;
    reg                 cu_memwrite;
    reg                 cu_memtoreg;

//id ctrl
    assign id_br = cu_br;
//ex alu ctrl
    assign cu_exalu_ctrl = {cu_opcode,cu_ex_ww, cu_ex_func};
    assign cu_opcode = instr[5:0];    
    assign cu_ex_ww = instr[25:24];
    assign cu_ex_func = instr[31:26];
//ex mem ctrl
    assign cu_exmem_ctrl = {cu_memread,cu_memwrite};
    assign cu_imme = instr[31:16];

//wb ctrl
    assign cu_wb_ctrl = {cu_wb_ppp, cu_memtoreg, cu_regwrite};
    assign cu_wb_ppp = instr[23:21];

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
                6'b010101: //Rtype
                begin
                    cu_br = 2'b00;
                    cu_regwrite = 1'b1;
                    cu_memread = 1'b0;
                    cu_memwrite = 1'b0;
                    cu_memtoreg = 1'b0; // alu_out to rf
                end
                6'b000001: //load reg from mem
                //EA<- 16'b0, imme
                //rd<= mem[ea] 
                begin
                    cu_br = 2'b00;
                    cu_regwrite = 1'b0;
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
                6'b010001: //beq
                begin
                    cu_br = 2'b01;
                    cu_regwrite = 1'b0;
                    cu_memread = 1'b0;
                    cu_memwrite = 1'b0;
                    cu_memtoreg = 1'b1; // alu_out to rf
                end
                6'b110001: //bne
                begin
                    cu_br = 2'b10;
                    cu_regwrite = 1'b0;
                    cu_memread = 1'b0;
                    cu_memwrite = 1'b0;
                    cu_memtoreg = 1'b0; // alu_out to rf
                end
                6'b001111: //nop
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