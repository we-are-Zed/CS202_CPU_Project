module io(
    input mRead,
    input mWrite,
    input ioRead,
    input ioWrite,
    input [31:0] addr_in,  // from alu_result 
    input[31:0]Mdata,//data from memory
    input[31:0]Rdata,//data from register files(idecode 32)
    input[15:0]bdata,//data from ioread
    output[31:0]addr,//address to memory
    output [31:0]r_data,//data to register files
    output reg [31:0]w_data,//data to memory or Io
    output LEDCtrl, // LED Chip Select
    output SwitchCtrl // Switch Chip Select
);
    assign addr=addr_in;
    assign r_data=(ioRead==1)?{16'b0000000000000000,bdata}:Mdata;
    assign LEDCtrl= (ioWrite == 1'b1)?1'b1:1'b0; // led 妯″潡鐨勭墖閫変俊鍙凤紝楂樼數骞虫湁鏁 ; 
    assign SwitchCtrl= (ioRead == 1'b1)?1'b1:1'b0; //switch 妯″潡鐨勭墖閫変俊鍙凤紝楂樼數骞虫湁鏁 ;
    always@* begin
        if((mWrite==1)||(ioWrite==1)) begin
          if(addr_in==32'hFFFFFC60) begin
              w_data={16'b0,bdata};
              end else begin
        
            w_data=Rdata;
            end
        end
        else begin
            w_data=32'hzzzzzzzz;
        end
    end
endmodule
