module IFetch(
    input clk,
    input rst,
    input [31:0] imm32,
    input branch,
    input zero,
    output [31:0] inst
);

    reg [31:0] pc;
    wire [31:0] pc_next;
    wire [31:0] instruction;
    wire [13:0] addra;

    programrom program_rom_inst (
        .rom_clk_i(clk),
        .rom_adr_i(addra),
        .Instruction_o(instruction),
        .upg_rst_i(upg_rst_i),
        .upg_clk_i(upg_clk_i),
        .upg_wen_i(upg_wen_i),
        .upg_adr_i(upg_adr_i),
        .upg_dat_i(upg_dat_i),
        .upg_done_i(upg_done_i)
    );

    // 地址是PC值的低14位，忽略最低2位（因为PC值是4的倍数）
    assign addra = pc[15:2];

    // 在负边沿更新PC值
    always @(negedge clk) begin
        if (!rst)
            pc <= 32'h00000000; // 同步复位，低电平有效
        else
            pc <= pc_next;
    end

    // PC更新逻辑
    assign pc_next = (branch && zero) ? (pc + imm32) : (pc + 4);

    // 在正边沿从指令存储中读取指令
    assign inst = instruction;

endmodule