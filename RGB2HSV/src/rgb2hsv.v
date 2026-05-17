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
// first divide by 255. latency 18
//=================================  

wire de_after_div;  

///---div R 255 ----------
   wire signed [15:0] r_d_255; 
    
   divider_unsigned_L18 R_div_255 (
      .aclk(clk),                                      // input wire aclk
      .s_axis_divisor_tvalid(1'b1),    // input wire s_axis_divisor_tvalid
      .s_axis_divisor_tdata(8'd255),      // input wire [7 : 0] s_axis_divisor_tdata
      .s_axis_dividend_tvalid(de_in),  // input wire s_axis_dividend_tvalid
      .s_axis_dividend_tdata(R_in),    // input wire [7 : 0] s_axis_dividend_tdata
      .m_axis_dout_tvalid(de_after_div),          // output wire m_axis_dout_tvalid
      .m_axis_dout_tdata(r_d_255)            // output wire [15 : 0] m_axis_dout_tdata
    );


    wire signed [9:0] r_01; 
    assign r_01[9] =1'b0;
    assign r_01[8] = r_d_255[8]; // czesc calkowita wyniku
    assign r_01[7:0] = r_d_255[7:0]; // czesc ulamkowa wyniku
    
///---div G 255 ----------
   wire [15:0] g_d_255; 
    
   divider_unsigned_L18 G_div_255 (
      .aclk(clk),                                      // input wire aclk
      .s_axis_divisor_tvalid(1'b1),    // input wire s_axis_divisor_tvalid
      .s_axis_divisor_tdata(8'd255),      // input wire [7 : 0] s_axis_divisor_tdata
      .s_axis_dividend_tvalid(de_in),  // input wire s_axis_dividend_tvalid
      .s_axis_dividend_tdata(G_in),    // input wire [7 : 0] s_axis_dividend_tdata
      .m_axis_dout_tvalid(de_after_div),          // output wire m_axis_dout_tvalid
      .m_axis_dout_tdata(g_d_255)            // output wire [15 : 0] m_axis_dout_tdata
    );

    wire signed [9:0] g_01; 
    assign g_01[9] =1'b0;
    assign g_01[8] = g_d_255[8]; // czesc calkowita wyniku
    assign g_01[7:0] = g_d_255[7:0]; // czesc ulamkowa wyniku

///---div B 255 ----------
   wire [15:0] b_d_255; 
    
   divider_unsigned_L18 b_div_255 (
      .aclk(clk),                                      // input wire aclk
      .s_axis_divisor_tvalid(1'b1),    // input wire s_axis_divisor_tvalid
      .s_axis_divisor_tdata(8'd255),      // input wire [7 : 0] s_axis_divisor_tdata
      .s_axis_dividend_tvalid(de_in),  // input wire s_axis_dividend_tvalid
      .s_axis_dividend_tdata(B_in),    // input wire [7 : 0] s_axis_dividend_tdata
      .m_axis_dout_tvalid(de_after_div),          // output wire m_axis_dout_tvalid
      .m_axis_dout_tdata(b_d_255)            // output wire [15 : 0] m_axis_dout_tdata
    );

//===========================
// unsigned to signed
//=============================
    wire signed [9:0] b_01; 
    assign b_01[9] =1'b0;
    assign b_01[8] = b_d_255[8]; // czesc calkowita wyniku
    assign b_01[7:0] = b_d_255[7:0]; // czesc ulamkowa wyniku
    
//===================
//calculate min and max and C
//===================  

    wire [9:0] MAX;
    wire [9:0] MIN;
    wire [1:0] MAX_idx;
    wire [1:0] MIN_idx;
    
    wire signed [30:0] rgb_01_d1;
    
    Delay_Line #(.N(30), .DELAY(1)) delay_rgb_01 (
        .clk(clk), 
        .ce(1'b1), 
        .idata({de_after_div, r_01, g_01, b_01}), 
        .odata(rgb_01_d1)
    );
    wire de_after_min_max = rgb_01_d1[30];
    wire signed [9:0] r_01_d1 = rgb_01_d1[29:20];
    wire signed [9:0] g_01_d1 = rgb_01_d1[19:10];
    wire signed [9:0] b_01_d1 = rgb_01_d1[9:0];
    
    //latency #1
    max_rgb #(.N(10))
        max (
            .clk(clk),
            .ce(de_after_div),
            .R(r_01),
            .G(g_01),
            .B(b_01),
            .MAX(MAX),
            .MAX_idx(MAX_idx)
         );
    
    //latency #1
    min_rgb #(.N(10))
        min (
            .clk(clk),
            .ce(de_after_div),
            .R(r_01),
            .G(g_01),
            .B(b_01),
            .MIN(MIN),
            .MIN_idx(MIN_idx)
         );  
            
        wire signed [9:0] C_01; 
        
        //latency 2
        C_substracter_L2 C_sub (
          .A(MAX),      // input wire [9:0] A
          .B(MIN),      // input wire [9 : 0] B
          .CLK(clk),  // input wire CLK
          .CE(de_after_min_max),    // input wire CE
          .S(C_01)      // output wire [9 : 0] S
        );
        
        wire de_after_C;
        Delay_Line #(.N(30), .DELAY(1)) delay_after_C (
            .clk(clk), 
            .ce(1'b1), 
            .idata(de_after_min_max), 
            .odata(de_after_C)
        );         
        
//===========================
// Calculate S        
// ==========================        
    wire signed [23:0] S_reg;
    div_S_L22 div_S (
      .aclk(clk),                    // input wire aclk
      .s_axis_divisor_tvalid(de_after_C),    // input wire s_axis_divisor_tvalid
      .s_axis_divisor_tdata(C_01),      // input wire [15 : 0] s_axis_divisor_tdata
      .s_axis_dividend_tvalid(de_after_min_max),  // input wire s_axis_dividend_tvalid
      .s_axis_dividend_tdata(MAX),    // input wire [15 : 0] s_axis_dividend_tdata
      .m_axis_dout_tvalid(de_after_2D),          // output wire m_axis_dout_tvalid
      .m_axis_dout_tdata(S_reg)            // output wire [23 : 0] m_axis_dout_tdata
);

    wire signed [9:0] S_01; 
    assign S_01[9] = S_reg[23];
    assign b_01[8] = S_reg[8]; // czesc calkowita wyniku
    assign b_01[7:0] = S_reg[7:0]; // czesc ulamkowa wyniku
        
// ==================================
// delay synchronization sygnal and final assigment
//=================================
    
    wire [2:0] sync_in  = {de_in, hsync_in, vsync_in};
    wire [2:0] sync_out;
    
    Delay_Line #(.N(3), .DELAY(19)) delay_sync (
        .clk(clk), 
        .ce(1'b1), 
        .idata(sync_in), 
        .odata(sync_out)
    );
    
    assign de_out    = sync_out[2];
    assign hsync_out = sync_out[1];
    assign vsync_out = sync_out[0];   
    
    
    assign pixel_out = 24'd0;
endmodule 