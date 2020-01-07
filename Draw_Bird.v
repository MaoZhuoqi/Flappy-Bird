//bird位置控制
module Draw_Bird(
    input clk10,
    input clr,
	 input game_end,
    input up,
	 input down,
    output reg [9:0] bird_y_pos
    );
	
	 
	 always @ (posedge clk10, negedge clr) 
	 begin
		if (!clr)
			bird_y_pos <= 10'd70;
		else if (~game_end) 
		 begin
			if ((up == 1) && (bird_y_pos >= 10'd15))
				bird_y_pos <= bird_y_pos - 10'd6;
			if ((down == 1) && (bird_y_pos <= 10'd465))
				bird_y_pos <= bird_y_pos + 10'd6;
			else if (bird_y_pos >=10'd466)
				bird_y_pos <= 10'd465;
			else if (bird_y_pos <=10'd14)
				bird_y_pos <= 10'd15;
		end
	 end
		
endmodule

