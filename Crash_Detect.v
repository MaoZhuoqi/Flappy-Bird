//碰撞检测
module Crash_Detect(
    input clr,
    input [9:0] bird_y_pos,
    input [9:0] tube1_x_pos,
    input [9:0] tube1_y_pos,
    input [9:0] tube2_x_pos,
    input [9:0] tube2_y_pos,
    input [9:0] tube3_x_pos,
    input [9:0] tube3_y_pos,
    output game_end
    );
	 
	wire crash;
	

	wire [9:0] bird_x_pos;
	assign bird_x_pos = 10'd180; 

	assign crash = (
		(((bird_y_pos + 10'd15 >= tube1_y_pos + 10'd50) | (bird_y_pos - 10'd15 <= tube1_y_pos - 10'd50)) &
			((bird_x_pos + 10'd15 >= tube1_x_pos - 10'd30) & (bird_x_pos - 10'd15 <= tube1_x_pos + 10'd30))) |
		(((bird_y_pos + 10'd15 >= tube2_y_pos + 10'd50) | (bird_y_pos -10'd15 <= tube2_y_pos - 10'd50)) &
			((bird_x_pos + 10'd15 >= tube2_x_pos - 10'd30) & (bird_x_pos - 10'd15 <= tube2_x_pos + 10'd30))) |
		(((bird_y_pos + 10'd15 >= tube3_y_pos + 10'd50) | (bird_y_pos - 10'd15 <= tube3_y_pos - 10'd50)) &
			((bird_x_pos + 10'd15 >= tube3_x_pos - 10'd30) & (bird_x_pos - 10'd15 <= tube3_x_pos + 10'd30)))
		);
	

	assign game_end = 
		(!clr) ? 0:
		(crash) ? 1:
		0;

endmodule