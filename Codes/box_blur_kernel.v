`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: JP
// 
// Create Date: 03/28/2022 05:31:55 PM
// Design Name: 
// Module Name: box_blur_kernel
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


module box_blur_kernel#(parameter imagesize = 512, pixelsize = 8, pixelsize_out = 24, pixeltotal=72, kernellength = 8, kerneldepth = 9)
(
    input clk,                               // clock
    input pixelInput_valid,                  // to indicate a valid pixel at input
    input [pixeltotal -1 : 0] pixelInput,    // input pixel
   
    output reg [pixelsize-1:0] pixelOutput,  // output pixel after processing
    output reg pixelOutput_valid             // signal to indicate that a pixel is available at output after processing
);
integer i = 0;
reg [kernellength-1:0] Box_Blur_Kernel [kerneldepth-1:0];           // to store the kernel matrix 
reg [15:0] multiplied_kernel[8:0];                                  // to store the multiplied pixels
reg [15:0] Sum_Kernel, Sum;                                         // to store the added pixels after mutiplication and division

reg Valid_1;                                                        // valid signal
reg Valid_2;                                                        // valid signal
//reg 

// Initializing the kernel matrix with values 
initial
begin
    for (i=0; i < kerneldepth; i = i+1)
    begin
        Box_Blur_Kernel[i] <= 1 ; 
    end
 
end


// Mutipling the kernel matrix with the incoming pixel
always @(posedge clk)
begin
    for(i = 0; i< kerneldepth; i = i+1)
    begin
        multiplied_kernel[i] <= Box_Blur_Kernel[i]*pixelInput[i*8+:8];
    end
    Valid_1 <= pixelInput_valid;
end
 
 
 // Adding the mutiplied pixel
 always @(*)
 begin
    Sum = 0;
    for(i = 0; i< kerneldepth; i = i+1)
    begin
        Sum = Sum + multiplied_kernel[i];
        
    end 
   
 end 
 
 always @(posedge clk)
 begin
    Sum_Kernel <= Sum; 
    Valid_2 <= Valid_1;
 end
 
 
 // Sending back the processed pixel 
 always @(posedge clk)
 begin
    
    pixelOutput <= Sum_Kernel/9;
    pixelOutput_valid <= Valid_2 ;
 end 
    
    
    
    
    
endmodule
