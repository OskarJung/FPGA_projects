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
   div_unsigned_L18 R_div_255 (
        .aclk(clk), // input wire aclk
        // input wire divisior tvalis and [7:0] tdata
        .s_axis_divisor_tvalid(1'b1), .s_axis_divisor_tdata(8'd255),
        // input wire dividend tvalid and [7:0] tdata
        .s_axis_dividend_tvalid(de_in), .s_axis_dividend_tdata(R_in), 
        // output wire dout tvalid and [15:0] tdata
        .m_axis_dout_tvalid(de_after_div), .m_axis_dout_tdata(r_d_255));
    
///---div G 255 ----------
   div_unsigned_L18 G_div_255 (
      .aclk(clk),
      .s_axis_divisor_tvalid(1'b1), .s_axis_divisor_tdata(8'd255),      
      .s_axis_dividend_tvalid(de_in), .s_axis_dividend_tdata(G_in),    
      .m_axis_dout_tvalid(de_after_div), .m_axis_dout_tdata(g_d_255)          
    );

///---div B 255 ---------- 
   div_unsigned_L18 b_div_255 (
      .aclk(clk),                                      
      .s_axis_divisor_tvalid(1'b1), .s_axis_divisor_tdata(8'd255),     
      .s_axis_dividend_tvalid(de_in), .s_axis_dividend_tdata(B_in),    
      .m_axis_dout_tvalid(de_after_div), .m_axis_dout_tdata(b_d_255)          
    );

//============================
//2. unsigned to signed
//=============================
    wire signed [9:0] R_sfix, G_sfix, B_sfix;
    assign R_sfix[9] =1'b0;
    assign R_sfix[8] = r_d_255[8]; // integer part 
    assign R_sfix[7:0] = r_d_255[7:0]; // fractional part

    assign G_sfix[9] =1'b0;
    assign G_sfix[8] = g_d_255[8]; 
    assign G_sfix[7:0] = g_d_255[7:0]; 

    assign B_sfix[9] =1'b0;
    assign B_sfix[8] = b_d_255[8];
    assign B_sfix[7:0] = b_d_255[7:0];
    
//===================================
//3. calculate min and max lanency 1
//===================================
    wire signed [9:0] MAX, MIN;
    wire [1:0] MAX_idx, MIN_idx;
    wire de_after_max, de_after_min;

    //latency #1
    max_rgb #(.N(10))
        max (.clk(clk), .de_in(de_after_div), 
            .R(R_sfix),.G(G_sfix),.B(B_sfix), // input R, G, B in [9:0]
            .MAX(MAX), .MAX_idx(MAX_idx), //output MAX [9:0] and MAX_idx [1:0]
            .de_out(de_after_max) // output valid signal for MAX
            );
    
    //latency #1
    min_rgb #(.N(10))
        min (.clk(clk), .de_in(de_after_div),
            .R(R_sfix), .G(G_sfix),.B(B_sfix),
            .MIN(MIN), .MIN_idx(MIN_idx),
            .de_out(de_after_min)
            );  

//===========================
// Calculate C = MAX - MIN. latency 2
//===========================
        wire signed [9:0] C; 
        wire de_after_C;

        //latency 2
        C_substracter_L2 C_sub (
            .CLK(clk),
            .A(MAX), .B(MIN), // in [9 : 0]
            .S(C)   // out [9 : 0]
        );
        
        Delay_Line #(.N(1), .DELAY(2)) 
            delay_after_C (.clk(clk), .ce(1'b1), .idata(de_after_min), .odata(de_after_C));         
        
//===========================
// Calculate S latency 22   
// ========================== 
    // Signal equalization for V division module
    wire signed [9:0] MAX_d2;
    Delay_Line #(.N(10), .DELAY(2)) 
        delay_V_for_S (.clk(clk), .ce(1'b1), .idata(MAX), .odata(MAX_d2));
    
    wire signed [9:0] divisor_V_for_S = (MAX_d2 == 10'd0) ? 10'd1 : MAX_d2; // Avoid division by zero

    wire signed [23:0] S_div;

    div_S_L22 div_S (.aclk(clk), 
        // input wire divisior tvalis and [15:0] tdata
        .s_axis_divisor_tvalid(1'b1), .s_axis_divisor_tdata(divisor_V_for_S), 
        // input wire dividend tvalid and [15:0] tdata     
        .s_axis_dividend_tvalid(de_after_C), .s_axis_dividend_tdata({{5{C[9]}}, C, 1'b0}), 
        // output wire dout tvalid and [23:0] tdata   
        .m_axis_dout_tvalid(de_after_S), .m_axis_dout_tdata(S_div)         
    );

    wire signed [9:0] S; 
    assign S[9] = S_div[23]; 
    assign S[8] = S_div[8];  // integer part 
    assign S[7:0] = S_div[7:0]; // fractional part
        
    wire is_max_zero = (MAX_d2 == 10'd0);
    wire is_max_zero_d22; 

    Delay_Line #(.N(1), .DELAY(22)) 
        delay_max_zero_flag (.clk(clk), .ce(1'b1), .idata(is_max_zero), .odata(is_max_zero_d22));
            
    wire signed [9:0] S_final = (is_max_zero_d22) ? 10'd0 : S;
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