`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2019 09:39:31 PM
// Design Name: 
// Module Name: fitbit
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


module fitbit(
    input [1:0] mode,
    input reset, start, clk,
    output sat, an0, an1, an2, an3, dp,
    output [6:0] sseg
    );
    
    wire clk1s;
    
    clkdiv1s c0 (clk,clk1s);
    
    wire pulse;
    
    pulsegenerator p0 (mode,clk,reset,start,pulse);
    
    wire [20:0] steps;
    wire [13:0] saturated;
    
    stepcounter s0 (pulse,reset,steps,saturated);
    
    wire [13:0] distance;
    
    distancecovered d0 (steps,distance);
    
    wire [3:0] secondsover32;
    
    stepsover32 s1 (steps,clk1s,reset,secondsover32);
    
    wire [13:0] highactsecs;
    
    highactivity a0 (steps,clk1s,reset,highactsecs);
    
    wire binout;
    
    modulecycler m0 (saturated,distance,highactsecs,secondsover32,clk1s,binout,sat,dp);
    
    wire [3:0] out3, out2, out1, out0;
    
    binconverter b0 (binout,out3,out2,out1,out0);
    
    wire [6:0] sseg3, sseg2, sseg1, sseg0;
    
    hexto7segment h0 (out0,sseg0);
    hexto7segment h1 (out1,sseg1);
    hexto7segment h2 (out2,sseg2);
    hexto7segment h3 (out3,sseg3);
    
    displayLogic d1 (clk,sseg0,sseg1,sseg2,sseg3,an0,an1,an2,an3,sseg);
    
endmodule

//send a hex value, returns seven segment
module hexto7segment(
    input [3:0] x,
    output reg [6:0] r
    );
    always@(*)
        case(x)
            4'b0000 : r = 7'b1000000;
            4'b0001 : r = 7'b1111001;
            4'b0010 : r = 7'b0100100;
            4'b0011 : r = 7'b0110000;
            4'b0100 : r = 7'b0011001;
            4'b0101 : r = 7'b0010010;
            4'b0110 : r = 7'b0000010;
            4'b0111 : r = 7'b1111000;
            4'b1000 : r = 7'b0000000;
            4'b1001 : r = 7'b0010000;
            4'b1010 : r = 7'b0001000;
            4'b1011 : r = 7'b0000011;
            4'b1100 : r = 7'b1000110;
            4'b1101 : r = 7'b0100001;
            4'b1110 : r = 7'b0000110;
            4'b1111 : r = 7'b0001110;
        endcase   
endmodule


//rotates 4 digits on 4 seven segment displays
module displayLogic(
    input clk,
    input [6:0] sseg0, sseg1, sseg2, sseg3,
    output reg an0, an1, an2, an3,
    output reg [6:0] sseg
    );
    reg [1:0] state, next_state;
    initial begin
        state = 2'b00;
    end 
    
    always@(*) begin
    case(state)
        2'b00 : begin {an3, an2, an1, an0} = 4'b1110; next_state = 2'b01; sseg = sseg0; end
        2'b01 : begin {an3, an2, an1, an0} = 4'b1101; next_state = 2'b10; sseg = sseg1; end
        2'b10 : begin {an3, an2, an1, an0} = 4'b1011; next_state = 2'b11; sseg = sseg2; end
        2'b11 : begin {an3, an2, an1, an0} = 4'b0111; next_state = 2'b00; sseg = sseg0; end
        endcase
    end
    
    always@(posedge clk) begin
        state <= next_state;
        end              
endmodule


//generates pulse to send to step counter based on mode
module pulsegenerator(
    input [1:0] mode,
    input clk, reset, start,
    output pulse
    );
  
endmodule

//module that takes input from the pulse generator and outputs step count and saturated step count
module stepcounter(
    input pulse, reset,
    output [20:0] steps,
    output [13:0] saturated
    );

endmodule

//calcualtes distance travelled based on steps (fixed point delta = .1), incriments of 5
module distancecovered(
    input [20:0] steps,
    output [13:0] distance
    );
    
endmodule

//calculates how many of the first 9 seconds had over 32 steps/sec
module stepsover32(
    input [20:0] steps,
    input clk, reset,
    output [3:0] seconds
    );
    
endmodule

//calculates time of high activity (seconds over 64 steps/sec after 1 consecutive minute over 64)
module highactivity(
    input [20:0] steps,
    input clk, reset,
    output [13:0] seconds   
    );
    
endmodule

//cycle output to seven segment between 4 modules every 2 seconds
module modulecycler(
    input [13:0] steps, distance, highactivity,
    input [3:0] over32,
    input clk,
    output [13:0] out, 
    output sat, dp
    );
    
endmodule

//converts binary number to 4 seperate digits
module binconverter(
    input [13:0] in,
    output [3:0] out3, out2, out1, out0
    );
    
endmodule

//divides clock to a 1 second period
module clkdiv1s(
    input clk,
    output clk_out
    );
    
endmodule