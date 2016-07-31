`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/05/2016 09:17:09 AM
// Design Name: 
// Module Name: pattern_generator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//
// Beginning on the positive edge of init, outputs a pattern defined by input parameters.
// For any given module, the pattern cannot be changed; this should prevent redundant hardware and
// creation of state.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pattern_generator#(
    parameter WIDTH,
    parameter HEIGHT,
    parameter B_WIDTH,
    parameter B_HEIGHT,
    parameter B_VGA,
    parameter PATTERN
    )(
    input init,
    input fclock, //goes high to indicate that it is time to generate a new frame
    input cclock, //goes high to indicate that 
    output [B_WIDTH-1:0] xout,
    output [B_HEIGHT-1:0] yout,
    output [(B_VGA*3-1):0] rgbout
    );
endmodule
