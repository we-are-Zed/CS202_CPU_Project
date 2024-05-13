module register{
input clk,
input rst,
input[4:0] rs1,
input[4:0] rs2,
input[4:0] wr,//read register and write register
input RegWrite,
input [31:0] WriteData,
output[31:0] ReadData1,
output[31:0]ReadData2
};


endmodule