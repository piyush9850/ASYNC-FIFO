class fifo_environment #(
    parameter WIDTH = 8
);

fifo_generator #(WIDTH) gen;
fifo_driver #(WIDTH) drv;
fifo_monitor #(WIDTH) mon;
fifo_scoreboard #(WIDTH) scb;

mailbox #(fifo_transaction #(WIDTH)) gen2drv;
mailbox #(fifo_transaction #(WIDTH)) mon2scb;

virtual fifo_if #(WIDTH) vif;

function new(
    virtual fifo_if #(WIDTH) vif
);

this.vif = vif;

endfunction

task build();

    gen2drv = new();
    mon2scb = new();

    gen = new(gen2drv,100);
    drv = new(gen2drv,vif);
    mon = new(mon2scb,vif);
    scb = new(mon2scb);

endtask

task run();

    fork
        gen.run();
        drv.run();
        mon.run();
        scb.run();

    join_none

endtask

endclass