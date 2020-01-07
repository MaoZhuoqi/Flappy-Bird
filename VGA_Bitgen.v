//图像生成
module VGA_Bitgen(
	 input clk,
    input bright,
    input [9:0] x,
    input [9:0] y,
	 input [9:0] bird_y_pos,
	 input [9:0] tube1_x_pos,
	 input [9:0] tube1_y_pos,
	 input [9:0] tube2_x_pos,
	 input [9:0] tube2_y_pos,
	 input [9:0] tube3_x_pos,
	 input [9:0] tube3_y_pos,
	 input game_end,
	 input [4:0]re,
	 input [5:0]gr,
	 input [4:0]bl,
	 output reg [10:0]add,
	 input [7:0] score,
    output reg [4:0] red,
	 output reg [5:0] green,
	 output reg [4:0] blue
    );
	

	wire [9:0] bird_x_pos;
	assign bird_x_pos = 10'd180;
	
	reg [5:0] flag=1;
	reg [5:0] flagy=1;
	reg [3:0] dig_2;
	reg [3:0] dig_1;
	reg [3:0] dig_0;
	reg Dig0Seg0, Dig0Seg1, Dig0Seg2, Dig0Seg3, Dig0Seg4, Dig0Seg5, Dig0Seg6;
	reg Dig1Seg0, Dig1Seg1, Dig1Seg2, Dig1Seg3, Dig1Seg4, Dig1Seg5, Dig1Seg6;
	reg Dig2Seg0, Dig2Seg1, Dig2Seg2, Dig2Seg3, Dig2Seg4, Dig2Seg5, Dig2Seg6;
	reg digit_display_2, digit_display_1, digit_display_0;
	
	always @ (posedge clk) begin

		if (~game_end) 
		begin
			if (~bright)
			begin
				red = 5'b0;
				green = 6'b0;
				blue = 5'b0;
			end	
			else if ((x == bird_x_pos - 10'd20+flag)  && (y == bird_y_pos - 10'd20+flagy))
			begin
				add=40*(flagy-1)+flag;
				red = re;
				green = gr;
				blue = bl;
				if(flag<=40)
					flag=flag+1;
				else if(flagy<=38)
					begin
						flag=0;
						flagy=flagy+1;
					end
				else	flagy=0;
			end	
			else if (
				((x >= tube1_x_pos - 10'd30) && (x <= tube1_x_pos + 10'd30) && ((y >= tube1_y_pos + 10'd50) || (y <= tube1_y_pos - 10'd50))) || 
				((x >= tube2_x_pos - 10'd30) && (x <= tube2_x_pos + 10'd30) && ((y >= tube2_y_pos + 10'd50) || (y <= tube2_y_pos - 10'd50))) || 
				((x >= tube3_x_pos - 10'd30) && (x <= tube3_x_pos + 10'd30) && ((y >= tube3_y_pos + 10'd50) || (y <= tube3_y_pos - 10'd50)))
				)
				begin
				red = 5'b0;
				green = 6'b111111;//绿色水管
				blue = 5'b0; 
				end
			else if (
				((x >= tube1_x_pos + 10'd39) && (x <= tube1_x_pos + 10'd80) && ((y >= 10'd30) && (y <= 10'd50))) || 
				((x >= tube2_x_pos + 10'd40) && (x <= tube2_x_pos + 10'd93) && ((y >= 10'd30) && (y <= 10'd45))) || 
				((x >= tube3_x_pos + 10'd37) && (x <= tube3_x_pos + 10'd85) && ((y >= 10'd12) && (y <= 10'd23)))
				)
				begin
				red = 5'b00011;
				green = 6'b111111;//白云1
				blue = 5'b11111; 
				end
			else if (
				((x >= tube1_x_pos + 10'd39) && (x <= tube1_x_pos + 10'd58) && ((y >= 10'd13) && (y <= 10'd30))) || 
				((x >= tube2_x_pos + 10'd60) && (x <= tube2_x_pos + 10'd77) && ((y >= 10'd15) && (y <= 10'd30))) || 
				((x >= tube3_x_pos + 10'd50) && (x <= tube3_x_pos + 10'd70) && ((y >= 10'd3) && (y <= 10'd12)))
				)
				begin
				red = 5'b00011;
				green = 6'b111111;//白云2
				blue = 5'b11111; 
				end
			else if(y>=400)
				begin
				red=5'b01001;
				green=6'b0;
				blue=5'b00010;//地面
				end
			else
			begin
				red = 5'b11111;
				green = 6'b111111;
				blue = 5'b11111;//蓝色背景
				end
		end
		
		else begin
			
			dig_2 = score / 8'd100;
			dig_1 = (score / 8'd10) % 8'd10;
			dig_0 = score % 8'd10;
			
			
			Dig0Seg0 = ((x >= 10'd559) & (x <= 10'd609) & (y >= 10'd160) & (y <= 10'd170));
			Dig0Seg1 = ((x >= 10'd614) & (x <= 10'd624) & (y >= 10'd160) & (y <= 10'd237));
			Dig0Seg2 = ((x >= 10'd614) & (x <= 10'd624) & (y >= 10'd243) & (y <= 10'd320));
			Dig0Seg3 = ((x >= 10'd559) & (x <= 10'd609) & (y >= 10'd310) & (y <= 10'd320));
			Dig0Seg4 = ((x >= 10'd544) & (x <= 10'd554) & (y >= 10'd243) & (y <= 10'd320));
			Dig0Seg5 = ((x >= 10'd544) & (x <= 10'd554) & (y >= 10'd160) & (y <= 10'd237));
			Dig0Seg6 = ((x >= 10'd559) & (x <= 10'd609) & (y >= 10'd235) & (y <= 10'd245));

			Dig1Seg0 = ((x + 10'd120 >= 10'd559) & (x + 10'd120 <= 10'd609) & (y >= 10'd160) & (y <= 10'd170));
			Dig1Seg1 = ((x + 10'd120 >= 10'd614) & (x + 10'd120 <= 10'd624) & (y >= 10'd160) & (y <= 10'd237));
			Dig1Seg2 = ((x + 10'd120 >= 10'd614) & (x + 10'd120 <= 10'd624) & (y >= 10'd243) & (y <= 10'd320));
			Dig1Seg3 = ((x + 10'd120 >= 10'd559) & (x + 10'd120 <= 10'd609) & (y >= 10'd310) & (y <= 10'd320));
			Dig1Seg4 = ((x + 10'd120 >= 10'd544) & (x + 10'd120 <= 10'd554) & (y >= 10'd243) & (y <= 10'd320));
			Dig1Seg5 = ((x + 10'd120 >= 10'd544) & (x + 10'd120 <= 10'd554) & (y >= 10'd160) & (y <= 10'd237));
			Dig1Seg6 = ((x + 10'd120 >= 10'd559) & (x + 10'd120 <= 10'd609) & (y >= 10'd235) & (y <= 10'd245));
	
			Dig2Seg0 = ((x + 10'd240 >= 10'd559) & (x + 10'd240 <= 10'd609) & (y >= 10'd160) & (y <= 10'd170));
			Dig2Seg1 = ((x + 10'd240 >= 10'd614) & (x + 10'd240 <= 10'd624) & (y >= 10'd160) & (y <= 10'd237));
			Dig2Seg2 = ((x + 10'd240 >= 10'd614) & (x + 10'd240 <= 10'd624) & (y >= 10'd243) & (y <= 10'd320));
			Dig2Seg3 = ((x + 10'd240 >= 10'd559) & (x + 10'd240 <= 10'd609) & (y >= 10'd310) & (y <= 10'd320));
			Dig2Seg4 = ((x + 10'd240 >= 10'd544) & (x + 10'd240 <= 10'd554) & (y >= 10'd243) & (y <= 10'd320));
			Dig2Seg5 = ((x + 10'd240 >= 10'd544) & (x + 10'd240 <= 10'd554) & (y >= 10'd160) & (y <= 10'd237));
			Dig2Seg6 = ((x + 10'd240 >= 10'd559) & (x + 10'd240 <= 10'd609) & (y >= 10'd235) & (y <= 10'd245));
			
			
			case (dig_2)
				8'd0: digit_display_2 = (Dig2Seg0 | Dig2Seg1 | Dig2Seg2 | Dig2Seg3 | Dig2Seg4 | Dig2Seg5);
				8'd1: digit_display_2 = (Dig2Seg1 | Dig2Seg2);
				8'd2: digit_display_2 = (Dig2Seg0 | Dig2Seg1 | Dig2Seg6 | Dig2Seg4 | Dig2Seg3);
				8'd3: digit_display_2 = (Dig2Seg0 | Dig2Seg1 | Dig2Seg6 | Dig2Seg2 | Dig2Seg3);
				8'd4: digit_display_2 = (Dig2Seg5 | Dig2Seg6 | Dig2Seg1 | Dig2Seg2);
				8'd5: digit_display_2 = (Dig2Seg0 | Dig2Seg5 | Dig2Seg6 | Dig2Seg2 | Dig2Seg3);
				8'd6: digit_display_2 = (Dig2Seg0 | Dig2Seg5 | Dig2Seg6 | Dig2Seg2 | Dig2Seg3 | Dig2Seg4);
				8'd7: digit_display_2 = (Dig2Seg0 | Dig2Seg1 | Dig2Seg2);
				8'd8: digit_display_2 = (Dig2Seg0 | Dig2Seg1 | Dig2Seg2 | Dig2Seg3 | Dig2Seg4 | Dig2Seg5 | Dig2Seg6);
				8'd9: digit_display_2 = (Dig2Seg0 | Dig2Seg5 | Dig2Seg6 | Dig2Seg1 | Dig2Seg2 | Dig2Seg3);
				default: digit_display_2 = 1'b0;
			endcase

			case (dig_1)
				8'd0: digit_display_1 = (Dig1Seg0 | Dig1Seg1 | Dig1Seg2 | Dig1Seg3 | Dig1Seg4 | Dig1Seg5);
				8'd1: digit_display_1 = (Dig1Seg1 | Dig1Seg2);
				8'd2: digit_display_1 = (Dig1Seg0 | Dig1Seg1 | Dig1Seg6 | Dig1Seg4 | Dig1Seg3);
				8'd3: digit_display_1 = (Dig1Seg0 | Dig1Seg1 | Dig1Seg6 | Dig1Seg2 | Dig1Seg3);
				8'd4: digit_display_1 = (Dig1Seg5 | Dig1Seg6 | Dig1Seg1 | Dig1Seg2);
				8'd5: digit_display_1 = (Dig1Seg0 | Dig1Seg5 | Dig1Seg6 | Dig1Seg2 | Dig1Seg3);
				8'd6: digit_display_1 = (Dig1Seg0 | Dig1Seg5 | Dig1Seg6 | Dig1Seg2 | Dig1Seg3 | Dig1Seg4);
				8'd7: digit_display_1 = (Dig1Seg0 | Dig1Seg1 | Dig1Seg2);
				8'd8: digit_display_1 = (Dig1Seg0 | Dig1Seg1 | Dig1Seg2 | Dig1Seg3 | Dig1Seg4 | Dig1Seg5 | Dig1Seg6);
				8'd9: digit_display_1 = (Dig1Seg0 | Dig1Seg5 | Dig1Seg6 | Dig1Seg1 | Dig1Seg2 | Dig1Seg3);
				default: digit_display_1 = 1'b0;
			endcase

			case (dig_0)
				8'd0: digit_display_0 = (Dig0Seg0 | Dig0Seg1 | Dig0Seg2 | Dig0Seg3 | Dig0Seg4 | Dig0Seg5);
				8'd1: digit_display_0 = (Dig0Seg1 | Dig0Seg2);
				8'd2: digit_display_0 = (Dig0Seg0 | Dig0Seg1 | Dig0Seg6 | Dig0Seg4 | Dig0Seg3);
				8'd3: digit_display_0 = (Dig0Seg0 | Dig0Seg1 | Dig0Seg6 | Dig0Seg2 | Dig0Seg3);
				8'd4: digit_display_0 = (Dig0Seg5 | Dig0Seg6 | Dig0Seg1 | Dig0Seg2);
				8'd5: digit_display_0 = (Dig0Seg0 | Dig0Seg5 | Dig0Seg6 | Dig0Seg2 | Dig0Seg3);
				8'd6: digit_display_0 = (Dig0Seg0 | Dig0Seg5 | Dig0Seg6 | Dig0Seg2 | Dig0Seg3 | Dig0Seg4);
				8'd7: digit_display_0 = (Dig0Seg0 | Dig0Seg1 | Dig0Seg2);
				8'd8: digit_display_0 = (Dig0Seg0 | Dig0Seg1 | Dig0Seg2 | Dig0Seg3 | Dig0Seg4 | Dig0Seg5 | Dig0Seg6);
				8'd9: digit_display_0 = (Dig0Seg0 | Dig0Seg5 | Dig0Seg6 | Dig0Seg1 | Dig0Seg2 | Dig0Seg3);
				default: digit_display_0 = 1'b0;
			endcase
			
		
			if (digit_display_2 | digit_display_1 | digit_display_0)
			begin
				
				red = 8'b11111111;
				green = 8'b11111111;
				blue = 8'b11111111;
			end
			else
			begin
			
				red = 8'b00000000;
				green = 8'b00000000;
				blue = 8'b00000000;
			end	
		end
	end
	//死亡后分数显示
endmodule