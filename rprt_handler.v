module rptr_handler #(
    parameter DEPTH = 8
    )(
    input rclk,
    input read_en,
    input r_rst,
    input [$clog2(DEPTH):0] g_wptr_sync, // depth bit + 1 msb bit 

    output reg [$clog2(DEPTH):0] g_rptr,
    output reg empty,
    output [$clog2(DEPTH)-1:0] r_addr

);

wire rempty;

reg [$clog2(DEPTH):0] b_rptr; 

wire [$clog2(DEPTH):0] b_rptr_next; // next pointer

wire  [$clog2(DEPTH):0] g_rptr_next; // gray pointer next



 assign b_rptr_next = ( b_rptr + ( read_en && ~empty) ); // increment of binary pointer

assign g_rptr_next = (b_rptr_next >> 1) ^ b_rptr_next; // conversion of binary to gray 

assign r_addr = b_rptr[$clog2(DEPTH)-1:0]; // addr sent to mem just the lower bits

  assign rempty = (g_rptr_next == g_wptr_sync);


always @(posedge rclk or negedge r_rst) begin
    
    if(!r_rst)
    begin
        b_rptr <= 0;
        g_rptr <= 0;
        empty <= 1;

    end
    else 
    begin
        b_rptr <= b_rptr_next;
        g_rptr <= g_rptr_next;
        empty <= rempty;
    end


end

    
endmodule