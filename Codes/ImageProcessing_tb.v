`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2022 01:25:14 PM
// Design Name: 
// Module Name: ImageProcessing_tb
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


module ImageProcessing_tb(
);

parameter img_headersize = 1080;
parameter img_size = 262144;    //512*512 

reg clk;
 reg reset;
 reg [7:0] imgData;
 integer input_file, output_file,i;
 reg imgDataValid;
 integer sentSize;
 wire intr;
 wire [7:0] outData;
 wire outDataValid;
 integer receivedData=0;

 initial
 begin
    clk = 1'b0;
    forever
    begin
        #5 clk = ~clk;
    end
 end
 
 initial
 begin
    reset = 0;
    sentSize = 0;
    imgDataValid = 0;
    #100;
    reset = 1;
    #100;
    input_file = $fopen("E:/Vivado/image_processing/barbara_gray.bmp","rb");
    output_file = $fopen("E:/Vivado/image_processing/test_img_output.bmp","wb");
    for(i=0;i< img_headersize; i=i+1)
    begin
        $fscanf(input_file,"%c",imgData);
        $fwrite(output_file,"%c",imgData);
    end
    
    for(i=0;i<4*512;i=i+1)
    begin
        @(posedge clk);
        $fscanf(input_file,"%c",imgData);
        imgDataValid <= 1'b1;
    end
    sentSize = 4*512;
    @(posedge clk);
    imgDataValid <= 1'b0;
    while(sentSize < img_size)
    begin
        @(posedge intr);
        for(i=0;i<512;i=i+1)
        begin
            @(posedge clk);
            $fscanf(input_file,"%c",imgData);
            imgDataValid <= 1'b1;    
        end
        @(posedge clk);
        imgDataValid <= 1'b0;
        sentSize = sentSize+512;
    end
    @(posedge clk);
    imgDataValid <= 1'b0;
    @(posedge intr);
    for(i=0;i<512;i=i+1)
    begin
        @(posedge clk);
        imgData <= 0;
        imgDataValid <= 1'b1;    
    end
    @(posedge clk);
    imgDataValid <= 1'b0;
    @(posedge intr);
    for(i=0;i<512;i=i+1)
    begin
        @(posedge clk);
        imgData <= 0;
        imgDataValid <= 1'b1;    
    end
    @(posedge clk);
    imgDataValid <= 1'b0;
    $fclose(input_file);
 end
 
 always @(posedge clk)
 begin
     if(outDataValid)
     begin
         $fwrite(output_file,"%c",outData);
         receivedData = receivedData+1;
     end 
     if(receivedData == img_size)
     begin
        $fclose(output_file);
        $stop;
     end
 end
 Img_Processing_Top_Module DUT(
    .clk                 (clk),
    .rst                 (reset),
    .pixel_valid         (imgDataValid),
    .pixel_input         (imgData),
    .pixel_input_ready   (1'b1),                    
    
    .pixel_output_ready  (),               
    .pixel_out_valid     (outDataValid),           
    .output_pixel        (outData),
    .pixel_request       (intr)           
    );
 
 
 endmodule