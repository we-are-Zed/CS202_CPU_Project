module Decoder(
    input clk,
    input rst,
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

    always @(*) begin
        case (opcode)
            7'b1100011: begin // beq
                imm32 = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
            end
            7'b0000011, // lw
            7'b0010011: begin // I-type (addi, andi, ori)
                imm32 = {{20{inst[31]}}, inst[31:20]};
            end
            7'b0100011: begin // sw
                imm32 = {{20{inst[31]}}, inst[31:25], inst[11:7]}; 
            end
            
            default: begin
                imm32 = 32'b0; 
            end
        endcase
    end

endmodule