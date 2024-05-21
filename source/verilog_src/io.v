module io(
    input mRead,
    input mWrite,
    input ioRead,
    input ioWrite,
    input [31:0] addr_in,  // from alu_result 
    input[31:0]Mdata,//data from memory
    input[31:0]Rdata,//data from register files(idecode 32)
    input[15:0]bdata,//data from button
    output[31:0]addr,//address to memory
    output [31:0]r_data,//data to register files
    output reg [31:0]w_data//data to memory or Io
);
    assign addr=addr_in;
    assign r_data=(ioRead==1)?{0,bdata}:Mdata;
    always@* begin
        if((mWrite==1)||(ioWrite==1))begin
            w_data=Rdata;
        end
        else begin
            w_data=32'hffffffff;
        end
    end
endmodule