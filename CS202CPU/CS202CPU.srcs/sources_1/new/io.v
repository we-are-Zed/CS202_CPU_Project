module io(
    input mRead,
    input mWrite,
    input ioRead,
    input ioWrite,
    input[31:0]Mdata,//data from memory
    input[31:0]Rdata,//data from register files
    input[15:0]kdata,//data from keyboard
    input[15:0]bdata,//data from button
    output[31:0]addr,//address to memory
    output[31:0]r_data,//data to register files
    output[31:0]w_data,//data to memory or Io

);
endmodule