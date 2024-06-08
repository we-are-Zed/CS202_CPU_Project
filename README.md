# CS202_CPU_Project
## 开发者说明

|  姓名  |   学号   |            所负责工作             | 贡献比 |
| :----: | :------: | :-------------------------------: | :----: |
|  王卓  | 12210532 | oj模块测试，cpu数据通路完成，文档编写 | 33.3%  |
| 何家阳 |   12213023   |    完成汇编测试场景1和2，bonus指令测试场景编写    | 33.3%  |
| 杨若谷 |   12213043   |   输入模块，硬件部分和ip核设计    | 33.3%  |

## 开发者日志

| 完成内容                        | 日期 |
| ------------------------------- | ---- |
| ALU，Controller模块设计         | 5.14 |
| IFetch，Decoder模块设计         | 5.18 |
| top模块的基本连线               | 5.20 |
| 所有指令bug通过仿真确认完全无误 | 5.30 |
| coe写入fpga板完成测试场景       | 6.1  |

## CPU架构设计说明


### CPU特性

- ISA：使用RISCV指令集架构，包换所有的基本R指令，I指令，B指令，sw，jal，jalr，lui，auipc.具体的使用方式是通过导出RISCV指令并生成为coe文件形式烧入到fpga板，所有的指令机器码将会依次在时钟对应的跳边沿送入对应模块并产生各自的信号，最终在top模块中，各个模块的连线被接上，通过时钟依次执行完每一条指令。
- 寄存器信息：32个32位标准寄存器，除了x2和x31两个特殊寄存器，其他寄存器都被初始化为0，x2被初始化为32'h7FFFEFFC，x31被初始化为32'hFFFFFC00，分别用于栈指针和io地址。
- 异常处理：本cpu是一个单周期cpu，几乎不存在指令执行异常的情况，只要汇编指令编写逻辑正确，在硬件设计中就不需要特殊的异常检查。
- cpu时钟：设计一个额外的时钟IP核，输入的频率为100MHz，输出的频率为23MHz（参考lab课指导）
- CPI：由于是单周期cpu，一个时钟周期刚好完成一条指令的执行，所以CPI是1.
- 寻址空间设计：同“寄存器信息”里所说，x2寄存器作为栈指针地址，因为测试场景1和2都需要向下留出对应位置，所以直接给x2写死为32'h7FFFEFFC。x31作为io模块的基地址，从此地址出发的所有位置偏移均用作特殊的io交互功能。指令空间和数据空间读写位宽均为 32 bits，读写深度均为 16384。
- 对外设IO的支持：采用MMIO模式，参考lab11课件设计，从32'hFFFFFC00地址开始都为io交互地址。采用轮询方式，额外设计一个check使能信号用作确定测试场景和输入确定，设置一个reset信号进行重置。
- 七段数码管：接受来自IO的数据以及选择信号，用预先设定的形式来决定数据对应显示的数据，显示的数据为测试场景所要求的结果。
- VGA 输出：接受来自 IO 的数据进行输出，通过储存好的字阵选择信号输出对应的字符，输出内容与数码管一致。

### CPU接口
#### LED引脚定义：

| 引脚 | 规格     | 名称         | 功能         |
| ---- | -------- | ------------ | ------------ |
| K17  | `output` | `led_out[23]` | LED 引脚 23  |
| L13  | `output` | `led_out[22]` | LED 引脚 22  |
| M13  | `output` | `led_out[21]` | LED 引脚 21  |
| K14  | `output` | `led_out[20]` | LED 引脚 20  |
| K13  | `output` | `led_out[19]` | LED 引脚 19  |
| M20  | `output` | `led_out[18]` | LED 引脚 18  |
| N20  | `output` | `led_out[17]` | LED 引脚 17  |
| N19  | `output` | `led_out[16]` | LED 引脚 16  |
| M17  | `output` | `led_out[15]` | LED  引脚 15 |
| M16  | `output` | `led_out[14]` | LED 引脚 14  |
| M15  | `output` | `led_out[13]` | LED 引脚 13  |
| K16  | `output` | `led_out[12]` | LED 引脚 12  |
| L16  | `output` | `led_out[11]` | LED 引脚 11  |
| L15  | `output` | `led_out[10]` | LED 引脚 10  |
| L14  | `output` | `led_out[9]`  | LED 引脚 9   |
| J17  | `output` | `led_out[8]`  | LED 引脚 8   |
| F21  | `output` | `led_out[7]`  | LED 引脚 7   |
| G22  | `output` | `led_out[6]`  | LED 引脚 6   |
| G21  | `output` | `led_out[5]`  | LED 引脚 5   |
| D21  | `output` | `led_out[4]`  | LED 引脚 4   |
| E21  | `output` | `led_out[3]`  | LED 引脚 3   |
| D22  | `output` | `led_out[2]`  | LED 引脚 2   |
| E22  | `output` | `led_out[1]`  | LED 引脚 1   |
| A21  | `output` | `led_out[0]`  | LED 引脚 0   |

