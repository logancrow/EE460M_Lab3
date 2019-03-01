`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/28/2019 07:06:20 PM
// Design Name: 
// Module Name: tb_fitbit
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


module tb_fitbit();
reg [1:0] mode;
reg reset;
reg start;
reg clk;
wire sat;
wire an0;
wire an1;
wire an2;
wire an3;
wire dp;
wire [6:0] sseg;
wire clkout;

    fitbit u1 (
    .mode(mode),
    .reset(reset),
    .start(start),
     .clk(clk),
    .sat(sat), 
    .an0(an0),
    .an1(an1), 
    .an2(an2),
    .an3(an3), 
    .dp(dp),
    .sseg(sseg),
    .clkout(clkout)
    );
    
    initial begin
    mode = 2'b00;
    reset = 0;
    start = 0;
    clk = 0;
    #50
    start = 1;
    #500000000
    start = 0;
    reset = 1;
    #100
    reset = 0;
    start = 1;
    #400000000
    start = 0;
    reset = 1;
    end
    
    always #1 clk = ~clk;
    
endmodule
