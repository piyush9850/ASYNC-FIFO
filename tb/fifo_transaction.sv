class fifo_transaction#(
    parameter WIDTH = 8,
    parameter DEPTH = 8
);

rand bit write_en;
rand bit read_en;

rand bit [WIDTH-1:0] write_data;

rand bit [WIDTH-1:0] read_data;

bit full;
bit empty;



function new();

    write_en = 0;
    read_en = 0;
    write_data = 0;

    read_data = 0;
    full = 0;
    empty = 1;



      function void display(string name = "TRANSACTION");

        $display("------------------------------------------");
        $display("%s", name);
        $display("WRITE_EN  = %0b", write_en);
        $display("READ_EN   = %0b", read_en);
        $display("WRITE_DATA = %0h", write_data);
        $display("READ_DATA  = %0h", read_data);
        $display("FULL       = %0b", full);
        $display("EMPTY      = %0b", empty);
        $display("------------------------------------------");

    endfunction


endfunction
endclass