#### 开关引脚定义：

| 引脚 | 规格    | 名称            | 功能        |
| ---- | ------- | --------------- | ----------- |
| AB6  | `input` | `button_in[15]` | 开关引脚 15 |
| AB7  | `input` | `button_in[14]` | 开关引脚 14 |
| V7   | `input` | `button_in[13]` | 开关引脚 13 |
| AA6  | `input` | `button_in[12]` | 开关引脚 12 |
| Y6   | `input` | `button_in[11]` | 开关引脚 11 |
| T6   | `input` | `button_in[10]` | 开关引脚 10 |
| R6   | `input` | `button_in[9]`  | 开关引脚 9  |
| V5   | `input` | `button_in[8]`  | 开关引脚 8  |
| U6   | `input` | `button_in[7]`  | 开关引脚 7  |
| W5   | `input` | `button_in[6]`  | 开关引脚 6  |
| W6   | `input` | `button_in[5]`  | 开关引脚 5  |
| U5   | `input` | `button_in[4]`  | 开关引脚 4  |
| T5   | `input` | `button_in[3]`  | 开关引脚 3  |
| T4   | `input` | `button_in[2]`  | 开关引脚 2  |
| R4   | `input` | `button_in[1]`  | 开关引脚 1  |
| W4   | `input` | `button_in[0]`  | 开关引脚 0  |

#### 其他引脚定义：

| 引脚 | 规格     | 名称       | 功能      |
| ---- | -------- | ---------- | --------- |
| Y18  | `input`  | `clk` | FPGA 时钟 |
| P2   | `input`  | `check_ww` | check信号  |
| P4   | `input`  | `rst`   | rst信号  |

#### VGA|七段数码管引脚定义

| 引脚 | 规格     | 名称         | 功能                   |
| ---- | -------- | ------------ | ---------------------- |
| H15  | `output` | `v_rgb[11]`  | RGB 引脚 11            |
| J15  | `output` | `v_rgb[10]`  | RGB 引脚 10            |
| G18  | `output` | `v_rgb[9]`   | RGB 引脚 9             |
| G17  | `output` | `v_rgb[8]`   | RGB 引脚 8             |
| H22  | `output` | `v_rgb[7]`   | RGB 引脚 7             |
| J22  | `output` | `v_rgb[6]`   | RGB 引脚 6             |
| H18  | `output` | `v_rgb[5]`   | RGB 引脚 5             |
| H17  | `output` | `v_rgb[4]`   | RGB 引脚 4             |
| K22  | `output` | `v_rgb[3]`   | RGB 引脚 3             |
| K21  | `output` | `v_rgb[2]`   | RGB 引脚2              |
| G20  | `output` | `v_rgb[1]`   | RGB 引脚 1             |
| H20  | `output` | `v_rgb[0]`   | RGB 引脚 0             |
| M21  | `output` | `v_hs`       | 水平同步信号           |
| L21  | `output` | `v_vs`       | 垂直同步信号           |
| C19  | `output` | `seg_en[0]`  | 数码管使能引脚 0       |
| E19  | `output` | `seg_en[1]`  | 数码管使能引脚 1       |
| D19  | `output` | `seg_en[2]`  | 数码管使能引脚 2       |
| F18  | `output` | `seg_en[3]`  | 数码管使能引脚 3       |
| E18  | `output` | `seg_en[4]`  | 数码管使能引脚 4       |
| B20  | `output` | `seg_en[5]`  | 数码管使能引脚 5       |
| A20  | `output` | `seg_en[6]`  | 数码管使能引脚 6       |
| A18  | `output` | `seg_en[7]`  | 数码管使能引脚 7       |
| F15  | `output` | `segment_led[0]` | 数码管输出引脚 0       |
| F13  | `output` | `segment_led[1]` | 数码管输出引脚 1       |
| F14  | `output` | `segment_led[2]` | 数码管输出引脚 2       |
| F16  | `output` | `segment_led[3]` | 数码管输出引脚 3       |
| E17  | `output` | `segment_led[4]` | 数码管输出引脚 4       |
| C14  | `output` | `segment_led[5]` | 数码管输出引脚 5       |
| C15  | `output` | `segment_led[6]` | 数码管输出引脚 6       |
| E13  | `output` | `segment_led[7]` | 数码管输出引脚 7       |



### CPU内部结构


子模块说明：

