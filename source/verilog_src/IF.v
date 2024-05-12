`timescale 1ns / 1ps

module ifetch(
    input clk, 
    input nvic_clk, 
    input rst,
    input [31:0] result,
    input [8:0] pending_interrupts,
    input is_usage_fault,
    output alu_en,
    output [1:0] alu_type, // 01 R 00 I 10 coproc1
    output [4:0] rs,
    output [4:0] rt,
    output [4:0] rd,
    output [15:0] immediate,
    output [4:0] shamt,
    output [5:0] funct,
    output [5:0] opcode,
    output reg [31:0] return_addr,
    // UART
    input program_off, 
    input uart_clk, 
    input uart_write_en, 
    input [13:0] uart_addr,
    input [31:0] uart_data

);
wire [31:0] instruction;
wire [31:0] target_addr;
endmodule