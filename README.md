​                               

# **第一章 绪论**

## **1.1** **选题目的**

​     本项目设计的目的在于提高组员自身对于verilog语言编写的能力提升，同时游戏功能的实现需要对多方面的有理解，每个模块的编写都能提升自身的能力。Flappy Bird作为一款当时风靡全球的游戏，其实现方式也较为简单，代码的编写灵活性也较大，实现方法多样。

## **1.2** **项目构思**

​     项目想实现的功能是在1024*768分辨率下,游戏能基本实现图像的正常显示，能够正常从ROM中读取图片信息并通过VGA进行显示，通过key控制小鸟的飞行，当小鸟飞行碰到障碍物显示死亡，完成通关则显示通关，能够正常显示计分。需要编写合适的图像显示模块、积分模块、碰撞检测模块。



 

# **第二章 FlappyBird游戏设计方案**

## **2.1 FPGA概述**

AX301开发板使用的是 ALERA 公司的 CYCLONE IV 系列 FPGA，型号为 EP4CE6F17C8，256个引脚的FBGA封装。

其中，主要的参数， 逻辑单元 LE：6272； 乘法器 LAB：392； RAM：276480bit； IO数量：179 个； 内核电压：1.15V-1.25V(推荐 1.2V); 工作温度：0-85℃ 图为整个系统的结构示意图：



## **2.2** **VGA输出模块**

### **2.2.1** **模块介绍**

VGA 接口是一种 D 型接口，上面共有 15 针孔，分成三排，每排五个。比较重要的是3根RGB彩色分量信号和2根扫描同步信号HSYNC和VSYNC针。

另外16bit 真彩色显示，可以显示 2^16=65536 种颜色，RGB 分别占的位数为 5：6：5 模式，也就是红色用 5 位、绿色用6 位、蓝色用5 位来表示

### **2.2.3 verilog****代码构造**

```verilog
1.	module VGA_Controller(  
2.	    input clk,  
3.	    input clr,  
4.	    output reg vga_HS,  
5.	    output reg vga_VS,  
6.	    output reg [9:0] X,  
7.	    output reg [9:0] Y,  
8.	    output reg display  
9.	);  
10.	  
11.	   
12.	    parameter H_color_scan=640;  
13.	    parameter H_front_porch=16;  
14.	    parameter H_synch_pulse=96;  
15.	    parameter H_back_porch=48;  
16.	    parameter H_scan_width=800;  
17.	      
18.	   
19.	    parameter V_color_scan=480;  
20.	    parameter V_front_porch=10;  
21.	    parameter V_synch_pulse=2;  
22.	    parameter V_back_porch=33;  
23.	    parameter V_scan_width=525;  
24.	      
25.	  
26.	    reg [9:0] V_pos,H_pos;  
27.	      
28.	  
29.	    always @(posedge clk, negedge clr) begin  
30.	     if (!clr) begin  
31.	        H_pos <= 0;  
32.	        V_pos <= 0;  
33.	        end  
34.	     else begin  
35.	        if(H_pos < H_scan_width) begin  
36.	            H_pos <= H_pos + 1;  
37.	        end else begin   
38.	            H_pos <= 0;  
39.	              
40.	            if(V_pos < V_scan_width) begin  
41.	                V_pos <= V_pos + 1;  
42.	            end else begin  
43.	                V_pos <= 0;  
44.	            end  
45.	              
46.	        end  
47.	          
48.	  
49.	        if(H_pos > H_front_porch && H_pos < (H_front_porch+H_synch_pulse)) begin  
50.	            vga_HS <= 1'b0;  
51.	        end else begin  
52.	            vga_HS <= 1'b1;  
53.	        end  
54.	          
55.	  
56.	        if(V_pos > V_front_porch && V_pos < (V_front_porch+V_synch_pulse)) begin  
57.	            vga_VS <= 1'b0;  
58.	        end else begin  
59.	            vga_VS <= 1'b1;  
60.	        end  
61.	          
62.	  
63.	        if((H_pos > (H_front_porch + H_synch_pulse + H_back_porch))) begin  
64.	                display <= 1'b1;  
65.	                X <= H_pos - (H_front_porch + H_synch_pulse + H_back_porch -1) + 144;  
66.	                Y <= V_pos - (V_front_porch + V_synch_pulse + V_back_porch -1);  
67.	              
68.	        end else begin  
69.	                display <= 1'b0;  
70.	                X <= 0;  
71.	                Y <= 0;  
72.	        end  
73.	        end  
74.	          
75.	    end  
76.	      
77.	endmodule  

```



