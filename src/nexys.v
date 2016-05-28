`timescale 1ns / 1ps

//top level test module
module nexys(
   input CLK100MHZ,
   input[15:0] SW, 
   input BTNC, BTNU, BTNL, BTNR, BTND,
   input [7:0] JA, 
   output[3:0] VGA_R, 
   output[3:0] VGA_B, 
   output[3:0] VGA_G,
   output VGA_HS, 
   output VGA_VS, 
   output LED16_B, LED16_G, LED16_R,
   output LED17_B, LED17_G, LED17_R,
   output[15:0] LED,
   output[7:0] SEG,  // segments A-G (0-6), DP (7)
   output[7:0] AN,    // Display 0-7
   output AUD_PWM,
   output AUD_SD
   );
    
    //65MHz clock generation from IP
    wire reset,user_reset;
    reg clk_reset;
    wire power_on_reset;    // remain high for first 16 clocks
    wire locked;
    wire clock_65mhz;
    
    
    //generate a 65mhz and 25mhz clock
    xga_clkgen gen(.clk_100mhz(CLK100MHZ), .clk_65mhz(clock_65mhz), .reset(clk_reset), .locked(locked));
    
    //reset signal
    SRL16 reset_sr (.D(1'b0), .CLK(clock_65mhz), .Q(power_on_reset),
               .A0(1'b1), .A1(1'b1), .A2(1'b1), .A3(1'b1));
    defparam reset_sr.INIT = 16'hFFFF;
    
    //user reset
    debounce center(.reset(power_on_reset),.clock(clock_65mhz),.noisy(BTNC),.clean(user_reset));
    assign reset = user_reset | power_on_reset;
    
    //inputs--------------------------------------------------------------------------------------------------------
    
    //buttons
    wire up;
    wire down;
    wire left;
    wire right;
        
    //assigning buttons
    debounce dbu(.reset(reset),.clock(clock_65mhz),.noisy(BTNU),.clean(up));
    debounce dbd(.reset(reset),.clock(clock_65mhz),.noisy(BTND),.clean(down));
    debounce dbl(.reset(reset),.clock(clock_65mhz),.noisy(BTNL),.clean(left));
    debounce dbr(.reset(reset),.clock(clock_65mhz),.noisy(BTNR),.clean(right));
    

//  instantiate 7-segment display;  
    wire [31:0] data;
    wire [6:0] segments;
    display_8hex display8hex(.clk(clock_65mhz),.data(data), .seg(segments), .strobe(AN));    
    assign SEG[6:0] = segments;
    assign SEG[7] = 1'b1;
    
//////////////////////////////////////////////////////////////////////////////////
// main module instantiation / data transfer
    
    //parameters for later calculations
    //grid parameters should be changeable
    parameter SCREEN_WIDTH = 1024; //number of pixels
    parameter SCREEN_HEIGHT = 768;
    parameter GRID_WIDTH = 20; //number of cells
    parameter GRID_HEIGHT = 15;
    parameter VGA_WIDTH = 4; // width of each color bus
    
    parameter B_S_WIDTH = $clog2(SCREEN_WIDTH-1);
    parameter B_S_HEIGHT = $clog2(SCREEN_HEIGHT-1);
    parameter B_WIDTH = $clog2(GRID_WIDTH-1);
    parameter B_HEIGHT = $clog2(GRID_HEIGHT-1);
    
    //inputs and outputs
    wire [B_S_WIDTH-1:0] hcount; //vga
    wire [B_S_HEIGHT-1:0] vcount; //vga
    wire hsync, vsync, blank; //vga
    wire [VGA_WIDTH*3-1:0] p_rgb; //rgb of current pixel
    
    //counter (clock test)
    reg [7:0] frame_counter;
    reg [3:0] second_counter;
    assign data[31:28] = second_counter;
    
    
    //inputs to matrix display module
    reg [VGA_WIDTH*3-1:0] cell_rgb;
    reg [VGA_WIDTH-1:0] cell_r;
    reg [VGA_WIDTH-1:0] cell_g;
    reg [VGA_WIDTH-1:0] cell_b;
    reg [B_WIDTH-1:0] xcount;
    reg [B_HEIGHT-1:0] ycount;
    reg cell_en;
    reg display_update;
    reg [VGA_WIDTH*3-1:0] background;
    //(...) outputs
    wire [VGA_WIDTH*3-1:0] p_rgb;
    wire p_hsync;
    wire p_vsync;
    
    //passing data in
    reg passing_data;
    
    always @(posedge clock_65mhz) begin
        //every frame
        if (hcount == 0 && vcount == 0) begin
            background <= 12'hFFF;
            passing_data <= 1;
            display_update <= 1;
            frame_counter <= frame_counter + 1;
            if (frame_counter == 0) begin
                second_counter <= second_counter + 1;
            end
        end
        else if (display_update) begin //pull update low after only one cycle
            display_update <= 0;
        end
        
        //every clock tick
        if (passing_data && cell_en) begin
            cell_en <= 0; //pulse low again
            
            if (xcount == GRID_WIDTH - 1) begin //step through all cells
                xcount <= 0;
                ycount <= ycount + 1;
            end
            else begin
                xcount <= xcount + 1;
            end
            cell_r <= {second_counter[1:0], frame_counter[7:6]} + 1 + xcount + ycount;
            cell_g <= 1 + xcount + ycount * GRID_WIDTH;
            cell_b <= 1 + xcount + ycount;
            cell_rgb <= {cell_r, cell_g, cell_b};
            //1 + xcount + ycount * GRID_WIDTH + {second_counter, frame_counter[7:5]};
        end
        else if (passing_data) begin
            cell_en <= 1; //send pulse high to pass in data stored.
            
            //if on final cell
            if (xcount == GRID_WIDTH-1) begin
                if (ycount == GRID_HEIGHT-1) begin
                    passing_data <= 0; //finished sending in data
                end
            end
        end
    end
    
    //debouncing switches for test input
    wire sw1, sw2, sw3, sw4, sw5, sw6, sw7, sw8, sw9, sw10, sw11, sw12, sw13, sw14, sw15;
    debounce s1(.reset(reset),.clock(clock_65mhz),.noisy(SW[1]),.clean(sw1));
    debounce s2(.reset(reset),.clock(clock_65mhz),.noisy(SW[2]),.clean(sw2));
    debounce s3(.reset(reset),.clock(clock_65mhz),.noisy(SW[3]),.clean(sw3));
    debounce s4(.reset(reset),.clock(clock_65mhz),.noisy(SW[4]),.clean(sw4));
    debounce s5(.reset(reset),.clock(clock_65mhz),.noisy(SW[5]),.clean(sw5));
    debounce s6(.reset(reset),.clock(clock_65mhz),.noisy(SW[6]),.clean(sw6));
    debounce s7(.reset(reset),.clock(clock_65mhz),.noisy(SW[7]),.clean(sw7));
    debounce s8(.reset(reset),.clock(clock_65mhz),.noisy(SW[8]),.clean(sw8));
    debounce s9(.reset(reset),.clock(clock_65mhz),.noisy(SW[9]),.clean(sw9));
    debounce s10(.reset(reset),.clock(clock_65mhz),.noisy(SW[10]),.clean(sw10));
    debounce s11(.reset(reset),.clock(clock_65mhz),.noisy(SW[11]),.clean(sw11));
    debounce s12(.reset(reset),.clock(clock_65mhz),.noisy(SW[12]),.clean(sw12));
    debounce s13(.reset(reset),.clock(clock_65mhz),.noisy(SW[13]),.clean(sw13));
    debounce s14(.reset(reset),.clock(clock_65mhz),.noisy(SW[14]),.clean(sw14));
    debounce s15(.reset(reset),.clock(clock_65mhz),.noisy(SW[15]),.clean(sw15));
    
    //vga signal generation
    xvga vga1(.vclock(clock_65mhz),.hcount(hcount),.vcount(vcount),
          .hsync(hsync),.vsync(vsync),.blank(blank));
    
    //test pixel output
    /*wire[3:0] p_r, p_g, p_b;
    assign p_r = (hcount >= vcount) ? 4'hF : 4'h0;
    assign p_g = (hcount > (SCREEN_WIDTH >> 1)) ? 4'hF : 4'h0;
    assign p_b = (vcount > (SCREEN_HEIGHT >> 1)) ? 4'hF : 4'h0;
    assign p_rgb = {p_r, p_g, p_b};
    */
    
    
    
    matrix_display#(.S_WIDTH(SCREEN_WIDTH), .S_HEIGHT(SCREEN_HEIGHT), .WIDTH(GRID_WIDTH), .HEIGHT(GRID_HEIGHT), 
                    .B_S_WIDTH(B_S_WIDTH), .B_S_HEIGHT(B_S_HEIGHT), 
                    .B_WIDTH(B_WIDTH), .B_HEIGHT(B_HEIGHT), .B_VGA(VGA_WIDTH)) 
           display(.cell_rgb(cell_rgb), .cell_x(xcount), .cell_y(ycount), .cell_en(cell_en), .update(display_update), 
                    .hcount(hcount), .vcount(vcount),
                    .hsync(hsync), .vsync(vsync), .vclock(clock_65mhz), .blank(blank), .background(background), .p_rgb(p_rgb), 
                    .p_hsync(p_hsync), .p_vsync(p_vsync));
    
    //vga output.
    assign VGA_R = p_rgb[11:8];
    assign VGA_G = p_rgb[7:4];
    assign VGA_B = p_rgb[3:0];
    assign VGA_HS = ~p_hsync;
    assign VGA_VS = ~p_vsync;
    

    
endmodule

