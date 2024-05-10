`timescale 1ns / 1ps
module cpu_top(
    input sys_clk, rst_in, start_pg, rx,
    input [3:0] keyboard_row,
    output [3:0] keyboard_col,
    output start_pg_led, program_off_led, rst_led, uart_write_en_led, rx_led, tx,
    inout[15:0] gpio_a_out, gpio_b_out, gpio_c_out, 
    inout[4:0] gpio_d_out
);