`timescale 1ns / 1ps
module ALU (
    input alu_use,
    //input [1:0] alu_type,
    input [4:0] rd,//目标寄存器的编号
    input [5:0] opcode,
    input [5:0] fun,
    input [15:0] immediate,
    input [31:0] rs1,//源寄存器的值
    input [31:0] rs2,//目标寄存器的值或者第二个源寄存器的值
    output reg[31:0] result,
    output isFalse//标注是否发生错误

);
wire [31:0] immExt_signed;
wire [31:0] immExt_unsigned;
assign immExt_signed = {{16{immediate[15]}}, immediate};
assign immExt_unsigned = {{16{1'b0}}, immediate};

always @(alu_use,alu_type,opcode,fun,immediate,rs1,rs2)
    isFalse = 0;
    result=0;
    if(alu_use){
        if(alu_type==2'b01){//R-type
            case (fun)
               6'b100000: begin//说明是加法
                result = rs1 + rs2;
                if(rs1[31]==rs2[31] && rs1[31]!=result[31])//overflow
                    isFalse = 1;
               end
                6'b100010: begin//说明是减法
                 result = rs1 - rs2;
                 if(rs1[31]!=rs2[31] && rs1[31]!=result[31])//overflow
                      isFalse = 1;
                end
                dafault: begin
                    isFalse = 1;
                    result = 0;
                end
                
            endcase
        }else if(alu_type==2'b00){//I-type
            if(opcode==6'b001000){
                result = rs1 + immExt_signed;
                if(rs1[31]==immExt_signed[31] && rs1[31]!=result[31])//overflow
                    isFalse = 1;
            }
        }
    }
    
endmodule