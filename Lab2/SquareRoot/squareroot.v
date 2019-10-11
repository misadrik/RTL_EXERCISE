module squareroot(
    input CLK,
    input RST,
    input[15:0] Din,
    output[7:0] Dout);

    assign Dout = InvSqrt(Din);

    function [7:0] InvSqrt;
        input[15:0] Data;
        reg[7:0] square;
        reg[9:0] square_shift2;
        reg[9:0] remainer;
        
        integer i;
        begin
            //$display("Data_in %h", Data);

            //pq = 4p^2+4pq+q^2
            //for binary p q are always 0 or 1;
            //pq- 4p^2 then the remainer is always 4pq+q^2
            // spilit the value by two bits and compute each time with the remainer
            //just compair the remainer and 4pq+q^2 if greater the bit should be 1;
            square = 0;
            remainer = 0;
            square_shift2 = 0;
            for(i = 0; i < 8; i = i+1) begin
                remainer = remainer << 2;
                remainer = remainer + Data[15:14];

                square = square << 1;  //to store next value square << by 1
                square_shift2 = square << 1;  
                Data = Data << 2;
                $display("N:%d, %d %d", square, remainer, square_shift2);
                if(remainer >= square_shift2 + 1) begin   // assume q=1 and 4pq+q^2 becomes 4p+1
                    remainer = remainer - square_shift2 - 1;
                    square  = square + 1; // remainer is greater then the bit is one
                end
            end
            $display("Data_out %h, %d", square,square);
            InvSqrt = square;
        end

    endfunction
endmodule 