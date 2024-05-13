`timescale 1ns / 1ps
module cpu_top(
    input sys_clk,//系统的时钟
     input rst_in, //复位信号
     input start_pg,//开始编程
     input rx,//接收信号，用来接收串口的数据
    input [3:0] keyboard_row,//键盘的行输入
    output [3:0] keyboard_col,//向键盘发送列信号用来检测哪个按键被按了
    output start_pg_led, //开始编程的指示灯
    output program_off_led, //编程结束的指示灯
    output rst_led, //复位的指示灯
    output uart_write_en_led,//串口写使能的指示灯
    output rx_led,//显示是否接收到数据
    output tx,//串口发送数据
    inout[15:0] gpio_a_out, gpio_b_out, gpio_c_out, //这些是通用输入输出端口，可以配置为输入或输出，用于与外部设备的数据交换。
    inout[4:0] gpio_d_out//另一组通用输入输出端口，功能同上。
);
wire [3:0] gpio_e_out;
wire rst;
wire clk;
wire nvic_clk;//中断控制器的时钟
wire uart_clk;//串口的时钟
wire systick_clk;//系统滴答定时器的时钟
//wire rd_write_en;  控制是否向寄存器堆中的rd写入数据
//wire rt_write_en;  控制是否向寄存器堆中的rt写入数据
wire alu_use;//控制是否使用ALU
wire mem_write_en;//控制是否向内存写入数据
wire io_write_en;//控制是否向外设写入数据
wire is_sw//是否是存储器访问指令
wire io_target//是否是外设目标指令
wire is_usage_fault//是否是使用错误
wire curr_gpio_type//当前的gpio类型
wire[1:0] alu_type;//ALU的类型
wire[4:0] wr;//目标寄存器的编号
wire[4:0] rs1;//源寄存器的编号
wire[4:0] rs2;//第二个源寄存器的编号
wire[4:0] shamt;//移位量
wire[5:0] opcode;//操作码
wire[5:0] fun;//功能码
wire[5:0] gpio_types;//gpio的类型
wire[5:0] exti_en;//外部中断的使能
wire[9:0] io_access_addr;//外设的地址
wire[15:0] immediate;//立即数
wire[31:0]ReadData1,ReadData2,WriteData;// data in register
wire RegWrite//the signal of register
ALU alu(

)
registers reg(
       .clk(clk),
       .rst(rst),
       .rs1(rs1),
       .rs2(rs2),
       .wr(wr),
       .RegWrite(RegWrite),
       .ReadData1(ReadData1),
       .ReadData2(ReadData2),
       .WriteData(WriteData)
)
endmodule