`timescale 1ns / 1ps

module PC(clk,rst,NextPC,PC);
    input clk;
    input rst;
    input [31:0] NextPC;
    output reg[31:0] PC;
    
    always @(posedge clk or negedge rst)
    begin
        if(!rst)
            PC <= 32'b0;
        else
            PC <= NextPC;
    end
endmodule