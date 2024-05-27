onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib programrom_opt

do {wave.do}

view wave
view structure
view signals

do {programrom.udo}

run -all

quit -force
