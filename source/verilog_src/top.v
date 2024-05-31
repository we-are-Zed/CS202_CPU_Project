module cpu_top(
    input clk,
    input rst,
    input check,
    input [15:0] button_in,
    output wire [23:0] led_out,
    output [7:0] seg_out,
    output ioRead,
    output [31:0] ALUResult,
    output [31:0] inst,
    output [31:0] pc,
    output [31:0] pc_reg,
    output [1:0] ALUOp,
    output [2:0] funct3,
    output [31:0] imm32,
    output clock
);
   //wire alu_tb;
   //assign ALUResult=alu_tb;
   //wire clock;
    wire uart_clk;
   //wire [23:0] button_i;
   wire [15:0] button_out;

    //wire [31:0] pc;
    reg [31:0] NextPC;
    wire [31:0] next_pc_wire;
    //wire [31:0] inst;
    //wire [1:0] ALUOp;
    wire [31:0] ReadData1, ReadData2;
   // wire imm32;
    //wire [31:0] ALUResult;
    //wire [2:0] funct3;
    wire [6:0] funct7;
    wire ALUSrc;
    wire Branch;
    wire MemRead;
    wire MemtoReg;
    wire MemWrite;
    wire RegWrite;
    //wire ioRead;
    wire ioWrite;
    wire Jump;
    wire lui;
    wire auipc;
    wire jalr;
    wire zero;
    wire [2:0] BranchType;
    wire less;
    wire [31:0] ReadData;
    wire [31:0] WriteData;
    wire [31:0] ram_data;
    wire[31:0]r_data;
    wire [31:0]address_io;
wire[4:0] wr;//鐩爣瀵勫瓨鍣ㄧ殑缂栧彿
    wire[4:0] rs1;//婧愬瘎瀛樺櫒鐨勭紪鍙 
    wire[4:0] rs2;//绗簩涓簮瀵勫瓨鍣ㄧ殑缂栧彿


    assign funct3 = inst[14:12];
    assign funct7 = inst[31:25];
    assign next_pc_wire = NextPC;


    clk_wiz_0 cpuclk(
    .clk_in1(clk),
    .clk_out1(clock),
        .clk_out2(uart_clk)
    );

    IFetch ifetch(
        .clk(clock),
        .rst(rst),
        .Jump(Jump),
        .Jalr(jalr),
        .Branch(Branch),
        .zero(zero),
        .less(less),
        .BranchType(BranchType),
        .imm32(imm32),
        .rs1(ReadData1),
        .pc(pc),
        .inst(inst),
        .pc_reg(pc_reg)
    );

    Decoder decoder(
        .clk(clock),
        .rst(rst),
        .regWrite(RegWrite),
        .MemRead(MemRead),
        .IoRead(ioRead),
        .inst(inst),
        .writeData(r_data),
        .ALUResult(ALUResult),
        .rs1Data(ReadData1),
        .rs2Data(ReadData2),
        .imm32(imm32)
    );


    Controller controller(
        .inst(inst),
        .ALUResult(ALUResult),
        .Branch(Branch),
        .ALUSrc(ALUSrc),

        .MemorIOtoReg(MemtoReg),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .IoRead(ioRead),
        .IoWrite(ioWrite),
        .RegWrite(RegWrite),


        .ALUOp(ALUOp),
        .Jump(Jump),
        .jrn(jalr),
        
        .lui(lui),
        .auipc(auipc),
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
        .jalr(jalr),
        .pc_reg(pc_reg),
        .lui(lui),
        .auipc(auipc),
        .ALUSrc(ALUSrc),
        .ALUResult(ALUResult),
        .zero(zero),
        .less(less)
    );

    memory mem(
        .ram_clk_i(clock),
        .ram_wen_i(MemWrite),
        .ram_adr_i(address_io),
        .ram_dat_i(ReadData2),
        .ram_dat_o(ram_data),
        
        // UART杩欓儴鍒嗕紶鍏ョ殑鏁版嵁鎴戜笉纭畾
        .upg_rst_i(rst),
        .upg_clk_i(clock),
        .upg_wen_i(MemWrite),
        .upg_adr_i(ALUResult[15:2]),
        .upg_dat_i(ReadData2),
        .upg_done_i(1'b1),
        .funct3(funct3)
    );

    
     wire switchctrl;
     wire ledctrl;
     wire ioread_data;

     io sys_io(
        .mRead(MemRead),
        .mWrite(MemWrite),
        .ioRead(ioRead),
        .ioWrite(ioWrite),
        .addr_in(ALUResult),
        .Mdata(ram_data),
        .Rdata(ReadData1),
        .bdata(button_out),//data from button(io)
        .addr(address_io),
        .r_data(r_data),
        .w_data(WriteData),
        .LEDCtrl(ledctrl),
        .SwitchCtrl(switchctrl)
        );
  //  ioread ioread(
    //    .reset(rst),
      //  .ior(MemtoReg),
        //.switchctrl(switchctrl),
        //.ioread_data(ioread_data),//data to io
        //.ioread_data_switch(button_out)//data from button
   // );


    button button(
        .clk(clock),
        .rst(rst),
        .switchctrl(switchctrl),
        .button_in(button_in),
        .button_out(button_out)
    );
    wire [15:0]seg_data;
    seg_ctrl seg_ctrl(
        .clk(clock),
        .rst(rst),
        .ctrl(ledctrl),
        .seg_in(WriteData[15:0]),
        .seg_out(seg_data)
    );
    seg_transform seg_transform(
        .seg_in(seg_data),
        .seg_out(seg_out)
    );

    leds led24(
    .led_clk(clock),
    .ledrst(rst),
    .ledwrite(RegWrite),
    .ledcs(ledctrl),
    .ledaddr(2'b00),//鐩存帴鍙栨湯16浣 
    .ledwdata(WriteData[15:0]),
    .ledout(led_out)
    );
   
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


