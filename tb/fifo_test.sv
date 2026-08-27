class fifo_test #(
    parameter WIDTH = 8
);

 fifo_environment #(WIDTH) env;

 virtual fifo_if #(WIDTH) vif;

 function new(
    virtual fifo_if #(WIDTH) vif
 );

 this.vif = vif;

 endfunction

 task run();

    env = new(vif);
    env.build();
    env.run();

    #5000;
    $finish;
    
 endtask

endclass