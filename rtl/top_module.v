module top_module #(
    parameter DEPTH = 8,
    parameter WIDTH = 8
) (
    input wclk,
    input w_rst,
    input write_en,
    input [WIDTH-1:0] data_in,

    input rclk,
    input r_rst,
    input read_en,

    output full,
    output empty,
    output [WIDTH-1:0] data_out
);

// gray code pointers
   wire [$clog2(DEPTH):0] g_wptr;
    wire [$clog2(DEPTH):0] g_rptr;

    
    // Synchronized pointers

    wire [$clog2(DEPTH):0] g_wptr_sync;
    wire [$clog2(DEPTH):0] g_rptr_sync;

    // Memory addresses
    

    wire [$clog2(DEPTH)-1:0] wr_addr;
    wire [$clog2(DEPTH)-1:0] r_addr;




// synchronizer for write 
synchronizer #(
    .WIDTH($clog2(DEPTH) +1)
) sync_rptr (
    .clk(wclk),
    .rst(~w_rst),
    .async_in(g_rptr),
    .sync_out(g_rptr_sync)

);


// synchronizer for read 
synchronizer #(
    .WIDTH($clog2(DEPTH) +1)
) sync_wptr (
    .clk(rclk),
    .rst(~r_rst),
    .async_in(g_wptr),
    .sync_out(g_wptr_sync)
);


// write pointer handler 
   wptr_handler #(
        .DEPTH(DEPTH)
    ) wptr (
        .wclk(wclk),
        .write_en(write_en),
        .w_rst(w_rst),
        .g_rptr_sync(g_rptr_sync),

        .g_wptr(g_wptr),
        .full(full),
        .wr_addr(wr_addr)
    );

// read pointer handler 
      rptr_handler #(
        .DEPTH(DEPTH)
    ) rptr (
        .rclk(rclk),
        .read_en(read_en),
        .r_rst(r_rst),
        .g_wptr_sync(g_wptr_sync),

        .g_rptr(g_rptr),
        .empty(empty),
        .r_addr(r_addr)
    );

//fifo memory
       fifo_mem #(         
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) memory (
        .data_in(data_in),
        .write_en(write_en && !full),
        .wclk(wclk),
        .wr_addr(wr_addr),
        .r_addr(r_addr),
        .data_out(data_out)
    );



    
endmodule