module tb;

parameter WIDTH = 8;
parameter DEPTH = 8;

logic wclk;
logic rclk;

logic w_rst;
logic write_en;
logic [WIDTH-1:0] data_in;

logic r_rst;
logic read_en;

logic [WIDTH-1:0] data_out;
logic full;
logic empty;



logic [WIDTH-1:0] expected_q[$];

top_module #(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH)
) dut (
    .wclk(wclk),
 .w_rst(w_rst),
  .write_en(write_en),
   .data_in(data_in),
    .rclk(rclk),
     .r_rst(r_rst),
      .read_en(read_en),
       .full(full),
        .empty(empty),
         .data_out(data_out) 
         );


initial begin  // initialion of wclk with period 10
wclk = 0;
    forever begin
        #5;
wclk = ~wclk;
   end

end

initial begin // initialion of rclk with period 14
    rclk = 0;
forever begin
#7;
rclk = ~rclk;
end
end

initial begin  // reset condition
    
    w_rst = 0;
    r_rst = 0;

    write_en = 0;
    read_en = 0;

    data_in = 0;

    #50;

    w_rst = 1;
    r_rst = 1;


end

task automatic write_byte(input logic [WIDTH-1:0] val);  // write task

@(posedge wclk);
begin
    if(!full)
    begin
        write_en = 1;
        data_in = val;
        expected_q.push_back(data_in);
    end
end

@(posedge  wclk);
begin
write_en = 0;
end


endtask




endmodule 