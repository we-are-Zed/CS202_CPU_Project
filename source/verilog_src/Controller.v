module Controller(
    input [31:0] inst,
    output reg Branch,
    output reg MemRead,
    output reg MemtoReg,
    output reg MemWrite,
    output reg ALUSrc,
    output reg RegWrite,
    output reg [1:0] ALUOp
);

    // 提取操作码字段
    wire [6:0] opcode = inst[6:0];
    wire [2:0] funct3 = inst[14:12];
    wire [6:0] funct7 = inst[31:25];

    // 定义RISC-V指令的操作码
    localparam [6:0] R_TYPE = 7'b0110011;
    localparam [6:0] I_TYPE = 7'b0010011;
    localparam [6:0] LOAD = 7'b0000011;
    localparam [6:0] STORE = 7'b0100011;
    localparam [6:0] BRANCH = 7'b1100011;
    localparam [6:0] JALR = 7'b1100111;
    localparam [6:0] LUI = 7'b0110111;
    localparam [6:0] AUIPC = 7'b0010111;

    always @(*) begin
        // 初始化所有输出信号为0
        Branch = 0;
        MemRead = 0;
        MemtoReg = 0;
        MemWrite = 0;
        ALUSrc = 0;
        RegWrite = 0;
        ALUOp = 2'b00;

        case(opcode)
            R_TYPE: begin
                RegWrite = 1;
                ALUOp = 2'b10;
                ALUSrc = 0;
            end
            I_TYPE: begin
                RegWrite = 1;
                ALUOp = 2'b11; // 根据指令类型不同，可以进一步细化
                ALUSrc = 1;
            end
            LOAD: begin
                MemRead = 1;
                MemtoReg = 1;
                RegWrite = 1;
                ALUOp = 2'b00;
                ALUSrc = 1;
            end
            STORE: begin
                MemWrite = 1;
                ALUOp = 2'b00;
                ALUSrc = 1;
            end
            BRANCH: begin
                case(funct3)
                    3'b000: begin
                        ALUOp = 2'b01;//beq
                        Branch = 1;
                    end
                    3'b001: begin
                        ALUOp = 2'b01;//bne
                        Branch = 1;
                    end
                    3'b100: begin
                        ALUOp = 2'b01;//blt
                        Branch = 1;
                    end
                    3'b101: begin
                        ALUOp = 2'b01;//bge
                        Branch = 1;
                    end
                    3'b110: begin
                        ALUOp = 2'b01;//bltu
                        Branch = 1;
                    end
                    3'b111: begin
                        ALUOp = 2'b01;//bgeu
                        Branch = 1;
                    end
                    default:begin
                        Branch = 0;
                        ALUOp = 2'b00;
                    end
            endcase
            end
           // JALR: begin
                RegWrite = 1;
                ALUOp = 2'b00;
                ALUSrc = 1;
            //end
            //不确定jalr的ALUOp是多少以及需不要用
            default: begin
                // 对于未定义的操作码，保持所有信号为0
            end
        endcase
    end

endmodule
