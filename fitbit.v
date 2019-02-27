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
    wire clk128hz;
    wire dppass;
    
    clkdiv1s c0 (clk,clk1s);
    clkdiv128hz c1 (clk,clk128hz);
    
    wire pulse;
    
    pulsegenerator p0 (mode,clk,clk128hz,clk1s,reset,start,pulse);
    
    wire [20:0] steps;
    wire [13:0] saturated;
    
    stepcounter s0 (pulse,reset,steps,saturated);
    
    wire [13:0] distance;
    
    distancecovered d0 (steps,distance);
    
    wire [3:0] secondsover32;
    
    stepsover32 s1 (steps,clk1s,reset,start,secondsover32);
    
    wire [13:0] highactsecs;
    
    highactivity a0 (steps,clk1s,reset,start,highactsecs);
    
    wire binout;
    
    modulecycler m0 (saturated,distance,highactsecs,secondsover32,clk1s,binout,sat,dppass);
    
    wire [3:0] out3, out2, out1, out0;
    
    binconverter b0 (binout,out3,out2,out1,out0);
    
    wire [6:0] sseg3, sseg2, sseg1, sseg0;
    
    hexto7segment h0 (out0,sseg0);
    hexto7segment h1 (out1,sseg1);
    hexto7segment h2 (out2,sseg2);
    hexto7segment h3 (out3,sseg3);
    
    displayLogic d1 (clk,dppass,sseg0,sseg1,sseg2,sseg3,an0,an1,an2,an3,dp,sseg);
    
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
    input clk, dpin,
    input [6:0] sseg0, sseg1, sseg2, sseg3,
    output reg an0, an1, an2, an3, 
    output dpout,
    output reg [6:0] sseg
    );
    reg [1:0] state, next_state;
    initial begin
        state = 2'b00;
    end 
    
    assign dpout = dpin | an1;
    
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
    input clk, clk128hz, clk1s, reset, start,
    output reg pulse
    );
    
    wire clk64hz, clk32hz;
    
    clkdiv2 c2 (clk128hz,clk64hz);
    clkdiv2 c3 (clk64hz,clk32hz);
    
    reg off;
    
    initial begin
        off = 1'b1;
        pulse = 1'b0;
    end
    
    always@(posedge reset) off <= 1'b1;
    always@(posedge start) off <= 1'b0;
    
    always@(*) begin
        case(mode)
            2'b00 : begin if(!off) pulse <= clk32hz; else pulse = 1'b0; end
            2'b01 : begin if(!off) pulse <= clk64hz; else pulse = 1'b0; end
            2'b10 : begin if(!off) pulse <= clk128hz; else pulse = 1'b0; end
            //need to write code for case 4
        endcase
        
    end
  
endmodule

//module that takes input from the pulse generator and outputs step count and saturated step count
module stepcounter(
    input pulse, reset,
    output reg [20:0] steps,
    output reg [13:0] saturated
    );
    
    initial begin
        steps = 0;
        saturated = 0;
    end
    
    always@(posedge reset) begin 
        steps <= 0; 
        saturated <= 0;
    end
    
    always@(posedge pulse) begin
        steps <= steps + 1;
        if(steps > 9999) 
             saturated <= 9999; 
             else saturated <= steps; 
    end

endmodule

//calcualtes distance travelled based on steps (fixed point delta = .1), incriments of 5
module distancecovered(
    input [20:0] steps,
    output [13:0] distance
    );
    
    reg [2:0] decimal;
    
    initial decimal = 0;
    
    assign distance = (10*(steps/2048)) | decimal;
    
    always@(*) begin
        if((steps % 2048) > 1024) decimal <= 5;
            else decimal <= 0;
    end
endmodule

//calculates how many of the first 9 seconds had over 32 steps/sec
module stepsover32(
    input [20:0] steps,
    input clk, reset, start,
    output reg [3:0] seconds
    );
    
    reg [3:0] counter;
    reg [20:0] prev_steps;
    reg off;
    
    initial begin 
        counter = 0;
        prev_steps = 0;
        seconds = 0;
        off = 1'b1;
    end
    
    always@(posedge reset) begin
        off <= 1'b1;
        counter <= 0;
        prev_steps <= 0;
        seconds <= 0;
    end
    
    always@(posedge start) off <= 1'b0;
    
    always@(posedge clk) begin
        if(!off) begin
            if(counter < 9) begin
                counter <= counter + 1;
                if((steps - prev_steps) > 32) seconds <= seconds + 1;
            end
            prev_steps <= steps;
        end
    end
    
endmodule

//calculates time of high activity (seconds over 64 steps/sec after 1 consecutive minute over 64)
module highactivity(
    input [20:0] steps,
    input clk, reset, start,
    output reg [13:0] seconds   
    );
    
    reg off;
    reg [13:0] counter;
    reg [20:0] prev_steps;
    
    initial begin
        off = 1'b1;
        counter = 0;
        prev_steps = 0;
    end
    
    always@(posedge reset) begin
        off <= 1'b1;
        counter <= 0;
        seconds <= 0;
        prev_steps <= 0;
    end
    
    always@(posedge start) begin
        off <= 1'b0;
    end
    
    always@(posedge clk) begin
        if(!off) begin
            if((steps - prev_steps) > 64) begin
                counter = counter + 1;
                if(counter == 60) seconds  <= seconds + 60;
                if(counter > 60) seconds <= seconds + 1;
            end
            prev_steps <= steps;
        end
    end
    
endmodule

//cycle output to seven segment between 4 modules every 2 seconds
module modulecycler(
    input [13:0] steps, distance, highactivity,
    input [3:0] over32,
    input clk,
    output reg [13:0] out, 
    output reg sat, dp
    );
    
    reg [2:0] counter;
    
    initial begin
        counter  = 0;
    end
    
    always@(*) begin
        case({counter[2],counter[1]})
            2'b00 : begin out <= steps; if(steps == 9999) sat <= 1'b1;  else sat <= 1'b0; dp <= 1'b1; end
            2'b01 : begin out <= distance; dp <= 1'b0; sat <= 1'b0; end
            2'b10 : begin out <= over32; dp <= 1'b1; sat <= 1'b0; end
            2'b11 : begin out <= highactivity; dp <= 1'b1; sat <= 1'b0; end         
        endcase
    end
    
    always@(posedge clk) counter = (counter + 1)%8;
    
endmodule

//converts binary number to 4 seperate digits
module binconverter(
    input [13:0] in,
    output [3:0] out3, 
    inout [3:0] out2, out1, out0
    );
    
    assign out0 = in%10;
    assign out1 = (in%100) - out0;
    assign out2 = (in%1000) - out1 - out0;
    assign out3 = in - out2 - out1 - out0;
    
endmodule

//divides clock to a 1 second period
module clkdiv1s(
    input clk,
    output clk_out
    );
    
endmodule

//divides clock to 128 Hz
module clkdiv128hz(
    input clk,
    output clk_out
    );
    
endmodule

//output clock is half the frequency of the input clock
module clkdiv2(
    input clk,
    output reg clk_out
    );
    initial clk_out = 0;
    
    always@(posedge clk) clk_out = !clk_out;

endmodule