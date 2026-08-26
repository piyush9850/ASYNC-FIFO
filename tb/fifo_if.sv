interface fifo_if#(
    parameter DEPTH = 8,
    parameter WIDTH = 8
)(
    // clock signals
    input logic wclk,
    input logic rclk
);
    // write signals
    logic w_rst;
    logic write_en;
    logic [WIDTH-1:0] data_in;

    // read signals
    logic r_rst;
    logic read_en;
    
    // ouptut signals
    logic full;
    logic empty; 

    logic [WIDTH-1:0] data_out;

endinterface //fifo_if()