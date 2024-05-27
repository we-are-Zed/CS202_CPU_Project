module Decoder(
    input clk,
    input rst,
    input regWrite,
    input MemRead,
    input IoRead,
    input [31:0] inst,
    input [31:0] writeData,//
    input [31:0] ALUResult,
    output [31:0] rs1Data,
    output [31:0] rs2Data,
    output reg [31:0] imm32
);
    reg [31:0] registers [0:31]; // 32个32位寄存器
    wire [4:0] rs1, rs2, rd;
    wire [6:0] opcode;
    wire [2:0] funct3;
    integer i;

    // 提取指令字段
    assign rs1 = inst[19:15];
    assign rs2 = inst[24:20];
    assign rd = inst[11:7];
    assign opcode = inst[6:0];
    assign funct3 = inst[14:12];

    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'b0;
        end
        registers[31]=32'h0000FC00;
    end

    always @(*) begin
        if(!rst) begin
            rs1Data = 32'b0;
            rs2Data = 32'b0;
        end else begin
            rs1Data = registers[rs1];
            rs2Data = registers[rs2];
        end
    end



    // 在时钟上升沿写入寄存器
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
            registers[31]<=32'hFFFFFC50;
        end else if (regWrite&&rd!=0) begin
            if(MemRead||IoRead) begin
                registers[rd] <= writeData;
            end else begin
                registers[rd] <= ALUResult;
            end
        end
    end

    // 生成立即数
    always @(*) begin
        case (opcode)
            7'b1100011: begin // beq
                imm32 = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0}; // 立即数拼接并符号扩展
            end
            7'b0000011, // lw
            7'b0010011: begin // I-type (addi, andi, ori)
                imm32 = {{20{inst[31]}}, inst[31:20]}; // 符号扩展
            end
            7'b0100011: begin // sw
                imm32 = {{20{inst[31]}}, inst[31:25], inst[11:7]}; // 符号扩展
            end
            default: begin
                imm32 = 32'b0; // 其他情况默认
            end
        endcase
    end

endmodule