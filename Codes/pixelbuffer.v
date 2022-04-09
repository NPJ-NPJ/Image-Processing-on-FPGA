`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/26/2022 05:42:34 PM
// Design Name: 
// Module Name: pixelbuffer
// Project Name: Image Processing on Zynq
// Target Devices: ZedBoard
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

//The processed image is of type greyscale

module pixelbuffer #(parameter imagesize = 512, pixelsize = 8, pixelsize_out = 24)
(  
    input clk,                               // clock
    input rst,                               // reset
    input valid_pixel,                       // to indicate a valid pixel at input 
    input [pixelsize -1 : 0] pixel_in,       // input pixel
    
    input read_pixel,                        // to trigger the reading of the pixel from buffer
    output  [pixelsize_out-1:0] pixel_out    // pixel read from the buffer
   
);
    
reg [pixelsize - 1:0] pixelBuffer [imagesize-1:0];   // size of the buffer
   //Size of the variable that points the position of the pixel is found by log2(imagesize)   (log 2(512) = 9

reg [8:0] pixel_writePtr;       // current position of writing                           
reg [8:0] pixel_readPtr;        // current position of reading 

// Writing to buffer
always @(posedge clk)
begin
    if(rst)
    begin
        pixel_writePtr <= 'd0;
    end
    else if (valid_pixel)
    begin
        pixelBuffer[pixel_writePtr] <= pixel_in;     // stores the incoming pixel to memory
        pixel_writePtr <= pixel_writePtr + 'd1;      // increment the pointer
    end

end


// Reading from buffer

always @(posedge clk)
begin
    if(rst)
    begin
        pixel_readPtr <= 'd0;
    end
    else if (read_pixel)
    begin
       pixel_readPtr <= pixel_readPtr + 'd1;      // increment the pointer
    end

end
 assign pixel_out = {pixelBuffer[pixel_readPtr],pixelBuffer[pixel_readPtr+1],pixelBuffer[pixel_readPtr+2]};    
    
endmodule
