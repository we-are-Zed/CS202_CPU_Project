module Controller(
    input [31:0] inst,
    input [31:0] ALUResult,
    output reg Branch,
    output reg ALUSrc,//

    output reg MemorIOtoReg,
    output reg MemRead,//memread
    output reg MemWrite,//memwrite
    output reg IoRead,
    output reg IoWrite,
    output reg RegWrite,

    output reg [1:0] ALUOp,
    output reg Jump,
    output reg [2:0] BranchType,
    //output reg sft

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
    localparam [6:0] JAL = 7'b1101111;
    //localparam [6:0] LUI = 7'b0110111;
    //localparam [6:0] AUIPC = 7'b0010111;

    wire R_type;
    wire I_type;
    wire jrn;
    wire lw;
    wire sw;
    assign R_type = (opcode == R_TYPE)? 1'b1 : 1'b0;
    assign I_type = (opcode == I_TYPE)? 1'b1 : 1'b0;
    assign lw = (opcode == LOAD&&funct3==3'b002)? 1'b1 : 1'b0;
    assign sw = (opcode == STORE&&funct3==3'b002)? 1'b1 : 1'b0;
    assign Jump = (opcode == JALR||opcode==JAL)? 1'b1 : 1'b0;
    assign jrn = (opcode == JALR)? 1'b1 : 1'b0;
    assign ALUSrc = (I_type||lw||sw||jrn)? 1'b1 : 1'b0;
    assign RegWrite = (R_type||I_type||lw||jal)&&!jrn? 1'b1 : 1'b0;
    assign Branch = (opcode == BRANCH)? 1'b1 : 1'b0;
    assign MemRead = (lw==1'b1&&(ALUResult[21:0]!=22'b1111111111111111111111))? 1'b1 : 1'b0;
    assign MemWrite = (sw==1'b1&&(ALUResult[21:0]!=22'b1111111111111111111111))? 1'b1 : 1'b0;
    assign IoRead = (lw==1'b1&&(ALUResult[21:0]==22'b1111111111111111111111))? 1'b1 : 1'b0;
    assign IoWrite = (sw==1'b1&&(ALUResult[21:0]==22'b1111111111111111111111))? 1'b1 : 1'b0;
    assign MemorIOtoReg = (MemRead||IoRead)? 1'b1 : 1'b0;
    assign sft =(I_type&&(funct3==3'b101||funct3==3'b001))? 1'b1 : 1'b0;
    assign BranchType =(Branch)? inst[14:12] : 3'b000;

    always @(*) begin
        case(opcode)
        R_TYPE: begin
            ALUOp = 2'b10;
        end
        I_TYPE: begin
            ALUOp = 2'b00;
        end

        LOAD: begin
            ALUOp = 2'b00;
        end
        STORE: begin
            ALUOp = 2'b00;
        end
        BRANCH: begin
            ALUOp = 2'b01;
        end
        default: begin
            ALUOp = 2'b00;
        end
    endcase
    end


endmodule
