module IFetch(
    input clk,
    input rst,
    input Jump,
    input Branch,
    input zero,
    input [2:0] BranchType,
    input [31:0] imm32,
    output reg [31:0] pc,
    output [31:0] inst
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
        if (!rst)
            pc <= 32'h00000000; // Initialize PC to the start address
        else
            pc <= NextPC;
    end

    // Determine the next PC value
    always @(*) begin
        if (Jump) begin
            NextPC = pc + (imm32 << 1); // Jump instruction
        end else if (Branch) begin
            case (BranchType)
                3'b000: NextPC = zero ? (pc + (imm32 << 1)) : (pc + 4); // beq
                3'b001: NextPC = !zero ? (pc + (imm32 << 1)) : (pc + 4); // bne
                3'b100: NextPC = ($signed(pc) < $signed(imm32)) ? (pc + (imm32 << 1)) : (pc + 4); // blt
                3'b101: NextPC = ($signed(pc) >= $signed(imm32)) ? (pc + (imm32 << 1)) : (pc + 4); // bge
                3'b110: NextPC = (pc < imm32) ? (pc + (imm32 << 1)) : (pc + 4); // bltu
                3'b111: NextPC = (pc >= imm32) ? (pc + (imm32 << 1)) : (pc + 4); // bgeu
                default: NextPC = pc + 4;
            endcase
        end else begin
            NextPC = pc + 4; // Default to next sequential instruction
        end
    end

    // Read instruction from instruction memory on the positive edge of the clock
    assign inst = instruction;

endmodule