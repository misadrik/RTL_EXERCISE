module ALU#(
    parameter DATA_WIDTH = 64)(
    input[0:DATA_WIDTH-1]       ra,
    input[0:DATA_WIDTH-1]       rb,
    input[0:13]                 ex_alu_ctrl,
    input                       ex2alu_regwrite,
    input[0:4]                  alu_imme,
    output reg[0:DATA_WIDTH-1]  alu_out,
    output                      alu2wb_regwirte
    );

    wire[0:5]           alu_opcode;
    wire[0:1]           alu_ww;
    wire[0:5]           alu_func;
    reg                 ww_field_vld;
    reg                 func_vld;

    integer i;

    assign  {alu_opcode, alu_ww, alu_func} = ex_alu_ctrl;

    assign alu2wb_regwirte = ex2alu_regwrite && func_vld && ww_field_vld;



    always@(*) begin

        func_vld = 1'b1;

        case (alu_func)
            6'b000000:begin // bitwise and
                alu_out = ra&rb;
            end
            6'b000001:begin // bit or
                alu_out = ra|rb;
            end
            6'b000010:begin //bit xor
                alu_out = ra^rb;
            end
            6'b000011:begin //bit not
                alu_out = ~ra;
            end
            6'b000100: begin
                alu_out = ra;
            end
            6'b000101: begin
                alu_out = vadd(ra,rb,alu_ww); 
            end
            6'b000110: begin
                alu_out = vsub(ra,rb,alu_ww);
            end
            6'b000111: begin
                alu_out = vmuleuxy(ra,rb,alu_ww); //mult even
            end
            6'b001000: begin
                alu_out = vmulouxy(ra,rb,alu_ww); //mult odd
            end
            6'b001001: begin
                alu_out = vrtthxy(ra,alu_ww);// rotate right by half
            end
            6'b001010: begin
                alu_out = vsllxy(ra,rb,alu_ww); //shift left
            end
            6'b001011: begin
                alu_out = vsllixy(ra,alu_imme,alu_ww); //shift imme(rb)
            end
            6'b001100: begin
                alu_out = vsrlxy(ra,rb,alu_ww); //shift righ logic
            end
            6'b001101: begin
                alu_out = vsrlixy(ra,alu_imme,alu_ww); //shift right imme
            end
            6'b001110: begin
                alu_out = vsraxy(ra,rb,alu_ww); //shift right arith
            end
            6'b001111: begin
                alu_out = vsraixy(ra,alu_imme,alu_ww); //shift right arith imme
            end
            default: begin
                func_vld = 1'b0;
                alu_out = 64'b0;
            end

        endcase
    end

    always@(*) begin
        ww_field_vld = 1'b1;

        if((alu_func == 6'b000111) && (alu_ww == 2'b11)) begin
            ww_field_vld = 1'b0;
        end
        else if((alu_func == 6'b001000) && (alu_ww == 2'b11)) begin
            ww_field_vld = 1'b0;
        end
    end

