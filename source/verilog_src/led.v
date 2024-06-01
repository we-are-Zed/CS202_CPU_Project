`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module leds (
    input			ledrst,		// reset, active high (澶嶄綅淇″彿,楂樼數骞虫湁鏁?)
    input			led_clk,	// clk for led (鏃堕挓淇″彿)
    input			ledwrite,	// led write enable, active high (鍐欎俊鍙?,楂樼數骞虫湁鏁?)
    input			ledlow,		// 1 means the leds are selected as output 
    input			ledmid,		// 1 means the leds are selected as output 
    input			ledhigh,		// 1 means the leds are selected as output 
    //input	[1:0]	ledaddr,	// 2'b00 means updata the low 16bits of ledout, 2'b10 means updata the high 8 bits of ledout
    input	[15:0]	ledwdata,	// the data (from register/memorio)  waiting for to be writen to the leds of the board
    output reg [23:0]	ledout		// the data writen to the leds  of the board
);
  
    
    always @ (negedge led_clk or posedge ledrst) begin
        if (!ledrst)
            ledout <= 24'h000000;
		else if (ledlow||ledmid || ledhigh) begin
			if (ledlow )
				ledout[23:0] <= { ledout[23:16], ledwdata[15:0] };
			else if (ledmid )
				ledout[23:0] <= { ledout[23:16],ledwdata[7:0], ledout[7:0] };
			else if(ledhigh)
				ledout[23:0] <= {ledwdata[7:0], ledout[15:0] };
        end else begin
            ledout <= ledout;
        end
    end
	
endmodule
