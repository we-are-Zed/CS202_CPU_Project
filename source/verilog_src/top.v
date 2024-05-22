`timescale 1ns / 1ps
module cpu_top(
    input clk,
    input rst,//复位信号，低电平有效
    input start_pg,rx,
    output tx
   
);

    wire [31:0] PC;
    reg [31:0] NextPC;
    wire [31:0] inst;
    wire [1:0] ALUOp;
    wire [31:0] ReadData1, ReadData2, imm32;
    wire [31:0] ALUResult;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire ALUSrc;
    wire Branch;
    wire MemRead;
    wire MemtoReg;
    wire MemWrite;
    wire RegWrite;
    wire Jump;
    wire zero;
    wire [2:0] BranchType;
    wire less;
    wire [31:0] WriteData;
    wire [31:0] ram_data;

wire[4:0] wr;//目标寄存器的编号
    wire[4:0] rs1;//源寄存器的编�?
    wire[4:0] rs2;//第二个源寄存器的编号


    assign funct3 = inst[14:12];
    assign funct7 = inst[31:25];

    
    //wire先不删，可能会用�?
    //首先实例化cpuclk
    //再实例化if拿到数据
    //这里可能还需要实例化registers(已经在decoder里面实例化了)
    //然后实例化controller
 
   PC pc(
    .clk(clk),
    .rst(rst),
    .NextPC(NextPC),
    .PC(PC)
    );
    IFetch ifetch(
        .clk(clk),
        .rst(rst),
        .imm32(imm32),
        .branch(Branch),
        .zero(zero),
        .inst(inst)
    );
    Decoder decoder(
        .clk(clk),
        .rst(rst),
        .regWrite(RegWrite),
        .inst(inst),
        .writeData(WriteData),
        .rs1Data(ReadData1),
        .rs2Data(ReadData2),
        .imm32(imm32)
    );


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

    memory mem(
        .ram_clk_i(clk),
        .ram_wen_i(MemWrite),
        .ram_adr_i(ALUResult[15:2]),
        .ram_dat_i(ReadData2),
        .ram_dat_o(ram_data),
        
        // UART这部分传入的数据我不确定
        .upg_rst_i(rst),
        .upg_clk_i(clk),
        .upg_wen_i(MemWrite),
        .upg_adr_i(ALUResult[15:2]),
        .upg_dat_i(ReadData2),
        .upg_done_i(1'b1)
    );

    programrom progrom(
    .rom_clk_i(clk),
    .rom_adr_i(PC[15:2]),
    .Instruction_o(inst),

     // UART这部分传入的数据我不确定(同上 相信copilot)
    .upg_rst_i(rst),
    .upg_clk_i(clk),
    .upg_wen_i(MemWrite),
    .upg_adr_i(ALUResult[15:2]),
    .upg_dat_i(ReadData2),
    .upg_done_i(1'b1)

    );

    
   

    // 跳转j类型或分支类型的PC更新逻辑
    //没想好PC的更新�?�辑放在这里妥不�?
    always @(*) begin
        if (Branch) begin
            case (BranchType)
               3'b000: NextPC = zero ? (pc + (imm32 << 1)) : (PC + 4); // beq
                3'b001: NextPC = !zero ? (pc + (imm32 << 1)) : (PC + 4); // bne
                3'b100: NextPC = less ? (pc + (imm32 << 1)) : (PC + 4); // blt
                3'b101: NextPC = !less ? (pc + (imm32 << 1)) : (PC + 4); // bge
                3'b110: NextPC = less ? (pc + (imm32 << 1)) : (PC + 4); // bltu
                3'b111: NextPC = !less ? (pc + (imm32 << 1)) : (PC + 4); // bgeu
                default: NextPC = PC + 4;
            endcase
        end else if (Jump) begin
            NextPC = ALUResult; // 跳转指令（JALR �? JAL�?
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