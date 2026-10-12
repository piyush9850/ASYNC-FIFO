`timescale 1ns/1ps

//============================================================
// CONSTRAINT RANDOM TESTBENCH FOR ASYNCHRONOUS FIFO
//============================================================


//============================================================
// WRITE TRANSACTION
//============================================================

class wr_transaction;

    rand bit [7:0] wr_data;
    rand bit       wr_en;

    // 50% write, 50% idle
    constraint wr_en_c {
        wr_en dist {
            1 := 50,
            0 := 50
        };
    }

    constraint data_c {
        wr_data inside {[0:255]};
    }

    function wr_transaction copy();

        copy = new();

        copy.wr_data = this.wr_data;
        copy.wr_en   = this.wr_en;

    endfunction

    function void display();

        $display("[GEN-WR] wr_en=%0d  wr_data=%0h",
                 wr_en, wr_data);

    endfunction

endclass


//============================================================
// READ TRANSACTION
//============================================================

class rd_transaction;

    rand bit rd_en;

    // 50% read, 50% idle
    constraint rd_en_c {
        rd_en dist {
            1 := 50,
            0 := 50
        };
    }

    function rd_transaction copy();

        copy = new();

        copy.rd_en = this.rd_en;

    endfunction

    function void display();

        $display("[GEN-RD] rd_en=%0d", rd_en);

    endfunction

endclass


//============================================================
// INTERFACE
//============================================================

interface fifo_if;

    logic wr_clk;
    logic rd_clk;

    logic wr_rst;
    logic rd_rst;

    logic wr_en;
    logic rd_en;

    logic [7:0] wr_data;
    logic [7:0] rd_data;

    logic full;
    logic empty;

endinterface


//============================================================
// WRITE GENERATOR
//============================================================

class wr_generator;

    mailbox #(wr_transaction) wr_mbx;

    function new(mailbox #(wr_transaction) wr_mbx);

        this.wr_mbx = wr_mbx;

    endfunction


    task run();

        wr_transaction tr;

        for (int i = 0; i < 150; i++) begin

            tr = new();

            if (!tr.randomize()) begin

                $display("[GEN-WR] Randomization FAILED");
                $finish;

            end

            tr.display();

            wr_mbx.put(tr.copy());

        end

    endtask

endclass


//============================================================
// READ GENERATOR
//============================================================

class rd_generator;

    mailbox #(rd_transaction) rd_mbx;

    function new(mailbox #(rd_transaction) rd_mbx);

        this.rd_mbx = rd_mbx;

    endfunction


    task run();

        rd_transaction tr;

        for (int i = 0; i < 150; i++) begin

            tr = new();

            if (!tr.randomize()) begin

                $display("[GEN-RD] Randomization FAILED");
                $finish;

            end

            tr.display();

            rd_mbx.put(tr.copy());

        end

    endtask

endclass


//============================================================
// DRIVER
//============================================================

class driver;

    virtual fifo_if vif;

    mailbox #(wr_transaction) wr_mbx;
    mailbox #(rd_transaction) rd_mbx;


    function new(
        mailbox #(wr_transaction) wr_mbx,
        mailbox #(rd_transaction) rd_mbx
    );

        this.wr_mbx = wr_mbx;
        this.rd_mbx = rd_mbx;

    endfunction


    //========================================================
    // WRITE DRIVER
    //========================================================

    task write_drive();

        wr_transaction tr;

        for (int i = 0; i < 150; i++) begin

            wr_mbx.get(tr);

            @(negedge vif.wr_clk);

            vif.wr_en   <= tr.wr_en;
            vif.wr_data <= tr.wr_data;

        end

        @(negedge vif.wr_clk);

        vif.wr_en <= 0;

    endtask


    //========================================================
    // READ DRIVER
    //========================================================

    task read_drive();

        rd_transaction tr;

        for (int i = 0; i < 150; i++) begin

            rd_mbx.get(tr);

            @(negedge vif.rd_clk);

            vif.rd_en <= tr.rd_en;

        end

        @(negedge vif.rd_clk);

        vif.rd_en <= 0;

    endtask


    task run();

        fork

            write_drive();
            read_drive();

        join

    endtask

endclass


//============================================================
// WRITE MONITOR
//============================================================

class write_monitor;

    virtual fifo_if vif;

    mailbox #(wr_transaction) mon_mbx;


    function new(mailbox #(wr_transaction) mon_mbx);

        this.mon_mbx = mon_mbx;

    endfunction


    task run();

        wr_transaction tr;

        forever begin

            @(posedge vif.wr_clk);

            #1;

            tr = new();

            tr.wr_en   = vif.wr_en;
            tr.wr_data = vif.wr_data;

            // A write is accepted only when FIFO is not full
            if (vif.wr_en && !vif.full) begin

                $display(
                    "[MON-WR] ACCEPTED  data=%0h full=%0d",
                    vif.wr_data,
                    vif.full
                );

                mon_mbx.put(tr);

            end
            else begin

                $display(
                    "[MON-WR] IGNORED    en=%0d data=%0h full=%0d",
                    vif.wr_en,
                    vif.wr_data,
                    vif.full
                );

            end

        end

    endtask

endclass


//============================================================
// READ MONITOR
//
// IMPORTANT:
//
// fifo_mem uses:
//
// always @(posedge rd_clk)
//     if(rd_en)
//         rd_data <= mem[rd_addr];
//
// Therefore rd_data becomes valid AFTER the read clock edge.
//
// We capture the read request first, then wait a small amount
// of time before capturing rd_data.
//============================================================

class read_monitor;

    virtual fifo_if vif;

    mailbox #(bit [7:0]) mon_mbx;


    function new(mailbox #(bit [7:0]) mon_mbx);

        this.mon_mbx = mon_mbx;

    endfunction


    task run();

        bit read_accepted;

        forever begin

            @(posedge vif.rd_clk);

            // Determine whether a real read was accepted
            read_accepted = vif.rd_en && !vif.empty;

            if (read_accepted) begin

                // Wait for synchronous memory read to update rd_data
                #1;

                $display(
                    "[MON-RD] ACCEPTED  data=%0h empty=%0d",
                    vif.rd_data,
                    vif.empty
                );

                mon_mbx.put(vif.rd_data);

            end
            else begin

                $display(
                    "[MON-RD] IGNORED    en=%0d empty=%0d data=%0h",
                    vif.rd_en,
                    vif.empty,
                    vif.rd_data
                );

            end

        end

    endtask

endclass


//============================================================
// SCOREBOARD
//============================================================

class scoreboard;

    // Accepted writes
    mailbox #(wr_transaction) wr_mon_mbx;

    // Actual data from accepted reads
    mailbox #(bit [7:0]) rd_mon_mbx;

    // Expected FIFO data
    bit [7:0] expected_queue[$];

    int write_count;
    int read_count;
    int match_count;
    int error_count;


    function new(
        mailbox #(wr_transaction) wr_mon_mbx,
        mailbox #(bit [7:0]) rd_mon_mbx
    );

        this.wr_mon_mbx = wr_mon_mbx;
        this.rd_mon_mbx = rd_mon_mbx;

        write_count = 0;
        read_count  = 0;
        match_count = 0;
        error_count = 0;

    endfunction


    //========================================================
    // PROCESS WRITES
    //========================================================

    task write_check();

        wr_transaction tr;

        forever begin

            wr_mon_mbx.get(tr);

            expected_queue.push_back(tr.wr_data);

            write_count++;

            $display(
                "[SCO-WR] STORED = %0h | Queue size = %0d",
                tr.wr_data,
                expected_queue.size()
            );

        end

    endtask


    //========================================================
    // PROCESS READS
    //========================================================

    task read_check();

        bit [7:0] actual_data;
        bit [7:0] expected_data;

        forever begin

            rd_mon_mbx.get(actual_data);

            read_count++;

            if (expected_queue.size() == 0) begin

                $display(
                    "[SCO-RD] ERROR: Queue empty, actual=%0h",
                    actual_data
                );

                error_count++;

            end

            else begin

                expected_data = expected_queue.pop_front();

                if (actual_data === expected_data) begin

                    $display(
                        "[SCO-RD] MATCH  Expected=%0h Actual=%0h",
                        expected_data,
                        actual_data
                    );

                    match_count++;

                end

                else begin

                    $display(
                        "[SCO-RD] ERROR  Expected=%0h Actual=%0h",
                        expected_data,
                        actual_data
                    );

                    error_count++;

                end

            end

        end

    endtask


    //========================================================
    // RUN
    //========================================================

    task run();

        fork

            write_check();
            read_check();

        join

    endtask


    //========================================================
    // REPORT
    //========================================================

    task report();

        $display("");
        $display("====================================================");
        $display("              ASYNC FIFO TEST REPORT");
        $display("====================================================");

        $display("Accepted Writes : %0d", write_count);
        $display("Accepted Reads  : %0d", read_count);
        $display("Matches         : %0d", match_count);
        $display("Errors          : %0d", error_count);
        $display("Queue Remaining : %0d",
                 expected_queue.size());

        if (error_count == 0) begin

            $display("");
            $display("**************** TEST PASSED ****************");

        end
        else begin

            $display("");
            $display("**************** TEST FAILED ****************");

        end

        $display("====================================================");
        $display("");

    endtask

endclass


//============================================================
// TESTBENCH
//============================================================

module AFIFOtb;

    parameter DATA_WIDTH = 8;
    parameter DEPTH      = 8;


    //========================================================
    // INTERFACE
    //========================================================

    fifo_if vif();


    //========================================================
    // MAILBOXES
    //========================================================

    mailbox #(wr_transaction) wr_mbx;
    mailbox #(rd_transaction) rd_mbx;

    mailbox #(wr_transaction) wr_mon_mbx;
    mailbox #(bit [7:0])      rd_mon_mbx;


    //========================================================
    // OBJECTS
    //========================================================

    wr_generator wg;
    rd_generator rg;

    driver drv;

    write_monitor wr_mon;
    read_monitor  rd_mon;

    scoreboard sco;


    //========================================================
    // DUT
    //========================================================

    top #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (

        .wr_clk  (vif.wr_clk),
        .rd_clk  (vif.rd_clk),

        .wr_en   (vif.wr_en),
        .rd_en   (vif.rd_en),

        .wr_rst  (vif.wr_rst),
        .rd_rst  (vif.rd_rst),

        .wr_data (vif.wr_data),
        .rd_data (vif.rd_data),

        .full    (vif.full),
        .empty   (vif.empty)

    );


    //========================================================
    // CLOCKS
    //========================================================

    initial begin

        vif.wr_clk = 0;
        vif.rd_clk = 0;

    end


    // Write clock = 100 MHz
    always #5 vif.wr_clk = ~vif.wr_clk;

    // Read clock = 50 MHz
    always #10 vif.rd_clk = ~vif.rd_clk;


    //========================================================
    // INITIAL SIGNALS
    //========================================================

    initial begin

        vif.wr_rst = 0;
        vif.rd_rst = 0;

        vif.wr_en   = 0;
        vif.rd_en   = 0;
        vif.wr_data = 0;

    end


    //========================================================
    // CREATE OBJECTS
    //========================================================

    initial begin

        wr_mbx = new();
        rd_mbx = new();

        wr_mon_mbx = new();
        rd_mon_mbx = new();


        wg = new(wr_mbx);

        rg = new(rd_mbx);


        drv = new(
            wr_mbx,
            rd_mbx
        );


        wr_mon = new(wr_mon_mbx);

        rd_mon = new(rd_mon_mbx);


        sco = new(
            wr_mon_mbx,
            rd_mon_mbx
        );


        drv.vif = vif;

        wr_mon.vif = vif;

        rd_mon.vif = vif;

    end


    //========================================================
    // RESET
    //========================================================

    initial begin

        #40;

        vif.wr_rst = 1;
        vif.rd_rst = 1;

        $display("");
        $display("==============================================");
        $display("RESET RELEASED");
        $display("==============================================");
        $display("");

    end


    //========================================================
    // START TEST
    //========================================================

    initial begin

        // Wait for reset release
        wait(vif.wr_rst == 1);
        wait(vif.rd_rst == 1);

        #1;

        // Start scoreboard and monitors before drivers
        fork

            sco.run();

            wr_mon.run();

            rd_mon.run();

        join_none


        // Small delay so monitors are active
        #1;


        // Start generators and driver
        fork

            wg.run();
            rg.run();
            drv.run();

        join

    end


    //========================================================
    // WAVEFORM
    //========================================================

    initial begin

        $dumpfile("AFIFO.vcd");

        $dumpvars(0, AFIFOtb);

    end


    //========================================================
    // END SIMULATION
    //========================================================

    initial begin

        // Allow enough time for:
        // 150 write transactions
        // 150 read transactions
        // asynchronous pointer synchronization
        // FIFO draining

        #5000;

        sco.report();

        $finish;

    end

endmodule