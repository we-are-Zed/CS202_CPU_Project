module button(
input clk,
input rst,
input [15:0] button_in,
output[15:0] button_out//pass to io part
);
reg [15:0] button_choose;
assign button_out=button_choose;
always @(negedge clk or posedge rst) begin
   if(rst)begin
       button_choose<=16'b0;
   end
   else begin
         button_choose<=button_in;
    end  
end
endmodule