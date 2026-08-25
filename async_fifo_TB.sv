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

top_module dut (.wclk(wclk), .w_rst(w_rst), .write_en(write_en), .data_in(data_in), .rclk(rclk), .r_rst(r_rst), .read_en(read_en), .full(full), .empty(empty), .data_out(data_out) );



endmodule 