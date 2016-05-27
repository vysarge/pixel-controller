`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Valerie Sarge
// 
// Create Date: 05/27/2016 04:22:11 PM
// Design Name: 
// Module Name: matrix_display
// Project Name: pizel-controller
// Target Devices: 
// Tool Versions: 
// Description: 
//
//     Renders and outputs (VGA) a grid of cells, each a solid color.  Controlled by serial inputs.
//     Display is not updated as data is passed in; rather, the display updates to all changes on posedge update.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module matrix_display #(
    parameter S_WIDTH = 0, //make sure this is consistent with VGA signals!
    parameter S_HEIGHT = 0,
    parameter WIDTH = 0, //number of cells in each direction
    parameter HEIGHT = 0,
    parameter B_S_WIDTH = 0,
    parameter B_S_HEIGHT = 0,
    parameter B_WIDTH = 0,
    parameter B_HEIGHT = 0,
    parameter B_VGA = 0
    )(
    input [(B_VGA*3-1):0] cell_rgb, //input RGB; corresponds to (cell_y, cell_x) in the grid
    input [B_WIDTH-1:0] cell_x, //x coordinate for cell
    input [B_HEIGHT-1:0] cell_y, //y coordinate for cell
    input cell_en, //pulses high to indicate new serial input
    input update, //pulses high to indicate it is time to refresh outputs
    input [B_S_WIDTH-1:0] hcount, //input hcount and vcount
    input [B_S_HEIGHT-1:0] vcount,
    input hsync, //inputs produced by vga module
    input vsync,
    input vclock, //clock
    input blank, //active high
    output reg [(B_VGA*3-1):0] p_rgb, //the output of the current (vcount,hcount) pixel
    output reg p_hsync, //output these to easily keep up with correct delays on these signals
    output reg p_vsync
    );
    
    //rgb portions of output p_rgb
    wire [B_VGA-1:0] p_r;
    wire [B_VGA-1:0] p_g;
    wire [B_VGA-1:0] p_b;
    assign p_r = (hcount >= vcount) ? 4'hF : 4'h0;
    assign p_g = (hcount > (S_WIDTH >> 1)) ? 4'hF : 4'h0;
    assign p_b = (vcount > (S_HEIGHT >> 1)) ? 4'hF : 4'h0;
    
    //receive serial input
    always @(posedge cell_en) begin
        //
    end
    
    //receive update signal
    always @(posedge update) begin
        //
    end
    
    //every pixel
    always @(posedge vclock) begin
        //
        p_hsync <= hsync;
        p_vsync <= vsync;
        
        p_rgb <= blank ? 0 : {p_r, p_g, p_b};
    end
endmodule
