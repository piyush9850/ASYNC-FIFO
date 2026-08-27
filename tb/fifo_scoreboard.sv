class fifo_scoreboard #(
    parameter WIDTH = 8
);

mailbox #(fifo_transaction #(WIDTH)) mon2scb;

logic [WIDTH-1:0] expected_q[$];

int error_count;

function new(
    mailbox #(fifo_transaction #(WIDTH)) mon2scb
);

this.mon2scb = mon2scb;
error_count = 0;

endfunction

task run();

fifo_transaction #(WIDTH) tr;
logic [WIDTH-1:0] expected_data;

forever begin
    
    mon2scb.get(tr);

    
    
        if(tr.write_en)
        begin
            expected_q.push_back(tr.write_data);  // write checking

        end

   
        if(tr.read_en )  /// read checking
        begin

            if(expected_q.size() == 0)
            begin
                $display("ERROR queue is empty");
                error_count ++ ;

            end
            
            else 
            begin
            expected_data = expected_q.pop_front();
            
            if(tr.read_data !== expected_data)
            begin
                $display("MISMATCH: Got=%0h Expected=%0h",tr.read_data,expected_data);
                error_count++;
            end
            else
            begin
                $display("MATCH: Data=%0h",tr.read_data);
        
            end
        end
        end

end
endtask

endclass