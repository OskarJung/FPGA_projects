`timescale 1ns / 1ps

module tb_min_max_rgb();
    reg clk = 1'b0;
    reg ce = 1'b0; 
    reg [7:0] R; 
    reg [7:0] G;
    reg [7:0] B;
    
    wire [7:0] MAX;
    wire [7:0] MIN;
    wire [1:0] MAX_idx;
    wire [1:0] MIN_idx;
    
    max_rgb #(.N(8))
        dut_max (
            .clk(clk),
            .ce(ce),
            .R(R),
            .G(G),
            .B(B),
            .MAX(MAX),
            .MAX_idx(MAX_idx)
         );

    min_rgb #(.N(8))
        dut_min (
            .clk(clk),
            .ce(ce),
            .R(R),
            .G(G),
            .B(B),
            .MIN(MIN),
            .MIN_idx(MIN_idx)
         );              
    
    always #1 clk = ~clk;
    
    initial begin
        R = 8'd255; G = 8'd100; B = 8'd190;
      
        @(negedge clk); 
        ce = 1'b1; 
        
        @(negedge clk);
        
        $display("Time: %0t | MAX = %d, MAX_idx = %d, MIN = %d, MIN_idx = %d", 
                       $time, MAX, MAX_idx, MIN, MIN_idx);
                       
        @(negedge clk);
        R = 8'd50; G = 8'd200; B = 8'd10;
        
        @(negedge clk);
        $display("Time: %0t | MAX = %d, MAX_idx = %d, MIN = %d, MIN_idx = %d", 
                       $time, MAX, MAX_idx, MIN, MIN_idx);
                                      
        $finish; 
    end
    
endmodule