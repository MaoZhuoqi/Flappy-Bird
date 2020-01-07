//数码管计分
module SevenSegScoreDisplay(	
	 input clk,
    input [7:0] score,
	 output reg [2:0]sel,
	 output reg [6:0]DIG 
    );
	
	
	wire [6:0] HEX2, HEX1, HEX0;
	reg [3:0] dig_2;
	reg [3:0] dig_1;
	reg [3:0] dig_0;
	
	always @ (posedge clk)
	begin
				dig_2 <= score / 8'd100; // score/100
				dig_1 <= (score / 8'd10) % 8'd10;  // (score/10)%10
				dig_0 <= score % 8'd10; // score%10
	end
	
	reg [9:0] select = 0;
	always@(posedge clk)
	begin
		if(select>=0&select<10'b0010000000) 
		begin
			DIG=HEX0;
			sel=3'b011;
			select=select+1;
		end
		
		if(select>=10'b0010000000&select<10'b0100000000) 
		begin
			DIG=HEX1;
			sel=3'b101;
			select=select+1;
		end
		if(select>=10'b0100000000&select<10'b1000000000) 
		begin
			DIG=HEX2;
			sel=3'b110;
			select=select+1;
		end
		if(select==10'b1000000000) select=0;
		
	end
	
	dec_decoder D0(
					.dec_digit(dig_0),
					.segments(HEX0)
					);
	
				dec_decoder D1(
					.dec_digit(dig_1),
					.segments(HEX1)
					);
	
				dec_decoder D2(
					.dec_digit(dig_2),
					.segments(HEX2)
					);
		
		
		
endmodule

module dec_decoder(dec_digit, segments);
    input [3:0] dec_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (dec_digit)
            4'd0: segments = 7'b1000000;
            4'd1: segments = 7'b1111001;
            4'd2: segments = 7'b0100100;
            4'd3: segments = 7'b0110000;
            4'd4: segments = 7'b0011001;
            4'd5: segments = 7'b0010010;
            4'd6: segments = 7'b0000010;
            4'd7: segments = 7'b1111000;
            4'd8: segments = 7'b0000000;
            4'd9: segments = 7'b0011000;
				default: segments = 7'b0;
        endcase
endmodule