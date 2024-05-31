module io(
    input mRead,
    input mWrite,
    input ioRead,
    input ioWrite,
    input check,
    input [31:0] addr_in,  // from alu_result 
    input[31:0]Mdata,//data from memory
    input[31:0]Rdata,//data from register files(idecode 32)
    input[15:0]bdata,//data from ioread
    output[31:0]addr,//address to memory
    output [31:0]r_data,//data to register files
    output reg [31:0]w_data,//data to memory or Io
    output LEDlowCtrl, // LED Chip Select
    output LEDmidCtrl, // LED Chip Select
    output LEDhighCtrl, // LED Chip Select
    output SwitchCtrl // Switch Chip Select
);  
    wire check_in;
      wire [7:0] low_addr = addr_in[7:0];
      wire [3:0] mid_addr = addr_in[7:4];
    assign addr=addr_in;
    reg[15:0]iodata;//choose only one bit from board, or 16 bit from bodard
    assign r_data=(ioRead==1)?{16'b0000000000000000,iodata}:Mdata;//if we need to read data from io, then choose the final 16 bits,if
    //the data is from memory,then choose Mdata,
 //   assign LEDCtrl= (ioWrite == 1'b1)?1'b1:1'b0; // led
    assign LEDlowCtrl= (ioWrite == 1'b1&&low_addr==8'h62)?1'b1:1'b0; // led
    assign LEDmidCtrl= (ioWrite == 1'b1&&0)?1'b1:1'b0; // led
    assign LEDhighCtrl= (ioWrite == 1'b1&&low_addr==8'h60)?1'b1:1'b0; // led   
    assign SwitchCtrl= (ioRead == 1'b1&&mid_addr==8'h70)?1'b1:1'b0; //switch 
    assign check=(ioRead && low_addr ==8'h20) ? 1'b1:1'b0;
        always @(*) begin
      if (SwitchCtrl) begin
            iodata = bdata;
        end else if (check_in) begin
            iodata = {15'b0, check};
        end
    end

    always@* begin
        if((mWrite==1)||(ioWrite==1)) begin
                   w_data=Rdata;
              end
        
        else begin
            w_data=32'hzzzzzzzz;
        end
    end
endmodule
