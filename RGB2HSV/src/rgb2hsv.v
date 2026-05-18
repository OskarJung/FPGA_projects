`timescale 1ns / 1ps

module rgb2hsv(
    input clk,
    input [23:0] pixel_in,
    input de_in,
    input hsync_in,
    input vsync_in,
    output [23:0] pixel_out,
    output de_out,
    output hsync_out,
    output vsync_out    
);

    wire [7:0] R_in = pixel_in[23:16];
    wire [7:0] G_in = pixel_in [15:8];
    wire [7:0] B_in = pixel_in [7:0];
    
// ==================================
// 1. first divide by 255. latency 18
//=================================  
wire de_after_div;  
wire signed [15:0] r_d_255, g_d_255, b_d_255; 

///---div R 255 ----------
   divider_unsigned_L18 R_div_255 (
        .aclk(clk), // input wire aclk
        // input wire divisior tvalis and [7:0] tdata
        .s_axis_divisor_tvalid(1'b1), .s_axis_divisor_tdata(8'd255),
        // input wire dividend tvalid and [7:0] tdata
        .s_axis_dividend_tvalid(de_in), .s_axis_dividend_tdata(R_in), 
        // output wire dout tvalid and [15:0] tdata
        .m_axis_dout_tvalid(de_after_div), .m_axis_dout_tdata(r_d_255));
    
///---div G 255 ----------
   divider_unsigned_L18 G_div_255 (
      .aclk(clk),
      .s_axis_divisor_tvalid(1'b1), .s_axis_divisor_tdata(8'd255),      
      .s_axis_dividend_tvalid(de_in), .s_axis_dividend_tdata(G_in),    
      .m_axis_dout_tvalid(de_after_div), .m_axis_dout_tdata(g_d_255)          
    );

///---div B 255 ---------- 
   divider_unsigned_L18 b_div_255 (
      .aclk(clk),                                      
      .s_axis_divisor_tvalid(1'b1), .s_axis_divisor_tdata(8'd255),     
      .s_axis_dividend_tvalid(de_in), .s_axis_dividend_tdata(B_in),    
      .m_axis_dout_tvalid(de_after_div), .m_axis_dout_tdata(b_d_255)          
    );

//============================
//2. unsigned to signed
//=============================
    wire signed [9:0] r_01, g_01, b_01;
    assign r_01[9] =1'b0;
    assign r_01[8] = r_d_255[8]; // integer part 
    assign r_01[7:0] = r_d_255[7:0]; // fractional part

    assign g_01[9] =1'b0;
    assign g_01[8] = g_d_255[8]; 
    assign g_01[7:0] = g_d_255[7:0]; 

    assign b_01[9] =1'b0;
    assign b_01[8] = b_d_255[8];
    assign b_01[7:0] = b_d_255[7:0];
    
//===================
//3. calculate min and max lanency 1
//===================  
    wire [9:0] MAX, MIN;
    wire [1:0] MAX_idx, MIN_idx;
    
    wire signed [30:0] rgb_01_d1;
    
    Delay_Line #(.N(31), .DELAY(1)) 
        delay_rgb_01 (.clk(clk), .ce(1'b1), .idata({de_after_div, r_01, g_01, b_01}), .odata(rgb_01_d1));

    wire de_after_min_max = rgb_01_d1[30];
    wire signed [9:0] r_01_d1 = rgb_01_d1[29:20];
    wire signed [9:0] g_01_d1 = rgb_01_d1[19:10];
    wire signed [9:0] b_01_d1 = rgb_01_d1[9:0];
    
    //latency #1
    max_rgb #(.N(10))
        max (.clk(clk),.ce(1'b1), 
            .R(r_01),.G(g_01),.B(b_01), // input R, G, B in [9:0]
            .MAX(MAX), .MAX_idx(MAX_idx) //output MAX [9:0] and MAX_idx [1:0]
            );
    
    //latency #1
    min_rgb #(.N(10))
        min (.clk(clk),.ce(1'b1),
            .R(r_01),.G(g_01),.B(b_01),
            .MIN(MIN),.MIN_idx(MIN_idx)
            );  

//===========================
// Calculate C = MAX - MIN. latency 2
//===========================

        wire signed [9:0] C_01; 
        //latency 2
        C_substracter_L2 C_sub (
            .CLK(clk), .CE(1'b1),
            .A(MAX), .B(MIN), // in [9 : 0]
            .S(C_01)   // out [9 : 0]
        );
        
        wire de_after_C;
        Delay_Line #(.N(1), .DELAY(2)) 
            delay_after_C (.clk(clk), .ce(1'b1), .idata(de_after_min_max), .odata(de_after_C));         
        
//===========================
// Calculate S        
// ==========================        
    // wire signed [23:0] S_reg;
    // div_S_L22 div_S (.aclk(clk), 
    //     // input wire divisior tvalis and [15:0] tdata
    //     .s_axis_divisor_tvalid(de_after_C), .s_axis_divisor_tdata(C_01), 
    //     // input wire dividend tvalid and [15:0] tdata     
    //     .s_axis_dividend_tvalid(de_after_min_max), .s_axis_dividend_tdata(MAX), 
    //     // output wire dout tvalid and [23:0] tdata   
    //     .m_axis_dout_tvalid(de_after_2D), .m_axis_dout_tdata(S_reg)         
    // );

    // wire signed [9:0] S_01; 
    // assign S_01[9] = S_reg[23];
    // assign b_01[8] = S_reg[8];  // integer part of the result
    // assign b_01[7:0] = S_reg[7:0]; // fractional part of the result
        
// ==================================
// delay synchronization signal and final assignment
//=================================
    
    wire [2:0] sync_in  = {de_in, hsync_in, vsync_in};
    wire [2:0] sync_out;
    
    Delay_Line #(.N(3), .DELAY(21)) 
        delay_sync (.clk(clk), .ce(1'b1), .idata(sync_in), .odata(sync_out));
    
    assign de_out    = sync_out[2];
    assign hsync_out = sync_out[1];
    assign vsync_out = sync_out[0];   
    assign pixel_out = 24'd0;

endmodule 