## **2.3** **Crash_Detect（碰撞检测模块）**

### **2.3.1** **模块介绍**

此模块用于碰撞检测，当检测到像素重合则为碰撞，输出碰撞信号，为之后的模块控制提供判断信号。

### **2.3.2** **原理分析**

通过if语句进行判断，若小鸟所占的像素在水管的像素内则说明发生了碰撞，输出game_end信号。

### **2.3.3 verilog代码构造**

```verilog
1.	module Crash_Detect(  
2.	    input clr,  
3.	    input [9:0] bird_y_pos,  
4.	    input [9:0] tube1_x_pos,  
5.	    input [9:0] tube1_y_pos,  
6.	    input [9:0] tube2_x_pos,  
7.	    input [9:0] tube2_y_pos,  
8.	    input [9:0] tube3_x_pos,  
9.	    input [9:0] tube3_y_pos,  
10.	    output game_end  
11.	    );  
12.	       
13.	    wire crash;  
14.	      
15.	  
16.	    wire [9:0] bird_x_pos;  
17.	    assign bird_x_pos = 10'd180;   
18.	  
19.	    assign crash = (  
20.	        (((bird_y_pos + 10'd15 >= tube1_y_pos + 10'd50) | (bird_y_pos - 10'd15 <= tube1_y_pos - 10'd50)) &  
21.	            ((bird_x_pos + 10'd15 >= tube1_x_pos - 10'd30) & (bird_x_pos - 10'd15 <= tube1_x_pos + 10'd30))) |  
22.	        (((bird_y_pos + 10'd15 >= tube2_y_pos + 10'd50) | (bird_y_pos -10'd15 <= tube2_y_pos - 10'd50)) &  
23.	            ((bird_x_pos + 10'd15 >= tube2_x_pos - 10'd30) & (bird_x_pos - 10'd15 <= tube2_x_pos + 10'd30))) |  
24.	        (((bird_y_pos + 10'd15 >= tube3_y_pos + 10'd50) | (bird_y_pos - 10'd15 <= tube3_y_pos - 10'd50)) &  
25.	            ((bird_x_pos + 10'd15 >= tube3_x_pos - 10'd30) & (bird_x_pos - 10'd15 <= tube3_x_pos + 10'd30)))  
26.	        );  
27.	      
28.	  
29.	    assign game_end =   
30.	        (!clr) ? 0:  
31.	        (crash) ? 1:  
32.	        0;  
33.	  
34.	endmodule  

```



## **2.4** **Draw_Tubes（水管位置生成）模块**

### **2.4.1** **模块介绍**

此模块生成水管的位置信息，包括横坐标和纵坐标。

### **2.4.2** **原理分析**

通过random模块的调用，实现随机初始纵坐标的生成，其横坐标会根据分频时钟的变化而以此向左移动，实现水管的左移。

 

### **2.4.3 verilog代码构造**

