module synchronizer #(
    parameter WIDTH = 4 // variable width

)(
    input clk,
    input rst,
    input [WIDTH-1:0] async_in,

    output reg [WIDTH-1:0] sync_out
);

reg [WIDTH-1:0] q1; // internal

always @(posedge clk) begin
    
    if(rst)
    begin
        q1 <= 0;
        sync_out <= 0;

    end
    else
    begin
        q1 <= async_in;  
        sync_out <= q1;  // 2 ff 
    end

end
    
endmodule