IFetch：内部先实例化prgrom instmem IP核设计，从内存模块拿到指令信息，并在时钟下降沿把下一条pc赋值给pc连线。同时还根据外部输入信号，确定指令的不同类型，进行具体的pc更新。
| 端口名称          | 功用描述                                     |
| ----------------- | -------------------------------------------- |
| `rst`        |  复位信号                                |
| `clk`        |  时钟信号                                |
| `button_in`       | 16 位开关输入                                |
| `Jump`          | jump指令                             |
| `Jalr`             | 判断jalr（jr）                                  |
| `Branch`             | 分支指令                              |
| `zero`          |用于nextpc的判断                          |
| `less`           | 用于nextpc的判断                           |
| `BranchType`            | 分支类型                       |
| `imm32`            | 立即数                     |
| `rs1`         | 寄存器值                                  |
| `pc`          | pc寄存器                                |
| `inst`            | 从指令内存中读数据                   |
| `pc_reg`         | 存储pc值                                  |

![image](/dd/ifetch.png)


Decoder：负责寄存器堆的初始化（这里的寄存器采用系统文件自带的寄存器模块）和更新，根据输入的指令到对应的寄存器拿到数据并输出，与此同时，还需要根据具体的控制信号来决定，是否将ALU计算的结果或者内存取出的数据写回寄存器。

| 端口名称          | 功用描述                                     |
| ----------------- | -------------------------------------------- |
| `rst`        |  复位信号                                |
| `clk`        |  时钟信号                                |
| `lb`       | 检验lb指令                             |
| `regWrite`          | 是否写入寄存器                          |
| `MemRead`             | 是否读取内存                                 |
| `IoRead`             | 是否从io读取                           |
| `zero`          |用于nextpc的判断                          |
| `inst`           | 指令                         |
| `writeData`            | 写的数据                   |
| `ALUResult`            | ALU的结果                |
| `rs1Data`         | 寄存器1的数据                                  |
| `rs2Data`          | 寄存器2的数据                            |
| `imm32`            | 立即数                 |


![image](/dd/decode.png)

Controller(组合逻辑被综合分散优化，未找到图片)：
负责解析指令输出控制信号，包括MemRead，IoRead，jump，jrn，lui，auipc等信号，这些信号会送入到其他模块作为逻辑判断条件。
| 端口名称          | 功用描述                                     |
| ----------------- | -------------------------------------------- |
| `inst`        |  指令                            |
| `ALUResult`        |  ALU的结果                               |
| `Branch`       | 判断是否是branch                          |
| `ALUSrc`          | 判断从哪拿数据                      |
| `MemorIOtoReg`             | 是否去向寄存器                               |
| `MemRead`             | 是否读内存                          |
| `MemWrite`          |是否写内存                          |
| `IoRead`           | 是否从io中读                       |
| `IoWrite`            | 是否往io写                |
| `RegWrite  `            | 是否写寄存器               |
| `ALUOp`         | ALUop的值                                  |
| `Jump`          | 是否jump                            |
| `jrn  `            | 判断是不是JALR            |
| `lui`          |判断是否是lui                          |
| `auipc`           | 判断是否是auipc                        |
| `BranchType  `            |用于branch                   |
| `lb  `            | 判断是否是lb                |


ALU(组合逻辑被综合分散优化，未找到图片)：
根据controller模块输入的信号来决定具体如何进行计算，以及根据输入信号来判断第二个数据是用作立即数imm还是第二个寄存器。例如如果jalr信号为1，则结果为当前pc值+4；    operand2 = (ALUSrc) ? imm32 : ReadData2。
| 端口名称          | 功用描述                                     |
| ----------------- | -------------------------------------------- |
| `ReadData1`        |  读取数据1                              |
| `ReadData2`        |  读取数据2                               |
| `imm32`       | 立即数                          |
| `ALUOp`          | ALUop的值                      |
| `funct3`             | function3的值                               |
| `funct7`             | function7的值                          |
| `BranchType`          |分支类型                          |
| `Jump`           | 判断是否jump                        |
| `jalr`            | 判断是否是jalr                |
| `pc_reg  `            | 存储pc的值               |
| `lui`         | 判断是否是lui                                  |
| `auipc`          | 判断是否是auipc                            |
| `ALUSrc`            | 判断数据来源               |
| `lb`          |判断是否是lb                          |
| `ALUResult`           | alu结果                         |
| `zero  `            |用于branch                   |
| `less  `            | 用于branch                |


memory：用于包装IP核模块RAM，让接口更易于使用，通过地址信号的输入到对应的地址拿到数据并输出。

| 端口名称          | 功用描述                                     |
| ----------------- | -------------------------------------------- |
| `ram_clk_i`        |  时钟信号                               |
| `ram_wen_i`        |       写使能信号                          |
| `ram_adr_i`       | alu的结果地址值                          |
| `ram_dat_i`          | readdata2值                       |
| `ram_dat_o`             | ram的数据值                               |
| `upg_rst_i`             |      uart复位信号                  |
| `upg_clk_i`          |uart时钟信号                       |
| `upg_wen_i`           | uart写使能信号                        |
| `upg_adr_i`            | uart的结果地址值                   |
| `upg_dat_i  `            | uart写数据              |
| `upg_done_i`         | 是否完成                                |



![image](/dd/memory.png)

