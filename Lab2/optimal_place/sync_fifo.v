module sync_fifo#(
    parameter DATA_WIDTH = 16,
    parameter FIFO_DEPTH = 5)(
    input RST_n,
    input CLK,
    input[DATA_WIDTH-1:0]
    );