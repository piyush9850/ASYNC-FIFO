module fifo_mem #(
    parameter WIDTH = 8,
    parameter DEPTH = 8
) (
    input [WIDTH-1:0] data_in, /// inp and output declaration 
    input write_en,
    input wclk,
    input [$clog2(DEPTH)-1:0] wr_addr,
    input [$clog2(DEPTH)-1:0] r_addr, 

    output [WIDTH-1:0] data_out 


);

reg [WIDTH-1:0] mem [DEPTH-1:0]; // mem declaration


// write cond 

always @(posedge wclk) begin
    if(write_en)
    begin
        mem[wr_addr] <= data_in;
    end

end

assign data_out = mem[r_addr];  /// read condition


    
endmodule