module registers(
input clk,
input rst,
input[4:0] rs1,
input[4:0] rs2,
input[4:0] wr,//read register and write register
input RegWrite,
input [31:0] WriteData,
output[31:0] ReadData1,
output[31:0]ReadData2
)

;
reg[31:0] regs[0:31];//register file
integer i;
always @(posedge clk or posedge rst) begin
  if (rst) begin
        for (i = 0; i <=31; i = i + 1) begin
            regs[i] <= 0;
        end
   
    end
else 
begin
if(RegWrite&(wr!=0))
begin
regs[wr]<=WriteData;
end

end

end
//read part
assign ReadData1=regs[rs1];
assign ReadData2=regs[rs2]; //haven't consider zero register situation
endmodule