io：通信模块，用于控制数据与外设的交互，同时将数据传到对应的模块如led，decoder等

| 端口名称          | 功用描述                                     |
| ----------------- | -------------------------------------------- |
| `mRead`        |  是否从内存读                            |
| `mWrite`        |       是否写入内存                        |
| `ioRead`       | 是否从io读                         |
| `ioWrite`          | 是否往io写                    |
| `check`             | 确认输入信号                            |
| `addr_in`             |     从alu的结果来的数据               |
| `Mdata`          |从内存来的数据                      |
| `Rdata`           | 从寄存器堆来的数据                     |
| `bdata`            | 从拨码开关来的数据                 |
| `addr  `            | 去往内存的地址          |
| `r_data`         | 去向寄存器堆的数据                              |
| `w_data`             |      去IO或者内存的数据                |
| `LEDlowCtrl`          |led低位选择信号                       |
| `LEDmidCtrl`           | led中位选择信号                     |
| `LEDhighCtrl`            | led高位选择信号                   |
| `SwitchCtrl  `            | 拨码开关选择信号              |
| `segctrl`         | 七段数码管选择信号                              |


![image](/dd/io.png)

button：16个拨码开关，用于输入

| 端口名称 | 功用描述                 |
| -------- | ------------------------ |
| `clk`    | 时钟信号                 |
| `rst`    | 复位信号                |
| `switchctrl`  | 选择开关的输入 |
| `button_in`  | 拨码开关的输入    |
| `button_out`    | 拨码开关的输出          |

![image](/dd/button.png)

led：24个led灯，用于显示测试场景中需要展示的数据，与lab课件一致

| 端口名称 | 功用描述                 |
| -------- | ------------------------ |
| `led_clk`    | 时钟信号                 |
| `ledrst`    | 复位信号                |
| `ledwrite`  | 写入led |
| `ledlow`  | 选择低16位    |
| `ledmid`    | 选择8-15位            |
| `ledhigh`  | 选择高八位|
| `ledwdata`    | 传入数据               |
| `ledout`  | led的输出信号 |

![image](/dd/leds.png)

segment:将传入的数据转化为七段数码管上对应的显示

| 端口名称 | 功用描述                 |
| -------- | ------------------------ |
| `clk`    | 时钟信号                 |
| `rst`    | 复位信号                |
| `in`  | 输入数据 |
| `segctrl`  | 数码管选择信号    |
| `segment_led`    | 七段数码管段信号                |
| `seg_en`  | 七段数码管使能信号 |

![image](/dd/segment.png)

keydeb:消抖模块，将稳定的信号传给其他的模块

| 端口名称 | 功用描述                 |
| -------- | ------------------------ |
| `clk`    | 时钟输入                 |
| `rst`    | reset信号                |
| `key_i`  | 输入消抖前的按键信号 |
| `key_o`  | 输出消抖后的按键信号     |

![image](/dd/keydeb.png)

top：此模块可以看作是cpu的连接模块，也是coe烧入后程序的主入口。top的输入只包含clk，rst，check，button输入，输出则是led和seg（用作上板展示）。在top中，所有需要被用来连接两个模块的中间线被声明，并且在实例化模块的时候用wire将数据连接。除开在其他模块中被提前实例或包装的模块，top需要实例化系统时钟，ifetch，decoder，controller，alu，memory，io，button，seg，led等所有核心模块。
| 端口名称          | 功用描述                                     |
| ----------------- | -------------------------------------------- |
| `rst1`        | FPGA 复位信号                                |
| `clk`        | FPGA 时钟信号                                |
| `button_in`       | 16 位开关输入                                |
| `check_ww`          | check信号                                   |
| `row`             | 键盘行输入                                   |
| `col`             | 键盘列输出                                   |
| `led_out`          | 23 位 LED 输出                               |
| `v_rgb`           | VGA 红绿蓝色彩输出                           |
| `v_vs`            | VGA 垂直同步信号输出                         |
| `v_hs`            | VGA 水平同步信号输出                         |
| `segment_led`         | 数码管输出                                   |
| `seg_en`          | 数码管使能                                   |

![image](/dd/top.png)



## 系统上板使用说明





## 自测试说明

| 测试方法 | 测试类型 | 测试用例描述                                                 | 测试结果 | 测试结论                                           |
| -------- | -------- | ------------------------------------------------------------ | -------- | -------------------------------------------------- |
| 仿真     | 集成     | 在RARS里执行测试场景1后统计用到的指令，把这些指令写成一个小汇编样例烧入到vivado中，仿真和RARS进行一一对比 | 通过     | 基础R指令，I指令，Branch指令，lw，sw指令均正常工作 |
| 仿真     | 集成     | 把测试场景2的完整代码去掉输入步骤后，写成一个本地对照组，同样烧入到vivado里，仿真和RARS进行一一对比 | 通过     | jal，jalr，lui指令正常工作，且x2基地址确认无误     |
| 仿真     | 集成     | 把测试场景1中需要用到lb和lbu的部分单独截取，生成coe文件后烧入vivado，单独测试这两个指令能否正确取出结果 | 通过     | load类型能共用，单独取低8位的结果和扩展均正常      |

