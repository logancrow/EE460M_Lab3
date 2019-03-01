`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/27/2019 12:46:32 AM
// Design Name: 
// Module Name: pulsegenerator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pulsegenerator(
	input [1:0] mode,
	input clk, start,
	output reg pulse,
	output reg clkSec
);

reg [26:0] COUNT = 100000000;
reg [26:0] clkSpeed;
reg [26:0] clkCount;
reg [26:0] i;
reg [9:0] realTime;

	initial begin
		pulse = 1'b0;
		clkSec = 1'b0;
		realTime =0;
		i = 0;
		clkCount = 0;
	end
	
	always @(posedge clk) begin
	   
	   if (start == 1) //only do stuff if start is high
	       begin
	           if(clkCount == 100000000) //everytime the clock reaches the number of cycles that equates to a second in real time, increment real time and set the clock to the first cycle of the new count
	               begin
	               realTime <= realTime + 1;
	               clkCount <= 1;
	               end
	           else clkCount <= clkCount + 1;
	           
	           if(clkCount%50000000 == 0) clkSec <= ~clkSec;
	           
               if ((mode == 2'b11)&&(144 < realTime))   pulse = 1'b0; //if it's in hybrid mode and over 144 seconds, set the pulse to 0
               else //otherwise, toggle pulse when i increments to the value of clkSpeed
                   begin
                       if (i == clkSpeed)
                               begin
                                   i = 1;
                                   pulse = ~pulse;
                               end
                           else
                               begin
                                   i = i+1;
                                   pulse = ~pulse;
                               end
	               end
	       end
	   else //if start is low set pulse to 0 and reset clkCount and realTime
	       begin
	           pulse = 1'b0;
	           clkCount = 0;
	           realTime = 0;
	       end   
	end
	
	always @* begin
	   case(mode)
	       2'b00 : clkSpeed = COUNT/64; //wait for a half pulse at 32steps/sec
	       2'b01 : clkSpeed = COUNT/128; //wait for a half pulse at 64steps/sec
	       2'b10 : clkSpeed = COUNT/256; //wait for a half pulse at 128steps/sec
	       2'b11 : if(realTime == 0) clkSpeed = COUNT/40; //wait for a half pulse at 20steps/sec, occurs during the 1st second
	               else if (realTime == 1) clkSpeed = COUNT/66; //wait for a half pulse at 33steps/sec, occurs during the 2nd second
	               else if (realTime == 2) clkSpeed = COUNT/132; //wait for a half pulse at 66steps/sec, occurs during the 3rd second
	               else if (realTime == 3) clkSpeed = COUNT/54; //wait for a half pulse at 27steps/sec, occurs during the 4th second
	               else if (realTime == 4) clkSpeed = COUNT/140; //wait for a half pulse at 70steps/sec, occurs during the 5th second
	               else if (realTime == 5) clkSpeed = COUNT/60; //wait for a half pulse at 30steps/sec, occurs during the 6th second
	               else if (realTime == 6) clkSpeed = COUNT/38; //wait for a half pulse at 19steps/sec, occurs during the 7th second
	               else if (realTime == 7) clkSpeed = COUNT/60; //wait for a half pulse at 30steps/sec, occurs during the 8th second
	               else if (realTime == 8) clkSpeed = COUNT/66; //wait for a half pulse at 33steps/sec, occurs during the 9th second
	               else if (9 < realTime <= 73) clkSpeed = COUNT/138; //wait for a half pulse at 69steps/sec, occurs between 10-73 seconds
	               else if (73 < realTime <= 79) clkSpeed = COUNT/158; //wait for a half pulse at 79steps/sec, occurs between 74-79 seconds
	               else if (79 < realTime <= 144) clkSpeed = COUNT/248; //wait for a half pulse at 124steps/sec, occurs between 80-144 seconds
	               //else if (144 < realTime) pulse = 1'b0; //no pulse past 145 seconds
	               //else pulse = 1'b0; //no pulse if it doesn't fit one of these time constraints
	      default : pulse = 1'b0; //default setting is no pulse
	   endcase
	end

	
endmodule

// module clkDivSecond( input clk, input reset,
//     output reg clk_out);
 
//     reg [25:0] COUNT;
   
//     always @(posedge clk)
//     begin
//         if (COUNT == 49999999) begin
//         clk_out = ~clk_out;
//         COUNT = 0;
//         end
       
//     else COUNT = COUNT + 1;
//     end
// endmodule