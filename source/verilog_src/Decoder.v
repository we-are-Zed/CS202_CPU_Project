module Decoder(
    input clk,
    input rst,
    input lb,
    input regWrite,
    input MemRead,
    input IoRead,
    input [31:0] inst,
    input [31:0] writeData,
    input [31:0] ALUResult,
    output reg [31:0] rs1Data,
    output reg [31:0] rs2Data,
    output reg [31:0] imm32
);
    reg [31:0] registers [0:31]; 

    wire [4:0] rs1, rs2, rd;
    wire [6:0] opcode;
    wire [2:0] funct3;
    integer i;

    assign rs1 = inst[19:15];
    assign rs2 = inst[24:20];
    assign rd = inst[11:7];
    assign opcode = inst[6:0];
    assign funct3 = inst[14:12];

    initial begin
        for (i = 0; i < 31; i = i + 1) begin
            registers[i] = 32'b0;
        end
        registers[31]=32'hFFFFFC00;
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



     always @(*) begin
        if(lb==1'b1) begin
        if(funct3==3'b000) begin
            writeData = {24{writeData[7]},writeData[7:0]}
        end else begin
            writeData = {{24{1'b0}}, writeData[7:0]};
        end
    end
    end
     
    



    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            for (i = 0; i < 31; i = i + 1) begin
                registers[i] <= 32'b0;
            end
            registers[31]<=32'hFFFFFC00;
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
            7'b1100011: begin // beq, bne, blt, bge, bltu, bgeu
                imm32 = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
            end
             7'b0000011, // lw,lb,lbu
             7'b0010011, // I-type (addi, andi, ori)
             7'b1100111: begin // jalr
                           imm32 = {{20{inst[31]}}, inst[31:20]};
                       end
            7'b0100011: begin // sw
                imm32 = {{20{inst[31]}}, inst[31:25], inst[11:7]};
            end
            7'b1101111: begin // jal
                imm32 = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
            end
             7'b0010111: begin // auipc
                           imm32 = {inst[31:12], 12'b0};
                       end
              7'b0110111: begin // lui
                                       imm32 = {inst[31:12], 12'b0};
                                   end 
            default: begin
                imm32 = 32'b0;
            end
        endcase
    end

endmodule