function [0:DATA_WIDTH-1] vadd;
    input [0:DATA_WIDTH-1] ra;
    input [0:DATA_WIDTH-1] rb;
    input [0:1]            ww;
    begin
        if(ww == 2'b00)begin
            for(i = 0; i <= 56; i = i + 8) begin
                vadd[i+:8] = ra[i+:8] + rb[i+:8];
            end
        end
        else if(ww == 2'b01) begin
            for(i = 0; i <= 48; i = i + 16) begin
                vadd[i+:16] = ra[i+:16] + rb[i+:16];
            end         
        end
        else if(ww == 2'b10) begin
            for(i = 0; i <= 32; i = i + 32) begin
                vadd[i+:32] = ra[i+:32] + rb[i+:32];
            end     
        end
        else if(ww == 2'b11) begin
            vadd  = ra  + rb;   
        end
    end

endfunction 

function [0:DATA_WIDTH-1] vsub;
    input [0:DATA_WIDTH-1] ra;
    input [0:DATA_WIDTH-1] rb;
    input [0:1]            ww;
    begin
        if(ww == 2'b00)begin
            for(i = 0; i <= 56; i = i + 8) begin
                vsub[i+:8] = ra[i+:8] - rb[i+:8];
            end
        end
        else if(ww == 2'b01) begin
            for(i = 0; i <= 48; i = i + 16) begin
                vsub[i+:16] = ra[i+:16] - rb[i+:16];
            end         
        end
        else if(ww == 2'b10) begin
            for(i = 0; i <= 32; i = i + 32) begin
                vsub[i+:32] = ra[i+:32] - rb[i+:32];
            end     
        end
        else if(ww == 2'b11) begin
            vsub  = ra  - rb;   
        end
    end

endfunction 

//[0:7]a [0:7]b
//    a = 8'b0000_1101;
//    b = 8'b0000_1010;
//[0:7] c
//c = a*b = 10000010
function [0: DATA_WIDTH-1] vmuleuxy;
    input [0:DATA_WIDTH-1] ra;
    input [0:DATA_WIDTH-1] rb;
    input [0:1]            ww;
    begin
         if(ww == 2'b00)begin
            vmuleuxy[0:15]  = ra[0:7]   * rb[0:7];
            vmuleuxy[16:31] = ra[16:23] * rb[16:23];
            vmuleuxy[32:47] = ra[32:39] * rb[32:39];
            vmuleuxy[48:63] = ra[48:55] * rb[48:55];
        end
        else if(ww == 2'b01) begin
            vmuleuxy[0:31]  = ra[0:15]  * rb[0:15];
            vmuleuxy[32:63] = ra[32:47] * rb[32:47];     
        end
        else if(ww == 2'b10) begin
            vmuleuxy[0:63]  = ra[0:31]  * rb[0:31];
        end
        else if(ww == 2'b11) begin
            vmuleuxy = 64'b0; //invalid
        end       
    end
endfunction

function [0: DATA_WIDTH-1] vmulouxy;
    input [0:DATA_WIDTH-1] ra;
    input [0:DATA_WIDTH-1] rb;
    input [0:1]            ww;
    begin
         if(ww == 2'b00)begin
            vmulouxy[0:15]  = ra[8:15]   * rb[8:15];
            vmulouxy[16:31] = ra[24:31] * rb[24:31];
            vmulouxy[32:47] = ra[40:47] * rb[40:47];
            vmulouxy[48:63] = ra[56:63] * rb[56:63];
        end
        else if(ww == 2'b01) begin
            vmulouxy[0:31]  = ra[16:31] * rb[16:31];
            vmulouxy[32:63] = ra[48:63] * rb[48:63];     
        end
        else if(ww == 2'b10) begin
            vmulouxy[0:63]  = ra[32:63]  * rb[32:63];
        end
        else if(ww == 2'b11) begin
            vmulouxy = 64'b0; //invalid
        end       
    end
endfunction

function [0: DATA_WIDTH-1] vrtthxy; //each unit rotated right by half of size
    input [0:DATA_WIDTH-1] ra;
    input [0:1]            ww;
    begin
        if(ww == 2'b00)begin
            for(i = 0; i <= 56; i = i + 8) begin
                vrtthxy[i+:8] = {ra[(i+4)+:4], ra[i+:4]};
            end
        end
        else if(ww == 2'b01) begin
            for(i = 0; i <=48; i = i + 16) begin
                vrtthxy[i+:16] = {ra[(i+8)+:8], ra[i+:8]};
            end         
        end
        else if(ww == 2'b10) begin
            for(i = 0; i <= 32; i = i + 32) begin
                vrtthxy[i+:32] = {ra[(i+16)+:16], ra[i+:16]};
            end       
        end
        else if(ww == 2'b11) begin
            vrtthxy  = {ra[32:63], ra[0:31]};   
        end
    end
endfunction

function [0: DATA_WIDTH-1] vsllxy; //shift left
    input [0:DATA_WIDTH-1] ra;
    input [0:DATA_WIDTH-1] rb;
    input [0:1]            ww;

    reg[0:5] shift_bits;

    begin
        if(ww == 2'b00)begin
            for(i = 0; i <= 56; i = i + 8) begin
                shift_bits = rb[(i+5)+:3];
                vsllxy[i+:8] = ra[i+:8] << shift_bits;
            end
        end
        else if(ww == 2'b01) begin
            for(i = 0; i <=48; i = i + 16) begin
                shift_bits = rb[(i+12)+:4];
                vsllxy[i+:16] = ra[i+:16] << shift_bits;
            end         
        end
        else if(ww == 2'b10) begin
            for(i = 0; i <= 32; i = i + 32) begin
                shift_bits = rb[(i+27)+:5];
                vsllxy[i+:32] = ra[i+:32] << shift_bits;
            end       
        end
        else if(ww == 2'b11) begin
            shift_bits = rb[58+:6];
            vsllxy  = ra << shift_bits;  
        end
    end
endfunction

function [0: DATA_WIDTH-1] vsllixy; //shift left imme
    input [0:DATA_WIDTH-1] ra;
    input [0:4]            imme;
    input [0:1]            ww;

    reg[0:5] shift_bits;

    begin
        if(ww == 2'b00)begin
            shift_bits = imme[2:4];
            for(i = 0; i <= 56; i = i + 8) begin
                vsllixy[i+:8] = ra[i+:8] << shift_bits;
            end
        end
        else if(ww == 2'b01) begin
            shift_bits = imme[1:4];
            for(i = 0; i <=48; i = i + 16) begin
                vsllixy[i+:16] = ra[i+:16] << shift_bits;
            end         
        end
        else if(ww == 2'b10) begin
                shift_bits = imme[0:4];
            for(i = 0; i <= 32; i = i + 32) begin
                vsllixy[i+:32] = ra[i+:32] << shift_bits;
            end       
        end
        else if(ww == 2'b11) begin
            shift_bits = imme[0:4];
            vsllixy  = ra << shift_bits;  
        end
    end
endfunction

function [0: DATA_WIDTH-1] vsrlxy; //shift right
    input [0:DATA_WIDTH-1] ra;
    input [0:DATA_WIDTH-1] rb;
    input [0:1]            ww;

    reg[0:5] shift_bits;

    begin
        if(ww == 2'b00)begin
            for(i = 0; i <= 56; i = i + 8) begin
                shift_bits = rb[(i+5)+:3];
                vsrlxy[i+:8] = ra[i+:8] >> shift_bits;
            end
        end
        else if(ww == 2'b01) begin
            for(i = 0; i <=48; i = i + 16) begin
                shift_bits = rb[(i+12)+:4];
                vsrlxy[i+:16] = ra[i+:16] >> shift_bits;
            end         
        end
        else if(ww == 2'b10) begin
            for(i = 0; i <= 32; i = i + 32) begin
                shift_bits = rb[(i+27)+:5];
                vsrlxy[i+:32] = ra[i+:32] >> shift_bits;
            end       
        end
        else if(ww == 2'b11) begin
            shift_bits = rb[58+:6];
            vsrlxy  = ra >> shift_bits;  
        end
    end
endfunction


function [0: DATA_WIDTH-1] vsrlixy; //shift right imme //001101
    input [0:DATA_WIDTH-1] ra;
    input [0:4]            imme;
    input [0:1]            ww;

    reg[0:4] shift_bits;

    begin
        if(ww == 2'b00)begin
            shift_bits = imme[2:4];
            for(i = 0; i <= 56; i = i + 8) begin
                vsrlixy[i+:8] = ra[i+:8] >> shift_bits;
            end
        end
        else if(ww == 2'b01) begin
            shift_bits = imme[1:4];
            for(i = 0; i <=48; i = i + 16) begin
                vsrlixy[i+:16] = ra[i+:16] >> shift_bits;
            end         
        end
        else if(ww == 2'b10) begin
                shift_bits = imme[0:4];
            for(i = 0; i <= 32; i = i + 32) begin
                vsrlixy[i+:32] = ra[i+:32] >> shift_bits;
            end       
        end
        else if(ww == 2'b11) begin
            shift_bits = imme[0:4];
            vsrlixy  = ra  >>  shift_bits;  
        end
    end
endfunction

function [0: DATA_WIDTH-1] vsraxy; //shift right arithmetic //001110
    input [0:DATA_WIDTH-1] ra;
    input [0:DATA_WIDTH-1] rb;
    input [0:1]            ww;

    reg[0:5] shift_bits;

    begin
        if(ww == 2'b00)begin
            for(i = 0; i <= 56; i = i + 8) begin
                shift_bits = rb[(i+5)+:3];
                vsraxy[i+:8] = $signed(ra[i+:8]) >>> shift_bits;
            end
        end
        else if(ww == 2'b01) begin
            for(i = 0; i <=48; i = i + 16) begin
                shift_bits = rb[(i+12)+:4];
                vsraxy[i+:16] = $signed(ra[i+:16]) >>> shift_bits;
            end         
        end
        else if(ww == 2'b10) begin
            for(i = 0; i <= 32; i = i + 32) begin
                shift_bits = rb[(i+27)+:5];
                vsraxy[i+:32] = $signed(ra[i+:32]) >>> shift_bits;
            end       
        end
        else if(ww == 2'b11) begin
            shift_bits = rb[58+:6];
            vsraxy  = $signed(ra) >>> shift_bits;  
        end
    end
endfunction

function [0: DATA_WIDTH-1] vsraixy; //shift right imme arithmetic  //001111
    input [0:DATA_WIDTH-1] ra;
    input [0:4]            imme;
    input [0:1]            ww;

    reg[0:5] shift_bits;

    begin
        if(ww == 2'b00)begin
            shift_bits = imme[2:4];
            for(i = 0; i <= 56; i = i + 8) begin
                vsraixy[i+:8] = $signed(ra[i+:8]) >>> shift_bits;
            end
        end
        else if(ww == 2'b01) begin
            shift_bits = imme[1:4];
            for(i = 0; i <=48; i = i + 16) begin
                vsraixy[i+:16] = $signed(ra[i+:16]) >>> shift_bits;
            end         
        end
        else if(ww == 2'b10) begin
            shift_bits = imme[0:4];
            for(i = 0; i <= 32; i = i + 32) begin
                vsraixy[i+:32] = $signed(ra[i+:32]) >>> shift_bits;
            end       
        end
        else if(ww == 2'b11) begin
            shift_bits = imme[0:4];
            vsraixy  = $signed(ra)  >>>  shift_bits;  
        end
    end
endfunction
endmodule