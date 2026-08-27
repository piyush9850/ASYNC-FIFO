module wptr_handler #(
    parameter DEPTH = 8
    )(
    input wclk,
    input write_en,
    input w_rst,
    input [$clog2(DEPTH):0] g_rptr_sync, // depth bit + 1 msb bit 

    output reg [$clog2(DEPTH):0] g_wptr,
    output reg full,
    output [$clog2(DEPTH)-1:0] wr_addr

);

wire wfull;

reg [$clog2(DEPTH):0] b_wptr; 

wire [$clog2(DEPTH):0] b_wptr_next; // next pointer

wire  [$clog2(DEPTH):0] g_wptr_next; // gray pointer next



 assign b_wptr_next = ( b_wptr + ( write_en && ~full) ); // increment of binary pointer

assign g_wptr_next = (b_wptr_next >> 1) ^ b_wptr_next; // conversion of binary to gray 

assign wr_addr = b_wptr[$clog2(DEPTH)-1:0]; // addr sent to mem just the lower bits

  assign wfull = (g_wptr_next ==
                    { ~g_rptr_sync[$clog2(DEPTH):$clog2(DEPTH)-1],
                       g_rptr_sync[$clog2(DEPTH)-2:0] });


always @(posedge wclk or negedge w_rst) begin
    
    if(!w_rst)
    begin
        b_wptr <= 0;
        g_wptr <= 0;
        full <= 0;

    end
    else 
    begin
        b_wptr <= b_wptr_next;
        g_wptr <= g_wptr_next;
        full <= wfull;
    end


end

    
endmodule