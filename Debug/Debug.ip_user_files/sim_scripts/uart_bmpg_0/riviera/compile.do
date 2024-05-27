vlib work
vlib riviera

vlib riviera/xil_defaultlib

vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xil_defaultlib  -v2k5 \
"../../../../Debug.srcs/sources_1/ip/uart_bmpg_0/uart_bmpg.v" \
"../../../../Debug.srcs/sources_1/ip/uart_bmpg_0/upg.v" \
"../../../../Debug.srcs/sources_1/ip/uart_bmpg_0/sim/uart_bmpg_0.v" \


vlog -work xil_defaultlib \
"glbl.v"

