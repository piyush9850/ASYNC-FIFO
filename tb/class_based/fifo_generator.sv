class fifo_generator #(
    parameter WIDTH = 8
);

    mailbox #(fifo_transaction #(WIDTH)) gen2drv;

    int num_transactions;


    function new(
        mailbox #(fifo_transaction #(WIDTH)) gen2drv,
        int num_transactions = 100
    );

        this.gen2drv = gen2drv;
        this.num_transactions = num_transactions;

    endfunction


    task run();

        fifo_transaction #(WIDTH) tr;

        repeat(num_transactions)
        begin

            tr = new();

            assert(tr.randomize());

            gen2drv.put(tr);

        end

    endtask

endclass