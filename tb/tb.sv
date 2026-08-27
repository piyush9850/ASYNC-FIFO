module tb;

parameter WIDTH = 8;
parameter DEPTH = 8;

logic wclk;
logic rclk;

fifo_if #(WIDTH) vif(wclk,rclk); //interface




// DUT
top_module #(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH)
) dut (
    .wclk     (vif.wclk),
    .w_rst    (vif.w_rst),
    .write_en (vif.write_en),
    .data_in  (vif.data_in),

    .rclk     (vif.rclk),
    .r_rst    (vif.r_rst),
    .read_en  (vif.read_en),

    .full     (vif.full),
    .empty    (vif.empty),
    .data_out (vif.data_out)
);


fifo_test #(WIDTH) test;  // test object


initial begin // write clock

    wclk = 0;

    forever begin
        #5;
        wclk = ~wclk;
    end

end

initial begin // read clock

    rclk = 0;

    forever begin
        #7;
        rclk = ~rclk;
    end

end

initial begin
    
    vif.w_rst = 0;
    vif.r_rst = 0;

    #100 

    vif.w_rst = 1;
    vif.r_rst = 1;



    test = new(vif);
    test.run();



end

endmodule 