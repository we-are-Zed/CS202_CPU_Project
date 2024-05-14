module ALU(
    input [31:0] ReadData1,
    input [31:0] ReadData2,
    input [31:0] imm32,
    input [1:0] ALUOp,
    input [2:0] funct3,
    input [6:0] funct7,
    input ALUSrc,//selects the source of operand2. If it is 1’b0, the operand2 is ReadData2, and if it is 1’b1, imm32 is used.
    output reg [31:0] ALUResult,
    output zero
);

    wire [31:0] operand2;
    assign operand2 = (ALUSrc) ? imm32 : ReadData2;

    always @(*) begin
        case(ALUOp)
            2'b00: begin
                // (lw, sw)指令
                ALUResult = ReadData1 + operand2;
            end
            2'b01: begin
                // Branch instruction计算地址
                ALUResult = ReadData1 - operand2;
            end
            2'b10: begin
                // R-type instructions
                case({funct7, funct3})
                    10'b0000000_000: ALUResult = ReadData1 + operand2; // add
                    10'b0100000_000: ALUResult = ReadData1 - operand2; // sub
                    10'b0000000_111: ALUResult = ReadData1 & operand2; // and
                    10'b0000000_110: ALUResult = ReadData1 | operand2; // or
                    default: ALUResult = 32'b0; 
                endcase
            end
            default: ALUResult = 32'b0; 
        endcase
    end

    assign zero = (ALUResult == 32'b0) ? 1'b1 : 1'b0;

endmodule
