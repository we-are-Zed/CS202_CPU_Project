`timescale 1ns / 1ps
module cpu_top(
    input clk,
    input rst,//复位信号，低电平有效
    // uart part
    input start_pg,rx,
    output tx
    //input [31:0] inst,
    //input [31:0] ReadData1,
    //input [31:0] ReadData2,
    //input [31:0] imm32,
    //output [31:0] ALUResult,
    //output zero,
    //output less
);

    wire [31:0] operand2;
    wire [31:0] PC;
    reg [31:0] NextPC;
    wire [1:0] ALUOp;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire ALUSrc;
    wire Branch;
    wire MemRead;
    wire MemtoReg;
    wire MemWrite;
    wire RegWrite;
    wire Jump;
    wire [2:0] BranchType;

    assign funct3 = inst[14:12];
    assign funct7 = inst[31:25];

    assign operand2 = (ALUSrc) ? imm32 : ReadData2;
    
    //wire先不删，可能会用到
    //首先实例化cpuclk
    //再实例化if拿到数据
    //这里可能还需要实例化registers
    //然后实例化controller
    Controller controller(
        .inst(inst),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .ALUOp(ALUOp),
        .Jump(Jump),
        .BranchType(BranchType)
    );
    ALU alu(
        .ReadData1(ReadData1),
        .ReadData2(ReadData2),
        .imm32(imm32),
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .BranchType(BranchType),
        .Jump(Jump),
        .ALUSrc(ALUSrc),
        .ALUResult(ALUResult),
        .zero(zero),
        .less(less)
    );
    wire[31:0]ReadDataone,ReadDatatwo,WriteData;
    wire[4:0] wr;//目标寄存器的编号
    wire[4:0] rs1;//源寄存器的编号
    wire[4:0] rs2;//第二个源寄存器的编号
    registers regi(
       .clk(clk),
       .rst(rst),
       .rs1(rs1),
       .rs2(rs2),
       .wr(wr),
       .RegWrite(RegWrite),
       .ReadData1(ReadDataone),
       .ReadData2(ReadDatatwo),
       .WriteData(WriteData)
);
    PC pc(clk, rst, NextPC, PC);

    // 跳转j类型或分支类型的PC更新逻辑
    //没想好PC的更新逻辑放在这里妥不妥
    always @(*) begin
        if (Branch) begin
            case (BranchType)
                3'b000: if (zero) NextPC = PC + (imm32 << 1); // beq
                3'b001: if (!zero) NextPC = PC + (imm32 << 1); // bne
                3'b100: if (less) NextPC = PC + (imm32 << 1); // blt
                3'b101: if (!less) NextPC = PC + (imm32 << 1); // bge
                3'b110: if (less) NextPC = PC + (imm32 << 1); // bltu
                3'b111: if (!less) NextPC = PC + (imm32 << 1); // bgeu
                default: NextPC = PC + 4;
            endcase
        end else if (Jump) begin
            NextPC = ALUResult; // 跳转指令（JALR 或 JAL）
        end else begin
            NextPC = PC + 4;
        end
    end
    //Part for uart 
    // UART Programmer Pinouts
    wire upg_clk, upg_clk_o;
    wire upg_wen_o; //Uart write out enable
    wire upg_done_o; //Uart rx data have done
    //data to which memory unit of program_rom/dmemory32
    wire [14:0] upg_adr_o;
    //data to program_rom or dmemory32
    wire [31:0] upg_dat_o;

endmodule