#### .asm文件详细描述

##### 1. 如何实现IO模块，与用户交互

```assembly
start：
 
addi x31,zero, 0XFFFFFC00       # 加载内存地址 
#0x20(x31)为使能信号
#0x70（x31)为右边16个拨码的输入，
#0x60（x31)为右16个led灯输出，
#0x64（x31)为最左八个led灯输出，
#0x30（x31)为数码管输出
#0x74(x31)开始为内存数A
#0x78（x31）为内存数B

begin_1:
    lw s9,0x20(x31)          # 读取使能信号到 x1 (0xFFD0)
    beq s9, x0, begin_1        # 等待使能信号为0

begin_2:
    lw s9, 0x20(x31)          # 再次读取使能信号
    bne s9, x0, begin_2        # 等待使能信号为1
    lw a3, 0x70(x31)          # 从0xFFC8读取测试用例编号到 t1
    sw x0, 0x60(x31)           # 清零LED显示(0xFFC4)
        sw x0,0x64(x31)           # 清零LED显示(0xFFC4)
    sw x0,0x30(x31)		#清零数码管
   add s2,zero,zero
    beq a3, s2, test0_1       # 如果测试用例编号是0，跳转到 test0_1
......
```

如上，我们约定若 `lw` , `sw` 后面跟的地址大于 0xFFFFFC60 表示输出数据到开发板，大于 0xFFFFFC70 表示从开发板读取数据，若小于 0XFFFFFC60 或为 0XFFFFFC74， 0XFFFFFC78则表示实际意义上的 `lw` 与 `sw`。其中 `sw` 到 `x31` 的 0xFFFFFC60 地址表示以二进制输出值到开发板靠右边的 16 个 LED 灯上，亮灯表示 1，不亮表示 0。 `sw` 到 `x31` 的 0xFFFFFC60 地址表示以二进制输出值到开发板左边的 8 个 LED 灯上。 `sw` 到 `x31` 的 0xFFFFFC64 地址表示以二进制输出值到开发板靠右边 16 个 LED 灯上（也就是中间 8 个加上右边 8 个 LED 灯）。

 我们通过轮询的方式等待读入信号，当我们在开发板上输入完数据后，我们需要摁下并松开开发板上指定的按钮，这样，寄存器的 `s9` 的值便会完成 0->1->0 的转变，便可跳出两个循环等待，这是只需要在后面 `lw` 想要的值便能实现用户输入。同时，程序会在下一次轮询是重复循环，继续等待信号完成输入，这样只要用户完成输入后，点击按钮，就可以完成下一次输入 。

##### 2. 如何实现判断测试用例

```assembly
    lw a3, 0x70(x31)          # 从0xFFC8读取测试用例编号到 t1
   add s2,zero,zero
    beq a3, s2, test0_1       # 如果测试用例编号是0，跳转到 test0_1
    addi s2, s2, 1
    beq a3, s2, test1_1       # 如果测试用例编号是1，跳转到 test1_1
    addi s2, s2, 1
    beq a3, s2, test2_1       # 如果测试用例编号是2，跳转到 test2_1
    addi s2, s2, 1
    beq a3, s2, test3_1       # 如果测试用例编号是3，跳转到 test3_1
    addi s2, s2, 1
    beq a3, s2, test4_1       # 如果测试用例编号是4，跳转到 test4_1
    addi s2, s2, 1
    beq a3, s2, test5_1       # 如果测试用例编号是5，跳转到 test5_1
    addi s2, s2, 1
    beq a3, s2, test6_1       # 如果测试用例编号是6，跳转到 test6_1
    addi s2, s2, 1
    beq a3, s2, test7_1       # 如果测试用例编号是7，跳转到 test7_1
```

如上，先将 `s2` 寄存器中的值归零，然后将 `s2` 和 `a3` 中的值比较，若相等，则跳到对应的测试用例的代码；若不相等，则将 `s2` 中的值加一后再与 `a3` 中的值进行再一次比较，如此反复进行直到找到对应的测试用例。

##### 3. 递归实现出栈和入栈

