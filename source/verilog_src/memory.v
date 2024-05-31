module memory(
    input ram_clk_i, 
    input ram_wen_i, 
    input [31:0] ram_adr_i, 
    input [31:0] ram_dat_i, 
    output reg [31:0] ram_dat_o, 
    input upg_rst_i, 
    input upg_clk_i, 
    input upg_wen_i, 
    input [13:0] upg_adr_i, 
    input [31:0] upg_dat_i, 
    input upg_done_i,
    //input [2:0] funct3 // 新增用于区分lb和lbu
);
    wire ram_clk = !ram_clk_i;
    wire kickOff = upg_rst_i | (~upg_rst_i & upg_done_i);

    wire [31:0] mem_data;

    RAM RAM (
        .clka (kickOff ? ram_clk : upg_clk_i),
        .wea (kickOff ? ram_wen_i : upg_wen_i),
        .addra (kickOff ? ram_adr_i[15:2] : upg_adr_i),
        .dina (kickOff ? ram_dat_i : upg_dat_i),
        .douta (mem_data)
    );


   always @(*) begin
     //   case (funct3)
       //     3'b000: // lb
         //       ram_dat_o = {{24{mem_data[7]}}, mem_data[7:0]};
           // 3'b100: // lbu
             //   ram_dat_o = {24'b0, mem_data[7:0]};
            //default: 
                ram_dat_o = mem_data;
        //endcase
    end
endmodule