```verilog
1.	module Draw_Tubes(  
2.	    input clk10,  
3.	    input clr,  
4.	    input game_end,  
5.	    output reg [9:0] tube1_y_pos,  
6.	    output reg [9:0] tube2_y_pos,  
7.	    output reg [9:0] tube3_y_pos,  
8.	    output reg [9:0] tube1_x_pos,  
9.	    output reg [9:0] tube2_x_pos,  
10.	    output reg [9:0] tube3_x_pos,  
11.	    output reg [7:0] score  
12.	    );  
13.	  
14.	    wire [6:0] rand;  
15.	    reg [9:0] randconv;  
16.	      
17.	    random_gen pipe_gen(  
18.	        .clk(clk10),  
19.	        .out(rand)  
20.	    );  
21.	      
22.	    always @ (posedge clk10, negedge clr) begin  
23.	        if (!clr) begin  
24.	            score <= 8'b0;  
25.	            tube1_x_pos <= 10'd404;  
26.	            tube2_x_pos <= 10'd664;  
27.	            tube3_x_pos <= 10'd904;  
28.	            tube1_y_pos <= 10'd240;  
29.	            tube2_y_pos <= 10'd180;  
30.	            tube3_y_pos <= 10'd200;  
31.	        end  
32.	        else if (~game_end) begin  
33.	  
34.	            randconv <= rand + 10'd150;  
35.	            tube1_x_pos <= tube1_x_pos - 10'd5;  
36.	            tube2_x_pos <= tube2_x_pos - 10'd5;  
37.	            tube3_x_pos <= tube3_x_pos - 10'd5;  
38.	            if (tube1_x_pos <= 10'd114) begin  
39.	                tube1_x_pos <= 10'd904;  
40.	                tube1_y_pos <= randconv;  
41.	                score <= score + 8'd1;  
42.	            end  
43.	            if (tube2_x_pos <= 10'd114) begin  
44.	                tube2_x_pos <= 10'd904;  
45.	                tube2_y_pos <= randconv;  
46.	                score <= score + 8'd1;  
47.	            end  
48.	            if (tube3_x_pos <= 10'd114) begin  
49.	                tube3_x_pos <= 10'd904;  
50.	                tube3_y_pos <= randconv;  
51.	                score <= score + 8'd1;  
52.	            end  
53.	        end  
54.	    end  
55.	  
56.	endmodule  

```



 

## **2.5** **random_gen（随机数生成）模块**

### **2.5.1** **模块介绍**

此模块用于生成一个随机数，用于Draw Tube模块的调用。

### **2.5.2** **原理分析**

