//我先不删吧，跟byh讨论了一下，这个文件应该是不需要的
//因为ALUControl的功能已经在ALU.v里面实现了，直接通过func3和func7来判断ALU做什么事情
//但是也不排除后续ALU新加操作，导致ALU太冗杂，所以这个文件还是保留一下吧
module ALUControl (
    input [1:0] ALUOp,
    input [6:0] funct7,
    input [2:0] funct3,
    output reg [3:0] ALUControl
);
always @(*) begin
        case(ALUOp)
            2'b00: begin
                // Load and Store instructions (lw, sw)
                ALUControl = 4'b0010; // add操作
            end
            2'b01: begin
                // Branch instruction (beq)
                ALUControl = 4'b0110; // subtract
            end
            2'b10: begin
                // R-type指令
                case({funct7, funct3})
                    10'b0000000_000: ALUControl = 4'b0010; // add
                    10'b0100000_000: ALUControl = 4'b0110; // subtract
                    10'b0000000_111: ALUControl = 4'b0000; // AND
                    10'b0000000_110: ALUControl = 4'b0001; // OR
                    default: ALUControl = 4'b1111; 
                endcase
            end
            default: ALUControl = 4'b1111; 
        endcase
    end    
endmodule