```assembly
test6_1:
    lw s9, 0x20(x31)          
    beq s9, zero, test6_1 

test6_2:
    lw s9, 0x20(x31)         
    bne s9, x0, test6_2    

lw s3,0x70(x31) #input N
sw s3,0x64(x31)
addi s5,zero,1 #save N
addi s2,zero,0 
addi a0,s5,0
loop:

# for each i<N,calculate F(i),and compare N with F(i)

bgt s3,a0,continue    # F(i)<N
j done    #F(i)>=N
continue:
addi a0,s5,0
jal fact
addi s5,s5,1
j loop
done:
sw s2,0x30(x31)
j begin_1

fact:
addi sp, sp,-12 #adjust stack for 2 items
addi s2,s2,1
sw ra, 4(sp) #save the return address
sw a0, 0(sp) #save the argument n
addi t0,zero,2
bge a0,t0,L1
#beq t0, zero, L1 #if n>=2,go to L1
addi a0, zero, 1 #else return 1
addi sp, sp, 12 #pop 2 items off stack
addi s2,s2,1
jr ra #return to caller
L1:
addi a0, a0, -2 #n>=1; argument gets(n-2)
jal fact #call fact with(n-2)
addi t2, a0, 0 #save fact(n-1)
sw t2, 8(sp)
lw a0, 0(sp) #return from jal: restore argument
lw ra, 4(sp) #restore the return address
addi a0, a0, -1 #n>=1; argument gets(n-1)
jal fact #call fact with(n-1)
addi t1, a0, 0 #
lw a0, 0(sp) #return from jal: restore argument
lw ra, 4(sp) #restore the return address
lw t2, 8(sp)
addi s2,s2,1
addi sp, sp, 12 #adjust stack pointer to pop 2 items
add a0, t2, t1 #return FACT(N-2)+fact(n-1)
jr ra #return to the caller

```

如上，`x2(sp)` 是栈空间的指针，每次开辟12位栈空间用于存放新放入的返回地址、入栈参数、以及返回值（也就是累加的结果）。最后出栈的时候恢复返回值，入栈参数和返回地址。不断通过 `jal` 和 `jr ra` 实现入栈和出栈，并且每次入栈和出栈时用于记录入栈和出栈总次数的 `s2` 寄存器的值都会加1，从而实现记录入栈和出栈的总次数。

##### 4. 依次显示入栈（出栈）的参数，每个参数显示停留 2-3 秒（此处以显示入栈参数为例）

```assembly
test7_1:
    lw s9, 0x20(x31)        
    beq s9, zero, test7_1  
test7_2:
    lw s9, 0x20(x31)        
    bne s9, x0, test7_2    

   lw s3,0x70(x31)
       sw s3,0x64(x31)
addi s5,zero,1
addi a0,s5,0

loop7:
bgt s3,a0,continue7
j done7
continue7:
addi a0,s5,0
jal fact7
addi s5,s5,1
j loop7
done7:
j begin_1
fact7:
addi sp, sp,-12 #adjust stack for 2 items
sw ra, 4(sp) #save the return address
sw a0, 0(sp) #save the argument n

sw a0,0x30(x31) #output to seg

li s11,1600
li a7,10000
#delay 2~3s
iniloop1:

addi s11,s11,-1
bne s11,zero,iniloop1
outloop1:
li s11,1600
addi a7,a7,-1
bne a7,zero,iniloop1

addi t0,zero,2
bge a0, t0, L17 #test for n<2
addi a0, zero, 1 #else return 1
addi sp, sp, 12 #pop 2 items off stack
jr ra #return to caller
L17:
addi a0, a0, -2 #n>=1; argument gets(n-2)
jal fact7 #call fact with(n-2)
addi t2, a0, 0 
sw t2, 8(sp)

sw a0,0x30(x31)
li s11,1600
li a7,10000
iniloop:
addi s11,s11,-1
bne s11,zero,iniloop
outloop:
li s11,1600
addi a7,a7,-1
bne a7,zero,iniloop
lw a0, 0(sp) #return from jal: restore argument
lw ra, 4(sp) #restore the return address
addi a0, a0, -1 #n>=1; argument gets(n-1)
jal fact7 #call fact with(n-1)
addi t1, a0, 0 #
lw a0, 0(sp) #return from jal: restore argument
lw ra, 4(sp) #restore the return address
lw t2, 8(sp)
addi sp, sp, 12 #adjust stack pointer to pop 2 items
add a0, t2, t1 #return FACT(N-2)+fact(n-1)
jr ra #return to the caller

```

如上，在每次入栈时将入栈参数输出到开发板的led灯上，然后跳转到延迟循环iniloop,outloop:，在2-3秒后继续进行下一个参数的入栈操作。

##### 5. 实现两个 8bit 有符号数相加和相减，以及进行溢出判断（若溢出将结果取低八位加1并取反）

```assembly
test4_1:
    lw s9, 0x20(x31)          # 读取使能信号
    beq s9, zero, test4_1   # 等待使能信号为0

test4_2:
    lw s9, 0x20(x31)          # 再次读取使能信号
    bne s9, x0, test4_2     # 等待使能信号为1
    lw s3, 0x70(x31)          # 从0xFFC8读取8bit的数a到s3
 wait_input4:
    lw s9, 0x20(x31)          # 读取使能信号
    beq s9, zero, wait_input4   # 等待使能信号为0
test4_3:
    lw s9, 0x20(x31)          # 再次读取使能信号
    bne s9, x0, test4_3     # 等待使能信号为1
    lw s4, 0x70(x31)          # 从0xFFC8读取8bit的数b到s4
test4_4:
    add s6, s3, s4          # 计算a+b
    srli t1, s6, 8           # 取出进位位（第9位）
    andi s6, s6, 0xFF       # 取出低8位的值
    beq t1,zero,ddcal
    add s6, s6, t1          # 将进位位累加到低8位的值
    not s6, s6              # 对结果取反
 ddcal:
    sw s6, 0x30(x31)          # 将结果显示在数码管上
    j begin_1
```

