//生成随机数
module random_gen(
	input clk, 
	output reg [6:0] out
    );
	 
	 reg [20:0] rand;
	 initial rand = ~(20'b0);
	 reg [20:0] rand_next;
	 wire feed0;
	 wire feed1;
	 
	 assign feed0 = rand[20] ^ rand[15];
	 assign feed1 = rand[0] ^ rand [8]; 
	 
	 always @ (posedge clk)
	 begin
		rand <= rand_next;
		out = rand[6:0];
	 end
	 
	 always @ (*)
	 begin
		rand_next = {rand[18:0], feed0, feed1};
	 end

endmodule
