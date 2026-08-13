module wptr_handler #(
    parameter DEPTH = 8
    )(
    input wclk,
    input write_en,
    input w_rst,
    input [$clog2(DEPTH):0] g_rptr_sync, // depth bit + 1 msb bit 

    output [$clog2(DEPTH):0] g_wptr,
    output full,
    output [$clog2(DEPTH)-1:0] wr_addr

);

reg [$clog2(DEPTH):0] b_wptr; 

reg [$clog2(DEPTH):0] b_wptr_next; // next pointer

reg [$clog2(DEPTH):0] g_wptr_next; // gray pointer next



 assign b_wptr_next = ( b_wptr + ( wclk && ~full) ); // increment of binary pointer

assign g_wptr_next = (b_wptr_next >> 1) ^ b_wptr_next; // conversion of binary to gray 



    
endmodule