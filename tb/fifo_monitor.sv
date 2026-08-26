class fifo_monitor #(
    parameter WIDTH = 8
);


mailbox #(fifo_transaction #(WIDTH)) mon2scb;
virtual fifo_if #(WIDTH) vif;

function new(
    mailbox #(fifo_transaction #(WIDTH)) mon2scb,
virtual fifo_if #(WIDTH) vif
);

this.mon2scb = mon2scb;
this.vif = vif;

endfunction

task monitor_write();

fifo_transaction #(WIDTH) tr;

forever begin 
@(posedge vif.wclk)
  
  if(vif.write_en && !vif.full)
  begin
    tr = new();
    tr.write_en = 1;
    tr.read_en = 0;
    tr.write_data = vif.data_in;
    tr.full = vif.full;
    tr.empty = vif.empty;

    mon2scb.put(tr);

  end

end

endtask


task monitor_read();

fifo_transaction #(WIDTH) tr;

forever begin 
@(posedge vif.rclk)
  
  if(vif.read_en && !vif.empty)
  begin
    
                tr = new();

            tr.write_en  = 0;
            tr.read_en   = 1;
            tr.read_data = vif.data_out;
            tr.full      = vif.full;
            tr.empty     = vif.empty;

            mon2scb.put(tr);


  end

end

endtask

task run();

fork
    monitor_write();
    monitor_read();
join

endtask

endclass