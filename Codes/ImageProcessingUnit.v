`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/28/2022 09:47:05 PM
// Design Name: 
// Module Name: ImageProcessingUnit
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


module ImageProcessingUnit#(parameter imagesize = 512, pixelsize = 8, pixelsize_for_buffer = 24, pixelsize_from_buffers = 72, kernellength = 8, kerneldepth = 9)
(
    input clk,                                              // clock
    input rst,                                              // reset 
    input pixel_valid,                                      // to indicate a valid pixel at input
    input [pixelsize -1 : 0] pixel_Input,                   // input pixel
    
    output pixel_read,                                      // to trigger reading of pixel 
    output reg [pixelsize_from_buffers-1:0] pixel_Output,   // output pixel
    output reg  pixel_request                               // to request the new set of pixels to buffers
);

reg [8:0] valid_pixelCounter;
reg [8:0] read_PixelCounter;
reg [1:0] pixelBuffer_Wr_indicator;
reg [1:0] pixelBuffer_Rd_indicator;
reg pixelBuffer_valid_0;
reg pixelBuffer_valid_1;
reg pixelBuffer_valid_2;
reg pixelBuffer_valid_3;
reg pixelBuffer_read_0;
reg pixelBuffer_read_1;
reg pixelBuffer_read_2;
reg pixelBuffer_read_3;
wire [pixelsize_for_buffer-1 :0] bufferData0;
wire [pixelsize_for_buffer-1 :0] bufferData1;
wire [pixelsize_for_buffer-1 :0] bufferData2;
wire [pixelsize_for_buffer-1 :0] bufferData3;
reg Read_Pixel;
integer counter =0;
integer state;


assign pixel_read = Read_Pixel;


// Counting the number of pixels received
always @(posedge clk)
begin
    if(rst)
    begin
        valid_pixelCounter <= 0; 
    end else
        begin
            if(pixel_valid == 1)
            begin
               valid_pixelCounter <= valid_pixelCounter +1 ; 
            end
        end
end


// Counting the number of pixels read
always @(posedge clk)
begin
    if(rst)
    begin
        read_PixelCounter <= 0; 
    end else
        begin
            if(Read_Pixel == 1)
            begin
               read_PixelCounter <= read_PixelCounter +1 ; 
            end
        end
end



// Finding the buffer to which the incoming pixel has to be written
always @(posedge clk)
begin
    if(rst)
    begin
         pixelBuffer_Wr_indicator <= 0; 
        
    end else
        begin
            if(valid_pixelCounter == 511 && pixel_valid)
            begin
                pixelBuffer_Wr_indicator <= pixelBuffer_Wr_indicator+1;
            end
        end 
end



// Finding the buffer from which the pixel has to be read
always @(posedge clk)
begin
    if(rst)
    begin
         pixelBuffer_Rd_indicator <= 0;   
    end else
        begin
            if(read_PixelCounter == 511 && Read_Pixel)
            begin
                pixelBuffer_Rd_indicator <= pixelBuffer_Rd_indicator + 1;
            end
        end 
end




// Finding the total number of pixel written to the buffer so that the reading can be started.
always @(posedge clk)
begin
    if(rst)
    begin
        counter <= 0;
    end else 
        begin
            if(pixel_valid & !Read_Pixel)
            begin
                counter <= counter+1;    
            end else if (!pixel_valid & Read_Pixel)
                     begin
                        counter <= counter - 1;
                     end
        end
end



// Triggering the correct buffers to read, based on the findings 
always @(posedge clk)
begin
    if(rst)
    begin
        pixelBuffer_read_0 <= 'b0;  
        pixelBuffer_read_1 <= 'b0;
        pixelBuffer_read_2 <= 'b0;
        pixelBuffer_read_3 <= 'b0;     
    end else 
    begin
        case(pixelBuffer_Rd_indicator)
        0 : begin
                 pixelBuffer_read_0 <= Read_Pixel;  
                 pixelBuffer_read_1 <= Read_Pixel;
                 pixelBuffer_read_2 <= Read_Pixel;
                 pixelBuffer_read_3 <= 'b0;  
            end
        1 : begin
                pixelBuffer_read_0 <= 'b0;  
                pixelBuffer_read_1 <= Read_Pixel;
                pixelBuffer_read_2 <= Read_Pixel;
                pixelBuffer_read_3 <= Read_Pixel;  
            end 
        2 : begin
                pixelBuffer_read_0 <= Read_Pixel;  
                pixelBuffer_read_1 <= 'b0;
                pixelBuffer_read_2 <= Read_Pixel;
                pixelBuffer_read_3 <= Read_Pixel;     
            end 
        3 : begin
                 pixelBuffer_read_0 <= Read_Pixel;  
                 pixelBuffer_read_1 <= Read_Pixel;
                 pixelBuffer_read_2 <= 'b0;
                 pixelBuffer_read_3 <= Read_Pixel;      
            end          
        endcase
  end  
end



// Triggering the correct buffer to write, based on the findings 
always @(*)
begin
    if(rst)
    begin
        pixelBuffer_valid_0 <= 'b0;  
        pixelBuffer_valid_1 <= 'b0;
        pixelBuffer_valid_2 <= 'b0;
        pixelBuffer_valid_3 <= 'b0;     
    end else 
    begin
        case(pixelBuffer_Wr_indicator)
        0 : begin
                pixelBuffer_valid_0 <= pixel_valid;  
                pixelBuffer_valid_1 <= 'b0;
                pixelBuffer_valid_2 <= 'b0;
                pixelBuffer_valid_3 <= 'b0; 
            end
        1 : begin
                pixelBuffer_valid_0 <= 'b0; 
                pixelBuffer_valid_1 <= pixel_valid;
                pixelBuffer_valid_2 <= 'b0;
                pixelBuffer_valid_3 <= 'b0;    
            end 
        2 : begin
                pixelBuffer_valid_0 <= 'b0; 
                pixelBuffer_valid_1 <= 'b0;
                pixelBuffer_valid_2 <= pixel_valid;
                pixelBuffer_valid_3 <= 'b0;    
            end
        3 : begin
                pixelBuffer_valid_0 <= 'b0; 
                pixelBuffer_valid_1 <= 'b0;
                pixelBuffer_valid_2 <= 'b0;
                pixelBuffer_valid_3 <= pixel_valid;    
            end          
        endcase
  end  
end



// Sending out the pixel 
always @(*)
begin
    case(pixelBuffer_Rd_indicator)
    0 : begin
            pixel_Output <={bufferData2,bufferData1,bufferData0};    
        end
    1 : begin
            pixel_Output <={bufferData3,bufferData2,bufferData1}; 
        end 
    2 : begin
            pixel_Output <={bufferData0,bufferData3,bufferData2};  
        end
    3 : begin
            pixel_Output <={bufferData1,bufferData0,bufferData3};
        end          
        endcase  
end





// State machine to handle the reading of the pixel
always @(posedge clk)
begin
    if(rst)
    begin
        Read_Pixel <= 'b0;  
        state <= 0;
        pixel_request <= 'b0;
    end else 
    begin
        case(state)
        0 : begin
                pixel_request <= 'b0;
                if(counter >= 1536)
                begin
                    Read_Pixel <= 'b1;
                    state <= 1;
                end
            end
        1 : begin
                if(read_PixelCounter == 511)
                begin
                    state <= 0;
                    Read_Pixel <= 'b0;
                    pixel_request <= 'b1;
                end
            end    
        endcase
    end

end



// Instantiating the Buffers
pixelbuffer PB0(  
    . clk(clk),
    . rst(rst),
    . valid_pixel(pixelBuffer_valid_0),
    . pixel_in(pixel_Input),
    
    . read_pixel(pixelBuffer_read_0),
    . pixel_out (bufferData0)
   
);

pixelbuffer PB1(  
    . clk(clk),
    . rst(rst),
    . valid_pixel(pixelBuffer_valid_1),
    . pixel_in(pixel_Input),
    
    . read_pixel(pixelBuffer_read_1),
    . pixel_out (bufferData1)
   
);

pixelbuffer PB2(  
    . clk(clk),
    . rst(rst),
    . valid_pixel(pixelBuffer_valid_2),
    . pixel_in(pixel_Input),
    
    . read_pixel(pixelBuffer_read_2),
    . pixel_out (bufferData2)
   
);

pixelbuffer PB3(  
    . clk(clk),
    . rst(rst),
    . valid_pixel(pixelBuffer_valid_3),
    . pixel_in(pixel_Input),
    
    . read_pixel(pixelBuffer_read_3),
    . pixel_out (bufferData3)
   
);

endmodule