如上，我们直接将两个数相加并取出第九位的值累加到第八位的值上，最后对结果取反即可。
##### 6. 处理浮点数

```assembly
test2_1:
    lw s9, 0x20(x31)            # 读取使能信号
    beq s9, zero, test2_1     # 等待使能信号为0

test2_2:
    lw s9, 0x20(x31)            # 再次读取使能信号
    bne s9, x0, test2_2       # 等待使能信号为1
    lw s3, 0x70(x31)            # 从0xFFC8读取输入的16bit浮点数到s3
    li t5,0x8000
    and t5,s3,t5
      srli t5,t5,15		#符号位
    li t0, 0x7C00             # 加载指数掩码
    and t1, s3, t0            # 取出指数部分
    srli t1, t1, 10            # 将指数右移10位
    li t2, 15                 # 指数基准值15
    sub t1, t1, t2            # 指数减去15
    li t3, 0x03FF             # 取出尾数部分
    and t2, s3, t3
    ori t2, t2, 0x0400         # 尾数加上隐含的1
    sll t2, t2, t1            # 按指数左移
    srli t2, t2, 10           # 取整数部分
    andi t4, s3, 0x03FF       # 检查尾数部分是否为0
    bne t5, zero, negative2   # 如果是负数，跳转到处理负数的分支
    sw t2, 0x30(x31)            # 向下取整（正数情况）
    j begin_1

negative2:
    beq t4, zero, no_increment_negative2 # 如果尾数部分为0，不加1
    addi t2, t2, 1            # 向上取整（负数情况）

no_increment_negative2:
   neg t2,t2
    sw t2, 0x30(x31)            # 将结果显示在数码管上
    j begin_1
```

如上，我们按照编码将浮点数各个部分分别提取并换算成整数，根据正负等情况判断四舍五入或取整的结果。


## 问题及总结

开发过程中遇到的较大问题：

1.本地使用vscode通过RISCV仿真模拟来完成代码主体，但是放到vivado上发现与真实的verilog语法不兼容，尤其是多分支信号的赋值，信号多重赋值导致的冲突等。

2.不应该在基础模块还没完成之前就进行top连线，导致连线途中信号紊乱接错（以及不应该写中文注释，在vscode和vivado来回转换时，中文信号变成了乱码，后期debug的时候对信号的定义不明晰）

3.通过仿真对指令执行debug的时候，不一定要烧最终测试场景的coe，这样会导致仿真文件里要用额外的check信号来模拟io的输入，非常麻烦且效率低下。应该额外准备一份不需要io输入的测试场景1和2的例子，在仿真的时候直接依次把所有指令执行完毕。

思考：

1.jal，jalr，auipc指令计算都需要用到当前pc值，但是pc值的更新是在一个周期内的下降沿，会导致一条指令执行过程中的pc值会有一次变化，导致alu结果变化一次，需要额外信号把当前pc值往前推半个周期，让它的更新与指令的执行同步，即使alu结果变化了一次，变化了之后的结果依然是正确结果。

2.在上升沿写回上一条指令的数据，不会和当前指令的执行产生冲突，由于是单周期cpu，写回时候的上升沿与此同时只在做取指令的操作，不会影响下一条指令的执行结果（同时也深刻的了解到流水线cpu的难点）。

总结：

这次项目经历之后，对cpu构成的理解更加深入，对指令的解析，数据通路构成，软硬件协同的理解比初识这门课时更加系统化理解。

## bonus部分

