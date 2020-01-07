//水管位置控制
module Draw_Tubes(
	input clk10,
	input clr,
	input game_end,
	output reg [9:0] tube1_y_pos,
	output reg [9:0] tube2_y_pos,
	output reg [9:0] tube3_y_pos,
	output reg [9:0] tube1_x_pos,
	output reg [9:0] tube2_x_pos,
	output reg [9:0] tube3_x_pos,
	output reg [7:0] score
    );

	wire [6:0] rand;
	reg [9:0] randconv;
	
	random_gen pipe_gen(
		.clk(clk10),
		.out(rand)
	);
	
	always @ (posedge clk10, negedge clr) begin
		if (!clr) begin
			score <= 8'b0;
			tube1_x_pos <= 10'd404;
			tube2_x_pos <= 10'd664;
			tube3_x_pos <= 10'd904;
			tube1_y_pos <= 10'd240;
			tube2_y_pos <= 10'd180;
			tube3_y_pos <= 10'd200;
		end
		else if (~game_end) begin

			randconv <= rand + 10'd150;
			tube1_x_pos <= tube1_x_pos - 10'd5;
			tube2_x_pos <= tube2_x_pos - 10'd5;
			tube3_x_pos <= tube3_x_pos - 10'd5;
			if (tube1_x_pos <= 10'd114) begin
				tube1_x_pos <= 10'd904;
				tube1_y_pos <= randconv;
				score <= score + 8'd1;
			end
			if (tube2_x_pos <= 10'd114) begin
				tube2_x_pos <= 10'd904;
				tube2_y_pos <= randconv;
				score <= score + 8'd1;
			end
			if (tube3_x_pos <= 10'd114) begin
				tube3_x_pos <= 10'd904;
				tube3_y_pos <= randconv;
				score <= score + 8'd1;
			end
		end
	end

endmodule