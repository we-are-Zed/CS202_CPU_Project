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
- 寻址空间设计：同“寄存器信息”里所说，x2寄存器作为栈指针地址，因为测试场景1和2都需要向下留出对应位置，所以直接给x2写死为32'h7FFFEFFC。x31作为io模块的基地址，从此地址出发的所有位置偏移均用作特殊的io交互功能。

- 对外设IO的支持：采用MMIO模式，参考lab11课件设计，从32'hFFFFFC00地址开始都为io交互地址。采用轮询方式，额外设计一个check使能信号用作确定测试场景和输入确定。


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

（连接关系图）

子模块说明：

IFetch：内部先实例化prgrom instmem IP核设计，从内存模块拿到指令信息，并在时钟下降沿把下一条pc赋值给pc连线。同时还根据外部输入信号，确定指令的不同类型，进行具体的pc更新。

Decoder：负责寄存器堆的初始化（这里的寄存器采用系统文件自带的寄存器模块）和更新，根据输入的指令到对应的寄存器拿到数据并输出，与此同时，还需要根据具体的控制信号来决定，是否将ALU计算的结果或者内存取出的数据写回寄存器。

Controller：负责解析指令输出控制信号，包括MemRead，IoRead，jump，jrn，lui，auipc等信号，这些信号会送入到其他模块作为逻辑判断条件。

ALU：根据controller模块输入的信号来决定具体如何进行计算，以及根据输入信号来判断第二个数据是用作立即数imm还是第二个寄存器。例如如果jalr信号为1，则结果为当前pc值+4；    operand2 = (ALUSrc) ? imm32 : ReadData2。

memory：用于包装IP核模块RAM，让接口更易于使用，通过地址信号的输入到对应的地址拿到数据并输出。

io：

button：

led：

seg_ctrl:

seg_transform:

top：此模块可以看作是cpu的连接模块，也是coe烧入后程序的主入口。top的输入只包含clk，rst，check，button输入，输出则是led和seg（用作上板展示）。在top中，所有需要被用来连接两个模块的中间线被声明，并且在实例化模块的时候用wire将数据连接。除开在其他模块中被提前实例或包装的模块，top需要实例化系统时钟，ifetch，decoder，controller，alu，memory，io，button，seg，led等所有核心模块。



## 系统上板使用说明





## 自测试说明

| 测试方法 | 测试类型 | 测试用例描述                                                 | 测试结果 | 测试结论                                           |
| -------- | -------- | ------------------------------------------------------------ | -------- | -------------------------------------------------- |
| 仿真     | 集成     | 在RARS里执行测试场景1后统计用到的指令，把这些指令写成一个小汇编样例烧入到vivado中，仿真和RARS进行一一对比 | 通过     | 基础R指令，I指令，Branch指令，lw，sw指令均正常工作 |
| 仿真     | 集成     | 把测试场景2的完整代码去掉输入步骤后，写成一个本地对照组，同样烧入到vivado里，仿真和RARS进行一一对比 | 通过     | jal，jalr，lui指令正常工作，且x2基地址确认无误     |
| 仿真     | 集成     | 把测试场景1中需要用到lb和lbu的部分单独截取，生成coe文件后烧入vivado，单独测试这两个指令能否正确取出结果 | 通过     | load类型能共用，单独取低8位的结果和扩展均正常      |



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
- VGA接口：
