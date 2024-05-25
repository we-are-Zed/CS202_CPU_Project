module ALU(
    input [31:0] ReadData1,
    input [31:0] ReadData2,
    input [31:0] imm32,
    input [1:0] ALUOp,
    input [2:0] funct3,
    input [6:0] funct7,
    input [2:0] BranchType,
    input lw,
    input sw,
    input Jump,
    input ALUSrc,//selects the source of operand2. If it is 1’b0, the operand2 is ReadData2, and if it is 1’b1, imm32 is used.
    output reg [31:0] ALUResult,
    output reg zero,
    output reg less
);

    wire [31:0] operand2;
    assign operand2 = (ALUSrc) ? imm32 : ReadData2;

    always @(*) begin

        zero = 0;
        less = 0;
        if(Jump) begin
           ALUResult = (ReadData1 + operand2) & ~1;
        end
        else begin

        case(ALUOp)
            2'b00: begin
                //I-type instructions
                case(funct3)
                    3'b000: ALUResult = ReadData1 + operand2; // addi
                    3'b111: ALUResult = ReadData1 & operand2; // andi
                    3'b110: ALUResult = ReadData1 | operand2; // ori
                    3'b100: ALUResult = ReadData1 ^ operand2; // xori
                    3'b001: ALUResult = ReadData1 << operand2; // slli
                    3'b101: begin
                        if(funct7[5] == 1) begin
                            ALUResult = ReadData1 >> operand2; // srai
                        end
                        else begin
                            ALUResult = ReadData1 >>> operand2; // srli
                        end
                    end
                    3'b010: ALUResult = ReadData1 + operand2; // sw lw
                    3'b011: ALUResult = (ReadData1 < operand2); // sltiu
                    default: ALUResult = 32'b0;
                endcase
            end
            2'b01: begin
                case(BranchType)
                     3'b000:begin//beq
                  ALUResult =ReadData1-operand2;
                  zero=(ALUResult==32'b0);
                  end
                    3'b001:begin//bne
                    ALUResult =ReadData1-operand2;
                    zero=(ALUResult!=32'b0);
                    end
                    3'b100:begin//blt
                    less = ($signed(ReadData1) < $signed(operand2));
                    end
                    3'b101: begin // bge
                            less = ($signed(ReadData1) >= $signed(operand2));
                        end
                    3'b110: begin // bltu
                            less = (ReadData1 < operand2);
                        end
                        3'b111: begin // bgeu
                            less = (ReadData1 >= operand2);
                        end
                        default:begin
                       zero=1'b0;
                          less=1'b0;
                    end
            endcase
            
            end
            2'b10: begin
                // R-type instructions
                case({funct7, funct3})
                    10'b0000000_000: ALUResult = ReadData1 + operand2; // add
                    10'b0100000_000: ALUResult = ReadData1 - operand2; // sub
                    10'b0000000_111: ALUResult = ReadData1 & operand2; // and
                    10'b0000000_110: ALUResult = ReadData1 | operand2; // or
                    10'b0000000_100: ALUResult = ReadData1 ^ operand2; // xor
                    10'b0000000_001: ALUResult = ReadData1 << operand2; // sll
                    10'b0100000_101: ALUResult = ReadData1 >> operand2; // sra
                    10'b0000000_101: ALUResult = ReadData1 >>> operand2; // srl
                    10'b0000000_010: ALUResult = ($signed(ReadData1) < $signed(operand2)); // slt
                    10'b0000000_011: ALUResult = (ReadData1 < operand2); // sltu
                    default: ALUResult = 32'b0; 
                endcase
            end
            default: ALUResult = 32'b0; 
        endcase
    end
end


endmodule
