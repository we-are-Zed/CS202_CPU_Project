`timescale 1ns / 1ps
module cpu_top(
    input clk,
    input rst,//复位信号，低电平有效
    input [31:0] inst,
    input [31:0] ReadData1,
    input [31:0] ReadData2,
    input [31:0] imm32,
    output [31:0] ALUResult,
    output zero
);

    wire [31:0] operand2;
    wire [31:0] PC;
    wire [31:0] NextPC;
    wire [1:0] ALUOp;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire ALUSrc;
    wire Branch;
    wire MemRead;
    wire MemtoReg;
    wire MemWrite;
    wire RegWrite;

    assign funct3 = inst[14:12];
    assign funct7 = inst[31:25];

    assign operand2 = (ALUSrc) ? imm32 : ReadData2;

    Controller controller(
        .inst(inst),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .ALUOp(ALUOp)
    );
    ALU alu(
        .ReadData1(ReadData1),
        .ReadData2(ReadData2),
        .imm32(imm32),
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .ALUSrc(ALUSrc),
        .ALUResult(ALUResult),
        .zero(zero)
    );
    PC pc(clk, rst, NextPC, PC);

endmodule