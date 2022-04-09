`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/08/2022 09:50:31 PM
// Design Name: 
// Module Name: Img_Processing_Top_Module
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


module Img_Processing_Top_Module#(parameter imagesize = 512, pixelsize = 8, pixelsize_for_buffer = 24, pixelsize_from_buffers = 72, kernellength = 8, kerneldepth = 9)
(
    input   clk,
    input   rst,
    input   pixel_valid,                   // to indicate that there is an incoming pixel 
    input   [pixelsize-1:0] pixel_input,   // incoming pixel 
    input   pixel_input_ready ,            // to indicate that pixek is ready to be send to FIFO          
    
    output  pixel_output_ready,            // to indicate that pixek is ready to be send out from FIFO 
    output  pixel_out_valid,               //  to indicate pixel coming out after processing 
    output  [pixelsize-1:0] output_pixel,  // output pixel after processing
    output  pixel_request                  // as a interrupt to control the incoming pixel
    );
    
    wire [pixelsize_from_buffers-1:0] pixel_out_buffer;
    wire [pixelsize-1:0] conv_pixel_out;
    wire valid_pixel_frm_buffer;
    wire valid_pixel_frm_conv;
    
    
    
    // Instantiating the Image Processing Unit
    ImageProcessingUnit ImPU(
     .clk                  (clk),
     .rst                  (!rst),
     .pixel_valid          (pixel_valid),
     .pixel_Input          (pixel_input),
    
     .pixel_read           (valid_pixel_frm_buffer),
     .pixel_Output         (pixel_out_buffer),
     .pixel_request        (pixel_request) 
);



// Instantiating the Kernel
 box_blur_kernel bbk(
    .clk                  (clk),
    .pixelInput_valid     (valid_pixel_frm_buffer),
    .pixelInput           (pixel_out_buffer), 
    
    .pixelOutput          (conv_pixel_out),
    .pixelOutput_valid    (valid_pixel_frm_conv)
);  


  
// Instantiating the FIFO 
FIFO fifo (
  .wr_rst_busy                (),       
  .rd_rst_busy                (),        
  .s_aclk                     (clk),                  
  .s_aresetn                  (rst),            
  .s_axis_tvalid              (valid_pixel_frm_conv),    
  .s_axis_tready              (),                     
  .s_axis_tdata               (conv_pixel_out),      
  .m_axis_tvalid              (pixel_out_valid),    
  .m_axis_tready              (pixel_input_ready),    
  .m_axis_tdata               (output_pixel),      
  .axis_prog_full             (axis_prog_full)  
);

assign pixel_output_ready = !axis_prog_full;
    
endmodule
