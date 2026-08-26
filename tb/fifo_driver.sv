class fifo_driver #(
    parameter WIDTH = 8
);


mailbox #(fifo_transaction #(WIDTH)) gen2drv;

virtual fifo_if #(WIDTH) vif;

function new(
    mailbox #(fifo_transaction #(WIDTH)) gen2drv,
virtual fifo_if #(WIDTH) vif
);

this.gen2drv = gen2drv;
this.vif = vif;

endfunction

task run();

fifo_transaction #(WIDTH) tr ;

forever begin
    
    gen2drv.get(tr);

    fork
        begin
            // write side
            if(tr.write_en) begin
                @(posedge vif.wclk);
                vif.write_en = 1;
                vif.read_en = 0;
                vif.data_in = tr.write_data;

                @(posedge vif.wclk);
                vif.write_en = 0;
            end
end
            // read side

             begin
                if (tr.read_en) begin
                    @(posedge vif.rclk);
                    vif.read_en = 1;
                    @(posedge vif.rclk);
                    vif.read_en = 0;
                end
            end


        

    join




end



endtask

endclass