- lui：在Controller模块里新增一个lui信号作为输出，连接到ALU模块里，若lui信号为1，则ALUResult = imm32，因为设计之初，我们让所有需要对立即数imm进行移位操作的指令都在Decoder模块里对imm的摘取做预处理：以lui为例imm32 = {inst[31:12], 12'b0};这样就无需在ALU模块里进行立即数移位。其余的控制信号和li指令相同。
- auipc：立即数的预处理同lui一样，在decoder模块里就预先进行移位。在ALU模块中，额外需要一个pc_reg信号，将pc信号整体提前半个周期，可以保留当前指令的pc值在后半个周期内正常使用，              ALUResult = pc_reg + imm32。pc_reg的生成需要在ifetch里进行操作，每次时钟下降沿的时候，pc <= NextPC，pc_reg <= pc两者同时保留，pc_reg作为另一个输出信号。
- VGA接口：通过将输入数据转换为字符图案并在VGA屏幕上显示。代码由三个主要模块组成：vga_ctrl、setchar 和 vga。vga_ctrl模块接收32位输入数据，将其转换为8个6位的字符代码；setchar模块根据字符代码生成7列8位的图案数据；vga模块利用这些图案数据生成VGA显示的RGB信号和同步信号（hs和vs）。整体思路是通过数据输入控制字符显示，实现字符在VGA屏幕上的正确显示
- vga

| 端口名称          | 功用描述                                     |
| ----------------- | -------------------------------------------- |
| `rst`        | 复位信号                                |
| `clk`        | 时钟信号                                |
| `vc_data`          | 传入vga的数据                              |
| `rgb`             | 传出的rgb信号                                 |
| `hs`             | 水平同步信号                        |
| `vs`             | 竖直同步信号                           |

 核心代码：
 ```verilog
   always @(posedge clk or posedge rst) begin
        if (!rst) begin
            rgb <= 12'b0;
        end else if (vcount >= UP_BOUND && vcount <= DOWN_BOUND && hcount >= LEFT_BOUND && hcount <= RIGHT_BOUND) begin
            if (vcount >= up_pos && vcount <= down_pos && hcount >= left_pos && hcount <= right_pos) begin
                if (p[hcount-left_pos][vcount-up_pos]) begin
                    rgb <= 12'b1111_1111_1111;
                end else begin
                    rgb <= 12'b0;
                end
            end else begin
                rgb <= 12'b0;
            end
        end else begin
            rgb <= 12'b0;
        end
    end
```
通过检查当前像素位置是否在预定义的绘制区域和图像对象内，并根据图像数据 p 数组的值来决定是否点亮该像素。复位信号确保在系统复位时将 rgb 信号清零。

  ![image](/dd/vga.png)
  
- vga_ctrl
 
| 端口名称          | 功用描述                                     |
| ----------------- | -------------------------------------------- |
| `rst`        | 复位信号                                |
| `clk`        | 时钟信号                                |
| `vga_ctrl`          | vga选择信号                                |
| `data_in`             | 传入的数据                                 |
| `data_out`             | 传出的数据                           |


 核心代码：
 ```verilog
    if(!rst) begin
            data_out <= {48'b111110_111110_111110_111110_111110_111110_111110_111110};//empty space
        end
         else if (!vga_ctrl) begin
                    data_out <= data_out;
                    end
        else begin
            data_out[5:0]    = {2'b00, data_in[3:0]};   // 扩展第0段4位到6位
           data_out[11:6]   = {2'b00, data_in[7:4]};   // 扩展第1段4位到6位
           data_out[17:12]  = {2'b00, data_in[11:8]};  // 扩展第2段4位到6位
           data_out[23:18]  = {2'b00, data_in[15:12]}; // 扩展第3段4位到6位
           data_out[29:24]  = {2'b00, data_in[19:16]}; // 扩展第4段4位到6位
           data_out[35:30]  = {2'b00, data_in[23:20]}; // 扩展第5段4位到6位
           data_out[41:36]  = {2'b00, data_in[27:24]}; // 扩展第6段4位到6位
           data_out[47:42]  = {2'b00, data_in[31:28]}; // 扩展第7段4位到6位
         
        end
```
 将传入的信号进行分隔以及扩展，之后传给vga中
 
  ![image](/dd/vga_ctrl.png)
  
- setchar

  
| 端口名称          | 功用描述                                     |
| ----------------- | -------------------------------------------- |
| `rst`        | 复位信号                                |
| `clk`        | 时钟信号                                |
| `data`          | 传入的选择数据                                 |
| `col0`             | 第0列                                   |
| `col1`             | 第1列                                   |
| `col2`          |第2列                         |
| `col3`           | 第3列                          |
| `col4`            | 第4列                        |
| `col5`            | 第5列                       |
| `col6`         | 第6列                                  |

 核心代码：
 ```verilog
   case (data)  
                6'b00_0000: // "0"
							begin
                    col0 <= 8'b0000_0000;
                    col1 <= 8'b0011_1110;
                    col2 <= 8'b0101_0001;
                    col3 <= 8'b0100_1001;
                    col4 <= 8'b0100_0101;
                    col5 <= 8'b0011_1110;
                    col6 <= 8'b0000_0000;
                end
                6'b00_0001: // "1"
							begin
                    col0 <= 8'b0000_0000;
                    col1 <= 8'b0000_0000;
                    ;
                    col2 <= 8'b0100_0010;
                    col3 <= 8'b0111_1111;
                    col4 <= 8'b0100_0000;
                    col5 <= 8'b0000_0000;
                    ;
                    col6 <= 8'b0000_0000;
                end
```
  之后的代码部分省略
  该部分通过分析传入的数据，来决定对应的vga显示输出（如数字1，字母a等）

  
 ### 项目报告到此结束，感谢！
