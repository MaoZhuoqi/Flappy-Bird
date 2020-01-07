//分频成25MHz时钟，用作VGA输出
module VGAFrequency(
	 input clk,
    output VGAclk
    );


pll fre_25M(
	.inclk0(clk),
	.c0(VGAclk)
);
endmodule