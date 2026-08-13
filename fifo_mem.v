module fifo_mem #(
    parameters WIDTH = 8,
    parameters DEPTH = 8
) (
    input [WIDTH-1:0] data_in, /// inp and output declaration 
    input write_en,
    input wclk,
    input [$clog2(DEPTH)-1:0] wr_addr,
    input [$clog2(DEPTH)-1:0] r_addr, 

    output [WIDTH-1,0] data_out 

);

reg [WIDTH-1:0] mem [DEPTH-1:0]; // mem declaration 


    
endmodule