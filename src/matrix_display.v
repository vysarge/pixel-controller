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
    parameter B_S_WIDTH = 0, //bits
    parameter B_S_HEIGHT = 0,
    parameter B_WIDTH = 0,
    parameter B_HEIGHT = 0,
    parameter B_VGA = 0,
    parameter BORDER = 3 //size, in pixels, of the border around the cells.  2*BORDER between colored areas.
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
    input [(B_VGA*3-1):0] background, //background rgb
    output reg [(B_VGA*3-1):0] p_rgb, //the output of the current (vcount,hcount) pixel
    output reg p_hsync, //output these to easily keep up with correct delays on these signals
    output reg p_vsync
    );
    
    //cell size parameters
    parameter CELL_WIDTH = S_WIDTH / WIDTH;
    parameter CELL_HEIGHT = S_HEIGHT / HEIGHT;
    parameter MAX_X = CELL_WIDTH * WIDTH;
    parameter MAX_Y = CELL_HEIGHT * HEIGHT;
    
    //for loop
    integer i;
    
    //stored color values for grid cells
    reg [(B_VGA*3-1):0] grid [B_WIDTH+B_HEIGHT:0]; //cells that are horizontally adjacent are adjacent
                                                   //vertically adjacent cells are separated by WIDTH
    reg [(B_VGA*3-1):0] display_grid [B_WIDTH+B_HEIGHT:0]; //grid currently displayed
    
    //test values
    wire [B_VGA-1:0] p_r;
    wire [B_VGA-1:0] p_g;
    wire [B_VGA-1:0] p_b;
    assign p_r = (hcount >= vcount) ? 4'hF : 4'h0;
    assign p_g = (hcount > (S_WIDTH >> 1)) ? 4'hF : 4'h0;
    assign p_b = (vcount > (S_HEIGHT >> 1)) ? 4'hF : 4'h0;
    
    //keeping track of which cell
    reg [B_WIDTH-1:0] xcount; //current cell positions
    reg [B_HEIGHT-1:0] ycount;
    //don't want to have to deal with division latency, so keep track of hcount and vcount
    //then increment registers above when appropriate
    reg [B_S_WIDTH-1:0] floor_hcount;
    reg [B_S_HEIGHT-1:0] floor_vcount;
    
    //receive serial input
    always @(posedge cell_en) begin
        //replace grid cell
        grid[cell_y*WIDTH + cell_x] <= cell_rgb;
    end
    
    //receive update signal
    always @(posedge update) begin
        //when told to update, do so
        for (i = 0; i < WIDTH*HEIGHT; i = i + 1) begin
            display_grid[i] <= grid[i];
        end
    end
    
    //every pixel
    always @(posedge vclock) begin
        if (hcount == 0 && vcount == 0) begin //new frame
            //reset trackers
            xcount <= 0;
            ycount <= 0;
            floor_hcount <= 0;
            floor_vcount <= 0;
        end
        else if (hcount == MAX_X) begin //update ycount at the end of each line; 
            if ((vcount-floor_vcount) == CELL_HEIGHT-1) begin //update ycount
                ycount <= ycount + 1;
                floor_vcount <= floor_vcount + CELL_HEIGHT;
            end
        end
        else if (hcount == 0) begin
            xcount <= 0; //reset xcount and floor_hcount for the new line
            floor_hcount <= 0;
        end
        else if (hcount < MAX_X) begin //standard increment
            if ((hcount-floor_hcount) >= CELL_WIDTH-1) begin //if the next pixel will be in the next cell, update xcount
                xcount <= xcount + 1;
                floor_hcount <= floor_hcount + CELL_WIDTH;
            end
        end
        //pipelining outputs
        p_hsync <= hsync;
        p_vsync <= vsync;
        
        //if on the edges of a pixel
        if (blank || hcount >= MAX_X || vcount >= MAX_Y) begin //if out of grid
            p_rgb <= 0; //display black
        end
        else if (hcount == 0 || (vcount - floor_vcount < BORDER || floor_vcount + CELL_HEIGHT - vcount < BORDER) || 
            (hcount - floor_hcount < BORDER || floor_hcount + CELL_WIDTH - hcount < BORDER)) begin
            p_rgb <= background; //display the background color
        end
        else begin //otherwise (if within a pixel)
            p_rgb <= display_grid[ycount*WIDTH+xcount]; //display current cell color
        end
        
    end
endmodule
