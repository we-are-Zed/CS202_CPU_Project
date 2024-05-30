module IFetch(
    input clk,
    input rst,
    input Jump,
    input Jalr, // 新增用于区分 jalr 指令的输入信号
    input Branch,
    input zero,
    input less,
    input [2:0] BranchType,
    input [31:0] imm32,
    input [31:0] rs1, // 新增用于 jalr 的寄存器值
    output reg [31:0] pc,
    output [31:0] inst,
    output reg [31:0] pc_reg
);

    reg [31:0] NextPC;
    wire [31:0] instruction;
    wire [13:0] addra;

    prgrom instmem (
        .clka (clk),
        .wea (1'b0),
        .addra (addra),
        .dina (32'h00000000),
        .douta (instruction)
    );

    // Address is the lower 14 bits of PC value, ignoring the lowest 2 bits (since PC value is a multiple of 4)
    assign addra = pc[15:2];

    // Update PC value on the negative edge of the clock or reset
    always @(negedge clk or negedge rst) begin
        if (!rst) begin
            pc <= 32'h00000000; // Initialize PC to the start address
            pc_reg<=32'h00000000;
            end
        else begin
            pc <= NextPC;
            pc_reg <= pc;
            end
    end

    // Determine the next PC value
    always @(*) begin
        if (Jump) begin
            if (Jalr) begin
                NextPC = (rs1 + imm32) & ~1; // jalr 指令
            end else begin
                NextPC = pc + imm32; // jal 指令
            end
        end else if (Branch) begin
            case (BranchType)
                3'b000: NextPC = zero ? (pc + imm32) : (pc + 4); // beq
                3'b001: NextPC = !zero ? (pc + imm32) : (pc + 4); // bne
                3'b100: NextPC = less ? (pc + imm32) : (pc + 4); // blt
                3'b101: NextPC = (!less || zero) ? (pc + imm32) : (pc + 4); // bge
                3'b110: NextPC = less ? (pc + imm32) : (pc + 4); // bltu
                3'b111: NextPC = (!less || zero) ? (pc + imm32) : (pc + 4); // bgeu
                default: NextPC = pc + 4;
            endcase
        end else begin
            NextPC = pc + 4; // Default to next sequential instruction
        end
    end

    // Read instruction from instruction memory
    assign inst = instruction;

endmodule

