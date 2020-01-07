module FlappyBird(
	 input CLOCK_50,
    input [1:0] KEY,
    output VGA_HS,
    output VGA_VS,
    output [4:0] VGA_R, 
	 output [5:0] VGA_G, 
	 output [4:0] VGA_B,
	 output [6:0] DIG,
	 output [2:0] SEL
    );
	
	wire [9:0] x;
	wire [9:0] y;
	wire clk10;
	wire [9:0] bird_y_pos;
	wire [9:0] tube1_x_pos;
	wire [9:0] tube1_y_pos;
	wire [9:0] tube2_x_pos;
	wire [9:0] tube2_y_pos;
	wire [9:0] tube3_x_pos;
	wire [9:0] tube3_y_pos;
	wire game_end;
	wire [7:0] score;
	wire bright;
	wire vgaclk;
	wire [10:0]add;
	wire [4:0]re,bl;
	wire [5:0]gr;
	assign VGA_CLK=vgaclk;

	wire isdisplay;
	wire [9:0] drawX,drawY;
	
	bird_rom birdrom(
		.clock(CLOCK_50),
		.address(add),
		.q({bl,gr,re})
	);
	
	VGA_Controller synchGen(
		.clk(vgaclk),
		.clr(KEY[1]),
		.vga_HS(VGA_HS),
		.vga_VS(VGA_VS),
		.X(drawX),
		.Y(drawY),
		.display(isdisplay)
		);
	
	VGA_Bitgen vga_bitgen(
		.clk(vgaclk),
		.bright(isdisplay),
		.x(drawX),
		.y(drawY),
		.bird_y_pos(bird_y_pos),
	   .tube1_x_pos(tube1_x_pos),
		.tube1_y_pos(tube1_y_pos),
		.tube2_x_pos(tube2_x_pos),
		.tube2_y_pos(tube2_y_pos),
		.tube3_x_pos(tube3_x_pos),
		.tube3_y_pos(tube3_y_pos),
		.game_end(game_end),
		.score(score),
		.red(VGA_R),
		.green(VGA_G),
		.blue(VGA_B),
		.add(add),
		.re(re),
		.gr(gr),
		.bl(bl)
		);
		
	VGAFrequency vga_clk(
		.clk(CLOCK_50),
		.VGAclk(vgaclk)
		);
	
	SevenSegScoreDisplay seven_seg_score_display(
		.clk(vgaclk),
		.score(score),
		.sel(SEL),
		.DIG(DIG)
		);
	
	SignalFrequency signalfrequency(
		.clk(CLOCK_50),
		.clk10(clk10)
		);
		
	Draw_Bird draw_bird(
		.clk10(clk10),
		.clr(KEY[1]),
		.game_end(game_end),
		.up(~KEY[0]),
		.down(KEY[0]),
		.bird_y_pos(bird_y_pos)
		);
	
	Draw_Tubes draw_tubes(
		.clk10(clk10),
		.clr(KEY[1]),
		.game_end(game_end),
	   .tube1_x_pos(tube1_x_pos),
		.tube1_y_pos(tube1_y_pos),
		.tube2_x_pos(tube2_x_pos),
		.tube2_y_pos(tube2_y_pos),
		.tube3_x_pos(tube3_x_pos),
		.tube3_y_pos(tube3_y_pos),
		.score(score)
		);
	
	Crash_Detect crash_detect(
		.clr(KEY[1]),
		.bird_y_pos(bird_y_pos),
		.tube1_x_pos(tube1_x_pos),
		.tube1_y_pos(tube1_y_pos),
		.tube2_x_pos(tube2_x_pos),
		.tube2_y_pos(tube2_y_pos),
		.tube3_x_pos(tube3_x_pos),
		.tube3_y_pos(tube3_y_pos),
		.game_end(game_end)
		);
	
endmodule