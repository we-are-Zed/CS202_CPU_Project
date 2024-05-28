module vga_ctrl(
    input clk,
    input rst,
    input vga_ctrl,
    input [2:0]data_in,//determine testcase
    output reg [35:0]data_out
);
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            data_out <= {36'b111110_111110_111110_111110_111110_111110};//empty space
        end
        else begin
            case(data_in)
            3'b000: begin data_out <= {36'b011101_001110_011100_011101_111110_000000}; end
            3'b001: begin data_out <= {36'b011101_001110_011100_011101_111110_000001}; end
            3'b010: begin data_out <= {36'b011101_001110_011100_011101_111110_000010}; end
            3'b011: begin data_out <= {36'b011101_001110_011100_011101_111110_000011}; end
            3'b100: begin data_out <= {36'b011101_001110_011100_011101_111110_000100}; end
            3'b101: begin data_out <= {36'b011101_001110_011100_011101_111110_000101}; end
            3'b110: begin data_out <= {36'b011101_001110_011100_011101_111110_000110}; end
            3'b111: begin data_out <= {36'b011101_001110_011100_011101_111110_000111}; end
            endcase
        end

    end
    endmodule