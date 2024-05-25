module seg_ctrl(
input clk,
input rst,
input ctrl,
input  [15:0] seg_in,
output reg [15:0] seg_out
);
always@(posedge clk or posedge rst) begin
    if(rst)begin
        seg_out<=16'b0;
    end
    else if(ctrl)begin
        seg_out<=seg_in;
    end
end
endmodule