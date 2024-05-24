`timescale 1ns / 1ps
module cpu_top(
    input clk,
    input rst,//复位信号，低电平有效
    input [23:0] button_in,
    output wire [23:0] led_out
);

   wire clock;
    wire uart_clk;
   //wire [23:0] button_i;
   wire [15:0] button_out;

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
    wire[4:0] rs1;//源寄存器的编号
    wire[4:0] rs2;//第二个源寄存器的编号


    assign funct3 = inst[14:12];
    assign funct7 = inst[31:25];

    
    //wire先不删，可能会用到
    //首先实例化cpuclk
    //再实例化if拿到数据
    //这里可能还需要实例化registers(已经在decoder里面实例化了)
    //然后实例化controller

    clk_wiz_0 cpuclk(
    .clk_in1(clk),
    .clk_out1(clock),
        .clk_out2(uart_clk)
    );

    IFetch ifetch(
        .clk(clock),
        .rst(rst),
        .imm32(imm32),
        .branch(Branch),
        .zero(zero),
        .inst(inst)
    );

    Decoder decoder(
        .clk(clock),
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
        .ram_clk_i(clock),
        .ram_wen_i(MemWrite),
        .ram_adr_i(ALUResult[15:2]),
        .ram_dat_i(ReadData2),
        .ram_dat_o(ram_data),
        
        // UART这部分传入的数据我不确定
        .upg_rst_i(rst),
        .upg_clk_i(clock),
        .upg_wen_i(MemWrite),
        .upg_adr_i(ALUResult[15:2]),
        .upg_dat_i(ReadData2),
        .upg_done_i(1'b1)
    );

    
     wire switchctrl;
     wire ledctrl;
     wire ioread_data;
     io sys_io(
        .mRead(MemRead),
        .mWrite(MemWrite),
        .ioRead(MemtoReg),
        .ioWrite(RegWrite),
        .addr_in(ALUResult),
        .Mdata(ram_data),
        .Rdata(ReadData1),
        .bdata(ioread_data),//data from button(io)
        .addr(ALUResult),
        .r_data(ReadData2),
        .w_data(WriteData),
        .LEDCtrl(ledctrl),
        .SwitchCtrl(switchctrl)
        );
    ioread ioread(
        .reset(rst),
        .ior(MemtoReg),
        .switchctrl(switchctrl),
        .ioread_data(ioread_data),//data to io
        .ioread_data_switch(button_out)//data from button
    );


    button button(
        .clk(clock),
        .rst(rst),
        .switchctrl(switchctrl)
        .button_in(button_in),
        .button_out(button_out)
    );

    leds led24(
    .led_clk(clock),
    .ledrst(rst),
    .ledwrite(RegWrite),
    .ledcs(ledctrl),
    .ledaddr(2'b00),//现在还未知,疑似是switch2N4的一些东西,直接读取拨码开关
    .ledwdata(WriteData[15:0]),
    .ledout(led_out)
    );
    // 跳转j类型或分支类型的PC更新逻辑
    //没想好PC的更新逻辑放在这里妥不妥
    always @(*) begin
        if (Branch) begin
            case (BranchType)
               3'b000: NextPC = zero ? (pc + (imm32 << 1)) : (pc + 4); // beq
                3'b001: NextPC = !zero ? (pc + (imm32 << 1)) : (pc + 4); // bne
                3'b100: NextPC = less ? (pc + (imm32 << 1)) : (pc + 4); // blt
                3'b101: NextPC = !less ? (pc + (imm32 << 1)) : (pc + 4); // bge
                3'b110: NextPC = less ? (pc + (imm32 << 1)) : (pc + 4); // bltu
                3'b111: NextPC = !less ? (pc + (imm32 << 1)) : (pc + 4); // bgeu
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