Rand初始值为~(20'b0),feed0和feed1通过rand的异或进行赋值，rand又进行左移，feed0和feed1补位，实现随机数的生成。

### **2.5.3 verilog代码构造**

```verilog
1.	module random_gen(  
2.	    input clk,   
3.	    output reg [6:0] out  
4.	    );  
5.	       
6.	     reg [20:0] rand;  
7.	     initial rand = ~(20'b0);  
8.	     reg [20:0] rand_next;  
9.	     wire feed0;  
10.	     wire feed1;  
11.	       
12.	     assign feed0 = rand[20] ^ rand[15];  
13.	     assign feed1 = rand[0] ^ rand [8];   
14.	       
15.	     always @ (posedge clk)  
16.	     begin  
17.	        rand <= rand_next;  
18.	        out = rand[6:0];  
19.	     end  
20.	       
21.	     always @ (*)  
22.	     begin  
23.	        rand_next = {rand[18:0], feed0, feed1};  
24.	     end  
25.	  
26.	endmodule  

```





 

## **2.6 Draw_Bird（鸟位置生成）模块**

### **2.6.1** **模块介绍**

此模块用于Bird的位置信息生成。

### **2.6.2** **原理分析**

Bird的横坐标不需要变化，因此只需对纵坐标进行变换，当检测到按键信息，bird的纵坐标就上移6个像素，否则下降6个像素。

### **2.6.3 verilog代码构造**

```verilog
1.	module Draw_Bird(  
2.	    input clk10,  
3.	    input clr,  
4.	     input game_end,  
5.	    input up,  
6.	     input down,  
7.	    output reg [9:0] bird_y_pos  
8.	    );  
9.	      
10.	       
11.	     always @ (posedge clk10, negedge clr)   
12.	     begin  
13.	        if (!clr)  
14.	            bird_y_pos <= 10'd70;  
15.	        else if (~game_end)   
16.	         begin  
17.	            if ((up == 1) && (bird_y_pos >= 10'd15))  
18.	                bird_y_pos <= bird_y_pos - 10'd6;  
19.	            if ((down == 1) && (bird_y_pos <= 10'd465))  
20.	                bird_y_pos <= bird_y_pos + 10'd6;  
21.	            else if (bird_y_pos >=10'd466)  
22.	                bird_y_pos <= 10'd465;  
23.	            else if (bird_y_pos <=10'd14)  
24.	                bird_y_pos <= 10'd15;  
25.	        end  
26.	     end  
27.	          
28.	endmodule  

```



 

## **2.7 SevenSegScoreDisplay（数码管计分）模块**

### **2.7.1** **模块介绍**

此模块用于在FPGA开发板上实时显示分数情况。

### **2.7.2** **原理分析**  

Score用于读取分数信息，通过计算得到各位数值进行赋值，sel作为数码管选择函数，数码管显示通过动态扫描的方式，再经过段选进行显示。

### **2.7.3 verilog代码构造**

```verilog
1.	module SevenSegScoreDisplay(      
2.	     input clk,  
3.	    input [7:0] score,  
4.	     output reg [2:0]sel,  
5.	     output reg [6:0]DIG   
6.	    );  
7.	      
8.	      
9.	    wire [6:0] HEX2, HEX1, HEX0;  
10.	    reg [3:0] dig_2;  
11.	    reg [3:0] dig_1;  
12.	    reg [3:0] dig_0;  
13.	      
14.	    always @ (posedge clk)  
15.	    begin  
16.	                dig_2 <= score / 8'd100; // score/100  
17.	                dig_1 <= (score / 8'd10) % 8'd10;  // (score/10)%10  
18.	                dig_0 <= score % 8'd10; // score%10  
19.	    end  
20.	      
21.	    reg [9:0] select = 0;  
22.	    always@(posedge clk)  
23.	    begin  
24.	        if(select>=0&select<10'b0010000000)   
25.	        begin  
26.	            DIG=HEX0;  
27.	            sel=3'b011;  
28.	            select=select+1;  
29.	        end  
30.	          
31.	        if(select>=10'b0010000000&select<10'b0100000000)   
32.	        begin  
33.	            DIG=HEX1;  
34.	            sel=3'b101;  
35.	            select=select+1;  
36.	        end  
37.	        if(select>=10'b0100000000&select<10'b1000000000)   
38.	        begin  
39.	            DIG=HEX2;  
40.	            sel=3'b110;  
41.	            select=select+1;  
42.	        end  
43.	        if(select==10'b1000000000) select=0;  
44.	          
45.	    end  
46.	      
47.	    dec_decoder D0(  
48.	                    .dec_digit(dig_0),  
49.	                    .segments(HEX0)  
50.	                    );  
51.	      
52.	                dec_decoder D1(  
53.	                    .dec_digit(dig_1),  
54.	                    .segments(HEX1)  
55.	                    );  
56.	      
57.	                dec_decoder D2(  
58.	                    .dec_digit(dig_2),  
59.	                    .segments(HEX2)  
60.	                    );  
61.	          
62.	          
63.	          
64.	endmodule  
65.	  
66.	module dec_decoder(dec_digit, segments);  
67.	    input [3:0] dec_digit;  
68.	    output reg [6:0] segments;  
69.	     
70.	    always @(*)  
71.	        case (dec_digit)  
72.	            4'd0: segments = 7'b1000000;  
73.	            4'd1: segments = 7'b1111001;  
74.	            4'd2: segments = 7'b0100100;  
75.	            4'd3: segments = 7'b0110000;  
76.	            4'd4: segments = 7'b0011001;  
77.	            4'd5: segments = 7'b0010010;  
78.	            4'd6: segments = 7'b0000010;  
79.	            4'd7: segments = 7'b1111000;  
80.	            4'd8: segments = 7'b0000000;  
81.	            4'd9: segments = 7'b0011000;  
82.	                default: segments = 7'b0;  
83.	        endcase  
84.	endmodule  

```





 

 

## **2.8 VGA_Bitgen（图像显示）模块**

### **2.8.1** **模块介绍**

在屏幕上显示各个图像，包括水管、鸟、背景、死后分数

### **2.8.2** **原理分析**

鸟通过调用BirdRom模块，每个像素读取一位，而显示出图像。

水管通过对对水管位置信息的调用，进行左右扩大，对输出赋值。

背景通过对不同区域的赋值产生不同的颜色。

死亡后分数显示通过读取score的值，计算得出各位数值，调用预设信息，在屏幕上显示分数。

### **2.8.3 verilog代码构造**

```verilog
1.	module VGA_Bitgen(  
2.	     input clk,  
3.	    input bright,  
4.	    input [9:0] x,  
5.	    input [9:0] y,  
6.	     input [9:0] bird_y_pos,  
7.	     input [9:0] tube1_x_pos,  
8.	     input [9:0] tube1_y_pos,  
9.	     input [9:0] tube2_x_pos,  
10.	     input [9:0] tube2_y_pos,  
11.	     input [9:0] tube3_x_pos,  
12.	     input [9:0] tube3_y_pos,  
13.	     input game_end,  
14.	     input [4:0]re,  
15.	     input [5:0]gr,  
16.	     input [4:0]bl,  
17.	     output reg [10:0]add,  
18.	     input [7:0] score,  
19.	    output reg [4:0] red,  
20.	     output reg [5:0] green,  
21.	     output reg [4:0] blue  
22.	    );  
23.	      
24.	  
25.	    wire [9:0] bird_x_pos;  
26.	    assign bird_x_pos = 10'd180;  
27.	      
28.	    reg [5:0] flag=1;  
29.	    reg [5:0] flagy=1;  
30.	    reg [3:0] dig_2;  
31.	    reg [3:0] dig_1;  
32.	    reg [3:0] dig_0;  
33.	    reg Dig0Seg0, Dig0Seg1, Dig0Seg2, Dig0Seg3, Dig0Seg4, Dig0Seg5, Dig0Seg6;  
34.	    reg Dig1Seg0, Dig1Seg1, Dig1Seg2, Dig1Seg3, Dig1Seg4, Dig1Seg5, Dig1Seg6;  
35.	    reg Dig2Seg0, Dig2Seg1, Dig2Seg2, Dig2Seg3, Dig2Seg4, Dig2Seg5, Dig2Seg6;  
36.	    reg digit_display_2, digit_display_1, digit_display_0;  
37.	      
38.	    always @ (posedge clk) begin  
39.	  
40.	        if (~game_end)   
41.	        begin  
42.	            if (~bright)  
43.	            begin  
44.	                red = 5'b0;  
45.	                green = 6'b0;  
46.	                blue = 5'b0;  
47.	            end   
48.	            else if ((x == bird_x_pos - 10'd20+flag)  && (y == bird_y_pos - 10'd20+flagy))  
49.	            begin  
50.	                add=40*(flagy-1)+flag;  
51.	                red = re;  
52.	                green = gr;  
53.	                blue = bl;  
54.	                if(flag<=40)  
55.	                    flag=flag+1;  
56.	                else if(flagy<=40)  
57.	                    begin  
58.	                        flag=0;  
59.	                        flagy=flagy+1;  
60.	                    end  
61.	                else    flagy=0;  
62.	            end   
63.	            else if (  
64.	                ((x >= tube1_x_pos - 10'd30) && (x <= tube1_x_pos + 10'd30) && ((y >= tube1_y_pos + 10'd50) || (y <= tube1_y_pos - 10'd50))) ||   
65.	                ((x >= tube2_x_pos - 10'd30) && (x <= tube2_x_pos + 10'd30) && ((y >= tube2_y_pos + 10'd50) || (y <= tube2_y_pos - 10'd50))) ||   
66.	                ((x >= tube3_x_pos - 10'd30) && (x <= tube3_x_pos + 10'd30) && ((y >= tube3_y_pos + 10'd50) || (y <= tube3_y_pos - 10'd50)))  
67.	                )  
68.	                begin  
69.	                red = 5'b0;  
70.	                green = 6'b111111;//绿色水管  
71.	                blue = 5'b0;   
72.	                end  
73.	            else if (  
74.	                ((x >= tube1_x_pos + 10'd39) && (x <= tube1_x_pos + 10'd80) && ((y >= 10'd30) && (y <= 10'd50))) ||   
75.	                ((x >= tube2_x_pos + 10'd40) && (x <= tube2_x_pos + 10'd93) && ((y >= 10'd30) && (y <= 10'd45))) ||   
76.	                ((x >= tube3_x_pos + 10'd37) && (x <= tube3_x_pos + 10'd85) && ((y >= 10'd12) && (y <= 10'd23)))  
77.	                )  
78.	                begin  
79.	                red = 5'b00011;  
80.	                green = 6'b111111;//白云1  
81.	                blue = 5'b11111;   
82.	                end  
83.	            else if (  
84.	                ((x >= tube1_x_pos + 10'd39) && (x <= tube1_x_pos + 10'd58) && ((y >= 10'd13) && (y <= 10'd30))) ||   
85.	                ((x >= tube2_x_pos + 10'd60) && (x <= tube2_x_pos + 10'd77) && ((y >= 10'd15) && (y <= 10'd30))) ||   
86.	                ((x >= tube3_x_pos + 10'd50) && (x <= tube3_x_pos + 10'd70) && ((y >= 10'd3) && (y <= 10'd12)))  
87.	                )  
88.	                begin  
89.	                red = 5'b00011;  
90.	                green = 6'b111111;//白云2  
91.	                blue = 5'b11111;   
92.	                end  
93.	            else if(y>=400)  
94.	                begin  
95.	                red=5'b01001;  
96.	                green=6'b0;  
97.	                blue=5'b00010;//地面  
98.	                end  
99.	            else  
100.	            begin  
101.	                red = 5'b11111;  
102.	                green = 6'b111111;  
103.	                blue = 5'b11111;//蓝色背景  
104.	                end  
105.	        end  
106.	          
107.	        else begin  
108.	              
109.	            dig_2 = score / 8'd100;  
110.	            dig_1 = (score / 8'd10) % 8'd10;  
111.	            dig_0 = score % 8'd10;  
112.	              
113.	              
114.	            Dig0Seg0 = ((x >= 10'd559) & (x <= 10'd609) & (y >= 10'd160) & (y <= 10'd170));  
115.	            Dig0Seg1 = ((x >= 10'd614) & (x <= 10'd624) & (y >= 10'd160) & (y <= 10'd237));  
116.	            Dig0Seg2 = ((x >= 10'd614) & (x <= 10'd624) & (y >= 10'd243) & (y <= 10'd320));  
117.	            Dig0Seg3 = ((x >= 10'd559) & (x <= 10'd609) & (y >= 10'd310) & (y <= 10'd320));  
118.	            Dig0Seg4 = ((x >= 10'd544) & (x <= 10'd554) & (y >= 10'd243) & (y <= 10'd320));  
119.	            Dig0Seg5 = ((x >= 10'd544) & (x <= 10'd554) & (y >= 10'd160) & (y <= 10'd237));  
120.	            Dig0Seg6 = ((x >= 10'd559) & (x <= 10'd609) & (y >= 10'd235) & (y <= 10'd245));  
121.	  
122.	            Dig1Seg0 = ((x + 10'd120 >= 10'd559) & (x + 10'd120 <= 10'd609) & (y >= 10'd160) & (y <= 10'd170));  
123.	            Dig1Seg1 = ((x + 10'd120 >= 10'd614) & (x + 10'd120 <= 10'd624) & (y >= 10'd160) & (y <= 10'd237));  
124.	            Dig1Seg2 = ((x + 10'd120 >= 10'd614) & (x + 10'd120 <= 10'd624) & (y >= 10'd243) & (y <= 10'd320));  
125.	            Dig1Seg3 = ((x + 10'd120 >= 10'd559) & (x + 10'd120 <= 10'd609) & (y >= 10'd310) & (y <= 10'd320));  
126.	            Dig1Seg4 = ((x + 10'd120 >= 10'd544) & (x + 10'd120 <= 10'd554) & (y >= 10'd243) & (y <= 10'd320));  
127.	            Dig1Seg5 = ((x + 10'd120 >= 10'd544) & (x + 10'd120 <= 10'd554) & (y >= 10'd160) & (y <= 10'd237));  
128.	            Dig1Seg6 = ((x + 10'd120 >= 10'd559) & (x + 10'd120 <= 10'd609) & (y >= 10'd235) & (y <= 10'd245));  
129.	      
130.	            Dig2Seg0 = ((x + 10'd240 >= 10'd559) & (x + 10'd240 <= 10'd609) & (y >= 10'd160) & (y <= 10'd170));  
131.	            Dig2Seg1 = ((x + 10'd240 >= 10'd614) & (x + 10'd240 <= 10'd624) & (y >= 10'd160) & (y <= 10'd237));  
132.	            Dig2Seg2 = ((x + 10'd240 >= 10'd614) & (x + 10'd240 <= 10'd624) & (y >= 10'd243) & (y <= 10'd320));  
133.	            Dig2Seg3 = ((x + 10'd240 >= 10'd559) & (x + 10'd240 <= 10'd609) & (y >= 10'd310) & (y <= 10'd320));  
134.	            Dig2Seg4 = ((x + 10'd240 >= 10'd544) & (x + 10'd240 <= 10'd554) & (y >= 10'd243) & (y <= 10'd320));  
135.	            Dig2Seg5 = ((x + 10'd240 >= 10'd544) & (x + 10'd240 <= 10'd554) & (y >= 10'd160) & (y <= 10'd237));  
136.	            Dig2Seg6 = ((x + 10'd240 >= 10'd559) & (x + 10'd240 <= 10'd609) & (y >= 10'd235) & (y <= 10'd245));  
137.	              
138.	              
139.	            case (dig_2)  
140.	                8'd0: digit_display_2 = (Dig2Seg0 | Dig2Seg1 | Dig2Seg2 | Dig2Seg3 | Dig2Seg4 | Dig2Seg5);  
141.	                8'd1: digit_display_2 = (Dig2Seg1 | Dig2Seg2);  
142.	                8'd2: digit_display_2 = (Dig2Seg0 | Dig2Seg1 | Dig2Seg6 | Dig2Seg4 | Dig2Seg3);  
143.	                8'd3: digit_display_2 = (Dig2Seg0 | Dig2Seg1 | Dig2Seg6 | Dig2Seg2 | Dig2Seg3);  
144.	                8'd4: digit_display_2 = (Dig2Seg5 | Dig2Seg6 | Dig2Seg1 | Dig2Seg2);  
145.	                8'd5: digit_display_2 = (Dig2Seg0 | Dig2Seg5 | Dig2Seg6 | Dig2Seg2 | Dig2Seg3);  
146.	                8'd6: digit_display_2 = (Dig2Seg0 | Dig2Seg5 | Dig2Seg6 | Dig2Seg2 | Dig2Seg3 | Dig2Seg4);  
147.	                8'd7: digit_display_2 = (Dig2Seg0 | Dig2Seg1 | Dig2Seg2);  
148.	                8'd8: digit_display_2 = (Dig2Seg0 | Dig2Seg1 | Dig2Seg2 | Dig2Seg3 | Dig2Seg4 | Dig2Seg5 | Dig2Seg6);  
149.	                8'd9: digit_display_2 = (Dig2Seg0 | Dig2Seg5 | Dig2Seg6 | Dig2Seg1 | Dig2Seg2 | Dig2Seg3);  
150.	                default: digit_display_2 = 1'b0;  
151.	            endcase  
152.	  
153.	            case (dig_1)  
154.	                8'd0: digit_display_1 = (Dig1Seg0 | Dig1Seg1 | Dig1Seg2 | Dig1Seg3 | Dig1Seg4 | Dig1Seg5);  
155.	                8'd1: digit_display_1 = (Dig1Seg1 | Dig1Seg2);  
156.	                8'd2: digit_display_1 = (Dig1Seg0 | Dig1Seg1 | Dig1Seg6 | Dig1Seg4 | Dig1Seg3);  
157.	                8'd3: digit_display_1 = (Dig1Seg0 | Dig1Seg1 | Dig1Seg6 | Dig1Seg2 | Dig1Seg3);  
158.	                8'd4: digit_display_1 = (Dig1Seg5 | Dig1Seg6 | Dig1Seg1 | Dig1Seg2);  
159.	                8'd5: digit_display_1 = (Dig1Seg0 | Dig1Seg5 | Dig1Seg6 | Dig1Seg2 | Dig1Seg3);  
160.	                8'd6: digit_display_1 = (Dig1Seg0 | Dig1Seg5 | Dig1Seg6 | Dig1Seg2 | Dig1Seg3 | Dig1Seg4);  
161.	                8'd7: digit_display_1 = (Dig1Seg0 | Dig1Seg1 | Dig1Seg2);  
162.	                8'd8: digit_display_1 = (Dig1Seg0 | Dig1Seg1 | Dig1Seg2 | Dig1Seg3 | Dig1Seg4 | Dig1Seg5 | Dig1Seg6);  
163.	                8'd9: digit_display_1 = (Dig1Seg0 | Dig1Seg5 | Dig1Seg6 | Dig1Seg1 | Dig1Seg2 | Dig1Seg3);  
164.	                default: digit_display_1 = 1'b0;  
165.	            endcase  
166.	  
167.	            case (dig_0)  
168.	                8'd0: digit_display_0 = (Dig0Seg0 | Dig0Seg1 | Dig0Seg2 | Dig0Seg3 | Dig0Seg4 | Dig0Seg5);  
169.	                8'd1: digit_display_0 = (Dig0Seg1 | Dig0Seg2);  
170.	                8'd2: digit_display_0 = (Dig0Seg0 | Dig0Seg1 | Dig0Seg6 | Dig0Seg4 | Dig0Seg3);  
171.	                8'd3: digit_display_0 = (Dig0Seg0 | Dig0Seg1 | Dig0Seg6 | Dig0Seg2 | Dig0Seg3);  
172.	                8'd4: digit_display_0 = (Dig0Seg5 | Dig0Seg6 | Dig0Seg1 | Dig0Seg2);  
173.	                8'd5: digit_display_0 = (Dig0Seg0 | Dig0Seg5 | Dig0Seg6 | Dig0Seg2 | Dig0Seg3);  
174.	                8'd6: digit_display_0 = (Dig0Seg0 | Dig0Seg5 | Dig0Seg6 | Dig0Seg2 | Dig0Seg3 | Dig0Seg4);  
175.	                8'd7: digit_display_0 = (Dig0Seg0 | Dig0Seg1 | Dig0Seg2);  
176.	                8'd8: digit_display_0 = (Dig0Seg0 | Dig0Seg1 | Dig0Seg2 | Dig0Seg3 | Dig0Seg4 | Dig0Seg5 | Dig0Seg6);  
177.	                8'd9: digit_display_0 = (Dig0Seg0 | Dig0Seg5 | Dig0Seg6 | Dig0Seg1 | Dig0Seg2 | Dig0Seg3);  
178.	                default: digit_display_0 = 1'b0;  
179.	            endcase  
180.	              
181.	          
182.	            if (digit_display_2 | digit_display_1 | digit_display_0)  
183.	            begin  
184.	                  
185.	                red = 8'b11111111;  
186.	                green = 8'b11111111;  
187.	                blue = 8'b11111111;  
188.	            end  
189.	            else  
190.	            begin  
191.	              
192.	                red = 8'b00000000;  
193.	                green = 8'b00000000;  
194.	                blue = 8'b00000000;  
195.	            end   
196.	        end  
197.	    end  
198.	    //死亡后分数显示  
199.	endmodule  

```



## **2.9 SignalFrequency（分频）模块**

### **2.9.1** **模块介绍**

​     分频器模块，将50MHz的频率分频成20Hz的频率，用于按键控制的时钟信号。

### **2.9.2** **原理分析**

  通过计数器，将50MHz频率进行分频。

### **2.9.3 verilog代码构造**

```verilog
1.	module SignalFrequency(  
2.	  
3.	     input clk,  
4.	    output reg clk10  
5.	    );  
6.	       
7.	    reg [22:0] count;  
8.	      
9.	    initial  
10.	    begin  
11.	        count = 0;  
12.	        clk10 = 1;  
13.	    end  
14.	      
15.	    always @ (posedge clk) begin  
16.	        begin  
17.	            count <= count + 1;  
18.	            if (count == 2500000) begin  
19.	                count <= 0;  
20.	                clk10 <= ~clk10;  
21.	            end  
22.	        end  
23.	    end  
24.	   
25.	endmodule  

```

​     

 
