`timescale 1ns/1ns
module alu_tb();
    parameter DATA_WIDTH = 64;
    reg                       clk;
    reg[0:DATA_WIDTH-1]       ra;
    reg[0:DATA_WIDTH-1]       rb;
    wire[0:13]                ex_alu_ctrl;
    reg                       ex2alu_regwrite;
    reg[0:4]                  alu_imme;
    wire[0:DATA_WIDTH-1]      alu_out;
    wire                      alu2wb_regwirte;

    reg[0:5]           alu_opcode;
    reg[0:1]           alu_ww;
    reg[0:5]           alu_func;   

    // reg[0:5]           state;
    reg[7*8:1] state;
    always #1 clk = ~clk;

    // localparam vand     = 6'b000000;
    // localparam vor      = 6'b000001;
    // localparam vxor     = 6'b000010;
    // localparam vnot     = 6'b000011;
    // localparam vmov     = 6'b000100;
    // localparam vadd     = 6'b000101;
    // localparam vsub     = 6'b000110;
    // localparam vmuleu   = 6'b000111;
    // localparam vmulou   = 6'b001000;
    // localparam vrtth    = 6'b001001;
    // localparam vsll     = 6'b001010;
    // localparam vslli    = 6'b001011;
    // localparam vsrl     = 6'b001100;
    // localparam vsrli    = 6'b001101;    
    // localparam vsra     = 6'b001110;
    // localparam vsrai    = 6'b001111;

    initial begin
        clk = 0;
        alu_func = 6'b0;
        #200;
        $stop;
    end

    always@(posedge clk) begin
        alu_opcode <= 6'b101010;
        // alu_ww     <= $urandom % 3'd4;
        alu_ww     <= 2'b00;
        ra         <= ($urandom % 9'd256)<<52;
        rb         <= ($urandom % 9'd256)<<52;
        alu_func   <= alu_func + 1'b1;
        ex2alu_regwrite <= 1'b1;
        alu_imme   <= $urandom % 6'd32;
    end
    
    always@(*) begin

        case (alu_func)
            6'b000000:begin // bitwise and
                state = "vand"; 
            end
            6'b000001:begin // bit or
                state = "vor";
            end
            6'b000010:begin //bit xor
                state = "vxor"; 
            end
            6'b000011:begin //bit not
                state = "vnot"; 
            end
            6'b000100: begin
                state = "vmov"; 
            end
            6'b000101: begin
                state = "vadd"; 
            end
            6'b000110: begin
                state = "vsub"; 
            end
            6'b000111: begin
                state = "vmuleu";
            end
            6'b001000: begin
                state = "vmulou"; 
            end
            6'b001001: begin
                state = "vrtth"; 
            end
            6'b001010: begin
                state = "vsll"; 
            end
            6'b001011: begin
                state = "vslli"; 
            end
            6'b001100: begin
                state = "vsrl"; 
            end
            6'b001101: begin
                state = "vsrli"; 
            end
            6'b001110: begin
                state = "vsra"; 
            end
            6'b001111: begin
                state = "vsrai";
            end
            default: begin
                state = "invalid";
            end

        endcase
    end
    assign ex_alu_ctrl = {alu_opcode, alu_ww, alu_func};

    ALU #(.DATA_WIDTH(64)) U_ALU(.ra(ra), .rb(rb), .ex_alu_ctrl(ex_alu_ctrl), .ex2alu_regwrite(ex2alu_regwrite), 
        .alu_imme(alu_imme), .alu_out(alu_out), .alu2wb_regwirte(alu2wb_regwirte));

endmodule